# Task 18 — Criar ListaProviders — State + Providers (com @riverpod code generation)

**Fase**: Application Layer (State Management)  
**Dependências**: Task 05-06 (Models Freezed), Task 14-15 (Repositórios Firestore)  
**Resultado**: Estado tipado com Freezed + providers gerados por @riverpod

---

## Contexto

> **MIGRAÇÃO CRÍTICA**: Riverpod 2.x deprecou `StateNotifier`.  
> Usamos `@riverpod` code generation com `Notifier` / `AsyncNotifier`.  
> Isso é obrigatório para Riverpod 3.x e é a prática recomendada hoje.

---

## Passo 1: Criar ListaState com Freezed

Criar `lib/features/lista_compras/application/lista_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/models/models.dart';

part 'lista_state.freezed.dart';

@freezed
class ListaState with _$ListaState {
  const factory ListaState({
    @Default([]) List<ListaCompras> listas,
    ListaCompras? listaSelecionada,
    @Default('') String termoBusca,
    @Default(false) bool carregando,
    String? erro,
  }) = _ListaState;
}
```

```powershell
dart run build_runner build --delete-conflicting-outputs
```

---

## Passo 2: Criar providers para FiltroBusca

Criar `lib/features/lista_compras/application/filtro_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/models.dart';
import 'lista_providers.dart';

part 'filtro_providers.g.dart';

/// Provider para o termo de busca atual.
@riverpod
class TermoBusca extends _$TermoBusca {
  @override
  String build() => '';

  void atualizar(String termo) {
    state = termo;
  }
}

/// Provider derivado: listas filtradas pelo termo de busca.
@riverpod
List<ListaCompras> listasFiltradas(ref) {
  final listas = ref.watch(listasStreamProvider).valueOrNull ?? [];
  final termo = ref.watch(termoBuscaProvider);

  if (termo.isEmpty) return listas;

  final termoLower = termo.toLowerCase();
  return listas.where((lista) {
    return lista.nome.toLowerCase().contains(termoLower) ||
        lista.itens.any((item) =>
            item.nome.toLowerCase().contains(termoLower));
  }).toList();
}
```

---

## Passo 3: Criar providers de Stream para listas

Criar `lib/features/lista_compras/application/lista_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/models.dart';
import '../infra/lista_repository.dart';
import '../../auth/application/auth_providers.dart';

part 'lista_providers.g.dart';

/// Stream de todas as listas do usuário atual.
/// Reage automaticamente a mudanças no auth state.
@riverpod
Stream<List<ListaCompras>> listasStream(ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(listaRepositoryProvider);
  return repo.watchListasDoUsuario(user.uid);
}

/// Stream de uma lista específica por ID.
@riverpod
Stream<ListaCompras?> listaStream(ref, {required String listaId}) {
  final repo = ref.watch(listaRepositoryProvider);
  return repo.watchLista(listaId);
}

/// Provider para a lista selecionada atualmente.
@riverpod
class ListaSelecionadaId extends _$ListaSelecionadaId {
  @override
  String? build() => null;

  void selecionar(String id) => state = id;
  void limpar() => state = null;
}

/// Provider derivado: dados da lista selecionada.
@riverpod
AsyncValue<ListaCompras?> listaSelecionada(ref) {
  final id = ref.watch(listaSelecionadaIdProvider);
  if (id == null) return const AsyncData(null);
  return ref.watch(listaStreamProvider(listaId: id));
}
```

---

## Passo 4: Provider para contagem de itens

```dart
// Adicionar ao final de lista_providers.dart

/// Contagem de itens pendentes e completados.
@riverpod
({int pendentes, int completados, int total}) contadorItens(
  ref, {
  required String listaId,
}) {
  final listaAsync = ref.watch(listaStreamProvider(listaId: listaId));
  return listaAsync.when(
    data: (lista) {
      if (lista == null) return (pendentes: 0, completados: 0, total: 0);
      final completados = lista.itens.where((i) => i.comprado).length;
      return (
        pendentes: lista.itens.length - completados,
        completados: completados,
        total: lista.itens.length,
      );
    },
    loading: () => (pendentes: 0, completados: 0, total: 0),
    error: (_, __) => (pendentes: 0, completados: 0, total: 0),
  );
}
```

---

## Passo 5: Gerar código

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Arquivos gerados:
- `lista_state.freezed.dart`
- `filtro_providers.g.dart`
- `lista_providers.g.dart`

---

## Diferenças do Angular

| Angular (ListaStore) | Flutter (Riverpod) |
|---|---|
| `signal<Lista[]>([])` | `@riverpod Stream<List<ListaCompras>>` |
| `computed(() => ...)` | `@riverpod listasFiltradas(ref)` (provider derivado) |
| `effect(() => { ... })` | `ref.listen()` / `ref.watch()` reativo |
| `BehaviorSubject.pipe(switchMap)` | `ref.watch(authProvider)` invalidação automática |
| Classe monolítica ListaStore | Providers granulares e composáveis |

---

## ✅ Checklist de Conclusão

- [ ] `ListaState` com Freezed (5 campos)
- [ ] `TermoBusca` Notifier com `@riverpod` (não StateNotifier!)
- [ ] `listasStream` provider reativo ao auth
- [ ] `listaStream` provider com parâmetro `listaId`
- [ ] `ListaSelecionadaId` Notifier
- [ ] `listasFiltradas` provider derivado
- [ ] `contadorItens` usando Dart 3 records
- [ ] `build_runner build` sem erros
- [ ] Nenhum uso de `StateNotifier` ou `StateNotifierProvider`
