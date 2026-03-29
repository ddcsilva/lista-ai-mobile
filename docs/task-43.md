# Task 43 — Text Import Dialog

**Fase**: UI  
**Dependências**: Task 23 (TextImportService), Task 31 (AppShell)  
**Resultado**: Dialog para importar vários itens colando texto

---

## Passo 1: Criar TextImportDialog

Criar `lib/features/lista/ui/dialogs/text_import_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/text_import_service.dart';
import '../../../../application/lista_store.dart';

class TextImportDialog extends ConsumerStatefulWidget {
  const TextImportDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const TextImportDialog(),
    );
  }

  @override
  ConsumerState<TextImportDialog> createState() => _TextImportDialogState();
}

class _TextImportDialogState extends ConsumerState<TextImportDialog> {
  final _controller = TextEditingController();
  List<String> _preview = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.text_snippet_outlined),
          const SizedBox(width: 8),
          const Text('Importar Texto'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cole ou digite itens, um por linha:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            
            // Campo de texto
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '2 leite\nPão francês\n3 banana\nQueijo minas',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              onChanged: (_) => _atualizarPreview(),
            ),
            const SizedBox(height: 8),

            // Preview
            if (_preview.isNotEmpty) ...[
              Text(
                '${_preview.length} item(s) detectado(s):',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _preview.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        '• ${_preview[index]}',
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 8),
            Text(
              'Dica: "2 leite" será interpretado como 2 unidades de leite',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _preview.isEmpty ? null : _importar,
          child: Text('Importar ${_preview.length} itens'),
        ),
      ],
    );
  }

  void _atualizarPreview() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) {
      setState(() => _preview = []);
      return;
    }

    final linhas = texto
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    setState(() => _preview = linhas);
  }

  void _importar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    final importService = ref.read(textImportServiceProvider);
    final store = ref.read(listaStoreProvider.notifier);

    final itens = importService.importar(texto);
    
    for (final item in itens) {
      store.adicionarItem(
        nome: item.nome,
        quantidade: item.quantidade,
        categoria: item.categoria,
      );
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${itens.length} itens importados!')),
    );
  }
}
```

---

## Passo 2: Conectar no AppShell

No menu popup handler da `app_shell.dart`:

```dart
case 'importar':
  if (context.mounted) {
    TextImportDialog.show(context);
  }
  break;
```

---

## ✅ Checklist de Conclusão

- [ ] Dialog com TextField multilinha
- [ ] Preview: contagem de itens detectados
- [ ] Lista dos itens em preview
- [ ] Botão "Importar X itens" (desabilitado se vazio)  
- [ ] Parse inteligente (quantidade + nome)
- [ ] SnackBar confirmação
- [ ] Hint com exemplo
- [ ] Dica sobre formato "2 leite"
