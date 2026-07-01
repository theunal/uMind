import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/i18n/app_localizations.dart';
import 'data/repositories/question_repository.dart';
import 'data/repositories/progress_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final progressRepo = ProgressRepository();
  await progressRepo.init();

  runApp(MyApp(progressRepo: progressRepo));
}

class MyApp extends StatelessWidget {
  final ProgressRepository progressRepo;

  const MyApp({super.key, required this.progressRepo});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<QuestionRepository>(
          create: (_) => QuestionRepository(),
        ),
        Provider<ProgressRepository>.value(
          value: progressRepo,
        ),
      ],
      child: MaterialApp.router(
        title: 'uMind',
        theme: AppTheme.dark,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
      ),
    );
  }
}
