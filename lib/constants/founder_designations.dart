/// Fixed list of founder designations / posts used across the company feature.
///
/// Both the registrant's own role and every invited founder's post are picked
/// from this list — there is no free-text entry.
class FounderDesignations {
  const FounderDesignations._();

  static const List<String> values = <String>[
    'Founder',
    'Co-Founder',
    'CEO',
    'CTO',
    'COO',
    'CFO',
    'CMO',
    'CPO',
    'Head of Product',
    'Head of Engineering',
    'Head of Operations',
    'Head of Marketing',
    'Head of Finance',
    'Board Member',
    'Advisor',
  ];
}
