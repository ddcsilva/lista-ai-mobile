# Task 53 — Firebase Analytics — Eventos de Uso

**Fase**: Infraestrutura (Observabilidade)  
**Dependências**: Task 03 (firebase_analytics), Task 28 (GoRouter)  
**Resultado**: Rastreamento automático de navegação + eventos custom de uso

---

## Contexto

O Firebase Analytics já está nos deps (task-03) mas não estava sendo usado. Esta task configura tracking automático de rotas e define eventos custom importantes para entender o uso do app.

---

## Passo 1: Configurar observer de navegação

Atualizar `lib/core/routing/app_router.dart` para incluir o observer:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

@riverpod
GoRouter appRouter(ref) {
  final authState = ref.watch(authStateProvider);
  final authNotifier = ref.watch(authListenableProvider);

  return GoRouter(
    // ... config existente ...
    
    // Adicionar observer para tracking automático de page views:
    observers: [
      GoRouterObserver(),
    ],
  );
}
```

Criar `lib/core/infra/analytics/go_router_observer.dart`:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class GoRouterObserver extends NavigatorObserver {
  final _analytics = FirebaseAnalytics.instance;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _logScreen(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _logScreen(newRoute);
  }

  void _logScreen(Route route) {
    final name = route.settings.name;
    if (name != null) {
      _analytics.logScreenView(screenName: name);
    }
  }
}
```

---

## Passo 2: Criar AnalyticsService

Criar `lib/core/infra/analytics/analytics_service.dart`:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

@riverpod
AnalyticsService analyticsService(ref) => AnalyticsService();

class AnalyticsService {
  final _analytics = FirebaseAnalytics.instance;

  // ── Lista events ──

  Future<void> logCriarLista() async {
    await _analytics.logEvent(name: 'criar_lista');
  }

  Future<void> logExcluirLista() async {
    await _analytics.logEvent(name: 'excluir_lista');
  }

  Future<void> logCompartilharLista() async {
    await _analytics.logEvent(name: 'compartilhar_lista');
  }

  // ── Item events ──

  Future<void> logAdicionarItem({required String metodo}) async {
    await _analytics.logEvent(
      name: 'adicionar_item',
      parameters: {'metodo': metodo}, // 'texto', 'voz'
    );
  }

  Future<void> logComprarItem() async {
    await _analytics.logEvent(name: 'comprar_item');
  }

  // ── Voz events ──

  Future<void> logUsarVoz({required int itensDetectados}) async {
    await _analytics.logEvent(
      name: 'usar_voz',
      parameters: {'itens_detectados': itensDetectados},
    );
  }

  Future<void> logUsarTts() async {
    await _analytics.logEvent(name: 'usar_tts');
  }

  // ── Modo mercado ──

  Future<void> logModoMercado({required bool ativo}) async {
    await _analytics.logEvent(
      name: 'modo_mercado',
      parameters: {'ativo': ativo ? 1 : 0},
    );
  }

  // ── Export events ──

  Future<void> logExportarLista({required String tipo}) async {
    await _analytics.logEvent(
      name: 'exportar_lista',
      parameters: {'tipo': tipo}, // 'clipboard', 'share'
    );
  }

  // ── Auth events (complementar ao Firebase Auth automático) ──

  Future<void> logLogin({required String metodo}) async {
    await _analytics.logLogin(loginMethod: metodo);
  }

  Future<void> logSignUp({required String metodo}) async {
    await _analytics.logSignUp(signUpMethod: metodo);
  }

  // ── User properties ──

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
```

---

## Passo 3: Integrar nos Notifiers

Exemplo — adicionar tracking no `ListaNotifier`:

```dart
// Em lista_notifier.dart:
Future<String?> criarLista({required String nome}) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    // ... criar lista ...
    
    // Logar evento
    ref.read(analyticsServiceProvider).logCriarLista();
    
    return id;
  });
  return state.hasError ? null : state.value as String?;
}
```

Exemplo — tracking de voz no `VoiceInputNotifier`:

```dart
final itens = _parser.parse(transcriptFinal);
ref.read(analyticsServiceProvider).logUsarVoz(
  itensDetectados: itens.length,
);
```

---

## Passo 4: Gerar código

```powershell
dart run build_runner build --delete-conflicting-outputs
```

---

## ✅ Checklist de Conclusão

- [ ] `GoRouterObserver` registra page views automaticamente
- [ ] `AnalyticsService` com eventos tipados
- [ ] Eventos de lista: criar, excluir, compartilhar
- [ ] Eventos de item: adicionar (c/ método), comprar
- [ ] Eventos de voz: usar_voz (c/ itens), usar_tts
- [ ] Eventos de modo mercado
- [ ] Eventos de export (clipboard/share)
- [ ] Eventos de auth (login/signup c/ método)
- [ ] Integrado nos Notifiers relevantes
- [ ] `build_runner build` sem erros
