# Task 29 — Login Page UI

**Fase**: UI  
**Dependências**: Task 28 (router)  
**Resultado**: Tela de login com formulário de email/senha e botão Google

---

## Passo 1: Substituir o placeholder por UI real

Substituir `lib/features/auth/ui/login_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomeController = TextEditingController();
  
  bool _isRegistro = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Ícone
                Icon(
                  Icons.shopping_cart_rounded,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Lista AI',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sua lista de compras inteligente',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // Botão Google
                _buildBotaoGoogle(colorScheme),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Formulário Email/Senha
                _buildFormulario(theme, colorScheme),
                const SizedBox(height: 16),

                // Erro
                if (_erro != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _erro!,
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Botão principal
                _buildBotaoPrincipal(colorScheme),
                const SizedBox(height: 16),

                // Toggle registro/login
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegistro = !_isRegistro;
                      _erro = null;
                    });
                  },
                  child: Text(
                    _isRegistro
                        ? 'Já tem conta? Faça login'
                        : 'Não tem conta? Registre-se',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoGoogle(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _loginGoogle,
        icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        label: const Text('Continuar com Google'),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFormulario(ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Nome (só no registro)
          if (_isRegistro)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (_isRegistro && (v == null || v.trim().isEmpty)) {
                    return 'Informe seu nome';
                  }
                  return null;
                },
              ),
            ),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            validator: (v) {
              if (v == null || !v.contains('@')) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Senha
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
            validator: (v) {
              if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoPrincipal(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLoading ? null : _submitForm,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(_isRegistro ? 'Criar Conta' : 'Entrar'),
      ),
    );
  }

  // --- Handlers serão implementados na Task 30 ---
  
  Future<void> _loginGoogle() async {
    // TODO: Task 30
  }

  Future<void> _submitForm() async {
    // TODO: Task 30
  }
}
```

---

## ✅ Checklist de Conclusão

- [ ] Layout: logo + título + subtítulo
- [ ] Botão "Continuar com Google"
- [ ] Divider "ou"
- [ ] Formulário com Email + Senha (+ Nome no modo registro)
- [ ] Toggle login/registro
- [ ] Validação de formulário (email, senha min 6, nome obrigatório)
- [ ] Toggle visibilidade senha
- [ ] Loading state no botão
- [ ] Exibição de erro
