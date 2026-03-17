import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';

class AddStepModal extends StatefulWidget {
  final RecipeStep? initialStep;
  final int stepNumber;
  final ValueChanged<RecipeStep> onStepAdded;
  final VoidCallback? onStepDeleted;
  final int maxAllowedTimeSeconds;
  final int otherStepsTimeSeconds;

  const AddStepModal({
    super.key,
    this.initialStep,
    required this.stepNumber,
    required this.onStepAdded,
    this.onStepDeleted,
    this.maxAllowedTimeSeconds = 0,
    this.otherStepsTimeSeconds = 0,
  });

  @override
  State<AddStepModal> createState() => _AddStepModalState();
}

class _AddStepModalState extends State<AddStepModal> {
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _hController = TextEditingController();
  final TextEditingController _mController = TextEditingController();
  final TextEditingController _sController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialStep != null) {
      _instructionController.text = widget.initialStep!.instruction;
      final total = widget.initialStep!.timerSeconds;
      final hours = total ~/ 3600;
      final minutes = (total % 3600) ~/ 60;
      final seconds = total % 60;
      _hController.text = hours == 0 ? '' : hours.toString();
      _mController.text = minutes == 0 ? '' : minutes.toString();
      _sController.text = seconds == 0 ? '' : seconds.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.initialStep != null;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Step ${widget.stepNumber}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            TextField(
              controller: _instructionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe this cooking step...',
                filled: true,
                fillColor: AppColors.cardRose.withValues(alpha: 0.1),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Timer (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTimeInput('Hrs', _hController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeInput('Min', _mController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeInput('Sec', _sController)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                if (isEditing)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      onPressed: widget.onStepDeleted == null
                          ? null
                          : () {
                              widget.onStepDeleted!();
                              Navigator.pop(context);
                            },
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      style: IconButton.styleFrom(side: const BorderSide(color: Colors.redAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(12)),
                    ),
                  ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final instruction = _instructionController.text.trim();
                      if (instruction.isEmpty) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Instruction cannot be empty.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        return;
                      }

                      final totalSec =
                          (int.tryParse(_hController.text) ?? 0) * 3600 +
                          (int.tryParse(_mController.text) ?? 0) * 60 +
                          (int.tryParse(_sController.text) ?? 0);
                      
                      if (widget.maxAllowedTimeSeconds > 0 && totalSec > widget.maxAllowedTimeSeconds) {
                        final maxHours = widget.maxAllowedTimeSeconds ~/ 3600;
                        final maxMinutes = (widget.maxAllowedTimeSeconds % 3600) ~/ 60;
                        final maxSeconds = widget.maxAllowedTimeSeconds % 60;
                        final maxTimeStr = maxHours > 0 
                          ? '$maxHours:${maxMinutes.toString().padLeft(2, '0')}:${maxSeconds.toString().padLeft(2, '0')}'
                          : '${maxMinutes}m ${maxSeconds}s';
                        
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('Single step time cannot exceed total cooking time ($maxTimeStr).'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        return;
                      }
                      
                      final totalWithOtherSteps = widget.otherStepsTimeSeconds + totalSec;
                      if (widget.maxAllowedTimeSeconds > 0 && totalWithOtherSteps > widget.maxAllowedTimeSeconds) {
                        final remainingTime = widget.maxAllowedTimeSeconds - widget.otherStepsTimeSeconds;
                        final hours = remainingTime ~/ 3600;
                        final minutes = (remainingTime % 3600) ~/ 60;
                        final seconds = remainingTime % 60;
                        final remainingStr = hours > 0 
                          ? '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                          : '${minutes}m ${seconds}s';
                        
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('Total step times exceed cooking time. Remaining time: $remainingStr.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        return;
                      }
                      
                      widget.onStepAdded(
                        RecipeStep(
                          instruction: instruction,
                          timerSeconds: totalSec,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosePink, minimumSize: const Size(0, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text(isEditing ? 'Update Step' : 'Add Step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInput(String label, TextEditingController controller) {
    return Column(
      children: [
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
  
          decoration: InputDecoration(
            suffixText: label.toLowerCase(),
            suffixStyle: const TextStyle(fontSize: 12, color: Colors.black),
            filled: true,
            fillColor: AppColors.cardRose.withValues(alpha: 0.5),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5)),
          ),
        ),
      ],
    );
  }
}