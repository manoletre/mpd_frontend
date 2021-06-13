class MedicationInfo {
  final String name;
  final int dosageInMg;
  final String consumption;
  final String time;
  final int totalDosage;
  final int remainingDosage;
  final bool prescription;

  MedicationInfo(
      {required this.name,
      required this.dosageInMg,
      required this.consumption,
      required this.time,
      required this.totalDosage,
      required this.remainingDosage,
      required this.prescription});

  factory MedicationInfo.fromJson(Map<String, dynamic> json) {
    return MedicationInfo(
      name: json["name"].substring(0, 10),
      dosageInMg: json["postId"]*10,
      consumption: json["body"].substring(0, 10),
      time: json["body"].substring(10, 20),
      totalDosage: json["postId"]*15,
      remainingDosage: json["postId"]*15-json["postId"]*10,
      prescription: true,
    );
    /*
    return MedicationInfo(
        name: json["name"],
        dosageInMg: json["dosageInMg"],
        consumption: json["consumption"],
        time: json["time"],
        totalDosage: json["totalDosage"],
        remainingDosage: json["remainingDosage"],
        prescription: json["prescription"]);
    */
  }
}

class PackageInfo {
  final String name;
  final String description;
  final String prescription;

  PackageInfo(
      {required this.name,
      required this.description,
      required this.prescription});

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
        name: json["name"].toString().substring(0, 10),
        description: json["email"].toString(),
        prescription: json["body"].toString().substring(0, 10));
  }
}
