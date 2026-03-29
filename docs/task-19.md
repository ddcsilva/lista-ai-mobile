# Task 19 — Criar ListaNotifier — CRUD Operations (com @riverpod AsyncNotifier)

**Fase**: Application Layer (State Management)  
**Dependências**: Task 18 (lista_providers), Task 14-15 (Repositórios)  
**Resultado**: Notifier com operações CRUD completas + tratamento de erro robusto

---

## Contexto

> **Padrão @riverpod Notifier**: Em vez de `StateNotifier<ListaState>`,  
> usamos `@riverpod class ListaNotifier extends _$ListaNotifier` com `AsyncValue.guard()`.

---

## Passo 1: Criar ListaNotifier

Criar `lib/features/lista_compras/application/lista_notifier.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/models.dart';
import '../infra/lista_repository.dart';
import '../../auth/application/auth_providers.dart';

part 'lista_notifier.g.dart';

/// Notifier responsável por operações de escrita (CRUD) em listas.
///
/// As operações de leitura ficam nos providers de stream (task-18).
/// Este notifier gerencia ações do usuário com error handling.
@riverpod
class ListaNotifier extends _$ListaNotifier {
  @override
  FutureOr<void> build() {
    // Notifier sem estado inicial — usado apenas para ações.
  }

  ListaRepository get _repo => ref.read(listaRepositoryProvider);

  String? get _uid => ref.read(currentUserProvider)?.uid;
  String? get _userName => ref.read(currentUserProvider)?.displayName;

  /// Cria uma nova lista de compras.
  Future<String?> criarLista({required String nome}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = _uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      final novaLista = ListaCompras(
        id: '', // gerado pelo Firestore
        nome: nome.trim(),
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
        criadorUid: uid,
        criadorNome: _userName,
        membros: {
          uid: MembroLista(
            uid: uid,
            nome: _userName ?? '',
            papel: PapelMembro.dono,
            adicionadoEm: DateTime.now(),
          ),
        },
      );

      return _repo.criarLista(novaLista);
    });

    return state.hasError ? null : state.value as String?;
  }

  /// Renomeia uma lista existente.
  Future<void> renomearLista({
    required String listaId,
    required String novoNome,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.atualizarLista(listaId, {
        'nome': novoNome.trim(),
        'atualizadoEm': DateTime.now(),
      });
    });
  }

  /// Remove uma lista completamente.
  Future<void> excluirLista({required String listaId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = _uid;
      if (uid == null) throw Exception('Usuário não autenticado');
      await _repo.excluirLista(listaId, uid);
    });
  }
}
```

---

## Passo 2: Criar ItemNotifier para operações em itens

Criar `lib/features/lista_compras/application/item_notifier.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/models.dart';
import '../infra/lista_repository.dart';
import '../../auth/application/auth_providers.dart';

part 'item_notifier.g.dart';

const _uuid = Uuid();

/// Notifier para operações CRUD em itens dentro de uma lista.
@riverpod
class ItemNotifier extends _$ItemNotifier {
  @override
  FutureOr<void> build() {}

  ListaRepository get _repo => ref.read(listaRepositoryProvider);

  /// Adiciona um item à lista.
  Future<void> adicionarItem({
    required String listaId,
    required String nome,
    CategoriaItem categoria = CategoriaItem.outros,
    int quantidade = 1,
    String? nota,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider);

      final novoItem = ItemLista(
        id: _uuid.v4(),
        nome: nome.trim(),
        quantidade: quantidade,
        categoria: categoria,
        nota: nota,
        criadoEm: DateTime.now(),
        adicionadoPorUid: user?.uid,
        adicionadoPorNome: user?.displayName,
      );

      await _repo.adicionarItem(listaId, novoItem);
    });
  }

  /// Toggle comprado/não comprado.
  Future<void> toggleComprado({
    required String listaId,
    required String itemId,
    required bool comprado,
  }) async {
    state = await AsyncValue.guard(() async {
      await _repo.atualizarItem(listaId, itemId, {'comprado': !comprado});
    });
  }

  /// Atualiza campos de um item.
  Future<void> editarItem({
    required String listaId,
    required String itemId,
    String? nome,
    int? quantidade,
    CategoriaItem? categoria,
    String? nota,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updates = <String, dynamic>{};
      if (nome != null) updates['nome'] = nome.trim();
      if (quantidade != null) updates['quantidade'] = quantidade;
      if (categoria != null) updates['categoria'] = categoria.value;
      if (nota != null) updates['nota'] = nota;

      if (updates.isNotEmpty) {
        await _repo.atualizarItem(listaId, itemId, updates);
      }
    });
  }

  /// Remove um item da lista.
  Future<void> removerItem({
    required String listaId,
    required String itemId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.removerItem(listaId, itemId);
    });
  }

  /// Remove todos os itens comprados.
  Future<void> limparComprados({required String listaId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.limparItensComprados(listaId);
    });
  }
}
```

---

## Passo 3: Gerar código

```powershell
dart run build_runner build --delete-conflicting-outputs
```

---

## Passo 4: Uso na UI (preview)

```dart
// Na tela:
final listaNotifier = ref.read(listaNotifierProvider.notifier);
final itemNotifier = ref.read(itemNotifierProvider.notifier);

// Criar lista
final novoId = await listaNotifier.criarLista(nome: 'Supermercado');

// Adicionar item
await itemNotifier.adicionarItem(
  listaId: novoId!,
  nome: 'Arroz',
  categoria: CategoriaItem.graos,
);

// Observar estado de loading/error:
ref.listen(listaNotifierProvider, (prev, next) {
  next.whenOrNull(
    error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    ),
  );
});
```

---

## ✅ Checklist de Conclusão

- [ ] `ListaNotifier` com `@riverpod` (não StateNotifier!)
- [ ] `criarLista` com `AsyncValue.guard()`
- [ ] `renomearLista` com `AsyncValue.guard()`
- [ ] `excluirLista` com `AsyncValue.guard()`
- [ ] `ItemNotifier` com `@riverpod`
- [ ] `adicionarItem` com UUID e metadados do usuário
- [ ] `toggleComprado` sem loading state desnecessário
- [ ] `editarItem` com updates parciais
- [ ] `removerItem` e `limparComprados`
- [ ] `build_runner build` sem erros
- [ ] Error handling consistente com `AsyncValue.guard()`
- [ ] Nenhum uso de `StateNotifier` ou `StateNotifierProvider`
