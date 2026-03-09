import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';

class HomeMealOverviewCard extends StatefulWidget {
  const HomeMealOverviewCard({
    super.key,
    required this.date,
    required this.mealType,
    required this.items, 
    required this.totals, 
    this.isTotalsLoading = false,
  });

  final DateTime date;
  final String mealType;
  final List<dynamic>? items;
  final dynamic totals;
  final bool isTotalsLoading;

  @override
  State<HomeMealOverviewCard> createState() => _HomeMealOverviewCardState();
}

class _HomeMealOverviewCardState extends State<HomeMealOverviewCard> {
  int _currentIndex = 0;

  String _formatDate(DateTime dt) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    final weekday = weekdays[dt.weekday - 1];
    final month = months[dt.month - 1];
    return '$weekday, $month ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = widget.items?.length ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(widget.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.rosePink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.mealType,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.rosePink,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 140, 
                  child: itemCount == 0
                      ? _buildEmptyState()
                      : Stack(
                          children: [
                            PageView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: itemCount,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return _buildFullWidthRecipeCard(index);
                              },
                            ),
                            
                            if (itemCount > 1)
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 8, 
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(itemCount, (index) {
                                    final bool isActive = _currentIndex == index;
                                    
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: isActive ? 16 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isActive 
                                            ? AppColors.rosePink 
                                            : Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // RIGHT SIDE: Nutrition Totals Box (Now anchored to the bottom)
          Container(
            width: 110, 
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardRose, 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.3), width: 1.5),
            ),
            child: widget.isTotalsLoading 
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Totals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildMacroRow('Calories', '320'), 
                      const SizedBox(height: 4),
                      _buildMacroRow('Protein', '24g'),
                      const SizedBox(height: 4),
                      _buildMacroRow('Fats', '12g'),
                      const SizedBox(height: 4),
                      _buildMacroRow('Carbs', '30g'),
                      const SizedBox(height: 4),
                      _buildMacroRow('Fiber', '5g'),
                      const SizedBox(height: 4),
                      _buildMacroRow('Sugar', '8g'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1.5),
      ),
      child: const Center(
        child: Text(
          'No recipes added yet.\nTap to add!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildFullWidthRecipeCard(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 8), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.grey.shade300,
              child: const Icon(
                Icons.image_rounded, 
                color: Colors.black26, 
                size: 50,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delicious Recipe ${index + 1}', 
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Takes 25 mins • Easy',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}