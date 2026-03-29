# Task 26 — Compartilhamento Service (com @riverpod)

**Fase**: Application Services  
**Dependências**: Task 06, Task 08, Task 11, Task 16  
**Resultado**: Serviço completo de convites e gestão de membros

---

## Contexto

Este é o serviço mais complexo. Ele gerencia:
- Enviar convites (com validações: limite membros, limite listas, email cadastrado)
- Escutar convites pendentes em real-time via Stream providers
- Aceitar/Recusar convites (operação em batch no Firestore)
- Revogar acesso / Sair da lista

> **NOTA**: Usamos `@riverpod` Notifier + Stream providers em vez do deprecado `StateNotifier`.

---

## Passo 1: Criar Stream providers para convites

Criar `lib/features/lista_compras/application/convite_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/models.dart';
import '../infra/firestore_convite_repository.dart';
import '../../auth/application/auth_providers.dart';

part 'convite_providers.g.dart';

/// Stream de convites pendentes do usuário atual.
@riverpod
Stream<List<Convite>> convitesPendentesStream(ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.email == null) return Stream.value([]);

  final repo = ref.watch(conviteRepositoryProvider);
  return repo.buscarConvitesPendentes(user!.email!.toLowerCase());
}

/// Contagem de convites pendentes (para badge).
@riverpod
int totalConvitesPendentes(ref) {
  return ref.watch(convitesPendentesStreamProvider).valueOrNull?.length ?? 0;
}
```

## Passo 2: Criar CompartilhamentoNotifier para ações

