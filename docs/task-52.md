# Task 52 — Acessibilidade (Semantics + a11y)

**Fase**: UI (Cross-cutting)  
**Dependências**: Task 29-40 (telas construídas)  
**Resultado**: App acessível com TalkBack (Android) e VoiceOver (iOS)

---

## Contexto

Flutter não gera semântica acessível automaticamente para widgets custom. Precisamos adicionar `Semantics`, labels e hints em todos os elementos interativos.

---

## Passo 1: Regras gerais de acessibilidade

### 1.1 Botões e ícones

Todo `IconButton` DEVE ter `tooltip`:

```dart
// ❌ ERRADO
IconButton(icon: Icon(Icons.delete), onPressed: _excluir)

// ✅ CORRETO
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: _excluir,
  tooltip: 'Excluir item',
)
```

### 1.2 Imagens e ícones decorativos

```dart
// Ícone informativo — precisa de semântica
Semantics(
  label: 'Item comprado',
  child: Icon(Icons.check_circle, color: Colors.green),
)

// Ícone decorativo — excluir da árvore semântica
ExcludeSemantics(
  child: Icon(Icons.arrow_forward),
)
```

### 1.3 Listas e cards

```dart
Semantics(
  label: 'Lista Supermercado, 5 itens pendentes, 3 comprados',
  child: ListaCard(lista: lista),
)
```

---

## Passo 2: Checklist por tela

### HomePage
```dart
Semantics(
  label: 'Criar nova lista de compras',
  child: FloatingActionButton(
    onPressed: _criarLista,
    tooltip: 'Nova lista',
    child: const Icon(Icons.add),
  ),
)
```

### ItemTile (checkbox de item)
```dart
Semantics(
  label: '${item.nome}, ${item.comprado ? "comprado" : "pendente"}',
  hint: 'Toque duas vezes para ${item.comprado ? "desmarcar" : "marcar como comprado"}',
  child: CheckboxListTile(
    value: item.comprado,
    title: Text(item.nome),
    onChanged: (_) => _toggleComprado(item),
  ),
)
```

### VoiceInputButton
```dart
Semantics(
  label: state.gravando 
      ? 'Gravando. Toque para parar.'
      : 'Adicionar itens por voz',
  hint: 'Toque duas vezes para ${state.gravando ? "parar gravação" : "iniciar gravação de voz"}',
  child: ...,
)
```

### Badge de convites
```dart
Semantics(
  label: '$total convites pendentes',
  child: Badge(
    label: Text('$total'),
    child: const Icon(Icons.mail_outline),
  ),
)
```

---

## Passo 3: Tamanhos mínimos de toque

Material 3 define tamanho mínimo de 48x48dp para alvos de toque:

```dart
// Garantir tamanho mínimo:
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(
    icon: const Icon(Icons.star),
    onPressed: _toggleFavorito,
    tooltip: 'Favoritar',
  ),
)
```

> **Dica**: `IconButton` já garante 48x48 por padrão no Material 3.
> Mas widgets custom podem precisar de ajuste.

---

## Passo 4: Contraste de cores

Verificar razão de contraste mínima (WCAG AA):
- Texto normal: 4.5:1
- Texto grande (18sp+): 3:1

```dart
// No AppTheme, verificar que cores de texto sobre backgrounds atendem contraste:
// Usar ferramentas: flutter_accessibility_service, ou Developer Options > Color correction
```

---

## Passo 5: Ordem de foco

Garantir que elementos focáveis seguem ordem lógica de leitura:

```dart
// Para forçar ordem específica:
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      FocusTraversalOrder(
        order: const NumericFocusOrder(1),
        child: TextField(decoration: const InputDecoration(labelText: 'Nome da lista')),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(2),
        child: ElevatedButton(onPressed: _criar, child: const Text('Criar')),
      ),
    ],
  ),
)
```

---

## Passo 6: Teste de acessibilidade

```dart
// No widget test:
testWidgets('lista card has correct semantics', (tester) async {
  await tester.pumpWidget(/* ... */);
  
  expect(
    tester.getSemantics(find.byType(ListaCard)),
    matchesSemantics(
      label: 'Lista Supermercado, 5 itens pendentes',
      hasTapAction: true,
    ),
  );
});
```

E testar manualmente:
1. Android: Settings > Accessibility > TalkBack → ON
2. iOS: Settings > Accessibility > VoiceOver → ON
3. Navegar pelo app usando gestos de swipe

---

## ✅ Checklist de Conclusão

- [ ] Todo `IconButton` tem `tooltip`
- [ ] Ícones informativos têm `Semantics(label:)`
- [ ] Ícones decorativos têm `ExcludeSemantics`
- [ ] Cards de lista têm semântica descritiva
- [ ] CheckboxListTile dos itens tem label + hint
- [ ] Botão de voz tem estado descrito (gravando/parado)
- [ ] Badge de convites anuncia contagem
- [ ] FAB tem `tooltip` e `Semantics`
- [ ] Alvos de toque ≥ 48x48dp
- [ ] Contraste de cores ≥ 4.5:1 (WCAG AA)
- [ ] Ordem de foco lógica
- [ ] Testes de semântica em widget tests
- [ ] Teste manual com TalkBack/VoiceOver
