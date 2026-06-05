import 'package:bostra/models/country.dart';

class CountryPickerConstants {
  static final List<Country> availableCountries = <Country>[
    const Country(
      phoneCode: "+977",
      countryCode: "NP",
      prefixImage:
          "https://www.worldometers.info/images/flags/original/np.webp",
    ),
    const Country(
      phoneCode: "+91",
      countryCode: "IN",
      prefixImage:
          "https://www.worldometers.info/images/flags/original/in.webp",
    ),
    const Country(
      phoneCode: "+880",
      countryCode: "BD",
      prefixImage:
          "https://www.worldometers.info/images/flags/original/bd.webp",
    ),
    const Country(
      phoneCode: "+86",
      countryCode: "CN",
      prefixImage:
          "https://www.worldometers.info/images/flags/original/cn.webp",
    ),
  ];
}
