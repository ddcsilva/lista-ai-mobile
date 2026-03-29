# Task 27 — Migração Service

**Fase**: Application Services  
**Dependências**: Task 11, Task 14, Task 15  
**Resultado**: Serviço de migração de dados legados (formato antigo → novo)

---

## Contexto

O app original armazenava dados em `users/{uid}/lista/principal`. O novo formato usa `listas/{listaId}` com índice em `users/{uid}/minhasListas/{listaId}`. O serviço migra automaticamente na primeira vez.

---

## Passo 1: Criar MigracaoService

Criar `lib/features/lista_compras/application/migracao_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/infra/firebase/firebase_providers.dart';
import '../../../shared/utils/id_generator.dart';
import '../domain/models/models.dart';
import '../domain/ports/lista_repository.dart';
import '../domain/ports/lista_index_repository.dart';
import '../infra/firestore_lista_repository.dart';
import '../infra/firestore_lista_index_repository.dart';

class MigracaoService {
  final FirebaseFirestore _firestore;
  final ListaRepository _listaRepo;
  final ListaIndexRepository _indexRepo;

  MigracaoService(this._firestore, this._listaRepo, this._indexRepo);

  /// Migra lista legada se existir e o usuário não tiver listas no índice.
  /// Retorna o ID da lista migrada ou null.
  Future<String?> migrar(String uid, String displayName, String email) async {
    try {
      // Verificar se lista legada existe
      final legado = await _verificarListaLegada(uid);
      if (legado == null) return null;

      // Verificar se já migrou (tem listas no índice)
      final jaPopulado = await _verificarIndexJaPopulado(uid);
      if (jaPopulado) return null;

      // Executar migração
      return await _executarMigracao(uid, displayName, email, legado);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _verificarListaLegada(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('lista')
        .doc('principal')
        .get();
    return snap.exists ? snap.data() : null;
  }

  Future<bool> _verificarIndexJaPopulado(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('minhasListas')
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<String> _executarMigracao(
    String uid,
    String displayName,
    String email,
    Map<String, dynamic> dadosLegados,
  ) async {
    final novoId = gerarId();
    final agora = DateTime.now();

    // Converter itens legados
    final itensRaw = (dadosLegados['itens'] as List<dynamic>?) ?? [];
    final itens = itensRaw.map((i) {
      final item = i as Map<String, dynamic>;
      return ItemLista(
        id: item['id'] as String,
        nome: item['nome'] as String,
        quantidade: (item['quantidade'] as num).toInt(),
        comprado: item['comprado'] as bool? ?? false,
        criadoEm: DateTime.tryParse(item['criadoEm'] as String? ?? '') ?? agora,
        categoria: categoriaFromString(item['categoria'] as String?),
        nota: item['nota'] as String?,
        adicionadoPorUid: uid,
        adicionadoPorNome: displayName,
      );
    }).toList();

    final novaLista = ListaCompras(
      id: novoId,
      nome: 'Minha Lista',
      itens: itens,
      criadoEm: DateTime.tryParse(dadosLegados['criadoEm'] as String? ?? '') ?? agora,
      atualizadoEm: agora,
      criadorUid: uid,
      criadorNome: displayName,
      membros: {
        uid: MembroLista(
          nome: displayName,
          email: email,
          papel: PapelMembro.dono,
          entradoEm: agora,
        ),
      },
    );

    final ref = MinhaListaRef(
      id: novoId,
      nome: 'Minha Lista',
      papel: PapelMembro.dono,
      atualizadoEm: agora,
    );

    // Salvar nova lista + índice
    await _listaRepo.salvarLista(novaLista, novoId);
    await _indexRepo.adicionarReferencia(uid, ref);

    // Remover lista legada (best-effort)
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('lista')
          .doc('principal')
          .delete();
    } catch (_) {}

    return novoId;
  }
}

final migracaoServiceProvider = Provider<MigracaoService>((ref) {
  return MigracaoService(
    ref.watch(firestoreProvider),
    ref.watch(listaRepositoryProvider),
    ref.watch(listaIndexRepositoryProvider),
  );
});
```

---

## ✅ Checklist de Conclusão

- [ ] `migrar()` — verifica legado + verifica índice + migra
- [ ] Converte itens legados para formato novo
- [ ] Cria lista em `listas/{novoId}`
- [ ] Cria índice em `users/{uid}/minhasListas/{novoId}`
- [ ] Remove lista legada (best-effort)
- [ ] Retorna null se não há nada para migrar
- [ ] Provider criado
