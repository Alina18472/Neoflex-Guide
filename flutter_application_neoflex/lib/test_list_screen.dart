import 'package:flutter/material.dart';
import 'package:flutter_application_neoflex/quiz_screen.dart';
import 'package:flutter_application_neoflex/user_state.dart';
import 'package:provider/provider.dart';

class TestsListScreen extends StatelessWidget {
  const TestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();

    final tests = [
      {
        'id': 'neo_history',
        'title': 'История NeoFlex',
        'description': 'Основные вехи развития компании',
        'icon': Icons.history_edu,
        'color': Color.fromARGB(255, 228, 79, 138),
        'questionsCount': 5,
        'reward': 15,
      },
      {
        'id': 'dart_basics',
        'title': 'Основы Dart',
        'description': 'Базовый синтаксис языка Dart',
        'icon': Icons.code,
        'color': Color.fromARGB(255, 147, 46, 201),
        'questionsCount': 6,
        'reward': 10,
      },
      {
        'id': 'flutter_widgets',
        'title': 'Flutter Widgets',
        'description': 'Основные виджеты во Flutter',
        'icon': Icons.widgets,
        'color': Color.fromARGB(255, 183, 55, 147),
        'questionsCount': 5,
        'reward': 10,
      },
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 64, 14, 73),
              Color.fromARGB(255, 183, 55, 106),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Тесты',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => _confirmReset(context),
                      tooltip: 'Сбросить прогресс',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: tests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final test = tests[index];
                      final isPassed = userState.wasRewarded(
                        test['id'] as String,
                      );
                      return _buildTestCard(context, test, isPassed);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context,
    Map<String, dynamic> test,
    bool isPassed,
  ) {
    return GestureDetector(
      onTap: () => _startTest(context, test),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.9),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: test['color']!.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(test['icon'], size: 28, color: test['color']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 183, 55, 106),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    test['description'],
                    style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.8)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                       Icon(
                        Icons.help_outline,
                        size: 16,
                        color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${test['questionsCount']} вопросов',
                        style:  TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.7),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${test['reward']}',
                        style: const TextStyle(color: Colors.deepOrange),
                      ),
                      if (isPassed)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Color.fromARGB(255, 183, 55, 106),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startTest(BuildContext context, Map<String, dynamic> test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => QuizScreen(
              testId: test['id'],
              testTitle: test['title'],
              questions: _getQuestionsForTest(test['id']),
              reward: test['reward'],
            ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Сбросить прогресс?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Все баллы и пройденные тесты будут удалены.'),
                const Text('(для тестирования)'),
              ]
              
            ),
           
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  'Сбросить',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await Provider.of<UserState>(context, listen: false).resetProgress();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Прогресс сброшен')));
    }
  }

  List<Map<String, dynamic>> _getQuestionsForTest(String testId) {
    switch (testId) {
      case 'neo_history':
        return [
          {
            'question': 'В каком году была основана компания Neoflex?',
            'options': ['2005', '2012', '2015', '2018'],
            'correctIndex': 0,
          },
          {
            'question': 'Сколько проектов было выполнено за первый год?',
            'options': ['5', '9', '18', '20'],
            'correctIndex': 2,
          },
          {
            'question':
                'В каком году Neoflex вошел в число 100 лучших партнеров IBM?',
            'options': ['2001', '2006', '2011', '2019'],
            'correctIndex': 1,
          },
          {
            'question':
                'Когда компания Neoflex собрала первые 100 сотрудников?',
            'options': ['2006', '2008', '2009', '2012'],
            'correctIndex': 1,
          },
          {
            'question':
                'В каком году был открыт филиал и центр разработки Neoflex в городе Пензе с целью создания и развития команды экспертов?',
            'options': ['2015', '2018', '2020', '2023'],
            'correctIndex': 2,
          },
        ];
      case 'dart_basics':
        return [
          {
            'question': 'Как объявить переменную в Dart?',
            'options': ['var', 'final', 'const', 'Все варианты верны'],
            'correctIndex': 3,
          },
          {
            'question':
                'Какой тип данных используется для хранения целых чисел в Dart?',
            'options': ['double', 'int', 'String', 'num'],
            'correctIndex': 1,
          },
          {
            'question':
                'Какое ключевое слово используется для создания функции в Dart?',
            'options': ['def', 'func', 'function', 'void'],
            'correctIndex': 3,
          },
          {
            'question':
                'Какой метод используется для вывода текста в консоль в Dart?',
            'options': ['print()', 'console.log()', 'echo()', 'output()'],
            'correctIndex': 0,
          },
          {
            'question':
                'Какое ключевое слово используется для обозначения переменной, которая не может измениться?',
            'options': ['const', 'final', 'static', 'fixed'],
            'correctIndex': 1,
          },
          {
            'question': 'Каковы правила именования переменных в Dart?',
            'options': [
              'Можно начинать с цифры',
              'Только буквы и цифры',
              'Не может содержать пробелы',
              'Все вышеперечисленные',
            ],
            'correctIndex': 2,
          },
        ];
      case 'flutter_widgets':
        return [
          {
            'question':
                'Какой виджет используется для вертикального расположения объектов children?',
            'options': ['Row', 'Column', 'Stack', 'ListView'],
            'correctIndex': 1,
          },
          {
            'question': 'Какой виджет позволяет создавать круглый контейнер?',
            'options': [
              'BoxDecoration',
              'CircleAvatar',
              'RoundedRectangle',
              'ClipOval',
            ],
            'correctIndex': 1,
          },
          {
            'question':
                'Какой виджет используется для создания кнопки в Flutter?',
            'options': [
              'Button',
              'FlatButton',
              'RaisedButton',
              'Все вышеперечисленные',
            ],
            'correctIndex': 3,
          },
          {
            'question': 'Какой виджет выводит текст на экран?',
            'options': ['Text', 'Label', 'Display', 'Content'],
            'correctIndex': 0,
          },
          {
            'question':
                'Какой виджет используется для создания сетки для размещения объектов children?',
            'options': ['GridView', 'ListView', 'Stack', 'Column'],
            'correctIndex': 0,
          },
        ];
      default:
        return [];
    }
  }
}
