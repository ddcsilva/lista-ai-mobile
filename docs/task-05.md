# Task 05 — Criar Models: ItemLista e ListaCompras (com Freezed)

**Fase**: Domain Layer  
**Dependências**: Task 04 (CategoriaItem), Task 03 (Freezed instalado)  
**Resultado**: Classes imutáveis geradas por Freezed com JSON serialization

---

## Contexto

No Angular, estes são interfaces TypeScript. Em Dart 3 com **Freezed**, geramos automaticamente:
- `copyWith` type-safe
- `==` / `hashCode` por value equality
- `toString` legível
- `fromJson` / `toJson` gerados por `json_serializable`

> **POR QUE FREEZED em vez de escrever manualmente?**  
> - Elimina boilerplate de `copyWith`, `toMap`, `fromMap` (centenas de linhas)  
> - Garante imutabilidade real (sem bugs de mutação acidental)  
> - Erros de typo nas keys JSON são detectados em build time  
> - Integra com Dart 3 pattern matching (`switch`, `sealed`)  

---

## Passo 1: Criar TimestampConverter (Firestore ↔ DateTime)

Criar `lib/features/lista_compras/domain/models/firestore_converters.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converte DateTime <-> Firestore Timestamp em fromJson/toJson.
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return DateTime.now(); // fallback seguro
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Para DateTime? nullable.
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}
```

---

## Passo 2: Criar ItemLista

Criar `lib/features/lista_compras/domain/models/item_lista.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'categoria_item.dart';
import 'firestore_converters.dart';

part 'item_lista.freezed.dart';
part 'item_lista.g.dart';

/// Representa um item individual na lista de compras.
@freezed
class ItemLista with _$ItemLista {
  const factory ItemLista({
    required String id,
    required String nome,
    @Default(1) int quantidade,
    @Default(false) bool comprado,
    @TimestampConverter() required DateTime criadoEm,
    String? nota,
    @Default(CategoriaItem.outros) CategoriaItem categoria,
    String? adicionadoPorUid,
    String? adicionadoPorNome,
  }) = _ItemLista;

  factory ItemLista.fromJson(Map<String, dynamic> json) =>
      _$ItemListaFromJson(json);
}
```

---

## Passo 3: Criar ListaCompras

Criar `lib/features/lista_compras/domain/models/lista_compras.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'item_lista.dart';
import 'membro_lista.dart';
import 'firestore_converters.dart';

part 'lista_compras.freezed.dart';
part 'lista_compras.g.dart';

/// Representa uma lista de compras completa com itens embutidos.
@freezed
class ListaCompras with _$ListaCompras {
  const factory ListaCompras({
    required String id,
    required String nome,
    @Default([]) List<ItemLista> itens,
    @TimestampConverter() required DateTime criadoEm,
    @TimestampConverter() required DateTime atualizadoEm,
    String? criadorUid,
    String? criadorNome,
    @Default({}) Map<String, MembroLista> membros,
  }) = _ListaCompras;

  factory ListaCompras.fromJson(Map<String, dynamic> json) =>
      _$ListaComprasFromJson(json);
}
```

---

## Passo 4: Gerar código

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Isso gera automaticamente:
- `item_lista.freezed.dart` — copyWith, ==, hashCode, toString
- `item_lista.g.dart` — fromJson, toJson
- `lista_compras.freezed.dart`
- `lista_compras.g.dart`

> **Dica**: durante desenvolvimento, use `watch` para gerar automaticamente:
> ```powershell
> dart run build_runner watch --delete-conflicting-outputs
> ```

---

## Passo 5: Criar barrel file

Criar `lib/features/lista_compras/domain/models/models.dart`:

```dart
export 'categoria_item.dart';
export 'item_lista.dart';
export 'lista_compras.dart';
export 'membro_lista.dart';
export 'minha_lista_ref.dart';
export 'convite.dart';
export 'firestore_converters.dart';
```

---

## Passo 6: Usar nos repositórios

Com Freezed, os repositórios Firestore ficam mais simples:

```dart
// ANTES (manual):
await docRef.set(lista.toMap());
final lista = ListaCompras.fromMap(snapshot.data()!);

// DEPOIS (Freezed):
await docRef.set(lista.toJson());
final lista = ListaCompras.fromJson(snapshot.data()!);
```

---

## ✅ Checklist de Conclusão

- [ ] `TimestampConverter` para Firestore DateTime
- [ ] `ItemLista` com `@freezed` (9 campos)
- [ ] `ListaCompras` com `@freezed` (8 campos)
- [ ] `build_runner build` gera .freezed.dart e .g.dart sem erros
- [ ] `fromJson` / `toJson` funcionais com Timestamps
- [ ] Value equality funciona (`ItemLista(...) == ItemLista(...)`)
- [ ] Barrel file `models.dart` exporta tudo
- [ ] Arquivos gerados adicionados ao `.gitignore` (opcional)
