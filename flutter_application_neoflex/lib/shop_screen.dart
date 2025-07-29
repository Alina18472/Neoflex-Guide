import 'package:flutter/material.dart';
import 'package:flutter_application_neoflex/database/database_helper.dart';
import 'package:flutter_application_neoflex/models/shop_item.dart';
import 'package:flutter_application_neoflex/user_state.dart';
import 'package:provider/provider.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();
    final userPoints = userState.points;

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
          child: FutureBuilder<List<ShopItem>>(
            future: DatabaseHelper().getAllShopItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Ошибка: ${snapshot.error}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final items = snapshot.data ?? [];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Магазин мерча',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ваши баллы:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:  Color.fromARGB(255, 141, 19, 80),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.deepOrangeAccent),
                              const SizedBox(width: 6),
                              Text(
                                userPoints.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrangeAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Доступный мерч:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildShopItem(
                            context,
                            item: item,
                            userPoints: userPoints,
                            onPurchase:
                                () => _purchaseItem(context, item, userState),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShopItem(
    BuildContext context, {
    required ShopItem item,
    required int userPoints,
    required VoidCallback onPurchase,
  }) {
    final canAfford = userPoints >= item.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(item.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            style: const TextStyle(
              color: Color.fromARGB(255, 141, 19, 80),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.deepOrangeAccent),
                  const SizedBox(width: 4),
                  Text(
                    item.price.toString(),
                    style: TextStyle(
                      color: canAfford ? Colors.deepOrangeAccent : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: canAfford ? onPurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canAfford ? Color.fromARGB(255, 141, 19, 80) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  canAfford ? 'Купить' : 'Недостаточно баллов',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseItem(
    BuildContext context,
    ShopItem item,
    UserState userState,
  ) async {
    final shouldBuy = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title:  Text('Подтверждение покупки',
            style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.8))),
            content: Text('Купить "${item.name}" за ${item.price} баллов?',
            style: TextStyle(color: Color.fromARGB(255, 141, 19, 80)),),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:  Text('Купить',
                style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.8))),
              ),
            
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Отмена',
                style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.8))),
              ),
            ],
          ),
    );

    if (shouldBuy == true && context.mounted) {
      try {
        await userState.spendPoints(item.price, item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Вы купили ${item.name}!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
