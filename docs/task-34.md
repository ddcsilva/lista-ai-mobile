# Task 34 — Item Card

**Fase**: UI  
**Dependências**: Task 32 (ListaPage), Task 18/19 (ListaStore)  
**Resultado**: Widget de cada item da lista com ações (comprar, editar, excluir, favoritar)

---

## Passo 1: Criar ItemCard widget

Criar `lib/features/lista/ui/widgets/item_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/lista_store.dart';
import '../../../../application/favoritos_service.dart';
import '../../../../domain/models/item_lista.dart';
import '../../../../domain/models/categoria_item.dart';

class ItemCard extends ConsumerStatefulWidget {
  final ItemLista item;
  final bool isComprado;

  const ItemCard({
    super.key,
    required this.item,
    required this.isComprado,
  });

  @override
  ConsumerState<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends ConsumerState<ItemCard> {
  bool _isEditing = false;
  late TextEditingController _nomeController;
  late TextEditingController _qtdController;
  late TextEditingController _notaController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.item.nome);
    _qtdController = TextEditingController(text: widget.item.quantidade.toString());
    _notaController = TextEditingController(text: widget.item.nota ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _qtdController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;

    if (_isEditing) {
      return _buildEditMode(theme, colorScheme);
    }

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmarExclusao(context),
      onDismissed: (_) => _excluirItem(),
      child: ListTile(
        leading: Checkbox(
          value: item.comprado,
          onChanged: (_) => _toggleComprado(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          item.nome,
          style: TextStyle(
            decoration: item.comprado ? TextDecoration.lineThrough : null,
            color: item.comprado
                ? colorScheme.onSurfaceVariant.withOpacity(0.6)
                : colorScheme.onSurface,
          ),
        ),
        subtitle: _buildSubtitle(item, theme),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge quantidade
            if (item.quantidade > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'x${item.quantidade}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            // Favoritar
            IconButton(
              icon: Icon(
                _isFavorito() ? Icons.star : Icons.star_border,
                color: _isFavorito() ? Colors.amber : null,
                size: 20,
              ),
              onPressed: _toggleFavorito,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        onTap: () => setState(() => _isEditing = true),
      ),
    );
  }

  Widget? _buildSubtitle(ItemLista item, ThemeData theme) {
    if (item.nota == null || item.nota!.isEmpty) return null;
    return Text(
      item.nota!,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEditMode(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nome
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                isDense: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Quantidade
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _qtdController,
                    decoration: const InputDecoration(
                      labelText: 'Qtd',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                // Nota
                Expanded(
                  child: TextField(
                    controller: _notaController,
                    decoration: const InputDecoration(
                      labelText: 'Nota (opcional)',
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _salvarEdicao,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleComprado() {
    final store = ref.read(listaStoreProvider.notifier);
    store.toggleComprado(widget.item.id);
  }

  bool _isFavorito() {
    final favoritos = ref.watch(favoritosServiceProvider);
    return favoritos.isFavorito(widget.item.nome);
  }

  void _toggleFavorito() {
    final favoritos = ref.read(favoritosServiceProvider);
    favoritos.toggle(widget.item.nome);
  }

  void _salvarEdicao() {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    final qtd = int.tryParse(_qtdController.text) ?? 1;
    final nota = _notaController.text.trim();

    final store = ref.read(listaStoreProvider.notifier);
    store.editarItem(
      itemId: widget.item.id,
      nome: nome,
      quantidade: qtd.clamp(1, 99),
      nota: nota.isEmpty ? null : nota,
    );

    setState(() => _isEditing = false);
  }

  Future<bool?> _confirmarExclusao(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir item?'),
        content: Text('Remover "${widget.item.nome}" da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _excluirItem() {
    final store = ref.read(listaStoreProvider.notifier);
    store.removerItem(widget.item.id);
  }
}
```

---

## ✅ Checklist de Conclusão

- [ ] Checkbox para marcar/desmarcar como comprado
- [ ] Nome do item com strikethrough quando comprado
- [ ] Badge "x2" para quantidade > 1
- [ ] Nota exibida como subtitle italic
- [ ] Estrela para favoritar/desfavoritar
- [ ] Tap no item → modo edição inline
- [ ] Modo edição: campos nome, qtd, nota + salvar/cancelar
- [ ] Swipe left → excluir com confirmação
- [ ] Dismissible com background vermelha
- [ ] Validação (nome obrigatório, qtd 1-99)
