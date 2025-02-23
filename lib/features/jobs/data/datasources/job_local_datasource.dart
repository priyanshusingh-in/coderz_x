import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/enums/job_type.dart';

class JobLocalDataSource {
  Future<List<JobEntity>> getJobs({
    String? searchQuery,
    JobType? jobType,
    String? location,
    List<String>? requirements = const [],
  }) async {
    // Load and parse the local JSON file
    final String jsonString = await rootBundle.loadString('lib/data/jobs.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final Map<String, dynamic> jobsMap = jsonData['jobs'];

    // Convert jobs map to list and apply filters
    return jobsMap.entries
        .where((entry) {
          final job = entry.value as Map<String, dynamic>;
          job['id'] = entry.key; // Add the job ID

          // Apply search query filter
          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            final title = (job['title'] as String).toLowerCase();
            final company = (job['company'] as String).toLowerCase();
            final description = (job['description'] as String).toLowerCase();

            if (!title.contains(query) &&
                !company.contains(query) &&
                !description.contains(query)) {
              return false;
            }
            return true;
          }

          // Apply job type filter
          if (jobType != null) {
            final jobTypeStr = jobType.toString().split('.').last.toLowerCase();
            if (job['type'].toString().toLowerCase() != jobTypeStr) {
              return false;
            }
          }

          // Apply location filter
          if (location != null && location.isNotEmpty) {
            final jobLocation = job['location'] as Map<String, dynamic>;
            final cityState = '${jobLocation['city']}, ${jobLocation['state']}';
            if (!cityState.toLowerCase().contains(location.toLowerCase())) {
              return false;
            }
          }

          // Apply requirements filter
          if (requirements != null && requirements.isNotEmpty) {
            final jobRequirements = List<String>.from(job['requirements']);
            if (!requirements.any((req) => jobRequirements.any((jobReq) =>
                jobReq.toLowerCase().contains(req.toLowerCase())))) {
              return false;
            }
          }

          return true;
        })
        .map((entry) => JobEntity.fromMap(
            {...entry.value as Map<String, dynamic>, 'id': entry.key},
            entry.key))
        .toList();
  }

  Future<JobEntity> getJobById(String jobId) async {
    final String jsonString = await rootBundle.loadString('lib/data/jobs.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final Map<String, dynamic> jobsMap = jsonData['jobs'];

    if (!jobsMap.containsKey(jobId)) {
      throw Exception('Job not found');
    }

    return JobEntity.fromMap({...jobsMap[jobId], 'id': jobId}, jobId);
  }

  Future<List<String>> getUniqueLocations() async {
    final String jsonString = await rootBundle.loadString('lib/data/jobs.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final Map<String, dynamic> jobsMap = jsonData['jobs'];

    final Set<String> uniqueLocations = {'Remote'};

    for (var job in jobsMap.values) {
      if (job['location'] != null) {
        final location = job['location'] as Map<String, dynamic>;
        final cityState = '${location['city']}, ${location['state']}';
        uniqueLocations.add(cityState);
      }
    }

    return uniqueLocations.toList();
  }
}
