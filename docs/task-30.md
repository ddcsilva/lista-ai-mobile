# Task 30 — Login Page Logic

**Fase**: UI (Lógica)  
**Dependências**: Task 29 (Login UI), Task 12 (Auth Service)  
**Resultado**: Login/registro funcional com Google e Email/Senha

---

## Passo 1: Criar provider de estado de auth

Criar `lib/features/auth/providers/auth_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_service.dart';

// Re-exporta o authServiceProvider e authStateProvider já criados na Task 12
// Este arquivo centraliza imports de auth para as features de UI
```

---

## Passo 2: Implementar handlers na LoginPage

Atualizar `lib/features/auth/ui/login_page.dart` com a lógica:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_service.dart';

// ... (manter toda a UI da Task 29) ...

// Implementar os handlers:

Future<void> _loginGoogle() async {
  setState(() {
    _isLoading = true;
    _erro = null;
  });

  try {
    final authService = ref.read(authServiceProvider);
    await authService.loginComGoogle();
    // Router vai redirecionar automaticamente via authStateProvider
  } catch (e) {
    setState(() {
      _erro = _traduzirErro(e);
    });
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _erro = null;
  });

  try {
    final authService = ref.read(authServiceProvider);
    final email = _emailController.text.trim();
    final senha = _passwordController.text;

    if (_isRegistro) {
      final nome = _nomeController.text.trim();
      await authService.registrarComEmail(email, senha, nome);
    } else {
      await authService.loginComEmail(email, senha);
    }
    // Router vai redirecionar automaticamente
  } catch (e) {
    setState(() {
      _erro = _traduzirErro(e);
    });
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

String _traduzirErro(dynamic erro) {
  final msg = erro.toString().toLowerCase();
  if (msg.contains('user-not-found')) {
    return 'Usuário não encontrado';
  }
  if (msg.contains('wrong-password') || msg.contains('invalid-credential')) {
    return 'Senha incorreta';
  }
  if (msg.contains('email-already-in-use')) {
    return 'Este e-mail já está cadastrado';
  }
  if (msg.contains('weak-password')) {
    return 'Senha muito fraca';
  }
  if (msg.contains('invalid-email')) {
    return 'E-mail inválido';
  }
  if (msg.contains('too-many-requests')) {
    return 'Muitas tentativas. Tente novamente em alguns minutos';
  }
  if (msg.contains('network-request-failed')) {
    return 'Sem conexão com a internet';
  }
  if (msg.contains('popup-closed-by-user') || msg.contains('canceled')) {
    return 'Login cancelado';
  }
  return 'Erro ao fazer login. Tente novamente';
}
```

---

## Passo 3: Adicionar métodos ao AuthService (se não existem)

No `lib/core/auth/auth_service.dart`, garantir que existam:

```dart
Future<void> loginComGoogle() async {
  final googleUser = await _googleSignIn.signIn();
  if (googleUser == null) throw Exception('canceled');
  
  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  
  await _firebaseAuth.signInWithCredential(credential);
}

Future<void> loginComEmail(String email, String senha) async {
  await _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: senha,
  );
}

Future<void> registrarComEmail(String email, String senha, String nome) async {
  final result = await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: senha,
  );
  await result.user?.updateDisplayName(nome);
}

Future<void> logout() async {
  await Future.wait([
    _firebaseAuth.signOut(),
    _googleSignIn.signOut(),
  ]);
}

User? get usuarioAtual => _firebaseAuth.currentUser;

Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
```

---

## Passo 4: Teste manual

1. `flutter run`
2. Verificar: tela de login aparece
3. Testar criar conta com email/senha
4. Testar login com Google
5. Após login, deve redirecionar para `/lista`
6. Verificar se erros (email inválido, senha curta) aparecem corretamente

---

## ✅ Checklist de Conclusão

- [ ] Handler `_loginGoogle()` funcional
- [ ] Handler `_submitForm()` funcional (login e registro)
- [ ] Tradução de erros Firebase para PT-BR
- [ ] Loading indicator durante operação
- [ ] Redirecionamento automático após login
- [ ] Erros exibidos no UI
- [ ] `mounted` check antes de setState
