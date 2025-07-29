// // class Accelerator {
// //   final String id;
// //   final String title;
// //   final String description;
// //   final String duration;
// //   final String reward;
// //   final String imagePath;
// //   final String status; // 'available', 'in_progress', 'completed'

// //   Accelerator({
// //     required this.id,
// //     required this.title,
// //     required this.description,
// //     required this.duration,
// //     required this.reward,
// //     required this.imagePath,
// //     required this.status,
// //   });
// // }

// class Accelerator {
//   final String id;
//   final String title;
//   final String description;
//   final String duration;
//   final String reward;
//   final String imagePath;
//   final DateTime startDate;
//   final String? applicationStatus;
//   final DateTime? applicationDate;

//   Accelerator({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.duration,
//     required this.reward,
//     required this.imagePath,
//     required this.startDate,
//     this.applicationStatus,
//     this.applicationDate,
//   });

//   Accelerator copyWith({
//     String? applicationStatus,
//     DateTime? applicationDate,
//   }) {
//     return Accelerator(
//       id: id,
//       title: title,
//       description: description,
//       duration: duration,
//       reward: reward,
//       imagePath: imagePath,
//       startDate: startDate,
//       applicationStatus: applicationStatus ?? this.applicationStatus,
//       applicationDate: applicationDate ?? this.applicationDate,
//     );
//   }
// }

class Accelerator {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String reward;
  final String imagePath;
  final DateTime startDate;
  final String? applicationStatus;
  final DateTime? applicationDate;

  Accelerator({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.reward,
    required this.imagePath,
    required this.startDate,
    this.applicationStatus,
    this.applicationDate,
  });

  // Конвертация в Map для SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'reward': reward,
      'image_path': imagePath,
      'start_date': startDate.toIso8601String(),
    };
  }

  // Создание объекта из Map
  factory Accelerator.fromMap(Map<String, dynamic> map) {
    return Accelerator(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      duration: map['duration'],
      reward: map['reward'],
      imagePath: map['image_path'],
      startDate: DateTime.parse(map['start_date']),
      applicationStatus: map['application_status'],
      applicationDate: map['application_date'] != null 
          ? DateTime.parse(map['application_date'])
          : null,
    );
  }

  // Копирование объекта с обновлением полей
  Accelerator copyWith({
    String? applicationStatus,
    DateTime? applicationDate,
  }) {
    return Accelerator(
      id: id,
      title: title,
      description: description,
      duration: duration,
      reward: reward,
      imagePath: imagePath,
      startDate: startDate,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      applicationDate: applicationDate ?? this.applicationDate,
    );
  }
}