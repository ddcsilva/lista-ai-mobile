# Task 20 — Criar FavoritosNotifier (com @riverpod)

**Fase**: Application Layer  
**Dependências**: Task 15 (MinhasListasRepository), Task 05-06 (Models)  
**Resultado**: Gerenciamento de listas favoritas com @riverpod

---

## Contexto

No Angular, `FavoritosService` usa signals e BehaviorSubject para manter as listas favoritas.  
Em Flutter, usamos um **Stream provider** para reatividade automática + um **Notifier** para ações.

---

## Passo 1: Criar providers de favoritos

Criar `lib/features/lista_compras/application/favoritos_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/models.dart';
import '../infra/minhas_listas_repository.dart';
import '../../auth/application/auth_providers.dart';

part 'favoritos_providers.g.dart';

/// Stream reativo das listas marcadas como favoritas pelo usuário.
@riverpod
Stream<List<MinhaListaRef>> favoritasStream(ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(minhasListasRepositoryProvider);
  return repo.watchFavoritas(user.uid);
}

/// Stream de todas as referências de listas do usuário (favoritas ou não).
@riverpod
Stream<List<MinhaListaRef>> minhasListasStream(ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(minhasListasRepositoryProvider);
  return repo.watchTodasMinhasListas(user.uid);
}

/// Verifica se uma lista específica é favorita.
@riverpod
bool isListaFavorita(ref, {required String listaId}) {
  final favoritas = ref.watch(favoritasStreamProvider).valueOrNull ?? [];
  return favoritas.any((f) => f.listaId == listaId);
}
```

---

## Passo 2: Criar FavoritosNotifier para ações

Criar `lib/features/lista_compras/application/favoritos_notifier.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../infra/minhas_listas_repository.dart';
import '../../auth/application/auth_providers.dart';

part 'favoritos_notifier.g.dart';

/// Notifier para ações de favoritar/desfavoritar listas.
@riverpod
class FavoritosNotifier extends _$FavoritosNotifier {
  @override
  FutureOr<void> build() {}

  MinhasListasRepository get _repo =>
      ref.read(minhasListasRepositoryProvider);

  String? get _uid => ref.read(currentUserProvider)?.uid;

  /// Toggle favorito de uma lista.
  Future<void> toggleFavorito({
    required String listaId,
    required bool atualmenteFavorita,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = _uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      await _repo.atualizarMinhaLista(
        uid,
        listaId,
        {'favorita': !atualmenteFavorita},
      );
    });
  }

  /// Atualiza o último acesso de uma lista.
  Future<void> registrarAcesso({required String listaId}) async {
    state = await AsyncValue.guard(() async {
      final uid = _uid;
      if (uid == null) return;

      await _repo.atualizarMinhaLista(
        uid,
        listaId,
        {'ultimoAcesso': DateTime.now()},
      );
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
// No widget:
class ListaCard extends ConsumerWidget {
  final String listaId;
  const ListaCard({required this.listaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isListaFavoritaProvider(listaId: listaId));
    final notifier = ref.read(favoritosNotifierProvider.notifier);

    return IconButton(
      icon: Icon(isFav ? Icons.star : Icons.star_border),
      color: isFav ? Colors.amber : null,
      onPressed: () => notifier.toggleFavorito(
        listaId: listaId,
        atualmenteFavorita: isFav,
      ),
    );
  }
}
```

---

## ✅ Checklist de Conclusão

- [ ] `favoritasStream` provider reativo ao auth
- [ ] `minhasListasStream` provider
- [ ] `isListaFavorita` provider derivado com parâmetro
- [ ] `FavoritosNotifier` com `@riverpod` (não StateNotifier!)
- [ ] `toggleFavorito` com `AsyncValue.guard()`
- [ ] `registrarAcesso` para tracking
- [ ] `build_runner build` sem erros
- [ ] Preview de uso na UI
