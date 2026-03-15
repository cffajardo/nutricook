import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/widgets/recipe_tags_filter.dart';
import 'package:nutricook/widgets/image_upload_field.dart';

class CreateRecipeAboutPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const CreateRecipeAboutPage({super.key, required this.onNext});

  @override
  ConsumerState<CreateRecipeAboutPage> createState() =>
      _CreateRecipeAboutPageState();
}

class _CreateRecipeAboutPageState extends ConsumerState<CreateRecipeAboutPage> {
  bool _isPublic = true;
  List<String> _selectedTags = [];
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _servingsController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(recipeCreationProvider);
    _isPublic = state.isPublic;
    _selectedTags = List<String>.from(state.tags);
    _nameController = TextEditingController(text: state.name);
    _descriptionController = TextEditingController(text: state.description);
    _prepTimeController = TextEditingController(
      text: state.prepTimeMinutes == 0 ? '' : state.prepTimeMinutes.toString(),
    );
    _cookTimeController = TextEditingController(
      text: state.cookTimeMinutes == 0 ? '' : state.cookTimeMinutes.toString(),
    );
    _servingsController = TextEditingController(
      text: state.servings <= 0 ? '' : state.servings.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),

          _buildImageUploader(),
          const SizedBox(height: 24),

          _buildTextField(
            label: 'Recipe Name',
            hint: 'e.g. Classic Ratatouille',
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Description',
            hint: 'Tell us about your dish...',
            maxLines: 4,
            controller: _descriptionController,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildStatInput(
                  'Prep Time',
                  'min',
                  controller: _prepTimeController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatInput(
                  'Cook Time',
                  'min',
                  controller: _cookTimeController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatInput(
                  'Recipe Servings',
                  'serv',
                  controller: _servingsController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Set how many portions this recipe yields. Nutrition is shown per 1 recipe serving.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.55),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 32),

          _buildVisibilityToggle(),

          const SizedBox(height: 16),
          _buildTagSelectorButton(),  
          
          const SizedBox(height: 40),
          _buildNextButton(),

          
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    return ImageUploadField(
      folder: 'recipes',
      label: 'Upload Cover Photo',
      height: 200,
      onSuccess: (imageUrl) {
        ref.read(recipeCreationProvider.notifier).setImageUrl(imageUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cover photo uploaded successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatInput(
    String label,
    String unit, {
    required TextEditingController controller,
  }) {
    return Column(
      children: [
        Text(
          label, 
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.4),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    unit, 
                    style: const TextStyle(fontSize: 10, color: Colors.black38)
                  ),
                ],
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: AppColors.cardRose.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColors.rosePink.withValues(alpha: 0.1), 
                width: 1.5 
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(_isPublic ? Icons.public : Icons.lock_outline, color: AppColors.rosePink),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Public Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Visible to everyone in the Discovery feed', style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          Switch(
            value: _isPublic,
            onChanged: (val) => setState(() => _isPublic = val),
            activeThumbColor: AppColors.rosePink,
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _handleNext,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rosePink,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text('Next: Ingredients', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  void _handleNext() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please enter recipe name and description.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    ref.read(recipeCreationProvider.notifier).updateAbout(
          name: name,
          description: description,
          prepTimeMinutes: int.tryParse(_prepTimeController.text.trim()) ?? 0,
          cookTimeMinutes: int.tryParse(_cookTimeController.text.trim()) ?? 0,
          servings: ((int.tryParse(_servingsController.text.trim()) ?? 1)
                  .clamp(1, 999))
              .toInt(),
          isPublic: _isPublic,
          tags: _selectedTags,
        );

    widget.onNext();
  }

  void _openTagPicker() async {
  final List<String>? result = await showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true, 
    backgroundColor: Colors.transparent, 
    builder: (context) => RecipeTagsFilterModal(
      title: 'Select Tags',
      initialSelectedTags: _selectedTags,
    ),
  );

  if (result != null) {
    setState(() {
      _selectedTags = result; 
    });
  }
}

  Widget _buildTagSelectorButton() {
  return InkWell(
    onTap: _openTagPicker, 
    borderRadius: BorderRadius.circular(16),
    child: Container(
      width: double.infinity, 
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.1), 
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                    if (_selectedTags.isNotEmpty)
              TextButton(
                onPressed: () =>
                    setState(() => _selectedTags.clear()), 
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.redAccent, fontSize: 11),
                ),
              ),
          Row(
            children: [
              const Icon(Icons.local_offer_outlined, size: 16, color: AppColors.rosePink),
              const SizedBox(width: 8),
              Text(
                _selectedTags.isEmpty ? 'Add Tags' : 'Tags', 
                style: const TextStyle(fontSize: 12, color: AppColors.rosePink, fontWeight: FontWeight.bold)
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.rosePink),
            ],
          ),
          
          if (_selectedTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, 
              runSpacing: 8, 
              children: _selectedTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.rosePink.withValues(alpha: 0.2), 
                    width: 1.0,
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 11, 
                    color: AppColors.rosePink, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    ),
  );
}
}