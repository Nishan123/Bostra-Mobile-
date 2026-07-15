-- ============================================================================
-- Bostra — Investment Rewards & Investor Perks System
-- ----------------------------------------------------------------------------
-- Run this in the Supabase SQL editor (SQL Editor → New query). Idempotent —
-- safe to run more than once.
--
-- Design overview
--   • campaign_reward_tiers  — reward tiers a founder defines for a campaign.
--                              Independent table, FK → campaign. Never stored
--                              as JSON on the campaign row.
--   • investment_rewards     — an immutable SNAPSHOT of the tiers a specific
--                              investment unlocked, copied at investment time.
--                              Editing a tier later does NOT change past
--                              snapshots (spec requirement).
--
-- Eligibility
--   A tier unlocks for an investment when the investment satisfies EITHER the
--   tier's percentage-of-goal threshold (min_percent) OR its fixed-amount
--   threshold (min_amount). Percentage is the recommended/primary basis.
--
-- Snapshotting
--   An AFTER INSERT trigger on `investments` writes the snapshot automatically,
--   so the client never has to. The logic is also exposed as a callable
--   function for admin re-snapshots / backfills.
-- ============================================================================

-- ── 1. Reward tiers ─────────────────────────────────────────────────────────
create table if not exists public.campaign_reward_tiers (
  id                uuid primary key default gen_random_uuid(),
  campaign_id       uuid not null references public.campaign(id) on delete cascade,
  title             text not null,
  description       text not null default '',
  reward_type       text not null default 'custom',
  custom_type_label text,                       -- used when reward_type = 'custom'
  min_percent       numeric,                     -- % of funding goal (primary)
  min_amount        numeric,                     -- fixed amount (optional)
  delivery_estimate date,
  quantity_limit    integer,                     -- null = unlimited
  image_url         text,
  is_repeatable     boolean not null default false,
  sort_order        integer not null default 0,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  -- At least one threshold must be defined.
  constraint reward_tier_threshold_present
    check (min_percent is not null or min_amount is not null),
  constraint reward_tier_percent_range
    check (min_percent is null or (min_percent >= 0 and min_percent <= 100)),
  constraint reward_tier_amount_positive
    check (min_amount is null or min_amount >= 0)
);

create index if not exists idx_reward_tiers_campaign
  on public.campaign_reward_tiers (campaign_id, sort_order);

