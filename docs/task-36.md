# Task 36 — Empty State

**Fase**: UI  
**Dependências**: Task 32 (ListaPage)  
**Resultado**: Widget de estado vazio reutilizável

---

## Passo 1: Criar EmptyState widget

Criar `lib/features/lista/ui/widgets/empty_state.dart`:

```dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String mensagem;
  final IconData icone;
  final String? subtitulo;
  final Widget? acao;

  const EmptyState({
    super.key,
    required this.mensagem,
    required this.icone,
    this.subtitulo,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 72,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitulo!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (acao != null) ...[
              const SizedBox(height: 24),
              acao!,
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## ✅ Checklist de Conclusão

- [ ] Ícone grande centralizado
- [ ] Mensagem principal
- [ ] Subtítulo opcional
- [ ] Widget de ação opcional (ex: botão)
- [ ] Cores suaves (onSurfaceVariant)
