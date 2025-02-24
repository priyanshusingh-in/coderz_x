import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/service_locator.dart';
import 'core/error/error_handler.dart';
import 'core/error/error_widget.dart';
import 'core/theme/app_theme.dart';
import 'features/jobs/presentation/pages/job_listing_page.dart';
import 'features/jobs/presentation/pages/job_detail_page.dart';
import 'features/jobs/domain/entities/job_entity.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'secrets/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/jobs/presentation/bloc/job_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase only if not already initialized
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      name: 'thecoderz-x',
    );
    
    await Hive.initFlutter();
    await ServiceLocator.setup().then((_) {
      runApp(const CoderzXApp());
    });
  } catch (error) {
    runApp(ErrorApp(error: AppError(
      message: error.toString(),
      type: ErrorType.unknown,
      stackTrace: StackTrace.current,
    )));
  }
}

class ErrorApp extends StatelessWidget {
  final AppError error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GlobalErrorWidget(
          error: error,
          onRetry: () {
            // Attempt to restart the app
            main();
          },
        ),
      ),
    );
  }
}

class CoderzXApp extends StatelessWidget {
  const CoderzXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ServiceLocator.get<AuthBloc>()..add(CheckAuthStatusRequested()),
        ),
        BlocProvider(
          create: (_) => ServiceLocator.get<JobBloc>(),
        ),
        BlocProvider(
          create: (_) => ServiceLocator.get<ProfileBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'CoderzX',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Force dark mode for the futuristic look
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ErrorHandlerBuilder(
            child: Container(
              decoration: AppColors.darkDotGridBackground,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/job-details') {
            final job = settings.arguments as JobEntity;
            return MaterialPageRoute(
              builder: (context) => JobDetailPage(jobId: job.id),
            );
          }
          return null;
        },
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const JobListingPage();
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}

class ErrorHandlerBuilder extends StatelessWidget {
  final Widget child;

  const ErrorHandlerBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ErrorListener(
      child: child,
    );
  }
}

class ErrorListener extends StatefulWidget {
  final Widget child;

  const ErrorListener({super.key, required this.child});

  @override
  _ErrorListenerState createState() => _ErrorListenerState();
}

class _ErrorListenerState extends State<ErrorListener> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _buildErrorSnackBar(),
        ),
      ],
    );
  }

  Widget _buildErrorSnackBar() {
    // TODO: Implement real-time error notification mechanism
    return Container();
  }
}
