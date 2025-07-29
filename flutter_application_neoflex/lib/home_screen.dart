import 'package:flutter/material.dart';
import 'package:flutter_application_neoflex/accelerators_screen.dart';
import 'package:flutter_application_neoflex/account_screen.dart';
import 'package:flutter_application_neoflex/history_screen.dart';
import 'package:flutter_application_neoflex/shop_screen.dart';
import 'package:flutter_application_neoflex/test_list_screen.dart';
import 'package:flutter_application_neoflex/user_state.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userPoints = context.watch<UserState>().points;

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
                Text(
                  'Добро пожаловать!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildUserCard(context, userPoints),
                const SizedBox(height: 20),
                _buildProgressBar(context),
                const SizedBox(height: 24),
                _buildPhotoScroll(),
                const SizedBox(height: 24),
                Text(
                  'Разделы',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSectionsGrid(
                  context,
                ), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, int userPoints) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.star, size: 36, color: Colors.deepOrangeAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ваши баллы',
                  style: TextStyle(color:  const Color.fromARGB(255, 141, 19, 80), fontSize: 14),
                ),
                Text(
                  '$userPoints',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                ),
            child: const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 64, 14, 73),
              radius: 22,
              child: Icon(Icons.account_circle, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      
      children: [
        Text(
          'Ваш прогресс: 25%',
          style: TextStyle(color: const Color.fromARGB(255, 251, 249, 249), fontSize: 14),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.25,
            backgroundColor: const Color.fromARGB(255, 240, 239, 239),
            color: Colors.deepOrangeAccent,
            minHeight: 8,
            
          ),
        ),
        
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '250 опыта',
              style: TextStyle(
                color: Colors.deepOrangeAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '750 до следующего уровня',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoScroll() {
    final photoList = [
      'assets/images/history.png',
      'assets/images/image4.jpg',
      'assets/images/image2.jpg',
      'assets/images/image3.jpg',
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              photoList[index],
              height: 120,
              width: 200,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionsGrid(BuildContext context) {
    final sections = [
      {
        'title': 'История компании',
        'icon': Icons.article, 
        'route': HistoryScreen(),
      },
      {
        'title': 'Акселераторы',
        'icon': Icons.rocket_launch, 
        'route': AcceleratorsScreen(),
      },
      {
        'title': 'Обучение',
        'icon': Icons.school, 
        'route': null, 
      },
      {
        'title': 'Тесты',
        'icon': Icons.quiz,
        'route': TestsListScreen(),
      },
      {
        'title': 'Магазин',
        'icon': Icons.shopping_bag,
        'route': ShopScreen(),
      }, 
      {
        'title': 'Достижения',
        'icon': Icons.emoji_events, 
        'route': null, 
      },
    ];

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children:
          sections.map((section) {
            return _buildSectionCard(
              context,
              title: section['title'] as String,
              icon: section['icon'] as IconData,
              route: section['route'] as Widget?,
            );
          }).toList(),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? route,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => route));
        } else {
      
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Раздел "$title" находится в разработке.'),
              backgroundColor: Colors.deepOrangeAccent,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.deepOrangeAccent.withOpacity(0.85),
              Colors.redAccent.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
