enum VisaCity { astana, almaty }
enum VisaApplicantType { firstTime, returner }

extension VisaCityExt on VisaCity {
  String get displayName => this == VisaCity.astana ? "Астана" : "Алматы";
  String get flag        => this == VisaCity.astana ? "🏛️" : "🏔️";
  int    get minQ        => this == VisaCity.astana ? 6 : 3;
  int    get maxQ        => this == VisaCity.astana ? 9 : 5;
}

extension VisaApplicantTypeExt on VisaApplicantType {
  String get emoji => this == VisaApplicantType.firstTime ? "🌱" : "⭐";
}