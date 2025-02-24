import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/job_bloc.dart';
import '../bloc/job_detail_bloc.dart';

class JobDetailPage extends StatelessWidget {
  final String jobId;

  const JobDetailPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ServiceLocator.get<JobDetailBloc>()
            ..add(FetchJobDetailRequested(jobId: jobId)),
        ),
        BlocProvider.value(
          value: ServiceLocator.get<JobBloc>(),
        ),
      ],
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            _buildJobDetails(context),
          ],
        ),
        bottomNavigationBar: _buildApplyButton(context),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.transparent 
          : Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.work_outline,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
      ),
      actions: [
        BlocBuilder<JobBloc, JobState>(
          builder: (context, state) {
            return IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                // Removed bookmark job functionality
              },
            );
          },
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildJobDetails(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<JobDetailBloc, JobDetailState>(
        builder: (context, state) {
          if (state is JobDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JobDetailError) {
            return Center(
              child: Text(
                'Error loading job details: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is JobDetailLoaded) {
            final job = state.job;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildJobHeaderInfo(context, job),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Job Description'),
                  Text(
                    job.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Requirements'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: job.requirements.map((req) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                req,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Skills Required'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.skills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).primaryColor.withAlpha(51)
                            : Theme.of(context).primaryColor.withAlpha(25),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildJobHeaderInfo(BuildContext context, JobEntity job) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.company,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${job.salary.toStringAsFixed(0)}/year',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatPostDate(job.postedDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return BlocBuilder<JobDetailBloc, JobDetailState>(
      builder: (context, state) {
        if (state is JobDetailLoaded) {
          final job = state.job;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: job.applicationUrl != null
                  ? () async {
                      try {
                        final Uri url = Uri.parse(job.applicationUrl!);
                        if (await canLaunchUrl(url)) {
                          final launched = await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                            webViewConfiguration: const WebViewConfiguration(
                              enableJavaScript: true,
                              enableDomStorage: true,
                            ),
                          );
                          if (!launched) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to open the application URL. Please try again.'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        } else {
                          if (context.mounted) {
                            // Try fallback to external browser if available
                            final fallbackLaunched = await launchUrl(
                              url,
                              mode: LaunchMode.platformDefault,
                            );
                            if (!fallbackLaunched) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open the application URL. Please copy the link manually.'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error accessing the URL: ${e.toString()}'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _formatPostDate(DateTime postedDate) {
    final now = DateTime.now();
    final difference = now.difference(postedDate);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(postedDate);
    }
  }
}
