-- ============================================================================
-- Bostra — Campaign funding due date enforcement
-- ----------------------------------------------------------------------------
-- Run this in the Supabase SQL editor (SQL Editor → New query). Idempotent.
--
-- Campaigns now carry a funding due date in campaign.end_date (already an
-- existing column). This adds a server-side guard so that once the due date
-- has passed, no new investment can be inserted for that campaign — even if a
-- client tries to bypass the UI. Funding goes through an insert into the
-- `investments` table (the invest_in_campaign RPC), so a BEFORE INSERT trigger
-- there is the single chokepoint.
--
-- The window matches the app: a campaign is fundable through the END of its
-- due-date day, then closes.
-- ============================================================================

create or replace function public.enforce_campaign_due_date()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_end timestamptz;
begin
  select end_date into v_end
    from public.campaign
    where id = new.campaign_id;

  if v_end is not null
     and now() > (date_trunc('day', v_end) + interval '1 day' - interval '1 second')
  then
    raise exception 'Funding closed: this campaign''s due date has passed.'
      using errcode = 'check_violation';
  end if;

  return new;
end;
$$;

drop trigger if exists investments_due_date_check on public.investments;
create trigger investments_due_date_check
  before insert on public.investments
  for each row execute function public.enforce_campaign_due_date();

-- ============================================================================
-- Done. Investments are now rejected after a campaign's due date.
-- ============================================================================
