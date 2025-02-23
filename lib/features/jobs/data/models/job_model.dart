import 'package:equatable/equatable.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/enums/job_type.dart';

class JobModel extends Equatable {
  final String id;
  final String title;
  final String company;
  final String description;
  final List<String> requirements;
  final String location;
  final String employmentType;
  final double salary;
  final DateTime postedDate;
  final List<String> skills;
  final JobType type;
  final String? applicationUrl;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.requirements,
    required this.location,
    required this.employmentType,
    required this.salary,
    required this.postedDate,
    required this.skills,
    required this.type,
    this.applicationUrl,
  });

  // Convert to Domain Entity
  JobEntity toDomain() {
    return JobEntity(
      id: id,
      title: title,
      company: company,
      description: description,
      requirements: requirements,
      location: location,
      employmentType: employmentType,
      salary: salary,
      postedDate: postedDate,
      skills: skills,
      type: type,
      applicationUrl: applicationUrl,
    );
  }

  // Convert from JSON
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      description: json['description'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      location: json['location'] ?? '',
      employmentType: json['employmentType'] ?? '',
      salary: (json['salary'] ?? 0.0).toDouble(),
      postedDate: json['postedDate'] != null 
        ? DateTime.parse(json['postedDate']) 
        : DateTime.now(),
      skills: List<String>.from(json['skills'] ?? []),
      type: JobType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => JobType.fullTime,
      ),
      applicationUrl: json['applicationUrl'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'description': description,
      'requirements': requirements,
      'location': location,
      'employmentType': employmentType,
      'salary': salary,
      'postedDate': postedDate.toIso8601String(),
      'skills': skills,
      'type': type.toString(),
      'applicationUrl': applicationUrl,
      // Generate search keywords for flexible searching
      'searchKeywords': _generateSearchKeywords(),
      'locationKeywords': _generateLocationKeywords(),
    };
  }

  List<String> _generateSearchKeywords() {
    final keywords = <String>[];
    
    // Add lowercase versions of key searchable fields
    keywords.addAll([
      title.toLowerCase(),
      company.toLowerCase(),
      description.toLowerCase(),
    ]);

    // Add skills and requirements
    keywords.addAll(skills.map((skill) => skill.toLowerCase()));
    keywords.addAll(requirements.map((req) => req.toLowerCase()));

    // Remove duplicates and filter out short words
    return keywords.toSet().where((keyword) => keyword.length > 2).toList();
  }

  List<String> _generateLocationKeywords() {
    final keywords = <String>[];
    
    // Split location into individual words and add variations
    final locationParts = location.toLowerCase().split(RegExp(r'\s+'));
    keywords.addAll(locationParts);

    return keywords.toSet().toList();
  }

  @override
  List<Object?> get props => [
    id,
    title,
    company,
    description,
    requirements,
    location,
    employmentType,
    salary,
    postedDate,
    skills,
    type,
    applicationUrl
  ];
}
