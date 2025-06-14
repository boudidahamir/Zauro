import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:marketplace_app_v0/CustomNavBar.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';
import 'package:marketplace_app_v0/features/home/HomeContent.dart';
import 'package:marketplace_app_v0/features/cart/CartScreen.dart';
import 'package:marketplace_app_v0/features/profile/ProfileScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marketplace_app_v0/models/animal.dart' as models;
import 'package:marketplace_app_v0/features/orders/marketplace.dart' as feature;

List<models.Animal> animalList = [];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;
  late AnimationController _loadingAnimationController;
  List<models.Animal> _animals = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  final SupabaseClient supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();

  int get _totalAnimals => _animals.length;
  int get _aliveAnimals => _animals.where((a) => a.status == 'alive').length;
  int get _sickAnimals => _animals.where((a) => a.status == 'sick').length;
  int get _deadAnimals => _animals.where((a) => a.status == 'dead').length;
  int get _alerts => _sickAnimals + _deadAnimals;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _fetchAnimals();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fabAnimationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreAnimals();
      }
    });
  }

  Future<void> _fetchAnimals({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMoreData = true;
      _animals.clear();
    }

    if (!_hasMoreData || _isLoadingMore) return;

    try {
      setState(() {
        if (refresh || _animals.isEmpty) {
          _isLoading = true;
        }
        _error = null;
      });

      const pageSize = 20;
      final startRange = _currentPage * pageSize;
      final endRange = startRange + pageSize - 1;

      final response = await supabase
          .from('animals')
          .select('id, owner_id, name, status, image_url, created_at')
          .order('created_at', ascending: false)
          .range(startRange, endRange);

      final List<dynamic> data = response as List<dynamic>;
      final newAnimals = await compute(_parseAnimals, data);

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _animals = newAnimals;
        } else {
          _animals.addAll(newAnimals);
        }
        _hasMoreData = newAnimals.length == pageSize;
        _currentPage++;
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching animals: $e');
        print('Stack trace: $stackTrace');
      }

      if (!mounted) return;
      setState(() {
        _error = _getErrorMessage(e);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreAnimals() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);
    await _fetchAnimals();
  }

  String _getErrorMessage(dynamic error) {
    if (error is PostgrestException) {
      return 'Database error: ${error.message}';
    } else if (error is AuthException) {
      return 'Authentication error: Please log in again';
    } else {
      return 'Network error: Please check your connection';
    }
  }

  static List<models.Animal> _parseAnimals(List<dynamic> rows) {
    return rows
        .map((r) {
          try {
            return models.Animal.fromJson(r as Map<String, dynamic>);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing animal: $e, data: $r');
            }
            return null;
          }
        })
        .where((animal) => animal != null)
        .cast<models.Animal>()
        .toList();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _fabAnimationController.reverse();
      } else {
        _fabAnimationController.forward();
      }
    });
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _fetchAnimals(refresh: true);
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(_error ?? 'An unknown error occurred'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refreshData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _loadingAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final pages = [
      HomeContent(
        animals: _animals,
        totalAnimals: _totalAnimals,
        aliveAnimals: _aliveAnimals,
        sickAnimals: _sickAnimals,
        deadAnimals: _deadAnimals,
        alerts: _alerts,
        onRefresh: _refreshData,
        scrollController: _scrollController,
        isLoadingMore: _isLoadingMore,
        hasMoreData: _hasMoreData,
      ),
      feature.AnimalNFTMarketplace(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: ColorPalette.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _isLoading && _animals.isEmpty
            ? _buildLoadingState()
            : _error != null && _animals.isEmpty
                ? _buildErrorState()
                : IndexedStack(
                    index: _selectedIndex,
                    children: pages,
                  ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _loadingAnimationController,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ColorPalette.primary,
                    ColorPalette.primary.withOpacity(0.3),
                  ],
                ),
              ),
              child: const Icon(
                Icons.pets,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading animals...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Please try again',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _showErrorDialog,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 2) return null;

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
      child: FloatingActionButton(
        heroTag: 'cart_fab',
        onPressed: () => _onItemTapped(2),
        backgroundColor: ColorPalette.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.shopping_cart_rounded,
          size: 28,
        ),
      ),
    );
  }
}
