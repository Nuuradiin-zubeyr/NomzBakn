import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        'name': 'Main Card',
        'number': '**** 1234',
        'type': 'Visa',
        'balance': 5000.00,
        'color': Colors.blue,
        'logo': Icons.credit_card,
      },
      {
        'name': 'Business Card',
        'number': '**** 5678',
        'type': 'Mastercard',
        'balance': 12000.50,
        'color': Colors.deepPurple,
        'logo': Icons.credit_card,
      },
      {
        'name': 'Travel Card',
        'number': '**** 9012',
        'type': 'Visa',
        'balance': 320.75,
        'color': Colors.green,
        'logo': Icons.credit_card,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: (card['color'] as Color).withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (card['color'] as Color).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Icon(
                        card['logo'] as IconData,
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    card['number'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card['type'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$${(card['balance'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }
} 