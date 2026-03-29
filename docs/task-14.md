# Task 14 — Firestore Lista Repository

**Fase**: Infrastructure  
**Dependências**: Task 05, Task 09, Task 11  
**Resultado**: Implementação do ListaRepository usando Cloud Firestore

---

## Contexto

No Angular, o `FirestoreListaRepository` usa `onSnapshot` para listeners em real-time e transações para writes atômicos. No Flutter com `cloud_firestore`, o pattern é similar.

Coleção Firestore: `listas/{listaId}` — documento contém `itens[]` como array embutido.

---

## Passo 1: Criar FirestoreListaRepository

Criar `lib/features/lista_compras/infra/firestore_lista_repository.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/item_lista.dart';
import '../domain/models/lista_compras.dart';
import '../domain/ports/lista_repository.dart';

class FirestoreListaRepository implements ListaRepository {
  final FirebaseFirestore _firestore;

  FirestoreListaRepository(this._firestore);

  DocumentReference<Map<String, dynamic>> _listaDoc(String listaId) {
    return _firestore.collection('listas').doc(listaId);
  }

  @override
  Stream<ListaCompras> escutarLista(String listaId) {
    return _listaDoc(listaId).snapshots().map((snap) {
      if (!snap.exists) {
        throw Exception('Lista não encontrada: $listaId');
      }
      final data = snap.data()!;
      return ListaCompras.fromMap({...data, 'id': snap.id});
    });
  }

  @override
  Future<void> salvarLista(ListaCompras lista, String listaId) async {
    await _listaDoc(listaId).set(lista.toMap());
  }

  @override
  Future<void> renomearLista(String listaId, String novoNome) async {
    await _listaDoc(listaId).update({
      'nome': novoNome,
      'atualizadoEm': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deletarLista(String listaId) async {
    await _listaDoc(listaId).delete();
  }

  @override
  Future<void> adicionarItem(String listaId, ItemLista item) async {
    await _listaDoc(listaId).update({
      'itens': FieldValue.arrayUnion([item.toMap()]),
      'atualizadoEm': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removerItem(String listaId, String itemId) async {
    // Firestore não suporta remoção por campo em array.
    // Usamos transação para ler, filtrar e escrever.
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(_listaDoc(listaId));
      if (!snap.exists) return;

      final data = snap.data()!;
      final itens = (data['itens'] as List<dynamic>?) ?? [];
      final novosItens = itens
          .where((i) => (i as Map<String, dynamic>)['id'] != itemId)
          .toList();

      transaction.update(_listaDoc(listaId), {
        'itens': novosItens,
        'atualizadoEm': DateTime.now().toIso8601String(),
      });
    });
  }

  @override
  Future<void> atualizarItem(String listaId, ItemLista item) async {
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(_listaDoc(listaId));
      if (!snap.exists) return;

      final data = snap.data()!;
      final itens = (data['itens'] as List<dynamic>?) ?? [];
      final novosItens = itens.map((i) {
        final atual = i as Map<String, dynamic>;
        if (atual['id'] == item.id) {
          return item.toMap();
        }
        return atual;
      }).toList();

      transaction.update(_listaDoc(listaId), {
        'itens': novosItens,
        'atualizadoEm': DateTime.now().toIso8601String(),
      });
    });
  }

  @override
  Future<void> limparItens(String listaId) async {
    await _listaDoc(listaId).update({
      'itens': [],
      'atualizadoEm': DateTime.now().toIso8601String(),
    });
  }
}
```

## Passo 2: Criar provider Riverpod

Adicionar no mesmo arquivo ou em um arquivo separado de providers:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/infra/firebase/firebase_providers.dart';
import '../domain/ports/lista_repository.dart';

final listaRepositoryProvider = Provider<ListaRepository>((ref) {
  return FirestoreListaRepository(ref.watch(firestoreProvider));
});
```

## Passo 3: Verificar compilação

```powershell
flutter analyze
```

---

## Notas Importantes

### Sobre `FieldValue.arrayUnion`
- Funciona para *adicionar* itens ao array no Firestore
- Não funciona para *atualizar* ou *remover* — por isso usamos transações

### Sobre o design de "itens embutidos"
- O app Angular armazena itens como array dentro do documento da lista
- Isso é eficiente para listas pequenas (< 100 itens)
- Mantemos o mesmo design para compatibilidade

---

## ✅ Checklist de Conclusão

- [ ] `FirestoreListaRepository` implementa `ListaRepository`
- [ ] `escutarLista()` — Stream via `snapshots()`
- [ ] `salvarLista()` — `set()` no Firestore
- [ ] `renomearLista()` — `update()` parcial
- [ ] `deletarLista()` — `delete()`
- [ ] `adicionarItem()` — `FieldValue.arrayUnion`
- [ ] `removerItem()` — transação (ler + filtrar + escrever)
- [ ] `atualizarItem()` — transação (ler + map + escrever)
- [ ] `limparItens()` — `update()` com array vazio
- [ ] Provider Riverpod criado
