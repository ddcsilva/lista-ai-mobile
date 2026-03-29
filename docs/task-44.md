# Task 44 — Confirm Dialog Reutilizável

**Fase**: UI (Utilitário)  
**Dependências**: Nenhuma  
**Resultado**: Dialog de confirmação genérico para ações destrutivas

---

## Passo 1: Criar ConfirmDialog

Criar `lib/shared/ui/confirm_dialog.dart`:

```dart
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final String textoCancelar;
  final String textoConfirmar;
  final bool isDanger;

  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensagem,
    this.textoCancelar = 'Cancelar',
    this.textoConfirmar = 'Confirmar',
    this.isDanger = false,
  });

  /// Mostra o dialog e retorna true se confirmado
  static Future<bool> show(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String textoCancelar = 'Cancelar',
    String textoConfirmar = 'Confirmar',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        titulo: titulo,
        mensagem: mensagem,
        textoCancelar: textoCancelar,
        textoConfirmar: textoConfirmar,
        isDanger: isDanger,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(textoCancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: isDanger
              ? FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                )
              : null,
          child: Text(textoConfirmar),
        ),
      ],
    );
  }
}
```

---

## Passo 2: Exemplo de uso

```dart
// Em qualquer widget:
final confirmou = await ConfirmDialog.show(
  context,
  titulo: 'Excluir lista?',
  mensagem: 'Esta ação não pode ser desfeita.',
  textoConfirmar: 'Excluir',
  isDanger: true,
);

if (confirmou) {
  // executar ação
}
```

---

## Passo 3: Substituir confirmações existentes

Refatorar os locais que já usam `showDialog<bool>` inline para usar `ConfirmDialog.show()`:

- `item_card.dart` — confirmação de exclusão
- `modo_mercado_bar.dart` — desmarcar todos
- `share_lista_dialog.dart` — remover membro

---

## ✅ Checklist de Conclusão

- [ ] Dialog genérico com título, mensagem, ações
- [ ] Método estático `show()` retorna bool
- [ ] Modo `isDanger` com botão vermelho
- [ ] Textos customizáveis (cancelar/confirmar)
- [ ] Usado nos 3+ locais existentes
