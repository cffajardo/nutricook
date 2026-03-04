import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/techniques/techniques.dart';

class TechniqueSeeder {
  static const String cutting = TechniqueCategory.cutting;
  static const String prep = TechniqueCategory.prep;
  static const String dryHeat = TechniqueCategory.dryHeat;
  static const String moistHeat = TechniqueCategory.moistHeat;
  static const String combination = TechniqueCategory.combination;
  static const String presentation = TechniqueCategory.presentation;

  static List<Technique> techniques() {
    return const [
      Technique(id: 'chop', name: 'Chop', category: cutting, description: 'Cut ingredients into rough, uniform pieces.'),
      Technique(id: 'dice', name: 'Dice', category: cutting, description: 'Cut into small, even cubes.'),
      Technique(id: 'mince', name: 'Mince', category: cutting, description: 'Cut food into very fine pieces.'),
      Technique(id: 'slice', name: 'Slice', category: cutting, description: 'Cut into thin, broad pieces.'),
      Technique(id: 'julienne', name: 'Julienne', category: cutting, description: 'Cut into thin matchstick strips.'),
      Technique(id: 'brunoise', name: 'Brunoise', category: cutting, description: 'Cut into very small uniform cubes, typically from julienne.'),
      Technique(id: 'chiffonade', name: 'Chiffonade', category: cutting, description: 'Slice leafy herbs or greens into thin ribbons.'),
      Technique(id: 'grate', name: 'Grate', category: cutting, description: 'Shred ingredients into fine pieces using a grater.'),

      Technique(id: 'mix', name: 'Mix', category: prep, description: 'Combine ingredients until evenly distributed.'),
      Technique(id: 'whisk', name: 'Whisk', category: prep, description: 'Beat ingredients rapidly to blend and aerate.'),
      Technique(id: 'fold', name: 'Fold', category: prep, description: 'Gently combine mixtures while preserving air.'),
      Technique(id: 'knead', name: 'Knead', category: prep, description: 'Work dough to develop gluten structure.'),
      Technique(id: 'marinate', name: 'Marinate', category: prep, description: 'Soak food in a seasoned liquid to add flavor and tenderness.'),
      Technique(id: 'brine', name: 'Brine', category: prep, description: 'Soak food in saltwater to improve moisture retention and seasoning.'),
      Technique(id: 'blend', name: 'Blend', category: prep, description: 'Process ingredients into a smooth or uniform consistency.'),
      Technique(id: 'emulsify', name: 'Emulsify', category: prep, description: 'Combine fat and water-based liquids into a stable mixture.'),

      Technique(id: 'saute', name: 'Sauté', category: dryHeat, description: 'Cook quickly in a small amount of fat over relatively high heat.'),
      Technique(id: 'sear', name: 'Sear', category: dryHeat, description: 'Brown the surface over high heat to build flavor.'),
      Technique(id: 'pan-fry', name: 'Pan Fry', category: dryHeat, description: 'Cook in shallow fat with partial immersion.'),
      Technique(id: 'deep-fry', name: 'Deep Fry', category: dryHeat, description: 'Cook food fully submerged in hot oil.'),
      Technique(id: 'stir-fry', name: 'Stir Fry', category: dryHeat, description: 'Cook quickly over high heat with constant stirring.'),
      Technique(id: 'bake', name: 'Bake', category: dryHeat, description: 'Cook with dry, surrounding heat in an oven.'),
      Technique(id: 'roast', name: 'Roast', category: dryHeat, description: 'Cook in dry oven heat, usually at higher temperature for browning.'),
      Technique(id: 'grill', name: 'Grill', category: dryHeat, description: 'Cook over direct radiant heat, often on grates.'),
      Technique(id: 'broil', name: 'Broil', category: dryHeat, description: 'Cook with intense direct heat from above.'),
      Technique(id: 'toast', name: 'Toast', category: dryHeat, description: 'Brown and crisp the surface using dry heat.'),

      Technique(id: 'boil', name: 'Boil', category: moistHeat, description: 'Cook in liquid at a full rolling boil.'),
      Technique(id: 'simmer', name: 'Simmer', category: moistHeat, description: 'Cook gently in liquid just below boiling.'),
      Technique(id: 'poach', name: 'Poach', category: moistHeat, description: 'Cook delicately in liquid at low temperature.'),
      Technique(id: 'steam', name: 'Steam', category: moistHeat, description: 'Cook using steam from boiling liquid.'),
      Technique(id: 'blanch', name: 'Blanch', category: moistHeat, description: 'Briefly boil, then cool rapidly to stop cooking.'),
      Technique(id: 'parboil', name: 'Parboil', category: moistHeat, description: 'Partially boil before finishing with another method.'),
      Technique(id: 'sous-vide', name: 'Sous Vide', category: moistHeat, description: 'Cook vacuum-sealed food in precisely controlled water temperature.'),
      Technique(id: 'pressure-cook', name: 'Pressure Cook', category: moistHeat, description: 'Cook in pressurized steam to reduce cooking time.'),

      Technique(id: 'braise', name: 'Braise', category: combination, description: 'Sear first, then cook slowly in a covered vessel with some liquid.'),
      Technique(id: 'stew', name: 'Stew', category: combination, description: 'Cook smaller pieces gently in ample liquid until tender.'),
      Technique(id: 'pot-roast', name: 'Pot Roast', category: combination, description: 'Brown a large cut, then slowly cook covered with liquid.'),
      Technique(id: 'fricassee', name: 'Fricassee', category: combination, description: 'Cook by sautéing lightly, then braising in sauce.'),
      Technique(id: 'glaze', name: 'Glaze', category: combination, description: 'Coat food with a reduced liquid for flavor and sheen.'),

      Technique(id: 'plate', name: 'Plate', category: presentation, description: 'Arrange food intentionally for visual appeal and balance.'),
      Technique(id: 'garnish', name: 'Garnish', category: presentation, description: 'Finish with decorative and complementary edible elements.'),
      Technique(id: 'carve', name: 'Carve', category: presentation, description: 'Slice cooked meats or poultry into serving portions.'),
      Technique(id: 'quenelle', name: 'Quenelle', category: presentation, description: 'Shape soft food into smooth ovals using spoons.'),
      Technique(id: 'sauce-nappe', name: 'Sauce Nappé', category: presentation, description: 'Coat or spoon sauce neatly to enhance finish and flavor.'),
    ];
  }

  static Future<void> seed(FirebaseFirestore db, String collectionPath) async {
    final batch = db.batch();
    for (final technique in techniques()) {
      batch.set(db.collection(collectionPath).doc(technique.id), technique.toJson());
    }
    await batch.commit();
  }
}