# Task 06 — Criar Models: Convite, MembroLista, MinhaListaRef (com Freezed)

**Fase**: Domain Layer  
**Dependências**: Task 05 (TimestampConverter, barrel models), Task 03 (Freezed)  
**Resultado**: Classes imutáveis com enums sealed para status e papéis

---

## Contexto

Estas entidades modelam o sistema de **compartilhamento** de listas.  
Usamos Dart 3 **enums** com `JsonEnum` para serialização automática no Firestore.

---

## Passo 1: Criar StatusConvite (enum)

Criar `lib/features/lista_compras/domain/models/status_convite.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum StatusConvite {
  @JsonValue('pendente')
  pendente('pendente'),
  @JsonValue('aceito')
  aceito('aceito'),
  @JsonValue('recusado')
  recusado('recusado');

  const StatusConvite(this.value);
  final String value;
}
```

---

## Passo 2: Criar PapelMembro (enum)

Criar `lib/features/lista_compras/domain/models/papel_membro.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PapelMembro {
  @JsonValue('dono')
  dono('dono'),
  @JsonValue('editor')
  editor('editor'),
  @JsonValue('visualizador')
  visualizador('visualizador');

  const PapelMembro(this.value);
  final String value;
}
```

---

## Passo 3: Criar MembroLista

Criar `lib/features/lista_compras/domain/models/membro_lista.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'papel_membro.dart';
import 'firestore_converters.dart';

part 'membro_lista.freezed.dart';
part 'membro_lista.g.dart';

/// Representa um membro que participa de uma lista compartilhada.
@freezed
class MembroLista with _$MembroLista {
  const factory MembroLista({
    required String uid,
    required String nome,
    String? email,
    @Default(PapelMembro.editor) PapelMembro papel,
    @TimestampConverter() required DateTime adicionadoEm,
  }) = _MembroLista;

  factory MembroLista.fromJson(Map<String, dynamic> json) =>
      _$MembroListaFromJson(json);
}
```

---

## Passo 4: Criar Convite

Criar `lib/features/lista_compras/domain/models/convite.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'status_convite.dart';
import 'firestore_converters.dart';

part 'convite.freezed.dart';
part 'convite.g.dart';

/// Convite para compartilhar uma lista com outro usuário.
@freezed
class Convite with _$Convite {
  const factory Convite({
    required String id,
    required String listaId,
    required String listaNome,
    required String remetenteUid,
    required String remetenteNome,
    required String destinatarioEmail,
    String? destinatarioUid,
    @Default(StatusConvite.pendente) StatusConvite status,
    @TimestampConverter() required DateTime criadoEm,
    @NullableTimestampConverter() DateTime? respondidoEm,
  }) = _Convite;

  factory Convite.fromJson(Map<String, dynamic> json) =>
      _$ConviteFromJson(json);
}
```

---

## Passo 5: Criar MinhaListaRef

Criar `lib/features/lista_compras/domain/models/minha_lista_ref.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'papel_membro.dart';
import 'firestore_converters.dart';

part 'minha_lista_ref.freezed.dart';
part 'minha_lista_ref.g.dart';

/// Referência leve para uma lista favorita/do usuário.
/// Armazenada em `users/{uid}/minhasListas/{listaId}`.
@freezed
class MinhaListaRef with _$MinhaListaRef {
  const factory MinhaListaRef({
    required String listaId,
    required String nome,
    @Default(PapelMembro.dono) PapelMembro papel,
    @Default(false) bool favorita,
    @TimestampConverter() required DateTime adicionadoEm,
    @NullableTimestampConverter() DateTime? ultimoAcesso,
  }) = _MinhaListaRef;

  factory MinhaListaRef.fromJson(Map<String, dynamic> json) =>
      _$MinhaListaRefFromJson(json);
}
```

---

## Passo 6: Gerar código e testar

```powershell
dart run build_runner build --delete-conflicting-outputs
```

---

## Passo 7: Atualizar barrel file

Atualizar `lib/features/lista_compras/domain/models/models.dart`:

```dart
export 'categoria_item.dart';
export 'firestore_converters.dart';
export 'item_lista.dart';
export 'lista_compras.dart';
export 'membro_lista.dart';
export 'minha_lista_ref.dart';
export 'convite.dart';
export 'status_convite.dart';
export 'papel_membro.dart';
```

---

## ✅ Checklist de Conclusão

- [ ] `StatusConvite` enum com `@JsonEnum`
- [ ] `PapelMembro` enum com `@JsonEnum`
- [ ] `MembroLista` com `@freezed` (5 campos)
- [ ] `Convite` com `@freezed` (10 campos) incluindo `NullableTimestampConverter`
- [ ] `MinhaListaRef` com `@freezed` (6 campos)
- [ ] `build_runner build` sem erros
- [ ] Barrel file `models.dart` exporta todos os novos arquivos
- [ ] `fromJson` funciona com dados vindos do Firestore
