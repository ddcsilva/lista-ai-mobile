# Task 46 — Offline Support

**Fase**: Infraestrutura / UI  
**Dependências**: Task 13 (ConnectionService), Task 14 (Firestore repos)  
**Resultado**: App funciona offline com Firestore persistence + indicador de conexão

---

## Passo 1: Habilitar Firestore offline persistence

No `lib/core/firebase/firebase_init.dart`, garantir que persistence está habilitada:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Firestore offline persistence (habilitado por padrão no mobile, mas garantir)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
```

> **Nota**: No Flutter mobile (Android/iOS) o Firestore já tem persistence habilitada
> por padrão, diferente da web. Este passo garante e configura cache unlimited.

---

## Passo 2: Criar indicator de conexão

Criar `lib/shared/ui/connection_indicator.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection/connection_service.dart';

class ConnectionIndicator extends ConsumerWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectionStatusProvider);

    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 14,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 6),
          Text(
            'Sem conexão — alterações serão sincronizadas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Passo 3: Adicionar ConnectionIndicator ao AppShell

No `app_shell.dart`, adicionar abaixo da AppBar:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    appBar: ...,
    drawer: ...,
    body: Column(
      children: [
        const ConnectionIndicator(), // ← indicador offline
        Expanded(child: child),
      ],
    ),
  );
}
```

---

## Passo 4: Configurar ConnectionService provider

No `lib/core/connection/connection_service.dart`:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectionStatusProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return results.any((r) => r != ConnectivityResult.none);
  });
});

// Provider simplificado para uso síncrono
final isOnlineProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(connectionStatusProvider);
  return asyncValue.when(
    data: (online) => online,
    loading: () => true, // assume online enquanto carrega
    error: (_, __) => true,
  );
});
```

---

## Passo 5: Source metadata nos documentos Firestore

Ao usar `snapshots()` do Firestore, verificar se dados são do cache:

```dart
// Nos repositórios Firestore, ao observar docs:
FirebaseFirestore.instance
    .collection('listas')
    .doc(id)
    .snapshots(includeMetadataChanges: true)
    .map((snap) {
      final fromCache = snap.metadata.isFromCache;
      // Pode usar para UI indicator (ex: "dados offline")
      return snap;
    });
```

---

## ✅ Checklist de Conclusão

- [ ] Firestore persistence habilitada com cache unlimited
- [ ] ConnectionIndicator no topo (barra laranja/vermelha)
- [ ] "Sem conexão — alterações serão sincronizadas"
- [ ] Indicador desaparece quando volta online
- [ ] Provider de status de conexão com connectivity_plus
- [ ] CRUD funciona offline (Firestore cache)
- [ ] Sincroniza automaticamente ao voltar online
