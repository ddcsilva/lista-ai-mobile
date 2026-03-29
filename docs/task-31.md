# Task 31 — App Shell (Scaffold + Header)

**Fase**: UI  
**Dependências**: Task 28 (router), Task 12 (auth)  
**Resultado**: Scaffold principal com AppBar, Drawer e estrutura base

---

## Passo 1: Criar AppShell

Criar `lib/features/lista/ui/app_shell.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_service.dart';
import '../providers/lista_providers.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista AI'),
        centerTitle: true,
        actions: [
          // Botão compartilhar (será habilitado na Task 44)
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Task 44 - share dialog
            },
            tooltip: 'Compartilhar',
          ),
          // Menu popup
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenu(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'importar',
                child: ListTile(
                  leading: Icon(Icons.text_snippet_outlined),
                  title: Text('Importar texto'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'exportar',
                child: ListTile(
                  leading: Icon(Icons.ios_share),
                  title: Text('Exportar lista'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context, ref, usuario),
      body: child,
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, dynamic usuario) {
    return Drawer(
      child: Column(
        children: [
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
          // Minhas listas - será expandido na Task 49
          const ListTile(
            leading: Icon(Icons.list_alt),
            title: Text('Minhas Listas'),
            selected: true,
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              Navigator.pop(context); // fechar drawer
              await ref.read(authServiceProvider).logout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _handleMenu(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'importar':
        // TODO: Task 46 - dialog importar texto
        break;
      case 'exportar':
        // TODO: Task 44 - exportar
        break;
      case 'logout':
        ref.read(authServiceProvider).logout();
        break;
    }
  }
}
```

---

## Passo 2: Integrar AppShell no Router

Atualizar `lib/core/router/app_router.dart` para usar `ShellRoute`:

```dart
ShellRoute(
  builder: (context, state, child) => AppShell(child: child),
  routes: [
    GoRoute(
      path: '/lista',
      builder: (context, state) => const ListaPage(),
    ),
    GoRoute(
      path: '/lista/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ListaPage(listaId: id);
      },
    ),
  ],
),
```

---

## Passo 3: Criar ListaPage placeholder

Criar `lib/features/lista/ui/lista_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListaPage extends ConsumerWidget {
  final String? listaId;

  const ListaPage({super.key, this.listaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('Lista Page - será implementada na Task 32'),
    );
  }
}
```

---

## ✅ Checklist de Conclusão

- [ ] AppShell com Scaffold + AppBar
- [ ] Drawer com header do usuário (nome, email, foto)
- [ ] Menu popup (importar, exportar, sair)
- [ ] ShellRoute no GoRouter
- [ ] ListaPage placeholder
- [ ] Logout funcional
- [ ] AppBar com título "Lista AI"
