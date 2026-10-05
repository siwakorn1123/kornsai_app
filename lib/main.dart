import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const KornsaiApp(),
    ),
  );
}

class KornsaiApp extends StatelessWidget {
  const KornsaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'ก่อนสาย - รู้ก่อนของหมดอายุ ไม่ลืมกินยา',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(isLargeText: state.profile.isLargeText),
      home: state.isLoading
          ? const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⏳', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 16),
                    Text(
                      'ก่อนสาย',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : (state.profile.hasCompletedOnboarding
              ? const MainNavigationScreen()
              : const OnboardingScreen()),
    );
  }
}
