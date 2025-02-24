import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../jobs/presentation/pages/job_listing_page.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _professionController = TextEditingController();
  final _skillsController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Pre-fill email from authentication
    final authRepository = ServiceLocator.get<AuthRepository>();
    authRepository.getCurrentUser().then((result) {
      if (result.isSuccess) {
        setState(() {
          _emailController.text = result.email ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _skillsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitProfile() async {
    if (!mounted) return;
    if (_formKey.currentState!.validate()) {
      final authRepository = ServiceLocator.get<AuthRepository>();
      final result = await authRepository.getCurrentUser();
      if (!mounted) return;
      if (result.isSuccess) {
        final profile = ProfileEntity(
          userId: result.userId!,
          fullName: _fullNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          profession: _professionController.text,
          skills: _skillsController.text,
          location: _locationController.text,
          dateOfBirth: _selectedDate,
        );

        if (!mounted) return;
        context.read<ProfileBloc>().add(CreateProfileRequested(profile: profile));
      }
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
          'Complete Your Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: isDarkMode
            ? AppColors.darkDotGridBackground
            : AppColors.lightDotGridBackground,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const JobListingPage()),
              );
            }
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, kToolbarHeight + 32.0, 16.0, 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextFormField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      validator: (value) => value!.isEmpty 
                        ? 'Please enter your full name' 
                        : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty 
                        ? 'Please enter your phone number' 
                        : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _professionController,
                      label: 'Profession',
                      validator: (value) => value!.isEmpty 
                        ? 'Please enter your profession' 
                        : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _skillsController,
                      label: 'Skills (comma-separated)',
                      validator: (value) => value!.isEmpty 
                        ? 'Please enter your skills' 
                        : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _locationController,
                      label: 'Location',
                      validator: (value) => value!.isEmpty 
                        ? 'Please enter your location' 
                        : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePickerField(context),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Complete Profile'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _selectedDate == null
            ? 'Select Date of Birth'
            : DateFormat('dd MMM yyyy').format(_selectedDate!),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
