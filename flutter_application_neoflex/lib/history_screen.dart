
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'year': '2005',
      'title': 'Основание компании',
      'description':
          'В феврале 2005 года группа менеджеров, имеющих многолетний опыт автоматизации банковской деятельности, создает компанию Neoflex, сфокусированную на оказании профессиональных услуг в сфере IT для финансовых организаций.',
      'color': const Color.fromARGB(255, 103, 157, 252),
      'icon': Icons.business,
    },
    {
      'year': '2008',
      'title': 'Первые достижения',
      'description': 'В Neoflex работает 100 сотрудников.',
      'color': Colors.greenAccent,
      'icon': Icons.people_alt,
    },
    {
      'year': '2012',
      'title': 'Успешное сотрудничество',
      'description':
          'В банке ВТБ24 стартует первый для «Неофлекс» интеграционный проект с использованием платформы Oracle SOA Suite.',
      'color': Colors.amberAccent,
      'icon': Icons.handshake,
    },
    {
      'year': '2016',
      'title': 'ТОП-100',
      'description':
          'В 2016 году с компанией «Неофлекс» работает 73 клиента, более половины из которых входят в ТОП-100 российских банков.',
      'color': Colors.purpleAccent,
      'icon': Icons.emoji_events,
    },
    {
      'year': '2021',
      'title': 'Расширение',
      'description':
          'Команда Neoflex в 2021 году выросла с 785 до 1160 человек. Открыты новые офисы в Краснодаре и Самаре.',
      'color': Colors.redAccent,
      'icon': Icons.location_city,
    },
    {
      'year': '2024',
      'title': 'Результат',
      'description':
          'В 2024 году компания Neoflex продемонстрировала значительный рост по всем направлениям деятельности, укрепив свои позиции на рынке ИТ-решений и продолжив курс на инновации.',
      'color': Colors.tealAccent,
      'icon': Icons.trending_up,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 76, 26, 108),
              Color.fromARGB(255, 229, 124, 145),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'История компании',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              LinearProgressIndicator(
                value: (_currentPage + 1) / _slides.length,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: Colors.white,
                minHeight: 4,
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) => _buildSlide(_slides[index]),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => _buildPageIndicator(index),
                  ),
                ),
              ),

              // if (_currentPage == _slides.length - 1)
              //   Padding(
              //     padding: const EdgeInsets.only(bottom: 24, left: 95),
              //     child: ElevatedButton(
              //       onPressed: () => Navigator.pop(context),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.white.withOpacity(0.9),
              //         foregroundColor: const Color.fromARGB(255, 243, 115, 153),
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 32,
              //           vertical: 14,
              //         ),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(30),
              //         ),
              //       ),
              //       child: const Text(
              //         'Завершить просмотр',
              //         style: TextStyle(fontSize: 16),
              //       ),
              //     ),
              //   ),
              if (_currentPage == _slides.length - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center( // Добавлен виджет Center
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: const Color.fromARGB(255, 243, 115, 153),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Завершить просмотр',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slide['year'],
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: slide['color'],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            slide['description'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
      
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  slide['color'].withOpacity(0.2),
                  slide['color'].withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: slide['color'].withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                slide['icon'],
                size: 40,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color.fromARGB(255, 167, 71, 104) : Colors.white30,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}