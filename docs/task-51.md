# Task 51 — Firebase Crashlytics + Error Boundary Global

**Fase**: Infraestrutura (Observabilidade)  
**Dependências**: Task 03 (firebase_crashlytics instalado), Task 02 (Firebase init)  
**Resultado**: Captura automática de crashes, erros Flutter e erros async não tratados

---

## Contexto

Firebase Crashlytics captura automaticamente crashes nativos. Mas para erros de Dart (exceções não capturadas, erros no framework Flutter), precisamos configurar manualmente os handlers.

---

## Passo 1: Inicializar Crashlytics no main

Atualizar `lib/main.dart`:

```dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  // Capturar TODOS os erros async não tratados
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Capturar erros do framework Flutter (build, layout, paint)
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Capturar erros da plataforma (isolates)
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Desabilitar em debug para não poluir dashboard
    if (kDebugMode) {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(false);
    }

    runApp(
      const ProviderScope(
        child: ListaAiApp(),
      ),
    );
  }, (error, stack) {
    // Erros async não capturados dentro do zone
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}
```

---

## Passo 2: Criar provider para Crashlytics

Criar `lib/core/infra/crashlytics/crashlytics_provider.dart`:

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crashlytics_provider.g.dart';

@riverpod
FirebaseCrashlytics crashlytics(ref) => FirebaseCrashlytics.instance;
```

---

## Passo 3: Setar identificador do usuário

Atualizar os providers de auth para setar o user ID no Crashlytics quando logar:

```dart
// Em auth_providers.dart, adicionar um listener:
@riverpod
void crashlyticsUserSync(ref) {
  final user = ref.watch(currentUserProvider);
  final crashlytics = ref.watch(crashlyticsProvider);

  if (user != null) {
    crashlytics.setUserIdentifier(user.uid);
  } else {
    crashlytics.setUserIdentifier('');
  }
}
```

---

## Passo 4: Helper para captura de erros em Notifiers

Criar `lib/core/utils/error_reporter.dart`:

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Reporta um erro ao Crashlytics com contexto adicional.
Future<void> reportError(
  Object error,
  StackTrace stack, {
  String? reason,
  bool fatal = false,
}) async {
  await FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: reason ?? 'App error',
    fatal: fatal,
  );
}

/// Log customizado para breadcrumbs no Crashlytics.
void crashlyticsLog(String message) {
  FirebaseCrashlytics.instance.log(message);
}
```

---

## Passo 5: Usar nos Notifiers

```dart
// Em qualquer Notifier, no bloco catch:
state = await AsyncValue.guard(() async {
  try {
    await _repo.criarLista(novaLista);
  } catch (e, stack) {
    reportError(e, stack, reason: 'Erro ao criar lista');
    rethrow;
  }
});
```

---

## Passo 6: Criar Riverpod Observer para erros

Criar `lib/core/infra/riverpod_error_observer.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint('Provider error [${provider.name}]: $error');
    }
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Provider error: ${provider.name ?? provider.runtimeType}',
    );
  }
}
```

Registrar no `ProviderScope`:

```dart
ProviderScope(
  observers: [CrashlyticsProviderObserver()],
  child: const ListaAiApp(),
)
```

---

## ✅ Checklist de Conclusão

- [ ] `runZonedGuarded` captura erros async
- [ ] `FlutterError.onError` captura erros do framework  
- [ ] `PlatformDispatcher.instance.onError` captura erros de platform isolates
- [ ] Crashlytics desabilitado em debug mode
- [ ] Provider `crashlyticsProvider` para DI
- [ ] User ID sincronizado com auth state
- [ ] `reportError` helper para uso manual
- [ ] `CrashlyticsProviderObserver` captura erros de providers automaticamente
- [ ] `build_runner build` sem erros
