# Task 09 — Criar Ports (Repositórios Abstratos)

**Fase**: Domain Layer  
**Dependências**: Task 05, Task 06  
**Resultado**: Interfaces abstratas para os 3 repositórios

---

## Contexto

No Angular, os ports são `abstract class` com métodos `Observable`. Em Dart, usamos `abstract class` com `Stream` para real-time e `Future` para operações pontuais.

---

## Passo 1: Criar ListaRepository

Criar `lib/features/lista_compras/domain/ports/lista_repository.dart`:

```dart
import '../models/item_lista.dart';
import '../models/lista_compras.dart';

/// Contrato para acesso a listas de compras.
/// Implementações: FirestoreListaRepository.
abstract class ListaRepository {
  /// Escuta mudanças em uma lista em tempo real.
  Stream<ListaCompras> escutarLista(String listaId);

  /// Salva uma lista completa (cria ou sobrescreve).
  Future<void> salvarLista(ListaCompras lista, String listaId);

  /// Renomeia uma lista existente.
  Future<void> renomearLista(String listaId, String novoNome);

  /// Deleta uma lista.
  Future<void> deletarLista(String listaId);

  /// Adiciona um item à lista ativa.
  Future<void> adicionarItem(String listaId, ItemLista item);

  /// Remove um item da lista ativa.
  Future<void> removerItem(String listaId, String itemId);

  /// Atualiza um item existente.
  Future<void> atualizarItem(String listaId, ItemLista item);

  /// Remove todos os itens da lista.
  Future<void> limparItens(String listaId);
}
```

## Passo 2: Criar ListaIndexRepository

Criar `lib/features/lista_compras/domain/ports/lista_index_repository.dart`:

```dart
import '../models/minha_lista_ref.dart';

/// Contrato para o índice de listas do usuário.
/// Armazenado em: users/{uid}/minhasListas/
abstract class ListaIndexRepository {
  /// Escuta as listas do usuário em tempo real.
  Stream<List<MinhaListaRef>> carregarMinhasListas(String uid);

  /// Adiciona uma referência de lista ao índice do usuário.
  Future<void> adicionarReferencia(String uid, MinhaListaRef ref);

  /// Remove uma referência de lista do índice.
  Future<void> removerReferencia(String uid, String listaId);

  /// Atualiza uma referência existente.
  Future<void> atualizarReferencia(String uid, MinhaListaRef ref);
}
```

## Passo 3: Criar ConviteRepository

Criar `lib/features/lista_compras/domain/ports/convite_repository.dart`:

```dart
import '../models/convite.dart';

/// Contrato para gerenciamento de convites.
/// Armazenado em: convites/
abstract class ConviteRepository {
  /// Cria um novo convite.
  Future<void> criarConvite(Convite convite);

  /// Escuta convites pendentes de um e-mail em tempo real.
  Stream<List<Convite>> buscarConvitesPendentes(String email);

  /// Aceita um convite (muda status para 'accepted').
  Future<void> aceitarConvite(String conviteId);

  /// Recusa um convite (atualiza status).
  Future<void> recusarConvite(String conviteId);
}
```

## Passo 4: Criar barrel file

Criar `lib/features/lista_compras/domain/ports/ports.dart`:

```dart
export 'convite_repository.dart';
export 'lista_index_repository.dart';
export 'lista_repository.dart';
```

---

## Nota sobre diferenças Angular → Flutter

| Angular | Flutter |
|---------|---------|
| `Observable<T>` (RxJS) | `Stream<T>` (para real-time) |
| `Observable<void>` (one-shot) | `Future<void>` (para writes) |
| `abstract class` com `abstract` methods | `abstract class` (idêntico) |
| `listaId?: string` (opcional) | `String listaId` (obrigatório — sempre temos o ID) |

No Angular, o `listaId` era opcional porque o repositório mantinha estado interno. No Flutter com Riverpod, passamos o ID explicitamente.

---

## ✅ Checklist de Conclusão

- [ ] `ListaRepository` com 8 métodos (escutar, salvar, renomear, deletar, CRUD itens)
- [ ] `ListaIndexRepository` com 4 métodos (carregar, adicionar, remover, atualizar)
- [ ] `ConviteRepository` com 4 métodos (criar, buscar pendentes, aceitar, recusar)
- [ ] Barrel file exportando todos
- [ ] Uso de `Stream<T>` para real-time e `Future<void>` para writes
