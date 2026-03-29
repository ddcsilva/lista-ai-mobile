# Task 41 — Compartilhamento Dialog (Convites)

**Fase**: UI  
**Dependências**: Task 26 (CompartilhamentoService), Task 31 (AppShell)  
**Resultado**: Dialog para compartilhar lista com outros usuários via convite por email

---

## Passo 1: Criar ShareListaDialog

Criar `lib/features/lista/ui/dialogs/share_lista_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/compartilhamento_service.dart';
import '../../../../application/lista_store.dart';
import '../../../../domain/models/membro_lista.dart';
import '../../../../domain/models/convite.dart';

class ShareListaDialog extends ConsumerStatefulWidget {
  const ShareListaDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ShareListaDialog(),
    );
  }

  @override
  ConsumerState<ShareListaDialog> createState() => _ShareListaDialogState();
}

class _ShareListaDialogState extends ConsumerState<ShareListaDialog> {
  final _emailController = TextEditingController();
  bool _isEnviando = false;
  String? _erro;
  String? _sucesso;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = ref.watch(listaStoreProvider);
    final lista = store.listaAtual;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.group_add_outlined),
          const SizedBox(width: 8),
          const Text('Compartilhar Lista'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Membros atuais
            if (lista != null && lista.membros.isNotEmpty) ...[
              Text(
                'Membros (${lista.membros.length})',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...lista.membros.map((m) => _buildMembroTile(m)),
              const Divider(height: 24),
            ],

            // Campo email para convidar
            Text(
              'Convidar por e-mail',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'email@exemplo.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isEnviando ? null : _enviarConvite,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onSubmitted: (_) => _enviarConvite(),
            ),

            // Feedback
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _erro!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            if (_sucesso != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _sucesso!,
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ),

            // Loading
            if (_isEnviando)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),

            // Info limites
            const SizedBox(height: 12),
            Text(
              'Máximo 5 membros por lista\nConvites expiram em 24h',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildMembroTile(MembroLista membro) {
    final isDono = membro.papel == PapelMembro.dono;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        child: Text(
          (membro.nome ?? membro.email ?? '?')[0].toUpperCase(),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      title: Text(membro.nome ?? membro.email ?? 'Membro'),
      subtitle: membro.email != null ? Text(membro.email!) : null,
      trailing: isDono
          ? Chip(
              label: const Text('Dono'),
              labelStyle: const TextStyle(fontSize: 11),
              visualDensity: VisualDensity.compact,
            )
          : IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              onPressed: () => _removerMembro(membro),
              tooltip: 'Remover',
            ),
    );
  }

  Future<void> _enviarConvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _erro = 'E-mail inválido');
      return;
    }

    setState(() {
      _isEnviando = true;
      _erro = null;
      _sucesso = null;
    });

    try {
      final compartilhamento = ref.read(compartilhamentoServiceProvider);
      final store = ref.read(listaStoreProvider);
      
      await compartilhamento.enviarConvite(
        listaId: store.listaAtual!.id,
        emailConvidado: email,
      );

      _emailController.clear();
      setState(() {
        _sucesso = 'Convite enviado para $email';
      });
    } catch (e) {
      setState(() {
        _erro = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _isEnviando = false);
    }
  }

  Future<void> _removerMembro(MembroLista membro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover membro?'),
        content: Text('Remover ${membro.nome ?? membro.email} da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final compartilhamento = ref.read(compartilhamentoServiceProvider);
        await compartilhamento.removerMembro(
          listaId: ref.read(listaStoreProvider).listaAtual!.id,
          membroUid: membro.uid,
        );
      } catch (e) {
        if (mounted) {
          setState(() => _erro = e.toString().replaceAll('Exception: ', ''));
        }
      }
    }
  }
}
```

---

## ✅ Checklist de Conclusão

- [ ] Dialog com lista de membros atuais
- [ ] Badge "Dono" no proprietário
- [ ] Campo de email para convidar
- [ ] Enviar convite com feedback (sucesso/erro)
- [ ] Loading indicator durante envio
- [ ] Remover membro com confirmação
- [ ] Info de limites (5 membros, 24h expiração)
- [ ] Validação de email
