import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/recipe/widgets/add_ingredient_modal.dart';

class CreateRecipeIngredientsPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CreateRecipeIngredientsPage({super.key, required this.onNext, required this.onBack});

  @override
  State<CreateRecipeIngredientsPage> createState() => _CreateRecipeIngredientsPageState();
}

class _CreateRecipeIngredientsPageState extends State<CreateRecipeIngredientsPage> {
  final List<Map<String, dynamic>> _ingredients = [];

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIngredientModal(
        onIngredientAdded: (item) => setState(() => _ingredients.add(item)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _ingredients.isEmpty ? _buildEmptyState() : _buildIngredientList(),
        ),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _showAddModal,
            icon: const Icon(Icons.add_circle_outline, size: 80, color: AppColors.rosePink),
          ),
          const SizedBox(height: 16),
          const Text('Tap to add ingredients', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIngredientList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _ingredients.length + 1,
      itemBuilder: (context, index) {
        if (index == _ingredients.length) {
          return IconButton(
            onPressed: _showAddModal,
            icon: const Icon(Icons.add_circle_outline, color: AppColors.rosePink),
          );
        }
        final item = _ingredients[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
          ),
          child: Row(
            children: [
              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${item['amount']} ${item['unit']} • ${item['process']}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: widget.onBack, child: const Text('Back'))),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: ElevatedButton(onPressed: widget.onNext, child: const Text('Next'))),
        ],
      ),
    );
  }
}