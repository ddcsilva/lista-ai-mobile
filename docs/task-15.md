# Task 15 — Firestore Lista Index Repository

**Fase**: Infrastructure  
**Dependências**: Task 06, Task 09, Task 11  
**Resultado**: Implementação do ListaIndexRepository

---

## Contexto

Coleção Firestore: `users/{uid}/minhasListas/{listaId}` — índice otimizado para listar rapidamente as listas do usuário sem carregar todos os documentos de `listas/`.

---

## Passo 1: Criar FirestoreListaIndexRepository

Criar `lib/features/lista_compras/infra/firestore_lista_index_repository.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/minha_lista_ref.dart';
import '../domain/ports/lista_index_repository.dart';

class FirestoreListaIndexRepository implements ListaIndexRepository {
  final FirebaseFirestore _firestore;

  FirestoreListaIndexRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _colecao(String uid) {
    return _firestore.collection('users').doc(uid).collection('minhasListas');
  }

  @override
  Stream<List<MinhaListaRef>> carregarMinhasListas(String uid) {
    return _colecao(uid).snapshots().map((snap) {
      return snap.docs.map((doc) {
        return MinhaListaRef.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Future<void> adicionarReferencia(String uid, MinhaListaRef ref) async {
    await _colecao(uid).doc(ref.id).set(ref.toMap());
  }

  @override
  Future<void> removerReferencia(String uid, String listaId) async {
    await _colecao(uid).doc(listaId).delete();
  }

  @override
  Future<void> atualizarReferencia(String uid, MinhaListaRef ref) async {
    await _colecao(uid).doc(ref.id).update(ref.toMap());
  }
}
```

## Passo 2: Criar provider Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/infra/firebase/firebase_providers.dart';
import '../domain/ports/lista_index_repository.dart';

final listaIndexRepositoryProvider = Provider<ListaIndexRepository>((ref) {
  return FirestoreListaIndexRepository(ref.watch(firestoreProvider));
});
```

---

## ✅ Checklist de Conclusão

- [ ] `FirestoreListaIndexRepository` implementa `ListaIndexRepository`
- [ ] `carregarMinhasListas()` — Stream via `snapshots()`
- [ ] `adicionarReferencia()` — `set()` com doc ID = listaId
- [ ] `removerReferencia()` — `delete()`
- [ ] `atualizarReferencia()` — `update()`
- [ ] Provider Riverpod criado
