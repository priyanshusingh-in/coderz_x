import 'dart:async';
import 'package:coderz_x/core/theme/app_theme.dart';
import 'package:coderz_x/features/jobs/domain/enums/job_type.dart';
import 'package:coderz_x/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/job_entity.dart';
import '../bloc/job_bloc.dart';

class JobListingPage extends StatefulWidget {
  const JobListingPage({super.key});

  @override
  State<JobListingPage> createState() => _JobListingPageState();
}

class _JobListingPageState extends State<JobListingPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<JobBloc>().add(FetchJobsRequested());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _applySearch();
    });
  }

  void _applySearch() {
    final String searchQuery = _searchController.text.trim();

    if (searchQuery.isEmpty) {
      context.read<JobBloc>().add(FetchJobsRequested());
    } else {
      context.read<JobBloc>().add(
            SearchJobsRequested(
              query: searchQuery,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.transparent : Colors.white.withOpacity(0.8),
        elevation: isDarkMode ? 0 : 1,
        title: Text(
          'Job Listings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_outline,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: isDarkMode
            ? AppColors.darkDotGridBackground
            : AppColors.lightDotGridBackground,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 16),
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<JobBloc, JobState>(
                builder: (context, state) {
                  if (state is JobLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is JobError) {
                    return Center(child: Text(state.error.toString()));
                  } else if (state is JobLoaded) {
                    if (state.jobs.isEmpty) {
                      return const Center(
                        child: Text('No jobs found'),
                      );
                    }
                    return _buildJobList(state.jobs);
                  }
                  return const Center(child: Text('Start searching for jobs'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: Theme.of(context).textTheme.bodyLarge,
        onChanged: (value) {
          // Debounce search to avoid too many requests
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == _searchController.text) {
              context.read<JobBloc>().add(SearchJobsRequested(query: value));
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Search jobs...',
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade500,
              ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _applySearch();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildJobList(List<JobEntity> jobs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: JobListingCard(
            job: job,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/job-details',
                arguments: job,
              );
            },
          ),
        );
      },
    );
  }
}





class JobListingCard extends StatelessWidget {
  final JobEntity job;
  final VoidCallback? onTap;

  const JobListingCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: isDarkMode ? AppColors.darkGlassCard : null,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                job.company,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    job.type == JobType.remote
                        ? Icons.public
                        : Icons.location_on_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(job.postedDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.type.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
