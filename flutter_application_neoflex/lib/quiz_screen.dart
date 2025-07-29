import 'package:flutter/material.dart';
import 'package:flutter_application_neoflex/user_state.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final List<Map<String, dynamic>> questions;
  final int reward;

  const QuizScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    required this.questions,
    required this.reward,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  bool _showResults = false;
  bool _alreadyRewarded = false;
  bool _testPassed = false;
  @override
Widget build(BuildContext context) {
  if (_showResults) {
    return _buildResultsPage();
  }

  final currentQuestion = widget.questions[_currentQuestionIndex];
  final isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;

  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(255, 225, 48, 48),
          Color.fromARGB(255, 219, 128, 58),
          Colors.orangeAccent,
          Color.fromARGB(255, 248, 184, 99)
          
          
        ],
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        title: Text(
          widget.testTitle,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _confirmExit,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.questions.length,
              backgroundColor: const Color.fromARGB(255, 253, 220, 204),
              color: const Color.fromARGB(255, 255, 169, 89), 
              minHeight: 6,
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildQuestionPage(currentQuestion)),
          ],
        ),
      ),
      bottomNavigationBar: _isAnswered
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, 
                  foregroundColor: Colors.orange[800],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (isLastQuestion) {
                    _handleTestCompletion();
                  } else {
                    _goToNextQuestion();
                  }
                },
                child: Text(
                  isLastQuestion ? 'Завершить тест' : 'Следующий вопрос',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          : null,
    ),
  );
}
  

  Widget _buildQuestionPage(Map<String, dynamic> question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Вопрос ${_currentQuestionIndex + 1}/${widget.questions.length}',
          style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          question['question'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            itemCount: question['options'].length,
            itemBuilder: (context, index) {
              return _buildOptionCard(
                question['options'][index],
                index,
                question['correctIndex'],
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleTestCompletion() {
    final score = (_correctAnswers / widget.questions.length) * 100;
    final userState = Provider.of<UserState>(context, listen: false);
    final passed = score >= 90;
    final wasRewarded = userState.wasRewarded(widget.testId);

    setState(() {
      _testPassed = passed;
      _alreadyRewarded = wasRewarded;
      _showResults = true;
    });

    if (passed && !wasRewarded) {
      userState.addPoints(widget.reward, widget.testId);
    }
  }

  Widget _buildResultsPage() {

  final _gradient = _testPassed 
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 255, 158, 194), 
            Color.fromARGB(255, 67, 8, 118),
          ],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 64, 26, 95), 
            Color.fromARGB(255, 58, 1, 1),
          ],
        );
  return Container(
    decoration:  BoxDecoration(
      
    gradient: _gradient,
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _testPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 80,
                color: _testPassed ? const Color.fromARGB(255, 255, 156, 7) : const Color.fromARGB(255, 255, 86, 1),
              ),
              const SizedBox(height: 24),
              Text(
                _testPassed ? 'Тест пройден!' : 'Тест не пройден',
                style: TextStyle(
                  color: _testPassed ? Colors.white : Color.fromARGB(255, 255, 90, 1),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Правильных ответов: $_correctAnswers из ${widget.questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Результат: ${(_correctAnswers / widget.questions.length * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _testPassed ? Colors.white : Color.fromARGB(255, 255, 94, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (_testPassed && !_alreadyRewarded)
                Column(
                  children: [
                    const Text(
                      'Поздравляем с первым успешным прохождением!',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+${widget.reward} баллов',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Текущий баланс: ${Provider.of<UserState>(context).points} баллов',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              if (_testPassed && _alreadyRewarded)
                const Text(
                  'Вы уже получали баллы за этот тест ранее',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              if (!_testPassed)
                const Text(
                  'Для успешного прохождения нужно набрать 90% правильных ответов',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _testPassed ?Colors.white:const Color.fromARGB(206, 255, 255, 255),
                  foregroundColor:_testPassed ? const Color.fromARGB(255, 168, 65, 146):const Color.fromARGB(255, 58, 9, 47),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Вернуться к списку тестов',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildOptionCard(String option, int index, int correctIndex) {
    bool isSelected = index == _selectedOptionIndex;
    bool isCorrect = index == correctIndex;

    Color borderColor = const Color.fromARGB(255, 250, 250, 250).withOpacity(0.3);
    Color bgColor = const Color.fromARGB(255, 255, 255, 255);
    IconData? icon;

    if (_isAnswered && isSelected) {
      borderColor = isCorrect ? Colors.white : const Color.fromARGB(255, 254, 254, 254);
      bgColor =
          isCorrect
              ? Colors.green
              : Colors.redAccent;
      icon = isCorrect ? Icons.check_circle : Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isAnswered ? null : () => _checkAnswer(index, correctIndex),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                ),
              ),
              if (icon != null) Icon(icon, color: borderColor),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer(int selectedIndex, int correctIndex) {
    setState(() {
      _selectedOptionIndex = selectedIndex;
      _isAnswered = true;

      if (selectedIndex == correctIndex) {
        _correctAnswers++;
      }
    });
  }

  void _goToNextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedOptionIndex = null;
      _isAnswered = false;
    });
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      
      builder:
          (context) => AlertDialog(
             backgroundColor: Colors.white,
            title: Text('Прервать тест?',
            style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.8))),
            content: Text('Ваши текущие результаты не будут сохранены.',
            style: TextStyle(color: Color.fromARGB(255, 141, 19, 80))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Продолжить',
                style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.8))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Выйти',
                style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.8))),
              ),
            ],
          ),
    );

    if (shouldExit ?? false) {
      if (mounted) Navigator.pop(context);
    }
  }
}
