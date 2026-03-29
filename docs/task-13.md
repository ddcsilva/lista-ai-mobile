# Task 13 — Connection Service

**Fase**: Core Infrastructure  
**Dependências**: Task 03 (connectivity_plus), Task 11  
**Resultado**: Provider que monitora estado da conexão (online/offline)

---

## Passo 1: Criar ConnectionService

Criar `lib/core/services/connection_service.dart`:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que emite o estado de conectividade em tempo real.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return results.any((r) => r != ConnectivityResult.none);
  });
});

/// Conveniência: retorna true se está online.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).valueOrNull ?? true;
});
```

---

## Nota

No Angular, `ConnectionService` também tinha um `isReconnecting` signal com timeout de 2s. Se quiser replicar isso no Flutter, pode expandir com um `StateNotifier`:

```dart
class ConnectionNotifier extends StateNotifier<ConnectionState> {
  // ... lógica de reconnecting com Timer
}
```

Porém, para o MVP, o provider simples `isOnlineProvider` é suficiente. A lógica de "reconectando" pode ser adicionada depois.

---

## ✅ Checklist de Conclusão

- [ ] `connectivityProvider` — StreamProvider com `connectivity_plus`
- [ ] `isOnlineProvider` — true/false para conveniência
- [ ] Compila sem erros
