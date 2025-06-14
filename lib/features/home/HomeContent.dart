import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';
import 'package:marketplace_app_v0/core/widgets/form.dart';
import 'package:marketplace_app_v0/models/animal.dart';

class HomeContent extends StatefulWidget {
  final List<Animal> animals;
  final int totalAnimals;
  final int aliveAnimals;
  final int sickAnimals;
  final int deadAnimals;
  final int alerts;
  final VoidCallback onRefresh;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final bool hasMoreData;

  const HomeContent({
    super.key,
    required this.animals,
    required this.totalAnimals,
    required this.aliveAnimals,
    required this.sickAnimals,
    required this.deadAnimals,
    required this.alerts,
    required this.onRefresh,
    required this.scrollController,
    required this.isLoadingMore,
    required this.hasMoreData,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with TickerProviderStateMixin {
  String _search = '';
  String _selectedFilter = 'all';
  bool _isGridView = false;
  late AnimationController _animationController;
  late AnimationController _fabPulseController;
  late AnimationController _statsAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _filterOptions = [
    'all',
    'alive',
    'sick',
  ];
  final Map<String, IconData> _filterIcons = {
    'all': Icons.pets_rounded,
    'alive': Icons.favorite_rounded,
    'sick': Icons.healing_rounded,
    'dead': Icons.close_rounded,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabPulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.easeOutQuint,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.easeInOut,
    ));

    _statsAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabPulseController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  List<Animal> get _filteredAnimals {
    var filtered = widget.animals.where((a) {
      final matchesSearch =
          a.name.toLowerCase().contains(_search.toLowerCase());
      final matchesFilter =
          _selectedFilter == 'all' || a.status == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    filtered.sort((a, b) {
      const statusPriority = {'alive': 0, 'sick': 1, 'dead': 2};
      return (statusPriority[a.status] ?? 3)
          .compareTo(statusPriority[b.status] ?? 3);
    });

    return filtered;
  }

  Future<void> _openAddForm() async {
    HapticFeedback.mediumImpact();
    XFile? pickedImage;

    // Open camera to take a photo
    final ImagePicker picker = ImagePicker();
    try {
      pickedImage = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800, // Optional: Resize to optimize performance
        maxHeight: 800,
      );
    } catch (e) {
      // Handle camera permission denial or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to access camera. Please grant permission.')),
      );
      return;
    }

    if (pickedImage != null) {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useSafeArea: true,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: AddAnimalForm(), // Pass the image path
        ),
      );
      if (result == true) {
        widget.onRefresh();
        _showSuccessSnackBar('Animal added successfully! 🐾');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ColorPalette.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(16),
        elevation: 12,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleViewMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _isGridView = !_isGridView;
    });

    if (_isGridView) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'alive':
        return const Color(0xFF4CAF50);
      case 'sick':
        return const Color(0xFFFF9800);
      case 'dead':
        return const Color(0xFFF44336);
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      body: CustomScrollView(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildEnhancedSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildEnhancedSearchAndActions(),
                          const SizedBox(height: 32),
                          _buildEnhancedStatistics(isTablet),
                          const SizedBox(height: 24),
                          _buildEnhancedFilterChips(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildEnhancedAnimalsList(isTablet),
          if (widget.isLoadingMore)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorPalette.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading more animals...',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorPalette.primary,
                ColorPalette.primary.withOpacity(0.85),
                ColorPalette.primary.withOpacity(0.95),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Animal Dashboard',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.animals.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 54),
                        Text(
                          '${widget.totalAnimals} animals in your care',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: AnimatedRotation(
              turns: _isGridView ? 0.5 : 0,
              duration: const Duration(milliseconds: 600),
              child: Icon(
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            onPressed: _toggleViewMode,
            tooltip:
                _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.info_outline_rounded,
                color: Colors.white, size: 24),
            onPressed: () => _showInfoDialog(),
            tooltip: 'App Information',
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedSearchAndActions() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: 'Search animals...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color: Colors.grey.shade600, size: 22),
                        onPressed: () => setState(() => _search = ''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        AnimatedBuilder(
          animation: _fabPulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_fabPulseController.value * 0.06),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorPalette.primary,
                      ColorPalette.primary.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: ColorPalette.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openAddForm,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'New',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedStatistics(bool isTablet) {
    final stats = [
      {
        'icon': Icons.pets_rounded,
        'label': 'Total',
        'count': widget.totalAnimals,
        'color': const Color(0xFF2196F3)
      },
      {
        'icon': Icons.favorite_rounded,
        'label': 'Healthy',
        'count': widget.aliveAnimals,
        'color': const Color(0xFF4CAF50)
      },
      {
        'icon': Icons.healing_rounded,
        'label': 'Sick',
        'count': widget.sickAnimals,
        'color': const Color(0xFFFF9800)
      },
      {
        'icon': Icons.warning_rounded,
        'label': 'Critical',
        'count': widget.deadAnimals,
        'color': const Color(0xFFF44336)
      },
    ];

    return Column(
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;

        return Container(
          margin: EdgeInsets.only(top: index > 0 ? 16 : 0),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 800 + (index * 150)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..scale(value)
                  ..translate(0.0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildEnhancedStatCard(
                    stat['icon'] as IconData,
                    stat['label'] as String,
                    stat['count'] as int,
                    stat['color'] as Color,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedStatCard(
      IconData icon, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding for compactness
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(
            20), // Slightly smaller radius for consistency
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12, // Reduced blur for performance
            offset: const Offset(0, 4), // Adjusted offset for subtlety
          ),
        ],
        border:
            Border.all(color: color.withOpacity(0.1)), // Subtle colored border
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 6, // Reduced blur
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child:
                Icon(icon, color: color, size: 24), // Reduced size for balance
          ),
          const SizedBox(width: 12), // Consistent horizontal spacing
          Expanded(
            child: TweenAnimationBuilder<int>(
              duration: const Duration(milliseconds: 800), // Reduced duration
              tween: IntTween(begin: 0, end: count),
              builder: (context, value, child) {
                return Semantics(
                  label: '$label count: $value',
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 24, // Slightly reduced for readability
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.3,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8), // Adjusted spacing
          Semantics(
            label: '$label label',
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700, // Darker grey for better contrast
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filterOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final filter = entry.value;
          final isSelected = _selectedFilter == filter;
          final count = filter == 'all'
              ? widget.totalAnimals
              : widget.animals.where((a) => a.status == filter).length;

          return Container(
            margin: EdgeInsets.only(left: index > 0 ? 12 : 0),
            child: TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 500 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutQuint,
              builder: (context, value, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..scale(value)
                    ..translate(0.0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildEnhancedFilterChip(filter, count, isSelected),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnhancedFilterChip(String filter, int count, bool isSelected) {
    final color = isSelected ? Colors.white : Colors.grey.shade800;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuint,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  ColorPalette.primary,
                  ColorPalette.primary.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.85),
                ],
              ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? ColorPalette.primary.withOpacity(0.35)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 6 : 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedFilter = filter);
          },
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _filterIcons[filter],
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  '${filter.toUpperCase()} ($count)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAnimalsList(bool isTablet) {
    final filteredAnimals = _filteredAnimals;

    if (filteredAnimals.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.pets_rounded,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _search.isNotEmpty || _selectedFilter != 'all'
                    ? 'No animals match your criteria'
                    : 'No animals added yet',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _search.isNotEmpty || _selectedFilter != 'all'
                    ? 'Try adjusting your search or filter'
                    : 'Add your first animal to get started',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..scale(value)
                    ..translate(0.0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildEnhancedAnimalGridCard(filteredAnimals[index]),
                  ),
                );
              },
            ),
            childCount: filteredAnimals.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 80)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutQuint,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(100 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: _buildEnhancedAnimalListCard(
                      filteredAnimals[index], isTablet),
                ),
              );
            },
          ),
          childCount: filteredAnimals.length,
        ),
      ),
    );
  }

  Widget _buildEnhancedAnimalListCard(Animal animal, bool isTablet) {
    final statusColor = _getStatusColor(animal.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAnimalDetails(animal),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildEnhancedAnimalAvatar(animal, isTablet ? 48 : 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              animal.name,
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade900,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor.withOpacity(0.15),
                                  statusColor.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: statusColor.withOpacity(0.2)),
                            ),
                            child: Text(
                              animal.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAnimalGridCard(Animal animal) {
    final statusColor = _getStatusColor(animal.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAnimalDetails(animal),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey.shade100.withOpacity(0.9),
                              Colors.grey.shade50.withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: Center(
                          child: _buildEnhancedAnimalAvatar(animal, 72),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withOpacity(0.2),
                              statusColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          animal.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.pets_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAnimalAvatar(Animal animal, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            _getStatusColor(animal.status).withOpacity(0.25),
            _getStatusColor(animal.status).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(animal.status).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          animal.name.isNotEmpty ? animal.name[0].toUpperCase() : 'A',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            color: _getStatusColor(animal.status),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnimalDetails(Animal animal) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildEnhancedAnimalAvatar(animal, 56),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor(animal.status).withOpacity(0.2),
                                _getStatusColor(animal.status).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: _getStatusColor(animal.status)
                                    .withOpacity(0.3)),
                          ),
                          child: Text(
                            animal.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _getStatusColor(animal.status),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.calendar_today_rounded, 'Added',
                  DateTime.now().toString().split(' ')[0]),
              const SizedBox(height: 12),
              _buildDetailRow(
                  Icons.info_outline_rounded, 'Status', animal.status),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      // Implement edit functionality here
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorPalette.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white.withOpacity(0.95),
        title: Text(
          'About Animal Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.grey.shade900,
          ),
        ),
        content: Text(
          'Track and manage your animals with ease. Features include real-time status monitoring, detailed statistics, and intuitive filtering options.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 16,
                color: ColorPalette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
