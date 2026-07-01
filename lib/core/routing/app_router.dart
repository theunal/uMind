import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/level_select/level_select_screen.dart';
import '../../features/quiz/quiz_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelSelectScreen(),
    ),
    GoRoute(
      path: '/quiz/:level',
      builder: (context, state) {
        final level = int.parse(state.pathParameters['level']!);
        return QuizScreen(level: level);
      },
    ),
  ],
);

class AppRouter {
  static GoRouter get router => _router;
}
