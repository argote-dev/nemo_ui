import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  test('v2 has exactly four bounded semantic materials', () {
    final NemoThemeData theme = NemoThemeData.light();
    expect(NemoMaterial.values, hasLength(4));
    for (final NemoMaterial material in NemoMaterial.values) {
      final NemoMaterialRecipe recipe = theme.materials.recipeFor(material);
      expect(recipe.shadowOpacity, inInclusiveRange(0, 1));
      expect(recipe.outlineOpacity, inInclusiveRange(0, 1));
      expect(recipe.blurMultiplier, inInclusiveRange(0, 2));
    }
    expect(theme.materials.raised.polarity, NemoIlluminationPolarity.raised);
    expect(theme.materials.recessed.polarity, NemoIlluminationPolarity.inset);
  });
  test('high contrast is a shadow-free explicit-boundary substitution', () {
    final NemoThemeData theme = NemoThemeData.highContrast();
    for (final NemoMaterial material in NemoMaterial.values) {
      final NemoMaterialRecipe recipe = theme.materials.recipeFor(material);
      expect(recipe.shadowOpacity, 0);
      expect(recipe.outlineOpacity, 1);
    }
  });
  test('theme overrides replace complete material and interaction groups', () {
    const NemoMaterialTokens materials = NemoMaterialTokens.highContrast();
    const NemoInteractionTokens interactions = NemoInteractionTokens.standard;
    final NemoThemeData theme = NemoThemeData.light(
      overrides: const NemoThemeOverrides(
        materials: materials,
        interactions: interactions,
      ),
    );
    expect(theme.materials, same(materials));
    expect(theme.interactions, same(interactions));
  });

  test('shared press recipe is recessed and has bounded displacement', () {
    final NemoInteractionRecipe pressed =
        NemoThemeData.light().interactions.pressed;
    expect(pressed.material, NemoMaterial.recessed);
    expect(pressed.contentOffset, inInclusiveRange(0, 1));
  });
}
