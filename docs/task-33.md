# Task 33 — Item Form (Input Manual)

**Fase**: UI  
**Dependências**: Task 32 (ListaPage), Task 17 (CommandParser)  
**Resultado**: Campo de entrada de itens com parsing inteligente

---

## Passo 1: Criar ItemForm widget

Criar `lib/features/lista/ui/widgets/item_form.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/lista_store.dart';
import '../../../../application/command_parser_service.dart';
import '../../../../application/favoritos_service.dart';
import '../../../../application/historico_service.dart';
import '../../../../domain/models/item_lista.dart';
import '../../../../domain/models/categoria_item.dart';

class ItemForm extends ConsumerStatefulWidget {
  const ItemForm({super.key});

  @override
  ConsumerState<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends ConsumerState<ItemForm> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _sugestoes = [];
  bool _mostrarSugestoes = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Campo de entrada
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Adicionar item... (ex: 2 leite)',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(Icons.add),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _mostrarSugestoes = false);
                            },
                          )
                        : null,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onChanged: _onTextChanged,
                  onSubmitted: (_) => _adicionarItem(),
                ),
              ),
              const SizedBox(width: 8),
              
              // Botão Mic (será habilitado na Task 42)
              IconButton.filled(
                icon: const Icon(Icons.mic),
                onPressed: () {
                  // TODO: Task 42 - voice input
                },
                tooltip: 'Entrada por voz',
              ),
            ],
          ),
        ),

        // Lista de sugestões (autocomplete)
        if (_mostrarSugestoes && _sugestoes.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _sugestoes.length,
              itemBuilder: (context, index) {
                final sugestao = _sugestoes[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.history, size: 18),
                  title: Text(sugestao),
                  onTap: () => _selecionarSugestao(sugestao),
                );
              },
            ),
          ),
      ],
    );
  }

  void _onTextChanged(String texto) {
    setState(() {});
    
    if (texto.length < 2) {
      setState(() {
        _sugestoes = [];
        _mostrarSugestoes = false;
      });
      return;
    }
    
    // Buscar sugestões de favoritos + histórico
    final favoritos = ref.read(favoritosServiceProvider);
    final historico = ref.read(historicoServiceProvider);
    
    final textoLower = texto.toLowerCase();
    final sugestoesFav = favoritos.buscar(textoLower);
    final sugestoesHist = historico.buscar(textoLower);
    
    // Merge sem duplicatas, favoritos primeiro
    final todas = <String>{...sugestoesFav, ...sugestoesHist}.toList();
    
    setState(() {
      _sugestoes = todas.take(5).toList();
      _mostrarSugestoes = todas.isNotEmpty;
    });
  }

  void _selecionarSugestao(String sugestao) {
    _controller.text = sugestao;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: sugestao.length),
    );
    setState(() => _mostrarSugestoes = false);
    _adicionarItem();
  }

  void _adicionarItem() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    // Parser interpreta "2 leite" → {nome: "leite", quantidade: 2}
    final parser = ref.read(commandParserServiceProvider);
    final resultado = parser.parse(texto);

    // Adicionar à lista via store
    final store = ref.read(listaStoreProvider.notifier);
    store.adicionarItem(
      nome: resultado.nome,
      quantidade: resultado.quantidade,
      categoria: resultado.categoria,
      nota: resultado.nota,
    );

    // Salvar no histórico
    ref.read(historicoServiceProvider).adicionar(resultado.nome);

    // Limpar campo
    _controller.clear();
    setState(() {
      _sugestoes = [];
      _mostrarSugestoes = false;
    });
    
    // Manter foco no campo
    _focusNode.requestFocus();
  }
}
```

---

## Passo 2: Garantir que CommandParser retorna dados estruturados

Verificar no `command_parser_service.dart` que o método `parse()` retorna:

```dart
class ParseResult {
  final String nome;
  final int quantidade;
  final CategoriaItem? categoria;
  final String? nota;
  
  ParseResult({
    required this.nome,
    this.quantidade = 1,
    this.categoria,
    this.nota,
  });
}
```

---

## Passo 3: Garantir que FavoritosService e HistoricoService têm método `buscar`

```dart
// No FavoritosService:
List<String> buscar(String texto) {
  return _favoritos
      .where((f) => f.toLowerCase().contains(texto))
      .toList();
}

// No HistoricoService:
List<String> buscar(String texto) {
  return _historico
      .where((h) => h.toLowerCase().contains(texto))
      .toList();
}
```

---

## ✅ Checklist de Conclusão

- [ ] TextField com hint "Adicionar item..."
- [ ] Parse inteligente: "2 leite" → nome: leite, qtd: 2
- [ ] Autocomplete com favoritos + histórico
- [ ] Máximo 5 sugestões
- [ ] Selecionar sugestão adiciona item
- [ ] Clear button quando há texto
- [ ] Enter/Submit adiciona item
- [ ] Foco mantido após adicionar
- [ ] Botão mic (placeholder para Task 42)
- [ ] Salvar no histórico ao adicionar
