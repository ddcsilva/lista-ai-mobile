# Task 21 — Criar HistoricoNotifier (com @riverpod)

**Fase**: Application Layer  
**Dependências**: Task 14-15 (Repositórios), Task 05-06 (Models)  
**Resultado**: Gerenciamento de histórico de ações com @riverpod

---

## Contexto

No Angular, `HistoricoService` rastreia ações feitas nas listas (adição, remoção, conclusão).  
Em Flutter, mantemos a mesma lógica com providers reativos e um Notifier para ações.

---

## Passo 1: Criar HistoricoEntry model com Freezed

Criar `lib/features/lista_compras/domain/models/historico_entry.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'firestore_converters.dart';

part 'historico_entry.freezed.dart';
part 'historico_entry.g.dart';

@JsonEnum(valueField: 'value')
enum TipoAcao {
  @JsonValue('item_adicionado')
  itemAdicionado('item_adicionado'),
  @JsonValue('item_removido')
  itemRemovido('item_removido'),
  @JsonValue('item_comprado')
  itemComprado('item_comprado'),
  @JsonValue('item_editado')
  itemEditado('item_editado'),
  @JsonValue('lista_criada')
  listaCriada('lista_criada'),
  @JsonValue('lista_renomeada')
  listaRenomeada('lista_renomeada'),
  @JsonValue('membro_adicionado')
  membroAdicionado('membro_adicionado'),
  @JsonValue('membro_removido')
  membroRemovido('membro_removido');

  const TipoAcao(this.value);
  final String value;
}

/// Registro de uma ação no histórico da lista.
@freezed
class HistoricoEntry with _$HistoricoEntry {
  const factory HistoricoEntry({
    required String id,
    required String listaId,
    required TipoAcao tipo,
    required String descricao,
    required String autorUid,
    required String autorNome,
    @TimestampConverter() required DateTime criadoEm,
    Map<String, dynamic>? metadados,
  }) = _HistoricoEntry;

  factory HistoricoEntry.fromJson(Map<String, dynamic> json) =>
      _$HistoricoEntryFromJson(json);
}
```

---

## Passo 2: Criar providers de histórico

Criar `lib/features/lista_compras/application/historico_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/historico_entry.dart';
import '../infra/historico_repository.dart';

part 'historico_providers.g.dart';

/// Stream do histórico de uma lista específica, ordenado por data.
@riverpod
Stream<List<HistoricoEntry>> historicoStream(
  ref, {
  required String listaId,
}) {
  final repo = ref.watch(historicoRepositoryProvider);
  return repo.watchHistorico(listaId);
}

/// Histórico limitado (últimas N entradas) para preview.
@riverpod
Stream<List<HistoricoEntry>> historicoRecenteStream(
  ref, {
  required String listaId,
  int limite = 10,
}) {
  final repo = ref.watch(historicoRepositoryProvider);
  return repo.watchHistoricoRecente(listaId, limite: limite);
}
```

---

## Passo 3: Criar HistoricoNotifier para ações

Criar `lib/features/lista_compras/application/historico_notifier.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/historico_entry.dart';
import '../infra/historico_repository.dart';
import '../../auth/application/auth_providers.dart';

part 'historico_notifier.g.dart';

const _uuid = Uuid();

/// Notifier para registrar ações no histórico.
@riverpod
class HistoricoNotifier extends _$HistoricoNotifier {
  @override
  FutureOr<void> build() {}

  HistoricoRepository get _repo =>
      ref.read(historicoRepositoryProvider);

  /// Registra uma ação no histórico da lista.
  Future<void> registrarAcao({
    required String listaId,
    required TipoAcao tipo,
    required String descricao,
    Map<String, dynamic>? metadados,
  }) async {
    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final entry = HistoricoEntry(
        id: _uuid.v4(),
        listaId: listaId,
        tipo: tipo,
        descricao: descricao,
        autorUid: user.uid,
        autorNome: user.displayName ?? 'Anônimo',
        criadoEm: DateTime.now(),
        metadados: metadados,
      );

      await _repo.adicionarEntrada(entry);
    });
  }

  /// Limpa todo o histórico de uma lista.
  Future<void> limparHistorico({required String listaId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.limparHistorico(listaId);
    });
  }
}
```

---

## Passo 4: Criar HistoricoRepository (stub)

Criar `lib/features/lista_compras/infra/historico_repository.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/historico_entry.dart';

part 'historico_repository.g.dart';

@riverpod
HistoricoRepository historicoRepository(ref) {
  return HistoricoRepository(FirebaseFirestore.instance);
}

class HistoricoRepository {
  final FirebaseFirestore _firestore;

  HistoricoRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _historicoRef(String listaId) =>
      _firestore.collection('listas').doc(listaId).collection('historico');

  Stream<List<HistoricoEntry>> watchHistorico(String listaId) {
    return _historicoRef(listaId)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HistoricoEntry.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<HistoricoEntry>> watchHistoricoRecente(
    String listaId, {
    int limite = 10,
  }) {
    return _historicoRef(listaId)
        .orderBy('criadoEm', descending: true)
        .limit(limite)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HistoricoEntry.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> adicionarEntrada(HistoricoEntry entry) async {
    await _historicoRef(entry.listaId).doc(entry.id).set(entry.toJson());
  }

  Future<void> limparHistorico(String listaId) async {
    final batch = _firestore.batch();
    final docs = await _historicoRef(listaId).get();
    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
```

---

## Passo 5: Atualizar barrel file de models

Adicionar ao `models.dart`:
```dart
export 'historico_entry.dart';
```

---

## Passo 6: Gerar código

```powershell
dart run build_runner build --delete-conflicting-outputs
```

---

## ✅ Checklist de Conclusão

- [ ] `HistoricoEntry` model com Freezed + `TipoAcao` enum
- [ ] `historicoStream` provider reativo
- [ ] `historicoRecenteStream` com limite
- [ ] `HistoricoNotifier` com `@riverpod` (não StateNotifier!)
- [ ] `registrarAcao` com `AsyncValue.guard()`
- [ ] `limparHistorico` com batch delete
- [ ] `HistoricoRepository` com Firestore sub-collection
- [ ] Barrel file atualizado
- [ ] `build_runner build` sem erros
