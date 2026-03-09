import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';

class CreateRecipeAboutPage extends StatefulWidget {
  final VoidCallback onNext;
  const CreateRecipeAboutPage({super.key, required this.onNext});

  @override
  State<CreateRecipeAboutPage> createState() => _CreateRecipeAboutPageState();
}

class _CreateRecipeAboutPageState extends State<CreateRecipeAboutPage> {
  bool _isPublic = true;

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

          _buildTextField(label: 'Recipe Name', hint: 'e.g. Classic Ratatouille'),
          const SizedBox(height: 16),
          _buildTextField(label: 'Description', hint: 'Tell us about your dish...', maxLines: 4),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _buildStatInput('Prep Time', 'min')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatInput('Cook Time', 'min')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatInput('Servings', 'pax')),
            ],
          ),
          const SizedBox(height: 32),

          // --- PUBLIC/PRIVATE CHECKBOX ---
          _buildVisibilityToggle(),
          
          const SizedBox(height: 40),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_rounded, size: 48, color: AppColors.rosePink.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          const Text('Add Cover Photo', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.rosePink)),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 8),
        TextField(
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

  Widget _buildStatInput(String label, String unit) {
    return Column(
      children: [
        Text(
          label, 
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)
        ),
        const SizedBox(height: 8),
        TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
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
                width: 1.5 // Unified 1.5px border
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
      onPressed: widget.onNext,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rosePink,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text('Next: Ingredients', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}