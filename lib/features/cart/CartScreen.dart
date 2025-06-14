import 'package:flutter/material.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    // Updated static data with price included
    final pendingItems = [
      {
        'name': 'Dairy Cow',
        'breed': 'Holstein',
        'price': '5 HBAR',
        'imageUrl':
            'https://images.unsplash.com/photo-1583241576297-473a8e0b0cbe',
      },
      {
        'name': 'Beef Cow',
        'breed': 'Angus',
        'price': '2 HBAR',
        'imageUrl':
            'https://images.unsplash.com/photo-1581888227599-779811a7e48f',
      },
      {
        'name': 'Mountain Goat',
        'breed': 'Boer Goat',
        'price': '1 HBAR',
        'imageUrl':
            'https://images.unsplash.com/photo-1594041680374-bd5d6d5d19c2',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.primary,
        title: Text('Pending Transactions'),
        centerTitle: true,
      ),
      body: Container(
        color: ColorPalette.white,
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: pendingItems.length,
          itemBuilder: (context, index) {
            final item = pendingItems[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item['imageUrl']!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: Icon(Icons.pets, size: 36, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            item['breed']!,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            item['price']!,
                            style: TextStyle(
                              color: ColorPalette.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
