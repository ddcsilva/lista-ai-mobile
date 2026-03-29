# Task 28 — Configurar GoRouter com Auth Redirect e Deep Links

**Fase**: Infrastructure (Routing)  
**Dependências**: Task 10-11 (Auth providers), Task 27 (Shell com BottomNav)  
**Resultado**: Roteamento declarativo com proteção de rotas e redirect baseado em auth

---

## Contexto

> **ATENÇÃO**: `GoRouterRefreshStream` (usado em versões antigas de tutoriais)   
> cria um `StreamSubscription` que **nunca é cancelado** → memory leak.  
> A solução correta é usar `ref.watch` dentro do redirect ou `refreshListenable`.

---

## Passo 1: Criar AuthNotifier para GoRouter refresh

Criar `lib/core/routing/auth_listenable.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Listenable que notifica GoRouter quando auth state muda.
/// Usa onAuthStateChanged do Firebase diretamente — sem memory leak.
class AuthListenable extends ChangeNotifier {
  AuthListenable() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

---

## Passo 2: Criar rotas como constantes

Criar `lib/core/routing/app_routes.dart`:

```dart
/// Nomes e paths das rotas do app.
abstract final class AppRoutes {
  // Auth
  static const login = '/login';
  static const registro = '/registro';
  static const recuperarSenha = '/recuperar-senha';

  // Main (dentro do Shell)
  static const home = '/';
  static const favoritas = '/favoritas';
  static const perfil = '/perfil';

  // Lista
  static const lista = '/lista/:id';
  static String listaById(String id) => '/lista/$id';

  // Convites
  static const convites = '/convites';
  static const conviteDetalhe = '/convites/:id';
  static String conviteById(String id) => '/convites/$id';

  // 404
  static const notFound = '/404';
}
```

---

## Passo 3: Configurar GoRouter com Riverpod

Criar `lib/core/routing/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/application/auth_providers.dart';
import 'app_routes.dart';
import 'auth_listenable.dart';

// Importar todas as páginas
import '../../features/auth/ui/login_page.dart';
import '../../features/auth/ui/registro_page.dart';
import '../../features/auth/ui/recuperar_senha_page.dart';
import '../../features/lista_compras/ui/pages/home_page.dart';
import '../../features/lista_compras/ui/pages/lista_detalhe_page.dart';
import '../../features/lista_compras/ui/pages/favoritas_page.dart';
import '../../features/perfil/ui/perfil_page.dart';
import '../../features/convites/ui/convites_page.dart';
import '../../features/shared/ui/not_found_page.dart';
import '../../features/shared/ui/app_shell.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
AuthListenable authListenable(ref) {
  final listenable = AuthListenable();
  ref.onDispose(listenable.dispose);
  return listenable;
}

@riverpod
GoRouter appRouter(ref) {
  final authState = ref.watch(authStateProvider);
  final authNotifier = ref.watch(authListenableProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,

    // ── Redirect global ──
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final currentPath = state.matchedLocation;

      // Rotas que não exigem auth
      const publicRoutes = [
        AppRoutes.login,
        AppRoutes.registro,
        AppRoutes.recuperarSenha,
      ];
      final isPublicRoute = publicRoutes.contains(currentPath);

      // Não logado tentando acessar rota protegida
      if (!isLoggedIn && !isPublicRoute) {
        return AppRoutes.login;
      }

      // Logado tentando acessar rota pública (ex: login)
      if (isLoggedIn && isPublicRoute) {
        return AppRoutes.home;
      }

      // Sem redirect necessário
      return null;
    },

    // ── Rotas ──
    routes: [
      // Auth routes (sem shell/bottom nav)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.registro,
        builder: (context, state) => const RegistroPage(),
      ),
      GoRoute(
        path: AppRoutes.recuperarSenha,
        builder: (context, state) => const RecuperarSenhaPage(),
      ),

      // Main app com Shell (BottomNavigationBar)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.favoritas,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FavoritasPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.perfil,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PerfilPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.convites,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ConvitesPage(),
            ),
          ),
        ],
      ),

      // Rota de detalhe (fora do shell — tela cheia)
      GoRoute(
        path: AppRoutes.lista,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ListaDetalhePage(listaId: id);
        },
      ),

      // 404 fallback
      GoRoute(
        path: AppRoutes.notFound,
        builder: (context, state) => const NotFoundPage(),
      ),
    ],

    // ── Error handler (404 automático) ──
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}
```

---

## Passo 4: Gerar código

```powershell
dart run build_runner build --delete-conflicting-outputs
```

---

## Passo 5: Conectar no MaterialApp

Atualizar `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class ListaAiApp extends ConsumerWidget {
  const ListaAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Lista AI',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## Passo 6: Navegação programática

```dart
// Em qualquer widget:
context.go(AppRoutes.home);                        // substituir rota
context.push(AppRoutes.listaById('abc123'));         // empilhar rota
context.pop();                                       // voltar

// Via ref (fora de BuildContext):
ref.read(appRouterProvider).go(AppRoutes.login);
```

---

## Diferenças Angular → Flutter

| Angular | Flutter (GoRouter) |
|---|---|
| `RouterModule.forRoot([...])` | `GoRouter(routes: [...])` |
| `canActivate: [AuthGuard]` | `redirect: (context, state) => ...` |
| `router.navigate(['/lista', id])` | `context.push(AppRoutes.listaById(id))` |
| `<router-outlet>` | `ShellRoute` com `child` |
| Route resolver | `state.pathParameters['id']` |

---

## ✅ Checklist de Conclusão

- [ ] `AuthListenable` com `ChangeNotifier` + dispose correto (sem memory leak!)
- [ ] `AppRoutes` com constantes de rotas e helpers tipados
- [ ] `GoRouter` com `refreshListenable` (NÃO `GoRouterRefreshStream`)
- [ ] Redirect global: protege rotas privadas, redireciona logado
- [ ] `ShellRoute` para BottomNav nas rotas principais
- [ ] Rota de lista detalhe fora do shell (tela cheia)
- [ ] `errorBuilder` para 404 fallback
- [ ] `MaterialApp.router` configurado com `routerConfig`
- [ ] Navegação programática com `context.go`, `context.push`, `context.pop`
- [ ] `build_runner build` sem erros