Criar `lib/features/lista_compras/application/compartilhamento_notifier.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/infra/firebase/firebase_providers.dart';
import '../domain/models/models.dart';
import '../domain/rules/lista_compartilhada_rules.dart';
import '../infra/firestore_convite_repository.dart';

part 'compartilhamento_notifier.g.dart';

/// Tipos de erro ao enviar convite.
enum ConviteErro {
  emailNaoCadastrado,
  jaMembro,
  limiteParticipantes,
  limiteListas,
  erroRede,
}

/// Resultado de envio de convite.
class ConviteResultado {
  final bool sucesso;
  final ConviteErro? erro;

  const ConviteResultado.ok() : sucesso = true, erro = null;
  const ConviteResultado.falha(this.erro) : sucesso = false;
}

class CompartilhamentoNotifier extends _$CompartilhamentoNotifier {
  @override
  FutureOr<void> build() {}

  FirebaseFirestore get _firestore => ref.read(firestoreProvider);
  ConviteRepository get _conviteRepo => ref.read(conviteRepositoryProvider);

  /// Envia um convite para um email.
  Future<ConviteResultado> enviarConvite({
    required ListaCompras lista,
    required String convidadoEmail,
    required String donoUid,
    required String donoNome,
  }) async {
    final membros = lista.membros ?? {};

    if (!podeConvidarMembro(membros)) {
      return const ConviteResultado.falha(ConviteErro.limiteParticipantes);
    }

    // Já é membro?
    final jaMembroPorEmail = membros.values.any(
      (m) => m.email.toLowerCase() == convidadoEmail.toLowerCase(),
    );
    if (jaMembroPorEmail) {
      return const ConviteResultado.falha(ConviteErro.jaMembro);
    }

    // Buscar UID do convidado por email
    final uidConvidado = await _buscarUidPorEmail(convidadoEmail);
    if (uidConvidado == null) {
      return const ConviteResultado.falha(ConviteErro.emailNaoCadastrado);
    }

    // Verificar limite de listas do convidado
    final listasConvidado = await _contarListasCompartilhadas(uidConvidado);
    if (listasConvidado >= maxListasCompartilhadas) {
      return const ConviteResultado.falha(ConviteErro.limiteListas);
    }

    final agora = DateTime.now();
    final convite = Convite(
      id: '${lista.id}__$uidConvidado',
      listaId: lista.id,
      listaNome: lista.nome,
      donoUid: donoUid,
      donoNome: donoNome,
      convidadoUid: uidConvidado,
      convidadoEmail: convidadoEmail.toLowerCase(),
      criadoEm: agora,
      expiresAt: criarConviteExpiresAt(agora),
      status: StatusConvite.pending,
    );

    try {
      await _conviteRepo.criarConvite(convite);
      return const ConviteResultado.ok();
    } catch (_) {
      return const ConviteResultado.falha(ConviteErro.erroRede);
    }
  }

  /// Aceita um convite (operação em batch).
  Future<bool> aceitarConvite(Convite convite, String uid, String nome, String email) async {
    try {
      final agora = DateTime.now();
      final batch = _firestore.batch();

      // 1. Adicionar membro na lista
      final listaRef = _firestore.collection('listas').doc(convite.listaId);
      batch.update(listaRef, {
        'membros.$uid': MembroLista(
          nome: nome,
          email: email,
          papel: PapelMembro.colaborador,
          entradoEm: agora,
        ).toMap(),
        'atualizadoEm': agora.toIso8601String(),
      });

      // 2. Adicionar referência no índice do usuário
      final indexRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('minhasListas')
          .doc(convite.listaId);
      batch.set(indexRef, MinhaListaRef(
        id: convite.listaId,
        nome: convite.listaNome,
        papel: PapelMembro.colaborador,
        atualizadoEm: agora,
      ).toMap());

      // 3. Atualizar status do convite
      final conviteRef = _firestore.collection('convites').doc(convite.id);
      batch.update(conviteRef, {'status': 'accepted'});

      await batch.commit();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Recusa um convite.
  Future<void> recusarConvite(String conviteId) async {
    await _conviteRepo.recusarConvite(conviteId);
  }

  /// Revoga acesso de um membro (dono remove membro).
  Future<void> revogarAcesso(String listaId, String membroUid) async {
    await _removerMembroEmLote(listaId, membroUid);
  }

  /// Sai da lista (membro se remove).
  Future<void> sairDaLista(String listaId, String uid) async {
    await _removerMembroEmLote(listaId, uid);
  }

  /// Registra dados do usuário para lookup por email.
  Future<void> registrarUsuario(String uid, String email, String nome) async {
    try {
      await _firestore.collection('usuarios').doc(uid).set(
        {'email': email.toLowerCase(), 'nome': nome},
        SetOptions(merge: true),
      );
    } catch (_) {
      // Best-effort
    }
  }

  // === Privados ===

  Future<String?> _buscarUidPorEmail(String email) async {
    try {
      final snap = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email.toLowerCase())
          .get();
      if (snap.docs.isEmpty) return null;
      return snap.docs.first.id;
    } catch (_) {
      return null;
    }
  }

  Future<int> _contarListasCompartilhadas(String uid) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('minhasListas')
          .get();
      return snap.size;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _removerMembroEmLote(String listaId, String membroUid) async {
    final batch = _firestore.batch();

    final listaRef = _firestore.collection('listas').doc(listaId);
    batch.update(listaRef, {
      'membros.$membroUid': FieldValue.delete(),
      'atualizadoEm': DateTime.now().toIso8601String(),
    });

    final indexRef = _firestore
        .collection('users')
        .doc(membroUid)
        .collection('minhasListas')
        .doc(listaId);
    batch.delete(indexRef);

    await batch.commit();
  }
}
```

---

## ✅ Checklist de Conclusão

- [ ] `convitesPendentesStream` provider reativo ao auth
- [ ] `totalConvitesPendentes` provider derivado (para badge)
- [ ] `CompartilhamentoNotifier` com `@riverpod` (não StateNotifier!)
- [ ] `enviarConvite()` — com todas as validações
- [ ] `aceitarConvite()` — operação batch (3 writes atômicos)
- [ ] `recusarConvite()` — atualiza status
- [ ] `revogarAcesso()` / `sairDaLista()` — remove membro em batch
- [ ] `registrarUsuario()` — salva email para lookup
- [ ] Sem `StreamSubscription` manual (usa Stream providers)
- [ ] `build_runner build` sem erros
