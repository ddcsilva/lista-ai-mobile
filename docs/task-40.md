# Task 40 — Share / Export Dialog

**Fase**: UI  
**Dependências**: Task 22 (ExportService), Task 31 (AppShell)  
**Resultado**: Opção de exportar lista formatada e compartilhar via share nativo

---

## Passo 1: Criar ExportDialog

Criar `lib/features/lista/ui/dialogs/export_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../application/export_service.dart';
import '../../../../application/lista_store.dart';

class ExportDialog extends ConsumerWidget {
  const ExportDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => const ExportDialog(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(listaStoreProvider);
    final lista = store.listaAtual;
    
    if (lista == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Text('Nenhuma lista carregada'),
      );
    }
    
    final exportService = ref.read(exportServiceProvider);
    final textoFormatado = exportService.exportar(lista);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exportar Lista',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Preview
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  textoFormatado,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: textoFormatado));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copiado!')),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Share.share(
                        textoFormatado,
                        subject: 'Lista de Compras',
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Compartilhar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Passo 2: Conectar no AppShell

Atualizar o handler do menu na `app_shell.dart`:

```dart
case 'exportar':
  if (context.mounted) {
    ExportDialog.show(context);
  }
  break;
```

E no botão de compartilhar da AppBar:

```dart
IconButton(
  icon: const Icon(Icons.share_outlined),
  onPressed: () => ExportDialog.show(context),
  tooltip: 'Compartilhar',
),
```

---

## Passo 3: Verificar ExportService formatação

O `export_service.dart` deve gerar texto tipo:

```
🛒 Lista de Compras

🥬 Hortifruti
  ☐ Banana x3
  ☐ Tomate x2
  
🥛 Laticínios
  ☐ Leite
  ☑ Queijo

✅ 1/4 comprados
```

---

## ✅ Checklist de Conclusão

- [ ] Bottom sheet com preview do texto formatado
- [ ] Botão "Copiar" → clipboard
- [ ] Botão "Compartilhar" → share_plus nativo
- [ ] Formatação com emojis por categoria
- [ ] SnackBar confirmando "Copiado!"
- [ ] Conectado no menu popup + botão AppBar
