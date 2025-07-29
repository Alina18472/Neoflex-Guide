import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_neoflex/user_state.dart';
import 'package:flutter_application_neoflex/models/shop_item.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _showQrCode = false;

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),
                Center(
                  child: Container(
                
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.redAccent.withOpacity(0.6),
                          Colors.orangeAccent.withOpacity(0.6),
                        ],
                      ),
                       boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  )
                  ),
                

                const SizedBox(height: 16),
                _buildPointsAndQrToggle(userPoints),

                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      _showQrCode
                           ? _buildQrCodeContainer()
                          
                          : const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),
                Expanded(child: _buildPurchasedItemsList(userState)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsAndQrToggle(int points) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Ваши баллы: $points',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.star, color: Colors.deepOrangeAccent, size: 24),
          ],
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () {
            setState(() {
              _showQrCode = !_showQrCode;
            });
          },
          icon: const Icon(Icons.qr_code, color: Colors.white),
          label: Text(_showQrCode ? 'Скрыть' : 'Показать QR'),
        ),
      ],
    );
  }

 
  Widget _buildQrCodeContainer() {
  final userId = "user_123"; 

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(  
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: QrImageView(
            data: userId,
            version: QrVersions.auto,
            size: 180.0,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white70),
            children: [
              const TextSpan(text: 'Для получения мерча напишите в '),
              TextSpan(
                text: 'Telegram',
                style: TextStyle(
                  color: Colors.blue[300],
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _launchTelegram(context),
              ),
              const TextSpan(
                text: ' и покажите QR код администратору',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

  
  Future<void> _launchTelegram(BuildContext context) async {
  const url = 'https://t.me/neoflex_merch';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Не удалось открыть Telegram',
          style: TextStyle(color: Color.fromARGB(255, 61, 12, 133)),
        ),
        backgroundColor: Colors.white, 

    )
    );
  }
}

  

  Widget _buildPurchasedItemsList(UserState userState) {
    return FutureBuilder<List<ShopItem>>(
      future: userState.getPurchasedItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Expanded(
            child: Center(
              child: Text(
                'Ошибка загрузки товаров',
                style: TextStyle(color: Colors.red[300]),
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Expanded(
            child: Center(
              child: Text(
                'Нет купленных товаров',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        return Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildItemCard(items[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildItemCard(ShopItem item) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color.fromARGB(255, 251, 142, 87),
              Color.fromARGB(255, 228, 65, 65)],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {}, 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _getItemIcon(item),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    Text(
                      item.description,
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _getItemIcon(ShopItem item) {
    const defaultIcon = Icon(Icons.shopping_bag, size: 24, color: Colors.white);

    final iconMap = {
      'стикеры': const Icon(Icons.face, size: 24, color: Colors.white),
      'бутылка': const Icon(Icons.sports_baseball, size: 24, color: Colors.white),
      'блокнот': const Icon(Icons.book, size: 24, color: Colors.white),
      'колонка': const Icon(Icons.music_note , size: 24, color: Colors.white),
       'power': const Icon(Icons.power, size: 24, color: Colors.white),
    };

    final lowerName = item.name.toLowerCase();
    return iconMap.entries
        .firstWhere(
          (entry) => lowerName.contains(entry.key),
          orElse: () => MapEntry('', defaultIcon),
        )
        .value;
  }
}
