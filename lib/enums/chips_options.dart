enum ChipsOptions {
  all,
  technology,
  healthcare,
  finance,
  education,
  ecommerce,
  foodBeverage,
  realEstate,
  entertainment,
  agriculture,
  manufacturing,
  others;

  String get text {
    switch (this) {
      case ChipsOptions.all:
        return 'All';
      case ChipsOptions.technology:
        return 'Technology';
      case ChipsOptions.healthcare:
        return 'Healthcare';
      case ChipsOptions.finance:
        return 'Finance';
      case ChipsOptions.education:
        return 'Education';
      case ChipsOptions.ecommerce:
        return 'E-commerce';
      case ChipsOptions.foodBeverage:
        return 'Food & Beverage';
      case ChipsOptions.realEstate:
        return 'Real Estate';
      case ChipsOptions.entertainment:
        return 'Entertainment';
      case ChipsOptions.agriculture:
        return 'Agriculture';
      case ChipsOptions.manufacturing:
        return 'Manufacturing';
      case ChipsOptions.others:
        return 'Others';
    }
  }
}
