import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/i18n/app_localizations.dart';
import '../../data/models/iq_question.dart';
import '../../data/models/user_progress.dart';
import '../../data/repositories/question_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../shared/widgets/shape_widget.dart';

class QuizScreen extends StatefulWidget {
  final int level;

  const QuizScreen({super.key, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _AnswerRecord {
  final IQQuestion question;
  final int selectedIndex;
  final int correctIndex;
  final bool isCorrect;

  _AnswerRecord({
    required this.question,
    required this.selectedIndex,
    required this.correctIndex,
    required this.isCorrect,
  });
}

class _QuizScreenState extends State<QuizScreen> {
  List<IQQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _locked = false;
  int? _selectedOption;
  bool? _isCorrect;
  DateTime? _startTime;
  bool _loading = true;
  bool _showResult = false;
  bool _showReview = false;

  final List<_AnswerRecord> _answers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final repo = context.read<QuestionRepository>();
    final questions = await repo.getQuestionsForLevel(widget.level);
    setState(() {
      _questions = questions;
      _loading = false;
      _startTime = DateTime.now();
    });
  }

  void _onOptionTap(int index) {
    if (_locked) return;
    final question = _questions[_currentIndex];
    final correct = index == question.correctOptionIndex;

    setState(() {
      _locked = true;
      _selectedOption = index;
      _isCorrect = correct;
      if (correct) _score++;

      _answers.add(_AnswerRecord(
        question: question,
        selectedIndex: index,
        correctIndex: question.correctOptionIndex,
        isCorrect: correct,
      ));
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (_currentIndex + 1 >= _questions.length) {
        _finishQuiz();
      } else {
        setState(() {
          _currentIndex++;
          _locked = false;
          _selectedOption = null;
          _isCorrect = null;
        });
      }
    });
  }

  Future<void> _finishQuiz() async {
    final timeSpent = DateTime.now().difference(_startTime!).inMilliseconds;
    final repo = context.read<ProgressRepository>();
    final iqScore = repo.calculateIQScore(
      correctCount: _score,
      totalQuestions: _questions.length,
      timeSpentMs: timeSpent,
      level: widget.level,
    );

    await repo.updateLevelResult(
      widget.level,
      LevelResult(
        correct: _score,
        wrong: _questions.length - _score,
        timeSpentMs: timeSpent,
        iqScore: iqScore,
      ),
    );

    setState(() => _showResult = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final loc = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    if (_showReview) {
      return _buildReviewScreen(colors, loc);
    }

    if (_showResult) {
      return _buildResultScreen(colors, loc);
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildHeader(colors, loc),
              const SizedBox(height: 12),
              _buildProgressBar(colors),
              const SizedBox(height: 20),
              _buildMatrix3x3(question, colors),
              const Spacer(),
              Text(
                loc.chooseAnswer,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildOptions3x2(question, colors),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colors.textPrimary),
            onPressed: () => context.go('/levels'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            '${loc.level} ${widget.level}',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            loc.questionProgress(_currentIndex + 1, _questions.length),
            style: TextStyle(
              color: colors.primaryLight,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AppColors colors) {
    final progress = (_currentIndex + 1) / _questions.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
        minHeight: 8,
      ),
    );
  }

  Widget _buildMatrix3x3(IQQuestion question, AppColors colors) {
    return Center(
      child: SizedBox(
        width: 264,
        height: 264,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final isEmpty = index == 8;
            return Container(
              decoration: BoxDecoration(
                color: isEmpty
                    ? colors.primary.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isEmpty
                      ? colors.primary.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.1),
                  width: isEmpty ? 2 : 1,
                ),
                boxShadow: isEmpty
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isEmpty
                    ? Text(
                        '?',
                        style: TextStyle(
                          color: colors.primaryLight,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: ShapeWidget(
                          spec: question.sequence[index],
                          size: 55,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptions3x2(IQQuestion question, AppColors colors) {
    return SizedBox(
      width: 280,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: question.options.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final isSelected = _selectedOption == index;
          final isCorrectOption = index == question.correctOptionIndex;

          Color? borderColor;
          Color? glowColor;
          if (_locked && isSelected) {
            if (_isCorrect == true) {
              borderColor = colors.success;
              glowColor = colors.success.withValues(alpha: 0.8);
            } else {
              borderColor = colors.error;
              glowColor = colors.error.withValues(alpha: 0.8);
            }
          } else if (_locked && isCorrectOption && _isCorrect == false) {
            borderColor = colors.success;
            glowColor = colors.success.withValues(alpha: 0.4);
          }

          return GestureDetector(
            onTap: () => _onOptionTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor ?? Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: glowColor != null
                    ? [
                        BoxShadow(
                          color: glowColor,
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: ShapeWidget(
                  spec: question.options[index],
                  size: 50,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultScreen(AppColors colors, AppLocalizations loc) {
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.levelComplete,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '$_score/${_questions.length}',
                  style: TextStyle(
                    color: colors.primaryLight,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  loc.pointsEarned,
                  style: TextStyle(
                    color: colors.primarySurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$_score',
                            style: TextStyle(
                              color: colors.success,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            loc.correct,
                            style: TextStyle(
                              color: colors.successLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${_questions.length - _score}',
                            style: TextStyle(
                              color: colors.error,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            loc.wrong,
                            style: TextStyle(
                              color: colors.error.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/levels'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          loc.backToMenu,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showReview = true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                      backgroundColor: colors.primary.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      loc.viewAnswers,
                      style: TextStyle(
                        color: colors.primaryLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                        _score = 0;
                        _locked = false;
                        _selectedOption = null;
                        _isCorrect = null;
                        _showResult = false;
                        _answers.clear();
                        _startTime = DateTime.now();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      loc.retry,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewScreen(AppColors colors, AppLocalizations loc) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => setState(() => _showReview = false),
        ),
        title: Text(
          loc.answerReview,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _answers.length,
        itemBuilder: (context, index) {
          final answer = _answers[index];
          return _buildReviewItem(answer, colors, loc, index);
        },
      ),
    );
  }

  Widget _buildReviewItem(_AnswerRecord answer, AppColors colors, AppLocalizations loc, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: answer.isCorrect
              ? colors.success.withValues(alpha: 0.3)
              : colors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: answer.isCorrect
                      ? colors.success.withValues(alpha: 0.2)
                      : colors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: answer.isCorrect ? colors.success : colors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                answer.isCorrect ? Icons.check_circle : Icons.cancel,
                color: answer.isCorrect ? colors.success : colors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                answer.isCorrect ? loc.correct : loc.wrong,
                style: TextStyle(
                  color: answer.isCorrect ? colors.success : colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              children: [
                _buildMiniMatrix(answer.question, colors),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${loc.yourAnswer}: ',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          ShapeWidget(
                            spec: answer.question.options[answer.selectedIndex],
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${loc.correctAnswer}: ',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          ShapeWidget(
                            spec: answer.question.options[answer.correctIndex],
                            size: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMatrix(IQQuestion question, AppColors colors) {
    return SizedBox(
      width: 72,
      height: 72,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final isEmpty = index == 8;
          return Container(
            decoration: BoxDecoration(
              color: isEmpty
                  ? colors.primary.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: isEmpty
                    ? colors.primary.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Center(
              child: isEmpty
                  ? Text(
                      '?',
                      style: TextStyle(
                        color: colors.primaryLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : ShapeWidget(
                      spec: question.sequence[index],
                      size: 16,
                    ),
            ),
          );
        },
      ),
    );
  }
}
