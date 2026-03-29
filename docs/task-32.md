# Task 32 — Lista Page (Container Principal)

**Fase**: UI  
**Dependências**: Task 31 (AppShell), Task 18/19 (ListaStore)  
**Resultado**: Tela principal que exibe a lista de compras com itens agrupados

---

## Passo 1: Criar providers da Lista

Criar `lib/features/lista/providers/lista_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/lista_store.dart';
import '../../../domain/models/lista_compras.dart';
import '../../../domain/models/item_lista.dart';
import '../../../domain/models/categoria_item.dart';

// Provider principal — reexporta o listaStoreProvider da Task 19
// Conveniente ter num lugar só para os widgets importarem

/// Itens não comprados, agrupados por categoria
final itensNaoCompradosPorCategoriaProvider = Provider<Map<CategoriaItem, List<ItemLista>>>((ref) {
  final store = ref.watch(listaStoreProvider);
  final lista = store.listaAtual;
  if (lista == null) return {};

  final itens = lista.itens.where((i) => !i.comprado).toList();
  final mapa = <CategoriaItem, List<ItemLista>>{};
  
  for (final item in itens) {
    mapa.putIfAbsent(item.categoria, () => []).add(item);
  }
  
  // Ordena por ordem da enum (mesma ordem do Angular)
  final ordenado = Map.fromEntries(
    mapa.entries.toList()
      ..sort((a, b) => a.key.index.compareTo(b.key.index)),
  );
  
  return ordenado;
});

/// Itens comprados
final itensCompradosProvider = Provider<List<ItemLista>>((ref) {
  final store = ref.watch(listaStoreProvider);
  final lista = store.listaAtual;
  if (lista == null) return [];
  return lista.itens.where((i) => i.comprado).toList();
});

/// Progresso da lista
final progressoProvider = Provider<({int total, int comprados, double percentual})>((ref) {
  final store = ref.watch(listaStoreProvider);
  final lista = store.listaAtual;
  if (lista == null) return (total: 0, comprados: 0, percentual: 0);
  
  final total = lista.itens.length;
  final comprados = lista.itens.where((i) => i.comprado).length;
  final percentual = total > 0 ? comprados / total : 0.0;
  
  return (total: total, comprados: comprados, percentual: percentual);
});
```

---

## Passo 2: Implementar ListaPage

Atualizar `lib/features/lista/ui/lista_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/lista_store.dart';
import '../../../domain/models/categoria_item.dart';
import '../providers/lista_providers.dart';
import 'widgets/item_form.dart';
import 'widgets/item_card.dart';
import 'widgets/lista_summary.dart';
import 'widgets/empty_state.dart';
import 'widgets/category_header.dart';

class ListaPage extends ConsumerStatefulWidget {
  final String? listaId;
  
  const ListaPage({super.key, this.listaId});
  
  @override
  ConsumerState<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends ConsumerState<ListaPage> {
  @override
  void initState() {
    super.initState();
    // Carregar lista ao entrar na page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(listaStoreProvider.notifier);
      if (widget.listaId != null) {
        store.carregarLista(widget.listaId!);
      } else {
        store.carregarListaPadrao();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(listaStoreProvider);
    final itensPorCategoria = ref.watch(itensNaoCompradosPorCategoriaProvider);
    final itensComprados = ref.watch(itensCompradosProvider);
    final progresso = ref.watch(progressoProvider);
    
    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (store.listaAtual == null) {
      return const EmptyState(
        mensagem: 'Nenhuma lista encontrada',
        icone: Icons.shopping_cart_outlined,
      );
    }
    
    return Column(
      children: [
        // Resumo progresso
        if (progresso.total > 0)
          ListaSummary(
            total: progresso.total,
            comprados: progresso.comprados,
            percentual: progresso.percentual,
          ),
        
        // Formulário de adicionar item
        const ItemForm(),
        
        // Lista de itens
        Expanded(
          child: progresso.total == 0
              ? const EmptyState(
                  mensagem: 'Lista vazia!\nAdicione itens usando o campo acima ou o microfone',
                  icone: Icons.add_shopping_cart,
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    // Itens não comprados agrupados por categoria
                    ...itensPorCategoria.entries.map(
                      (entry) => _buildCategoriaGroup(entry.key, entry.value),
                    ),
                    
                    // Divider + itens comprados
                    if (itensComprados.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Comprados (${itensComprados.length})',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...itensComprados.map(
                        (item) => ItemCard(
                          item: item,
                          isComprado: true,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCategoriaGroup(CategoriaItem categoria, List<ItemLista> itens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryHeader(categoria: categoria, quantidade: itens.length),
        ...itens.map((item) => ItemCard(item: item, isComprado: false)),
      ],
    );
  }
}
```

---

## Passo 3: Criar CategoryHeader widget

Criar `lib/features/lista/ui/widgets/category_header.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../domain/models/categoria_item.dart';

class CategoryHeader extends StatelessWidget {
  final CategoriaItem categoria;
  final int quantidade;

  const CategoryHeader({
    super.key,
    required this.categoria,
    required this.quantidade,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            categoria.emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            categoria.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($quantidade)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ Checklist de Conclusão

- [ ] Providers: itens por categoria, comprados, progresso
- [ ] ListaPage carrega lista no initState
- [ ] Loading state com CircularProgressIndicator
- [ ] Lista agrupada por categoria com headers
- [ ] Seção "Comprados" colapsável
- [ ] Empty state quando lista vazia
- [ ] Summary bar com progresso
- [ ] CategoryHeader com emoji + label + contagem
