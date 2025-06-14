import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';

// Animal model remains unchanged
class Animal {
  final String id;
  final String ownerId;
  final String name;
  final String status;
  final String? imageUrl;
  final DateTime? createdAt;
  final double? price;
  final String breed;

  Animal({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.status,
    this.imageUrl,
    this.createdAt,
    this.price,
    required this.breed,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      price: json['price']?.toDouble(),
      breed: json['breed'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'status': status,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'price': price,
      'breed': breed,
    };
  }
}

class AnimalNFTMarketplace extends StatefulWidget {
  const AnimalNFTMarketplace({super.key});

  @override
  _AnimalNFTMarketplaceState createState() => _AnimalNFTMarketplaceState();
}

class _AnimalNFTMarketplaceState extends State<AnimalNFTMarketplace>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentUserId = "user_123";
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'name';

  // Sample data
  List<Animal> availableAnimals = [
    Animal(
      id: '1',
      ownerId: 'seller1',
      name: 'Bella',
      status: 'alive',
      breed: 'Holstein Cow',
      price: 2.5,
      imageUrl:
          'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=300',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
    ),
    Animal(
      id: '2',
      ownerId: 'seller2',
      name: 'Max',
      status: 'alive',
      breed: 'Angus Cow',
      price: 3.2,
      imageUrl:
          'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=300',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    Animal(
      id: '3',
      ownerId: 'seller3',
      name: 'Luna',
      status: 'alive',
      breed: 'Nubian Goat',
      price: 1.8,
      imageUrl:
          'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=300',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    Animal(
      id: '4',
      ownerId: 'seller4',
      name: 'Charlie',
      status: 'alive',
      breed: 'Boer Goat',
      price: 2.1,
      imageUrl:
          'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=300',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    Animal(
      id: '5',
      ownerId: 'seller5',
      name: 'Snowball',
      status: 'alive',
      breed: 'New Zealand Rabbit',
      price: 0.8,
      imageUrl:
          'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=300',
      createdAt: DateTime.now().subtract(Duration(hours: 12)),
    ),
    Animal(
      id: '6',
      ownerId: 'seller6',
      name: 'Cocoa',
      status: 'alive',
      breed: 'Dutch Rabbit',
      price: 0.9,
      imageUrl:
          'https://images.unsplash.com/photo-1583582538253-6b5f0c4bb4d0?w=300',
      createdAt: DateTime.now().subtract(Duration(hours: 6)),
    ),
  ];

  List<Animal> userAnimals = [
    Animal(
      id: 'user1',
      ownerId: 'user_123',
      name: 'Daisy',
      status: 'alive',
      breed: 'Jersey Cow',
      price: null,
      imageUrl:
          'https://images.unsplash.com/photo-1500595046743-cd271d694d30?w=300',
      createdAt: DateTime.now().subtract(Duration(days: 10)),
    ),
    Animal(
      id: 'user2',
      ownerId: 'user_123',
      name: 'Rocky',
      status: 'alive',
      breed: 'Alpine Goat',
      price: null,
      imageUrl:
          'https://images.unsplash.com/photo-1562808049-bb63a83fb4c8?w=300',
      createdAt: DateTime.now().subtract(Duration(days: 7)),
    ),
    Animal(
      id: 'user3',
      ownerId: 'user_123',
      name: 'Fluffy',
      status: 'alive',
      breed: 'Angora Rabbit',
      price: null,
      imageUrl:
          'https://images.unsplash.com/photo-1515002246390-7bf7e8f87b54?w=300',
      createdAt: DateTime.now().subtract(Duration(days: 4)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1)); // Simulate network call
    setState(() => _isLoading = false);
  }

  void _buyAnimal(Animal animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pets, color: ColorPalette.primary, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Purchase NFT',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.all(5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          animal.imageUrl ?? '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.fitHeight,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[100],
                            child: Icon(Icons.pets,
                                size: 40, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Animal: ${animal.name}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Breed: ${animal.breed}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600])),
                        SizedBox(height: 4),
                        Text('Price: ${animal.price} ETH',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.primary)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text('Would you like to confirm this purchase?',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          availableAnimals.remove(animal);
                          userAnimals.add(Animal(
                            id: animal.id,
                            ownerId: currentUserId,
                            name: animal.name,
                            status: animal.status,
                            breed: animal.breed,
                            price: null,
                            imageUrl: animal.imageUrl,
                            createdAt: animal.createdAt,
                          ));
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${animal.name} purchased successfully!'),
                            backgroundColor: ColorPalette.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Confirm Purchase',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sellAnimal(Animal animal) {
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sell, color: Colors.orange[700], size: 28),
                    SizedBox(width: 8),
                    Text(
                      'List NFT for Sale',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        animal.imageUrl ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[100],
                          child: Icon(Icons.pets,
                              size: 40, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Animal: ${animal.name}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Breed: ${animal.breed}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price (ETH)',
                    hintText: 'Enter price in ETH',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon:
                        Icon(Icons.monetization_on, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final price = double.tryParse(priceController.text);
                        if (price != null && price > 0) {
                          setState(() {
                            userAnimals.remove(animal);
                            availableAnimals.add(Animal(
                              id: animal.id,
                              ownerId: animal.ownerId,
                              name: animal.name,
                              status: animal.status,
                              breed: animal.breed,
                              price: price,
                              imageUrl: animal.imageUrl,
                              createdAt: animal.createdAt,
                            ));
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${animal.name} listed for sale!'),
                              backgroundColor: Colors.orange[700],
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a valid price'),
                              backgroundColor: Colors.red[600],
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          Text('List for Sale', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimalCard(Animal animal, bool isForSale) {
    return AnimationConfiguration.staggeredGrid(
      position: isForSale
          ? availableAnimals.indexOf(animal)
          : userAnimals.indexOf(animal),
      duration: const Duration(milliseconds: 400),
      columnCount: 2,
      child: ScaleAnimation(
        child: FadeInAnimation(
          child: Card(
            elevation: 6,
            shadowColor: Colors.grey.withOpacity(0.3),
            margin: EdgeInsets.all(10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => isForSale ? _buyAnimal(animal) : _sellAnimal(animal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 1.3, // Prevents image overflow
                      child: animal.imageUrl != null
                          ? Image.network(
                              animal.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: ColorPalette.primary,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.pets,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.pets,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          animal.breed,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: animal.status == 'alive'
                                ? ColorPalette.primary
                                : Colors.red[600],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            animal.status.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isForSale && animal.price != null) ...[
                          SizedBox(height: 8),
                          Text(
                            '${animal.price} ETH',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.primary,
                            ),
                          ),
                        ],
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => isForSale
                                ? _buyAnimal(animal)
                                : _sellAnimal(animal),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isForSale
                                  ? Colors.blue[700]
                                  : Colors.orange[700],
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isForSale ? 'Buy Now' : 'Sell',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Animal> _filterAndSortAnimals(List<Animal> animals) {
    var filtered = animals
        .where((animal) =>
            animal.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            animal.breed.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    filtered.sort((a, b) {
      if (_sortBy == 'name') {
        return a.name.compareTo(b.name);
      } else if (_sortBy == 'price') {
        return (a.price ?? double.infinity)
            .compareTo(b.price ?? double.infinity);
      } else {
        return (a.createdAt ?? DateTime.now())
            .compareTo(b.createdAt ?? DateTime.now());
      }
    });

    return filtered;
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.grey[50],
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search by name or breed...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'name', child: Text('Sort by Name')),
                    DropdownMenuItem(
                        value: 'price', child: Text('Sort by Price')),
                    DropdownMenuItem(
                        value: 'date', child: Text('Sort by Date')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _sortBy = value);
                  },
                ),
              ),
              SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.refresh, color: ColorPalette.primary),
                onPressed: _refreshData,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Animal NFT Marketplace',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ColorPalette.primary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: ColorPalette.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: ColorPalette.primary,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart, size: 20),
                      SizedBox(width: 8),
                      Text('Buy NFTs', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sell, size: 20),
                      SizedBox(width: 8),
                      Text('Sell NFTs', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Buy Tab
              Column(
                children: [
                  _buildSearchAndFilter(),
                  Expanded(
                    child: _filterAndSortAnimals(availableAnimals).isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No NFTs available for purchase',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Check back later for new listings!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : AnimationLimiter(
                            child: GridView.builder(
                              padding: EdgeInsets.all(12),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio:
                                    0.75, // Adjusted to prevent overflow
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _filterAndSortAnimals(availableAnimals)
                                  .length,
                              itemBuilder: (context, index) {
                                return _buildAnimalCard(
                                    _filterAndSortAnimals(
                                        availableAnimals)[index],
                                    true);
                              },
                            ),
                          ),
                  ),
                ],
              ),
              // Sell Tab
              Column(
                children: [
                  _buildSearchAndFilter(),
                  Expanded(
                    child: _filterAndSortAnimals(userAnimals).isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pets_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'You don\'t own any NFTs to sell',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Visit the Buy tab to get some NFTs!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : AnimationLimiter(
                            child: GridView.builder(
                              padding: EdgeInsets.all(12),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio:
                                    0.75, // Adjusted to prevent overflow
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount:
                                  _filterAndSortAnimals(userAnimals).length,
                              itemBuilder: (context, index) {
                                return _buildAnimalCard(
                                    _filterAndSortAnimals(userAnimals)[index],
                                    false);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: CircularProgressIndicator(
                  color: ColorPalette.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
