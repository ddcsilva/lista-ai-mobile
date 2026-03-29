# Task 16 — Firestore Convite Repository

**Fase**: Infrastructure  
**Dependências**: Task 06, Task 09, Task 11  
**Resultado**: Implementação do ConviteRepository

---

## Contexto

Coleção Firestore: `convites/{conviteId}` — documentos com status `pending`/`accepted`/`expired`. Listener filtra por `convidadoEmail` e `status == 'pending'`.

---

## Passo 1: Criar FirestoreConviteRepository

Criar `lib/features/lista_compras/infra/firestore_convite_repository.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/convite.dart';
import '../domain/ports/convite_repository.dart';

class FirestoreConviteRepository implements ConviteRepository {
  final FirebaseFirestore _firestore;

  FirestoreConviteRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _colecao {
    return _firestore.collection('convites');
  }

  @override
  Future<void> criarConvite(Convite convite) async {
    await _colecao.doc(convite.id).set(convite.toMap());
  }

  @override
  Stream<List<Convite>> buscarConvitesPendentes(String email) {
    return _colecao
        .where('convidadoEmail', isEqualTo: email.toLowerCase())
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => Convite.fromMap(doc.id, doc.data()))
          .where((c) => !c.isExpirado) // Filtrar expirados no client
          .toList();
    });
  }

  @override
  Future<void> aceitarConvite(String conviteId) async {
    await _colecao.doc(conviteId).update({'status': 'accepted'});
  }

  @override
  Future<void> recusarConvite(String conviteId) async {
    await _colecao.doc(conviteId).update({'status': 'expired'});
  }
}
```

## Passo 2: Criar provider Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/infra/firebase/firebase_providers.dart';
import '../domain/ports/convite_repository.dart';

final conviteRepositoryProvider = Provider<ConviteRepository>((ref) {
  return FirestoreConviteRepository(ref.watch(firestoreProvider));
});
```

## Passo 3: Índice Firestore necessário

⚠️ O query `where('convidadoEmail', ...).where('status', ...)` requer um **índice composto** no Firestore. Se já existe no app web, o mesmo índice serve. Caso contrário:

1. Rodar o app e observar o erro no console (Firestore gera link do índice)
2. Clicar no link para criar o índice automaticamente
3. Aguardar ~2 minutos para ativar

---

## ✅ Checklist de Conclusão

- [ ] `FirestoreConviteRepository` implementa `ConviteRepository`
- [ ] `criarConvite()` — `set()` com doc ID = convite.id
- [ ] `buscarConvitesPendentes()` — query composta com listener
- [ ] `aceitarConvite()` — `update()` status = 'accepted'
- [ ] `recusarConvite()` — `update()` status = 'expired'
- [ ] Filtro client-side de expirados (`!c.isExpirado`)
- [ ] Provider Riverpod criado
