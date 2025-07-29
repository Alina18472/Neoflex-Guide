// class AcceleratorApplication {
//   final String id;
//   final String acceleratorId;
//   final DateTime applicationDate;
//   final String status; // 'pending', 'approved', 'rejected'
//   final String? message;

//   AcceleratorApplication({
//     required this.id,
//     required this.acceleratorId,
//     required this.applicationDate,
//     this.status = 'pending',
//     this.message,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'accelerator_id': acceleratorId,
//       'application_date': applicationDate.toIso8601String(),
//       'status': status,
//       'message': message,
//     };
//   }

//   factory AcceleratorApplication.fromMap(Map<String, dynamic> map) {
//     return AcceleratorApplication(
//       id: map['id'],
//       acceleratorId: map['accelerator_id'],
//       applicationDate: DateTime.parse(map['application_date']),
//       status: map['status'],
//       message: map['message'],
//     );
//   }
// }

class AcceleratorApplication {
  final String id;
  final String acceleratorId;
  final DateTime applicationDate;
  final String status; // 'pending', 'approved', 'rejected'
  final String? message;

  AcceleratorApplication({
    required this.id,
    required this.acceleratorId,
    required this.applicationDate,
    this.status = 'pending',
    this.message,
  });

  factory AcceleratorApplication.empty() {
    return AcceleratorApplication(
      id: '',
      acceleratorId: '',
      applicationDate: DateTime.now(),
      status: 'none',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accelerator_id': acceleratorId,
      'application_date': applicationDate.toIso8601String(),
      'status': status,
      'message': message,
    };
  }

  factory AcceleratorApplication.fromMap(Map<String, dynamic> map) {
    return AcceleratorApplication(
      id: map['id'],
      acceleratorId: map['accelerator_id'],
      applicationDate: DateTime.parse(map['application_date']),
      status: map['status'],
      message: map['message'],
    );
  }
}