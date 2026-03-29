# Task 35 — Lista Summary (Barra de Progresso)

**Fase**: UI  
**Dependências**: Task 32 (ListaPage providers)  
**Resultado**: Barra de progresso mostrando itens comprados / total

---

## Passo 1: Criar ListaSummary widget

Criar `lib/features/lista/ui/widgets/lista_summary.dart`:

```dart
import 'package:flutter/material.dart';

class ListaSummary extends StatelessWidget {
  final int total;
  final int comprados;
  final double percentual;

  const ListaSummary({
    super.key,
    required this.total,
    required this.comprados,
    required this.percentual,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final todosComprados = total > 0 && comprados == total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: todosComprados
            ? colorScheme.primaryContainer.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Texto de progresso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                todosComprados
                    ? '✅ Compras concluídas!'
                    : '$comprados de $total itens comprados',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: todosComprados
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
              Text(
                '${(percentual * 100).toInt()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: todosComprados
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentual,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: todosComprados
                  ? colorScheme.primary
                  : colorScheme.secondary,
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

- [ ] Texto "X de Y itens comprados"
- [ ] Percentual numérico
- [ ] Barra de progresso linear
- [ ] Estado "Compras concluídas!" quando 100%
- [ ] Cores diferenciadas para completo/incompleto
