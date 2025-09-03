import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/spoonacular_service.dart';
import '../widgets/recipe_card.dart';

class RecipesScreen extends StatefulWidget {
  final List<String>? ingredients;
  final String? title;

  const RecipesScreen({super.key, this.ingredients, this.title});

  @override
  @override
  RecipesScreenState createState() => RecipesScreenState();
}

class RecipesScreenState extends State<RecipesScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Recipe> _allRecipes = [];
  final List<Recipe> _favoriteRecipes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _showFavorites = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadRecipes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreRecipes();
    }
  }

  final SpoonacularService _spoonacularService = SpoonacularService();

  Future<void> _loadRecipes() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
      _allRecipes.clear();
      _errorMessage = null; // Reset error message when retrying
    });

    try {
      final recipes =
          widget.ingredients != null && widget.ingredients!.isNotEmpty
              ? await _spoonacularService.searchRecipesByIngredients(
                  ingredients: widget.ingredients!,
                  number: _pageSize,
                  offset: 0,
                )
              : await _spoonacularService.getRandomRecipes(
                  number: _pageSize,
                  offset: 0,
                );

      setState(() {
        _allRecipes.addAll(recipes);
        _hasMore = recipes.length >= _pageSize;
      });
    } catch (e) {
      String errorMessage = 'Erro ao carregar receitas. Por favor, tente novamente.';

      if (e.toString().contains('402')) {
        errorMessage =
            'Limite de requisições excedido. Por favor, tente novamente mais tarde ou use uma chave de API diferente.';
      }

      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    _currentPage++;

    try {
      final recipes =
          widget.ingredients != null && widget.ingredients!.isNotEmpty
              ? await _spoonacularService.searchRecipesByIngredients(
                  ingredients: widget.ingredients!,
                  number: _pageSize,
                  offset: _currentPage * _pageSize,
                )
              : await _spoonacularService.getRandomRecipes(
                  number: _pageSize,
                  offset: _currentPage * _pageSize,
                );

      setState(() {
        _allRecipes.addAll(recipes);
        _hasMore = recipes.length >= _pageSize;
      });
    } catch (e) {
      _currentPage--; // Revert the page increment on error
      String errorMessage = 'Erro ao carregar mais receitas. Por favor, tente novamente.';

      if (e.toString().contains('402')) {
        errorMessage =
            'Limite de requisições excedido. Por favor, tente novamente mais tarde.';
      }

      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleFavorite(Recipe recipe, bool isFavorite) {
    setState(() {
      if (isFavorite) {
        _favoriteRecipes.removeWhere((r) => r.id == recipe.id);
      } else {
        _favoriteRecipes.add(recipe);
      }
    });
  }

  bool _isFavorite(Recipe recipe) {
    return _favoriteRecipes.any((r) => r.id == recipe.id);
  }

  List<Recipe> _getFilteredRecipes() {
    var filtered = _allRecipes;

    // Aplica filtro de pesquisa
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((recipe) {
        return recipe.title.toLowerCase().contains(query) ||
            recipe.ingredients.any((i) => i.toLowerCase().contains(query)) ||
            (recipe.tipo ?? '').toLowerCase().contains(query);
      }).toList();
    }

    // Aplica filtro de favoritos
    if (_showFavorites) {
      filtered = filtered.where(_isFavorite).toList();
    }

    return filtered;
  }

  Widget _buildRecipeList(List<Recipe> recipes) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: recipes.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= recipes.length) {
          return _buildLoading();
        }

        final recipe = recipes[index];
        return RecipeCard(
          key: ValueKey('recipe_${recipe.id}_$index'),
          recipe: recipe,
          onFavoritePressed: () => _toggleFavorite(recipe, _isFavorite(recipe)),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar receitas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecipes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fastfood_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma receita encontrada',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.ingredients?.isNotEmpty == true
                ? 'Tente adicionar mais ingredientes ou verifique sua conexão.'
                : 'Verifique sua conexão e tente novamente.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRecipes,
            child: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma receita encontrada',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _showFavorites
                ? 'Você ainda não tem receitas favoritas.'
                : 'Tente buscar por outros termos ou verifique a ortografia.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!_showFavorites) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              child: const Text('Limpar busca'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = _getFilteredRecipes();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Receitas'),
        actions: [
          // Barra de pesquisa
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar receitas...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Botão de favoritos
          IconButton(
            icon: Icon(_showFavorites ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
              });
            },
            tooltip: 'Mostrar favoritos',
          ),
        ],
      ),
      body: _errorMessage != null
          ? _buildError(_errorMessage!)
          : Column(
              children: [
                // Barra de pesquisa
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar receitas...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                // Lista de receitas
                Expanded(
                  child: _allRecipes.isEmpty && !_isLoading
                      ? _buildEmpty()
                      : filteredRecipes.isEmpty
                          ? _buildNoResults()
                          : _buildRecipeList(filteredRecipes),
                ),
                // Indicador de carregamento
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}
