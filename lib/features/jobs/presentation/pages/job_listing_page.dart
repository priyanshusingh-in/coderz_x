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
                letterSpacing: -0.5,
              ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.person_outline,
                color: isDarkMode ? Colors.white : Colors.black87,
                size: 28,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
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
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is JobError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.error.toString(),
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else if (state is JobLoaded) {
                    if (state.jobs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No jobs found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      );
                    }
                    return _buildJobList(state.jobs);
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start searching for jobs',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Hero(
      tag: 'searchBar',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          child: TextField(
            controller: _searchController,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  letterSpacing: 0.2,
                  height: 1.4,
                ),
            onChanged: (value) {
              if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                if (value == _searchController.text) {
                  context.read<JobBloc>().add(SearchJobsRequested(query: value));
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Search for jobs...',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                    letterSpacing: 0.2,
                  ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _applySearch();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      splashRadius: 24,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(List<JobEntity> jobs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 16.0),
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
      elevation: isDarkMode ? 0 : 2,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(isDarkMode ? 0.1 : 0.05),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: isDarkMode ? AppColors.darkGlassCard : null,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.2,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.company,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            letterSpacing: -0.2,
                            height: 1.4,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.type.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    icon: job.type == JobType.remote
                        ? Icons.public_rounded
                        : Icons.location_on_rounded,
                    label: job.location,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoChip(
                    context,
                    icon: Icons.calendar_today_rounded,
                    label: DateFormat('MMM d, yyyy').format(job.postedDate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: -0.3,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
