class MedicationInfo {
  final int medicationId;
  final String medicationName;
  final String medicationType;
  final String time;
  final double totalPriceInEur;
  final String boughtTime; //TODO: parse date into DateTime object
  final int dosageInMg;
  final int totalDosage;
  final int daysLeft;
  final bool prescription;
  final String description;
  final String status;
  final int prescriptionId;
  final List<String> tags;

  MedicationInfo({
    required this.medicationId,
    required this.medicationName,
    required this.medicationType,
    required this.time,
    required this.totalPriceInEur,
    required this.boughtTime,
    required this.dosageInMg,
    required this.totalDosage,
    required this.daysLeft,
    required this.prescription,
    required this.description,
    required this.status,
    required this.prescriptionId,
    required this.tags,
  });

  factory MedicationInfo.fromJson(Map<String, dynamic> json) {
    return MedicationInfo(
        medicationId: json["medication_id"],
        medicationName: json["medication_name"],
        medicationType: json["medicationType"],
        time: json["time"],
        totalPriceInEur: json["totalPriceInEur"],
        boughtTime: json["boughtTime"],
        dosageInMg: json["dosageInMg"],
        totalDosage: json["totalDosage"],
        daysLeft: json["daysLeft"],
        prescription: json["prescription"],
        description: json["description"],
        status: json["status"],
        prescriptionId: json["prescription_id"],
        tags: [json["description"]]);
  }

  @override
  bool operator ==(other) {
    return (other is MedicationInfo) && other.medicationName == medicationName;
  }

  @override
  int get hashCode => medicationName.hashCode;

  // if update operators: https://coflutter.com/dart-how-to-compare-2-objects/
}

class Prescription {
  final String prescriptionName;
  final int prescriptionId;
  final String doctorName;
  final String validUntil; //TODO: parse date into DateTime object
  final List<MedicationInfo> medications;

  Prescription(
      {required this.prescriptionName,
      required this.prescriptionId,
      required this.doctorName,
      required this.validUntil,
      required this.medications});

  factory Prescription.fromJson(Map<String, dynamic> json) {
    List<dynamic> medicationsRaw = json["medications"];
    List<MedicationInfo> medications =
        medicationsRaw.map((e) => MedicationInfo.fromJson(e)).toList();


    return Prescription(
      prescriptionName: json["prescription_name"],
      prescriptionId: json["prescription_id"],
      doctorName: json["doctor_name"],
      validUntil: json["valid_until"],
      medications: medications,
    );
  }

  bool medInPrescription(MedicationInfo med) {
    return medications.indexOf(med) >= 0;
  }
}

class ResponsibleDoctor {
  final int drId;
  final String drName;
  final String drEmail;
  final List<MedicationInfo> medInfos;

  ResponsibleDoctor(
      {required this.drId,
      required this.drName,
      required this.drEmail,
      required this.medInfos});

  factory ResponsibleDoctor.fromJson(Map<String, dynamic> json) {
    List<dynamic> medicationsRaw = json["medicine"];
    List<MedicationInfo> medications =
        medicationsRaw.map((e) => MedicationInfo.fromJson(e)).toList();

    return ResponsibleDoctor(
        drId: json["dr_id"],
        drName: json["dr_name"],
        drEmail: json["dr_email"],
        medInfos: medications);
  }
}
