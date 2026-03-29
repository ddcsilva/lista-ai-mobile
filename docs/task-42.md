# Task 42 — Convite Pendente Card

**Fase**: UI  
**Dependências**: Task 26 (CompartilhamentoService), Task 31 (AppShell)  
**Resultado**: Card exibido quando há convite pendente para aceitar/recusar

---

## Passo 1: Criar provider de convites pendentes

Em `lib/features/lista/providers/convite_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/compartilhamento_service.dart';
import '../../../core/auth/auth_service.dart';
import '../../../domain/models/convite.dart';

/// Stream de convites pendentes para o usuário logado
final convitesPendentesProvider = StreamProvider<List<Convite>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value([]);
  
  final compartilhamento = ref.read(compartilhamentoServiceProvider);
  return compartilhamento.observarConvitesPendentes(auth.email!);
});
```

---

## Passo 2: Criar ConvitePendenteCard widget

Criar `lib/features/lista/ui/widgets/convite_pendente_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/compartilhamento_service.dart';
import '../../../../domain/models/convite.dart';
import '../providers/convite_providers.dart';

class ConvitePendenteCard extends ConsumerWidget {
  const ConvitePendenteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convitesAsync = ref.watch(convitesPendentesProvider);

    return convitesAsync.when(
      data: (convites) {
        if (convites.isEmpty) return const SizedBox.shrink();
        return Column(
          children: convites.map(
            (c) => _ConviteCard(convite: c),
          ).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ConviteCard extends ConsumerStatefulWidget {
  final Convite convite;
  const _ConviteCard({required this.convite});

  @override
  ConsumerState<_ConviteCard> createState() => _ConviteCardState();
}

class _ConviteCardState extends ConsumerState<_ConviteCard> {
  bool _isProcessando = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final convite = widget.convite;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: colorScheme.secondaryContainer.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mail_outline,
                  color: colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Convite para lista compartilhada',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'De: ${convite.nomeConvidante ?? convite.emailConvidante}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Lista: ${convite.nomeLista ?? convite.listaId}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            
            if (_isProcessando)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _responder(false),
                    child: const Text('Recusar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _responder(true),
                    child: const Text('Aceitar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _responder(bool aceitar) async {
    setState(() => _isProcessando = true);

    try {
      final compartilhamento = ref.read(compartilhamentoServiceProvider);
      
      if (aceitar) {
        await compartilhamento.aceitarConvite(widget.convite.id);
      } else {
        await compartilhamento.recusarConvite(widget.convite.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              aceitar ? 'Convite aceito!' : 'Convite recusado',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessando = false);
    }
  }
}
```

---

## Passo 3: Integrar na ListaPage

Adicionar no topo da lista, antes do ItemForm:

```dart
Column(
  children: [
    ListaSummary(...),
    const ConvitePendenteCard(), // ← convites pendentes
    const ItemForm(),
    Expanded(child: ListView(...)),
    const ModoMercadoBar(),
  ],
)
```

---

## ✅ Checklist de Conclusão

- [ ] Stream de convites pendentes via provider
- [ ] Card com info do convite (remetente, lista)
- [ ] Botão "Aceitar" / "Recusar"
- [ ] Loading durante processamento
- [ ] SnackBar de feedback
- [ ] Card some automaticamente após resposta (stream atualiza)
- [ ] Card não aparece quando não há convites
