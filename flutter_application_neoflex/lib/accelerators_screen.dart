import 'package:flutter/material.dart';
import 'package:flutter_application_neoflex/models/accelerator.dart';
import 'package:flutter_application_neoflex/database/database_helper.dart';
import 'package:intl/intl.dart';

class AcceleratorsScreen extends StatefulWidget {
  const AcceleratorsScreen({super.key});

  @override
  State<AcceleratorsScreen> createState() => _AcceleratorsScreenState();
}

class _AcceleratorsScreenState extends State<AcceleratorsScreen> {
  late Future<List<Accelerator>> _acceleratorsFuture;
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _acceleratorsFuture = _fetchAcceleratorsWithStatus();
    });
  }

  Future<List<Accelerator>> _fetchAcceleratorsWithStatus() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      
      final accelerators = await db.query('accelerators');
      final applications = await db.query('applications');

      return accelerators.map((accelMap) {
        final application = applications.firstWhere(
          (app) => app['accelerator_id'] == accelMap['id'],
          orElse: () => {},
        );

        return Accelerator(
          id: accelMap['id'] as String,
          title: accelMap['title'] as String,
          description: accelMap['description'] as String,
          duration: accelMap['duration'] as String,
          reward: accelMap['reward'] as String,
          imagePath: accelMap['image_path'] as String,
          startDate: DateTime.parse(accelMap['start_date'] as String),
          applicationStatus: application['status'] as String?,
          applicationDate:
              application['application_date'] != null
                  ? DateTime.parse(application['application_date'] as String)
                  : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading accelerators: $e');
      throw Exception('Failed to load accelerators');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      'Акселераторы',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                   
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Accelerator>>(
                    future: _acceleratorsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildErrorWidget(snapshot.error.toString());
                      }

                      final accelerators = snapshot.data ?? [];

                      if (accelerators.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _loadData(),
                        color: Colors.white,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: accelerators.length,
                          itemBuilder: (context, index) {
                            return _buildAcceleratorCard(accelerators[index]);
                          },
                        ),
                      );
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

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Ошибка загрузки',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Повторить попытку'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.rocket_launch_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Нет доступных программ',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Новые акселераторы появятся позже',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceleratorCard(Accelerator accelerator) {
  final statusInfo = _getStatusInfo(accelerator);
  final canApply = accelerator.applicationStatus == null;

  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white, 
    elevation: 2,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showAcceleratorDetails(context, accelerator),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrangeAccent.withOpacity(0.85),
                      const Color.fromARGB(255, 219, 56, 56).withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      accelerator.title.substring(0, 2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accelerator.title,
                        style: TextStyle(
                          color: Color.fromARGB(255, 183, 55, 106), 
                          fontSize: 18,
                          
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Старт: ${_dateFormat.format(accelerator.startDate)}',
                        style: TextStyle(
                          color: Color.fromARGB(255, 183, 55, 106), 
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  side: BorderSide.none, 
                  backgroundColor: statusInfo.color.withOpacity(0.1),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusInfo.icon,
                        size: 16,
                        color: statusInfo.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusInfo.text,
                        style: TextStyle(color: statusInfo.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              accelerator.description,
              style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.8)), 
            ),
            const SizedBox(height: 12),
            if (!canApply) ...[
              LinearProgressIndicator(
                value: accelerator.applicationStatus == 'approved' ? 1.0 : 0.5,
                backgroundColor: Colors.grey[300],
                color: statusInfo.color,
                minHeight: 4,
              ),
              const SizedBox(height: 8),
            ],
            
          ],
        ),
      ),
    ),
  );
}

  void _showAcceleratorDetails(BuildContext context, Accelerator accelerator) {
  final statusInfo = _getStatusInfo(accelerator);
  final canApply = accelerator.applicationStatus == null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
             
              Color.fromARGB(255, 64, 14, 73),
              Color.fromARGB(255, 183, 55, 106),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                accelerator.title,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Старт: ${_dateFormat.format(accelerator.startDate)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 16),
              _buildDetailItem(
                Icons.schedule,
                'Длительность',
                accelerator.duration,
                iconColor: Colors.white, 
              ),
              const SizedBox(height: 12),
              _buildDetailItem(
                Icons.star, 
                'Награда', 
                accelerator.reward,
                iconColor: Colors.white, 
              ),
              if (!canApply) ...[
                const SizedBox(height: 12),
                _buildDetailItem(
                  statusInfo.icon,
                  'Статус заявки',
                  statusInfo.text,
                 
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Описание программы:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                accelerator.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8)), 
              ),
              const SizedBox(height: 24),
              if (canApply)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,  
                      foregroundColor:Color.fromARGB(255, 183, 55, 106),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showApplyDialog(context, accelerator);
                    },
                    child: const Text('Подать заявку'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),  
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showApplicationDetails(context, accelerator);
                    },
                    child: const Text('Подробнее о заявке'),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
  
}

 
  Widget _buildDetailItem(
    IconData icon,
    String title,
    String value, {
      Color? iconColor, 
    }
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon, 
            color: iconColor ?? Colors.white, 
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
        
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6), 
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyDialog(BuildContext context, Accelerator accelerator) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            title:  Text(
              'Подтверждение',
              style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.7)),
            ),
            content: Text(
              'Вы уверены, что хотите подать заявку на участие в программе "${accelerator.title}"?',
              style:TextStyle(
                color: Color.fromARGB(255, 183, 55, 106),
              
              ), 
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:  Text(
                  'Отмена',
                  style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.7)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _applyForAccelerator(context, accelerator);
                },
                child:  Text(
                  'Подтвердить',
                  style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.7)),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _applyForAccelerator(
    BuildContext context,
    Accelerator accelerator,
  ) async {
    try {
      await DatabaseHelper().applyForAccelerator(accelerator.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заявка на "${accelerator.title}" подана успешно!'),
          backgroundColor: Colors.deepOrangeAccent,
        ),
      );

      _loadData(); 
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showApplicationDetails(BuildContext context, Accelerator accelerator) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            title: Text(
              'Ваша заявка',
              style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.7)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accelerator.title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 183, 55, 106),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildApplicationStatus(accelerator),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Закрыть',
                  style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.7)),
                ), 
              ),
            ],
          ),
    );
  }

  Widget _buildApplicationStatus(Accelerator accelerator) {
    final statusInfo = _getStatusInfo(accelerator);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(statusInfo.icon, color: statusInfo.color),
            const SizedBox(width: 8),
            Text(
              statusInfo.text,
              style: TextStyle(
                color: statusInfo.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (accelerator.applicationDate != null)
          Text(
            'Дата подачи: ${_dateFormat.format(accelerator.applicationDate!)}',
            style: TextStyle(color: Color.fromARGB(255, 64, 14, 73).withOpacity(0.7)),
          ),
      ],
    );
  }

  _StatusInfo _getStatusInfo(Accelerator accelerator) {
    switch (accelerator.applicationStatus) {
      case 'approved':
        return _StatusInfo(Icons.check_circle, 'Одобрено', Colors.green);
      case 'rejected':
        return _StatusInfo(Icons.cancel, 'Отклонено', Colors.red);
      case 'pending':
        return _StatusInfo(Icons.pending, 'На рассмотрении', Color.fromARGB(255, 183, 55, 106));
      default:
        return _StatusInfo(Icons.lock_open, 'Доступно', Color.fromARGB(255, 183, 55, 106));
    }
  }
}

class _StatusInfo {
  final IconData icon;
  final String text;
  final Color color;

  _StatusInfo(this.icon, this.text, this.color);
}
