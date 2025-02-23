import 'package:coderz_x/features/jobs/domain/enums/job_type.dart';
import 'package:equatable/equatable.dart';

class JobEntity extends Equatable {
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

  const JobEntity({
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
        applicationUrl,
      ];

  JobEntity copyWith({
    String? id,
    String? title,
    String? company,
    String? description,
    List<String>? requirements,
    String? location,
    String? employmentType,
    double? salary,
    DateTime? postedDate,
    List<String>? skills,
    JobType? type,
    String? applicationUrl,
  }) {
    return JobEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      salary: salary ?? this.salary,
      postedDate: postedDate ?? this.postedDate,
      skills: skills ?? this.skills,
      type: type ?? this.type,
      applicationUrl: applicationUrl ?? this.applicationUrl,
    );
  }

  factory JobEntity.fromMap(Map<String, dynamic> map, String id) {
    // Add defensive checks for map structure
    if (map.isEmpty) {
      throw ArgumentError('Cannot create JobEntity from empty map');
    }

    String formatLocation(dynamic locationData) {
      if (locationData == null) return 'Location not specified';
      
      final location = locationData.toString();
      
      // Handle remote locations
      if (location.toLowerCase() == 'remote' || 
          (location.contains('type') && location.toLowerCase().contains('remote'))) {
        return 'Remote';
      }
      
      // Parse location if it's in {city: X, state: Y} format
      if (location.startsWith('{') && location.endsWith('}')) {
        try {
          final cityMatch = RegExp(r'city:\s*([^,}]+)').firstMatch(location);
          final stateMatch = RegExp(r'state:\s*([^,}]+)').firstMatch(location);
          final typeMatch = RegExp(r'type:\s*([^,}]+)').firstMatch(location);
          
          // Check if it's a remote position based on type
          if (typeMatch != null) {
            final type = typeMatch.group(1)?.trim().toLowerCase() ?? '';
            if (type == 'remote') {
              return 'Remote';
            }
          }
          
          if (cityMatch != null && stateMatch != null) {
            final city = cityMatch.group(1)?.trim().replaceAll(RegExp(r'[{}]'), '');
            final state = stateMatch.group(1)?.trim().replaceAll(RegExp(r'[{}]'), '');
            
            if (city != null && state != null && state.toLowerCase() != 'n/a') {
              return '$city, $state';
            } else if (city != null) {
              return city;
            }
          }
        } catch (e) {
          print('Error parsing location: $e');
        }
      }
      
      return location;
    }

    // Parse job type
    JobType parseJobType(dynamic typeData) {
      if (typeData == null) return JobType.fullTime;
      
      String typeStr = '';
      if (typeData is Map) {
        typeStr = typeData.values.first?.toString() ?? '';
      } else {
        typeStr = typeData.toString();
      }
      
      final rawType = typeStr.toLowerCase().replaceAll(' ', '');
      
      // Check if location indicates this is a remote position
      final location = map['location']?.toString().toLowerCase() ?? '';
      if (location == 'remote' || location.contains('type: remote')) {
        return JobType.remote;
      }
      
      switch (rawType) {
        case 'fulltime':
          return JobType.fullTime;
        case 'parttime':
          return JobType.partTime;
        case 'contract':
          return JobType.contract;
        case 'remote':
          return JobType.remote;
        case 'internship':
          return JobType.internship;
        default:
          return JobType.fullTime;
      }
    }

    try {
      return JobEntity(
        id: id,
        title: map['title']?.toString() ?? 'Untitled Position',
        company: map['company']?.toString() ?? 'Unknown Company',
        description: map['description']?.toString() ?? '',
        requirements: List<String>.from(map['requirements'] ?? []),
        location: formatLocation(map['location']),
        employmentType: map['employmentType']?.toString() ?? 'Not specified',
        salary: (map['salary'] as num?)?.toDouble() ?? 0.0,
        postedDate: map['postedDate'] is String 
            ? DateTime.parse(map['postedDate']) 
            : DateTime.now(),
        skills: List<String>.from(map['skills'] ?? []),
        type: parseJobType(map['type']),
        applicationUrl: map['applicationUrl']?.toString(),
      );
    } catch (e) {
      throw ArgumentError('Error parsing JobEntity: $e\nData: $map');
    }
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'title': title,
      'company': company,
      'description': description,
      'requirements': requirements,
      'location': location,
      'employmentType': employmentType,
      'salary': salary,
      'postedDate': postedDate.toIso8601String(),
      'skills': skills,
      'type': type.toString().split('.').last.toLowerCase(),
      'applicationUrl': applicationUrl,
      'searchable_fields': [
        'title:${title.toLowerCase()}',
        'company:${company.toLowerCase()}',
        'description:${description.toLowerCase()}'
      ],
      'location_lower': location.toLowerCase(),
    };
    return data;
  }
}
