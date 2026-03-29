# Task 45 — Multi-Lista (Drawer + Switcher)

**Fase**: UI  
**Dependências**: Task 31 (AppShell/Drawer), Task 15/16 (Repositories)  
**Resultado**: Drawer com lista de todas as listas do usuário + criar/trocar listas

---

## Passo 1: Criar provider de minhas listas

Em `lib/features/lista/providers/minhas_listas_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_service.dart';
import '../../../domain/models/minha_lista_ref.dart';
import '../../../infrastructure/repositories/firestore_lista_index_repository.dart';

/// Stream de referências das listas do usuário
final minhasListasProvider = StreamProvider<List<MinhaListaRef>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value([]);
  
  final repo = ref.read(listaIndexRepositoryProvider);
  return repo.observarMinhasListas(auth.uid);
});
```

---

## Passo 2: Expandir o Drawer no AppShell

Atualizar `lib/features/lista/ui/app_shell.dart` — substituir o drawer simples:

```dart
Widget _buildDrawer(BuildContext context, WidgetRef ref, dynamic usuario) {
  return Drawer(
    child: Column(
      children: [
        // Header do usuário
        UserAccountsDrawerHeader(
          accountName: Text(usuario?.displayName ?? 'Usuário'),
          accountEmail: Text(usuario?.email ?? ''),
          currentAccountPicture: CircleAvatar(
            backgroundImage: usuario?.photoURL != null
                ? NetworkImage(usuario.photoURL!)
                : null,
            child: usuario?.photoURL == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
        ),
        
        // Título "Minhas Listas"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minhas Listas',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => _criarNovaLista(context, ref),
                tooltip: 'Nova lista',
              ),
            ],
          ),
        ),
        
        // Lista de listas
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final minhasListas = ref.watch(minhasListasProvider);
              final storeState = ref.watch(listaStoreProvider);
              final listaAtualId = storeState.listaAtual?.id;
              
              return minhasListas.when(
                data: (listas) {
                  if (listas.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma lista criada'),
                    );
                  }
                  return ListView.builder(
                    itemCount: listas.length,
                    itemBuilder: (context, index) {
                      final lista = listas[index];
                      final isAtual = lista.listaId == listaAtualId;
                      
                      return ListTile(
                        leading: Icon(
                          lista.compartilhada
                              ? Icons.group
                              : Icons.list_alt,
                          color: isAtual
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(
                          lista.nome ?? 'Lista sem nome',
                          style: TextStyle(
                            fontWeight: isAtual ? FontWeight.bold : null,
                          ),
                        ),
                        subtitle: lista.compartilhada
                            ? const Text('Compartilhada')
                            : null,
                        selected: isAtual,
                        trailing: isAtual
                            ? const Icon(Icons.check, size: 18)
                            : null,
                        onTap: () {
                          Navigator.pop(context); // fechar drawer
                          _trocarLista(context, ref, lista.listaId);
                        },
                        onLongPress: () {
                          _opcoesLista(context, ref, lista);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Text('Erro: $e'),
                ),
              );
            },
          ),
        ),
        
        // Footer
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sair'),
          onTap: () async {
            Navigator.pop(context);
            await ref.read(authServiceProvider).logout();
          },
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}

void _trocarLista(BuildContext context, WidgetRef ref, String listaId) {
  ref.read(listaStoreProvider.notifier).carregarLista(listaId);
  // Ou usar GoRouter:
  // context.go('/lista/$listaId');
}

Future<void> _criarNovaLista(BuildContext context, WidgetRef ref) async {
  final nomeController = TextEditingController();
  
  final nome = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nova Lista'),
      content: TextField(
        controller: nomeController,
        decoration: const InputDecoration(
          hintText: 'Nome da lista',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, nomeController.text),
          child: const Text('Criar'),
        ),
      ],
    ),
  );

  nomeController.dispose();

  if (nome != null && nome.trim().isNotEmpty) {
    final store = ref.read(listaStoreProvider.notifier);
    await store.criarNovaLista(nome.trim());
    if (context.mounted) Navigator.pop(context); // fechar drawer
  }
}

void _opcoesLista(BuildContext context, WidgetRef ref, MinhaListaRef lista) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Renomear'),
            onTap: () {
              Navigator.pop(ctx);
              // TODO: dialog renomear
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Excluir lista'),
            textColor: Theme.of(context).colorScheme.error,
            iconColor: Theme.of(context).colorScheme.error,
            onTap: () async {
              Navigator.pop(ctx);
              final confirmar = await ConfirmDialog.show(
                context,
                titulo: 'Excluir lista?',
                mensagem: 'A lista "${lista.nome}" será excluída permanentemente.',
                textoConfirmar: 'Excluir',
                isDanger: true,
              );
              if (confirmar) {
                ref.read(listaStoreProvider.notifier).excluirLista(lista.listaId);
              }
            },
          ),
        ],
      ),
    ),
  );
}
```

---

## Passo 3: Atualizar AppBar para mostrar nome da lista

```dart
// No AppBar do AppShell:
appBar: AppBar(
  title: Consumer(
    builder: (context, ref, _) {
      final store = ref.watch(listaStoreProvider);
      final nome = store.listaAtual?.nome ?? 'Lista AI';
      return Text(nome);
    },
  ),
  centerTitle: true,
  // ... actions
),
```

---

## ✅ Checklist de Conclusão

- [ ] Drawer lista todas as listas do usuário (stream)
- [ ] Indicador visual da lista atual (bold + check)
- [ ] Ícone diferente para listas compartilhadas
- [ ] Tap troca para a lista selecionada
- [ ] Long press → opções (renomear, excluir)
- [ ] Botão "+" para criar nova lista
- [ ] Dialog "Nova Lista" com campo nome
- [ ] AppBar mostra nome da lista atual
- [ ] Logout no footer do drawer