-- ── 2. Earned reward snapshots ──────────────────────────────────────────────
create table if not exists public.investment_rewards (
  id                    uuid primary key default gen_random_uuid(),
  investment_id         uuid not null references public.investments(id) on delete cascade,
  tier_id               uuid references public.campaign_reward_tiers(id) on delete set null,
  campaign_id           uuid not null references public.campaign(id) on delete cascade,
  investor_id           uuid not null,
  -- Snapshot of the tier at investment time (immutable copy) ------------------
  title                 text not null,
  description           text not null default '',
  reward_type           text not null,
  custom_type_label     text,
  min_percent           numeric,
  min_amount            numeric,
  delivery_estimate     date,
  image_url             text,
  is_repeatable         boolean not null default false,
  -- Context at investment time -----------------------------------------------
  percent_at_investment numeric not null default 0,
  amount_at_investment  numeric not null default 0,
  -- Fulfillment --------------------------------------------------------------
  status                text not null default 'pending', -- pending | delivered | claimed
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create index if not exists idx_investment_rewards_investment
  on public.investment_rewards (investment_id);
create index if not exists idx_investment_rewards_investor
  on public.investment_rewards (investor_id);
create index if not exists idx_investment_rewards_campaign
  on public.investment_rewards (campaign_id);

-- ── 3. Snapshot logic ───────────────────────────────────────────────────────
-- Idempotent: re-running replaces the snapshot for that investment. Runs as a
-- SECURITY DEFINER so it can write snapshots regardless of the caller's RLS.
create or replace function public.snapshot_investment_rewards(p_investment_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_campaign_id uuid;
  v_investor_id uuid;
  v_amount      numeric;
  v_goal        numeric;
  v_percent     numeric;
begin
  select campaign_id, investor_id, amount
    into v_campaign_id, v_investor_id, v_amount
    from public.investments
    where id = p_investment_id;

  if v_campaign_id is null then
    return; -- investment not found; nothing to do
  end if;

  select target_amount into v_goal
    from public.campaign
    where id = v_campaign_id;

  v_percent := case
    when coalesce(v_goal, 0) > 0 then (v_amount / v_goal) * 100
    else 0
  end;

  -- Rebuild this investment's snapshot from scratch (idempotent).
  delete from public.investment_rewards where investment_id = p_investment_id;

  insert into public.investment_rewards (
    investment_id, tier_id, campaign_id, investor_id,
    title, description, reward_type, custom_type_label,
    min_percent, min_amount, delivery_estimate, image_url, is_repeatable,
    percent_at_investment, amount_at_investment, status
  )
  select
    p_investment_id, t.id, t.campaign_id, v_investor_id,
    t.title, t.description, t.reward_type, t.custom_type_label,
    t.min_percent, t.min_amount, t.delivery_estimate, t.image_url, t.is_repeatable,
    v_percent, v_amount, 'pending'
  from public.campaign_reward_tiers t
  where t.campaign_id = v_campaign_id
    and (
      (t.min_percent is not null and v_percent >= t.min_percent)
      or (t.min_amount is not null and v_amount >= t.min_amount)
    );
end;
$$;

create or replace function public.trg_snapshot_investment_rewards()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.snapshot_investment_rewards(new.id);
  return new;
end;
$$;

drop trigger if exists investments_snapshot_rewards on public.investments;
create trigger investments_snapshot_rewards
  after insert on public.investments
  for each row execute function public.trg_snapshot_investment_rewards();

-- ── 4. updated_at maintenance ───────────────────────────────────────────────
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists reward_tiers_touch on public.campaign_reward_tiers;
create trigger reward_tiers_touch
  before update on public.campaign_reward_tiers
  for each row execute function public.touch_updated_at();

drop trigger if exists investment_rewards_touch on public.investment_rewards;
create trigger investment_rewards_touch
  before update on public.investment_rewards
  for each row execute function public.touch_updated_at();

-- ── 5. Row Level Security ───────────────────────────────────────────────────
alter table public.campaign_reward_tiers enable row level security;
alter table public.investment_rewards   enable row level security;

-- Reward tiers: anyone can read (investors need to compare them); only the
-- campaign's creator can write.
drop policy if exists reward_tiers_select on public.campaign_reward_tiers;
create policy reward_tiers_select
  on public.campaign_reward_tiers for select
  using (true);

drop policy if exists reward_tiers_insert on public.campaign_reward_tiers;
create policy reward_tiers_insert
  on public.campaign_reward_tiers for insert
  with check (
    exists (select 1 from public.campaign c
            where c.id = campaign_id and c.user_id = auth.uid())
  );

drop policy if exists reward_tiers_update on public.campaign_reward_tiers;
create policy reward_tiers_update
  on public.campaign_reward_tiers for update
  using (
    exists (select 1 from public.campaign c
            where c.id = campaign_id and c.user_id = auth.uid())
  )
  with check (
    exists (select 1 from public.campaign c
            where c.id = campaign_id and c.user_id = auth.uid())
  );

drop policy if exists reward_tiers_delete on public.campaign_reward_tiers;
create policy reward_tiers_delete
  on public.campaign_reward_tiers for delete
  using (
    exists (select 1 from public.campaign c
            where c.id = campaign_id and c.user_id = auth.uid())
  );

-- Earned rewards: the investor who earned them, or the campaign founder, can
-- read. Inserts happen via the SECURITY DEFINER trigger (bypasses RLS); the
-- explicit insert policy is a safe fallback. The founder (and the investor,
-- for claiming) may update status.
drop policy if exists investment_rewards_select on public.investment_rewards;
create policy investment_rewards_select
  on public.investment_rewards for select
  using (
    investor_id = auth.uid()
    or exists (select 1 from public.campaign c
               where c.id = campaign_id and c.user_id = auth.uid())
  );

drop policy if exists investment_rewards_insert on public.investment_rewards;
create policy investment_rewards_insert
  on public.investment_rewards for insert
  with check (investor_id = auth.uid());

drop policy if exists investment_rewards_update on public.investment_rewards;
create policy investment_rewards_update
  on public.investment_rewards for update
  using (
    investor_id = auth.uid()
    or exists (select 1 from public.campaign c
               where c.id = campaign_id and c.user_id = auth.uid())
  )
  with check (
    investor_id = auth.uid()
    or exists (select 1 from public.campaign c
               where c.id = campaign_id and c.user_id = auth.uid())
  );

grant execute on function public.snapshot_investment_rewards(uuid) to authenticated;

-- ============================================================================
-- OPTIONAL — Backfill snapshots for investments made before this feature.
-- Safe: a no-op for campaigns that have no reward tiers. Uncomment to run.
-- ----------------------------------------------------------------------------
-- do $$
-- declare r record;
-- begin
--   for r in select id from public.investments loop
--     perform public.snapshot_investment_rewards(r.id);
--   end loop;
-- end $$;
-- ============================================================================
-- Done.
-- ============================================================================
