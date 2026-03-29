# Task 11 — Firebase Config e Providers (Riverpod)

**Fase**: Core Infrastructure  
**Dependências**: Task 02, Task 03  
**Resultado**: Providers Riverpod para Firebase e Firestore

---

## Passo 1: Criar firebase_providers.dart

Criar `lib/core/infra/firebase/firebase_providers.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para FirebaseAuth.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider para Firestore.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para Analytics.
final analyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});
```

## Passo 2: Atualizar main.dart para usar Riverpod

Atualizar `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: ListaAiApp(),
    ),
  );
}
```

## Passo 3: Atualizar app.dart para ConsumerWidget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListaAiApp extends ConsumerWidget {
  const ListaAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Lista AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Lista AI - Riverpod OK!'),
        ),
      ),
    );
  }
}
```

## Passo 4: Rodar e validar

```powershell
flutter run
```

---

## ✅ Checklist de Conclusão

- [ ] `firebase_providers.dart` com providers de Auth, Firestore e Analytics
- [ ] `main.dart` envolve app com `ProviderScope`
- [ ] `app.dart` é `ConsumerWidget`
- [ ] App roda sem erros
