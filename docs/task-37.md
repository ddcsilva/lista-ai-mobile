# Task 37 — Modo Mercado (Wake Lock + Bottom Bar)

**Fase**: UI  
**Dependências**: Task 32 (ListaPage), Task 25 (TTS)  
**Resultado**: Modo mercado que mantém tela ligada e exibe barra inferior com ações rápidas

---

## Passo 1: Criar provider para modo mercado

Criar `lib/features/lista_compras/application/modo_mercado_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'modo_mercado_provider.g.dart';

@riverpod
class ModoMercado extends _$ModoMercado {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void ativar() => state = true;
  void desativar() => state = false;
}
```

---

## Passo 2: Criar ModoMercadoBar widget

Criar `lib/features/lista/ui/widgets/modo_mercado_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../application/lista_store.dart';
import '../../../../application/tts_service.dart';

class ModoMercadoBar extends ConsumerStatefulWidget {
  const ModoMercadoBar({super.key});

  @override
  ConsumerState<ModoMercadoBar> createState() => _ModoMercadoBarState();
}

class _ModoMercadoBarState extends ConsumerState<ModoMercadoBar> {
  bool _ativo = false;

  @override
  void dispose() {
    if (_ativo) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _ativo
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Toggle modo mercado
            Expanded(
              child: InkWell(
                onTap: _toggleModoMercado,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        _ativo ? Icons.shopping_bag : Icons.shopping_bag_outlined,
                        color: _ativo ? colorScheme.primary : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _ativo ? 'No mercado' : 'Modo mercado',
                        style: TextStyle(
                          color: _ativo ? colorScheme.primary : null,
                          fontWeight: _ativo ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botão TTS - ler lista
            IconButton(
              icon: const Icon(Icons.volume_up_outlined),
              onPressed: _lerLista,
              tooltip: 'Ler lista em voz alta',
            ),

            // Botão desmarcar todos
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: _desmarcarTodos,
              tooltip: 'Desmarcar todos',
            ),
          ],
        ),
      ),
    );
  }

  void _toggleModoMercado() {
    setState(() => _ativo = !_ativo);
    
    if (_ativo) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void _lerLista() {
    ref.read(ttsNotifierProvider.notifier).toggle(listaId: widget.listaId);
  }

  void _desmarcarTodos() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desmarcar todos?'),
        content: const Text('Todos os itens serão desmarcados como não comprados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desmarcar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      ref.read(itemNotifierProvider.notifier).limparComprados(
        listaId: widget.listaId,
      );
    }
  }
}
```

---

## Passo 3: Integrar na ListaPage

No `lista_page.dart`, adicionar a barra no final do Column:

```dart
// Dentro do build da ListaPage, no final do Column:
const ModoMercadoBar(),
```

A estrutura fica:
```dart
Column(
  children: [
    ListaSummary(...),
    ItemForm(),
    Expanded(child: ListView(...)),
    const ModoMercadoBar(), // ← adicionar aqui
  ],
)
```

---

## ✅ Checklist de Conclusão

- [ ] Toggle modo mercado ativa/desativa wake lock
- [ ] Visual diferenciado quando ativo (cor, ícone preenchido)
- [ ] Botão "Ler lista" (TTS)
- [ ] Botão "Desmarcar todos" com confirmação
- [ ] Wake lock desativado no dispose
- [ ] Barra na parte inferior da tela
- [ ] SafeArea para evitar conflito com nav bar do sistema
