# Task 12 — Auth Service (Riverpod)

**Fase**: Core Infrastructure  
**Dependências**: Task 11  
**Resultado**: Autenticação Google + Email/Senha com estado reativo via Riverpod

---

## Contexto

No Angular, `AuthService` usa signals. No Flutter, usamos um `StreamProvider` do Riverpod que escuta o `authStateChanges()` do Firebase Auth.

---

## Passo 1: Criar AuthUser model

Criar `lib/core/auth/auth_user.dart`:

```dart
/// Modelo simplificado do usuário autenticado.
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });
}
```

## Passo 2: Criar Auth Provider (estado reativo)

Criar `lib/core/auth/auth_provider.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infra/firebase/firebase_providers.dart';
import 'auth_user.dart';

/// Stream do estado de autenticação.
/// Emite AuthUser quando logado, null quando deslogado.
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges().map((firebaseUser) {
    if (firebaseUser == null) return null;
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
    );
  });
});

/// Conveniência: retorna o user atual (pode ser null).
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Conveniência: retorna true se está logado.
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Conveniência: retorna true enquanto carrega o estado inicial.
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});
```

## Passo 3: Criar Auth Service (ações)

Criar `lib/core/auth/auth_service.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../infra/firebase/firebase_providers.dart';

/// Serviço com as ações de autenticação.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  /// Login com Google.
  Future<void> loginGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Cancelado pelo usuário

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  /// Login com email e senha.
  Future<void> loginEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  /// Registrar novo usuário com email, senha e nome.
  Future<void> registrar(String email, String password, String nome) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(nome.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  /// Logout.
  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
```

## Passo 4: Verificar compilação

```powershell
flutter analyze
```

---

## ✅ Checklist de Conclusão

- [ ] `AuthUser` model simples (uid, email, displayName, photoURL)
- [ ] `authStateProvider` — StreamProvider escutando `authStateChanges()`
- [ ] `currentUserProvider` — user atual ou null
- [ ] `isLoggedInProvider` / `isAuthLoadingProvider` — conveniências
- [ ] `AuthService` com `loginGoogle()`, `loginEmail()`, `registrar()`, `logout()`
- [ ] Google Sign-In integrado
- [ ] Compila sem erros
