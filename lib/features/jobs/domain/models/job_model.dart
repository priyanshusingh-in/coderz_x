import 'package:equatable/equatable.dart';
import '../enums/job_type.dart';

class JobModel extends Equatable {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final List<String> requirements;
  final JobType type;
  final double? salary;
  final DateTime postedDate;
  final List<String> skills;
  final String? applicationUrl;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.requirements,
    required this.type,
    this.salary,
    required this.postedDate,
    required this.skills,
    this.applicationUrl,
  });

  @override
  List<Object?> get props => [
    id, 
    title, 
    company, 
    location, 
    description, 
    requirements, 
    type, 
    salary, 
    postedDate,
    skills,
    applicationUrl
  ];

  // Convert from JSON
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      type: JobType.values.firstWhere(
        (type) => type.toString() == 'JobType.${json['type'] ?? 'fullTime'}',
        orElse: () => JobType.fullTime,
      ),
      salary: json['salary'] is num ? (json['salary'] as num?)?.toDouble() : null,
      postedDate: json['postedDate'] is String 
        ? DateTime.parse(json['postedDate']) 
        : DateTime.now(),
      skills: List<String>.from(json['skills'] ?? []),
      applicationUrl: json['applicationUrl'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'requirements': requirements,
      'type': type.toString().split('.').last,
      'salary': salary,
      'postedDate': postedDate.toIso8601String(),
      'skills': skills,
      'applicationUrl': applicationUrl,
    };
  }

  // Create a copyWith method for easy modification
  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? description,
    List<String>? requirements,
    JobType? type,
    double? salary,
    DateTime? postedDate,
    List<String>? skills,
    String? applicationUrl,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      type: type ?? this.type,
      salary: salary ?? this.salary,
      postedDate: postedDate ?? this.postedDate,
      skills: skills ?? this.skills,
      applicationUrl: applicationUrl ?? this.applicationUrl,
    );
  }
}

// Extension to convert JobType to readable string
extension JobTypeExtension on JobType {
  String get displayName {
    switch (this) {
      case JobType.fullTime:
        return 'Full Time';
      case JobType.partTime:
        return 'Part Time';
      case JobType.contract:
        return 'Contract';
      case JobType.remote:
        return 'Remote';
      case JobType.internship:
        return 'Internship';
    }
  }
}
