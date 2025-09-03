import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/recipe_model.dart';
import '../utils/animations/widget_animations.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onFavoritePressed;
  final bool showFavoriteButton;
  
  const RecipeCard({
    super.key,
    required this.recipe,
    this.onFavoritePressed,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleAnimation(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showRecipeDetails(context, recipe),
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.transparent,
          splashColor: Theme.of(context).primaryColor.withValues(
            red: Theme.of(context).primaryColor.r / 255 * 0.1,
            green: Theme.of(context).primaryColor.g / 255 * 0.1,
            blue: Theme.of(context).primaryColor.b / 255 * 0.1,
            alpha: 255,
          ),
          highlightColor: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe image with fade in animation
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: FadeInAnimation(
                  child: CachedNetworkImage(
                    imageUrl: recipe.linkImagem?.isNotEmpty == true
                        ? recipe.linkImagem!
                        : 'https://via.placeholder.com/300x200?text=Sem+imagem',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 500),
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.fastfood,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              // Title and info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.receita,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tipo: ${recipe.tipo != null && recipe.tipo!.isNotEmpty ? recipe.tipo![0].toUpperCase() + recipe.tipo!.substring(1) : 'Não especificado'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Favorite button
              if (showFavoriteButton) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite ? Colors.red : null,
                        ),
                        onPressed: onFavoritePressed,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SlideInAnimation(
        beginOffset: const Offset(0, 1),
        endOffset: Offset.zero,
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Container(
                    width: 60,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and image
                          Text(
                            recipe.receita,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tipo: ${_formatTipo(recipe.tipo ?? '')}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Recipe image
                          if (recipe.linkImagem?.isNotEmpty == true)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: recipe.linkImagem!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.fastfood,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),

                          // Recipe details
                          const SizedBox(height: 20),
                          if (recipe.ingredients.isNotEmpty) ...[
                            const Text(
                              'Ingredientes:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...recipe.ingredients.map(
                              (ingredient) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '• ',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Expanded(child: Text(ingredient.trim())),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          if (recipe.instructions.isNotEmpty) ...[
                            const Text(
                              'Modo de Preparo:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...recipe.instructions
                                .split('\n')
                                .where((step) => step.trim().isNotEmpty)
                                .toList()
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                            top: 4,
                                          ),
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${entry.key + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(entry.value.trim()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Favorite button
                if (showFavoriteButton)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(
                            red: 128 / 255,
                            green: 128 / 255,
                            blue: 128 / 255,
                            alpha: 0.2,
                          ),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          onFavoritePressed?.call();
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite ? Colors.red : null,
                        ),
                        label: Text(
                          recipe.isFavorite
                              ? 'Remover dos Favoritos'
                              : 'Adicionar aos Favoritos',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: recipe.isFavorite
                              ? Colors.red.withValues(
                                  red: 1.0,
                                  green: 0.0,
                                  blue: 0.0,
                                  alpha: 0.1,
                                )
                              : null,
                          foregroundColor: recipe.isFavorite
                              ? Colors.red
                              : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTipo(String tipo) {
    if (tipo.isEmpty) return 'Não especificado';
    return tipo[0].toUpperCase() + tipo.substring(1);
  }
}
