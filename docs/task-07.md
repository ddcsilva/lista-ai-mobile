# Task 07 — Criar Regras de Negócio: Item Rules

**Fase**: Domain Layer  
**Dependências**: Task 04, Task 05, Task 10 (id_generator)  
**Resultado**: Funções de validação e criação de itens

---

## Contexto

Estas regras são funções puras que validam e criam itens. Idênticas à versão Angular.

---

## Passo 1: Criar item_rules.dart

Criar `lib/features/lista_compras/domain/rules/item_rules.dart`:

```dart
import '../models/categoria_item.dart';
import '../models/item_lista.dart';
import '../../../../shared/utils/id_generator.dart';

/// Valida o nome do item: não vazio, máx 100 caracteres.
/// Retorna o nome trimado ou lança exceção.
String validarNomeItem(String nome) {
  final trimmed = nome.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('Nome do item não pode ser vazio');
  }
  if (trimmed.length > 100) {
    return trimmed.substring(0, 100);
  }
  return trimmed;
}

/// Valida a quantidade: inteiro entre 1 e 99.
/// Retorna a quantidade validada ou lança exceção.
int validarQuantidade(int qtd) {
  if (qtd < 1 || qtd > 99) {
    throw ArgumentError('Quantidade deve ser um inteiro entre 1 e 99');
  }
  return qtd;
}

/// Valida a nota: opcional, máx 200 caracteres.
/// Retorna null se vazia.
String? validarNota(String? nota) {
  if (nota == null) return null;
  final trimmed = nota.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.length > 200) {
    return trimmed.substring(0, 200);
  }
  return trimmed;
}

/// Cria um novo ItemLista com validação completa.
ItemLista criarItem(
  String nome,
  int quantidade, {
  String? nota,
  CategoriaItem? categoria,
  String? autorUid,
  String? autorNome,
}) {
  final notaValidada = validarNota(nota);
  return ItemLista(
    id: gerarId(),
    nome: validarNomeItem(nome),
    quantidade: validarQuantidade(quantidade),
    comprado: false,
    criadoEm: DateTime.now(),
    categoria: categoria ?? categoriaDefault,
    nota: notaValidada,
    adicionadoPorUid: autorUid,
    adicionadoPorNome: autorNome,
  );
}
```

## Passo 2: Testar mentalmente os cenários

Verificar que a lógica cobre:
- Nome vazio → `ArgumentError`
- Nome > 100 chars → truncado
- Quantidade 0 → `ArgumentError`
- Quantidade 100 → `ArgumentError`
- Quantidade 1-99 → OK
- Nota null → null
- Nota vazia → null
- Nota > 200 → truncada
- `criarItem` gera id único

---

## ✅ Checklist de Conclusão

- [ ] `validarNomeItem()` — trim + validação + truncamento
- [ ] `validarQuantidade()` — range 1-99
- [ ] `validarNota()` — nullable + trim + truncamento
- [ ] `criarItem()` — factory que usa todas as validações
- [ ] Usa `gerarId()` do `id_generator.dart` (Task 10)
