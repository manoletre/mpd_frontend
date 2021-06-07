class MedicationInfo {
  final String name;
  final String description;
  final String prescription;

  MedicationInfo(
      {required this.name,
      required this.description,
      required this.prescription});

  factory MedicationInfo.fromJson(Map<String, dynamic> json) {
    return MedicationInfo(
        name: json["name"],
        description: json["desc"],
        prescription: json["prescription"].toString());
  }
}