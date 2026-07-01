import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/geo_pattern.dart';
import '../../core/i18n/app_localizations.dart';
import '../../data/repositories/progress_repository.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with SingleTickerProviderStateMixin {
  int _currentLevel = 1;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowController.repeat(reverse: true);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final repo = context.read<ProgressRepository>();
    final progress = repo.getProgress();
    setState(() => _currentLevel = progress.currentLevel);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: GeoPattern(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.grid_view,
                          color: colors.primarySurface, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loc.levelSelect,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final isUnlocked = level <= _currentLevel;
                      final isCurrent = level == _currentLevel;

                      return _LevelButton(
                        level: level,
                        isUnlocked: isUnlocked,
                        isCurrent: isCurrent,
                        glowAnimation: _glowController,
                        onTap: isUnlocked
                            ? () => context.go('/quiz/$level')
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final bool isCurrent;
  final AnimationController glowAnimation;
  final VoidCallback? onTap;

  const _LevelButton({
    required this.level,
    required this.isUnlocked,
    required this.isCurrent,
    required this.glowAnimation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isCurrent
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    )
                  : null,
              color: isCurrent
                  ? null
                  : isUnlocked
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.03),
              border: isCurrent
                  ? null
                  : Border.all(color: Colors.white.withValues(alpha: 0.05)),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1)
                            .withValues(alpha: 0.4 + glowAnimation.value * 0.4),
                        blurRadius: 8 + glowAnimation.value * 12,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isUnlocked
                  ? Text(
                      '$level',
                      style: TextStyle(
                        color: isCurrent
                            ? Colors.white
                            : const Color(0xFFC7D2FE),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Icon(
                      Icons.lock,
                      color: Color(0xFF475569),
                      size: 16,
                    ),
            ),
          ),
        );
      },
    );
  }
}
