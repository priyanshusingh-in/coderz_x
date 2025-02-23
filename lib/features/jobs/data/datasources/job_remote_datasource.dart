import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/enums/job_type.dart';

class JobRemoteDataSource {
  final FirebaseFirestore _firestore;

  JobRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<JobEntity>> getJobs({
    String? searchQuery,
    JobType? jobType,
    String? location,
    List<String>? requirements = const [],
  }) async {
    Query query = _firestore.collection('jobs');

    // Apply filters
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchTerms = searchQuery.toLowerCase().split(' ')
          .where((term) => term.isNotEmpty)
          .toList();
      
      // Search for each term in the searchable_text array
      for (final term in searchTerms) {
        query = query.where('searchable_text', arrayContains: term);
      }
    }

    if (jobType != null) {
      query = query.where('type',
          isEqualTo: jobType.toString().split('.').last.toLowerCase());
    }

    if (location != null && location.isNotEmpty) {
      final searchLocation = location.trim().toLowerCase();
      query = query.where('location_lower', arrayContains: searchLocation);
    }

    if (requirements != null && requirements.isNotEmpty) {
      query = query.where('requirements', arrayContainsAny: requirements);
    }

    final snapshot = await query.get();

    try {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Ensure all required fields are present and properly formatted
            if (!data.containsKey('type') || !data.containsKey('location') || 
                !data.containsKey('title') || !data.containsKey('company')) {
              print('Warning: Document ${doc.id} is missing required fields: ' + 
                    'type: ${data.containsKey("type")}, ' +
                    'location: ${data.containsKey("location")}, ' +
                    'title: ${data.containsKey("title")}, ' +
                    'company: ${data.containsKey("company")}');
              return null;
            }
            return JobEntity.fromMap(data, doc.id);
          })
          .where((job) => job != null)
          .cast<JobEntity>()
          .toList();
    } catch (e) {
      print('Error parsing job documents: $e');
      rethrow;
    }
  }

  Future<JobEntity> getJobById(String jobId,
      {List<String>? requirements = const []}) async {
    final doc = await _firestore.collection('jobs').doc(jobId).get();

    if (!doc.exists) {
      throw Exception('Job not found');
    }

    return JobEntity.fromMap(doc.data() as Map<String, dynamic>, jobId);
  }

  Future<List<String>> getUniqueLocations() async {
    try {
      final snapshot = await _firestore.collection('jobs').get();
      print('Found ${snapshot.docs.length} jobs in Firebase');

      // Create a set to store unique locations
      final Set<String> uniqueLocations = {'Remote'};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('Processing job document: ${doc.id}');
        print('Job data: $data');

        if (data.containsKey('location') && data['location'] != null) {
          final location = data['location'];
          print('Raw location from Firebase: $location');

          if (location == null) continue;

          String formattedLocation = '';

          if (location is String) {
            if (location.toLowerCase() == 'remote') {
              continue; // Skip remote as it's already added
            }

            // Try to parse the location string
            if (location.contains('city:') || location.contains('state:')) {
              try {
                // Extract city and state using simpler string manipulation
                String? city;
                String? state;

                final parts = location.split(',');
                for (final part in parts) {
                  var trimmed = part.trim();
                  trimmed = trimmed.replaceAll('{', '');
                  trimmed = trimmed.replaceAll('}', '');
                  trimmed = trimmed.replaceAll('"', '');
                  trimmed = trimmed.replaceAll("'", '');

                  if (trimmed.startsWith('city:')) {
                    city = trimmed.substring(5).trim();
                  } else if (trimmed.startsWith('state:')) {
                    state = trimmed.substring(6).trim();
                  }
                }

                if (city != null && city.isNotEmpty) {
                  if (state != null &&
                      state.isNotEmpty &&
                      state.toLowerCase() != 'n/a') {
                    formattedLocation = '$city, $state';
                  } else {
                    formattedLocation = city;
                  }
                }
              } catch (e) {
                print('Error parsing location: $e');
                continue;
              }
            } else {
              // If it's a plain string without city/state format
              formattedLocation = location.trim();
            }

            if (formattedLocation.isNotEmpty) {
              print('Adding location: $formattedLocation');
              uniqueLocations.add(formattedLocation);
            }
          }
        }
      }

      final locationsList = uniqueLocations.toList()
        ..sort((a, b) {
          if (a == 'Remote') return -1;
          if (b == 'Remote') return 1;
          return a.compareTo(b);
        });

      print('Final locations list: $locationsList');
      return locationsList;
    } catch (e) {
      print('Error getting unique locations: $e');
      print('Stack trace: ${StackTrace.current}');
      return ['Remote'];
    }
  }
}
