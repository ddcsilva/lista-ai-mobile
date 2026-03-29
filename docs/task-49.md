# Task 49 — Widget Tests (UI)

**Fase**: Qualidade  
**Dependências**: Tasks de UI (29-47), Task 48 (test config)  
**Resultado**: Testes de widget para as telas principais

---

## Passo 1: Teste da LoginPage

Criar `test/features/auth/ui/login_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lista_ai/features/auth/ui/login_page.dart';

void main() {
  group('LoginPage', () {
    testWidgets('deve exibir logo e título', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.text('Lista AI'), findsOneWidget);
      expect(find.text('Sua lista de compras inteligente'), findsOneWidget);
    });

    testWidgets('deve exibir botão Google', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.text('Continuar com Google'), findsOneWidget);
    });

    testWidgets('deve exibir campos email e senha', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('deve alternar entre login e registro', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginPage()),
        ),
      );

      // Modo login — não tem campo Nome
      expect(find.text('Nome'), findsNothing);
      expect(find.text('Entrar'), findsOneWidget);

      // Clicar em "Não tem conta?"
      await tester.tap(find.text('Não tem conta? Registre-se'));
      await tester.pumpAndSettle();

      // Modo registro — tem campo Nome
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Criar Conta'), findsOneWidget);
    });

    testWidgets('deve validar email vazio', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginPage()),
        ),
      );

      // Tentar submeter com campos vazios
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('deve validar senha curta', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginPage()),
        ),
      );

      // Digitar email válido mas senha curta
      await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });
  });
}
```

---

## Passo 2: Teste do EmptyState

Criar `test/features/lista/ui/widgets/empty_state_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_ai/features/lista/ui/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('deve exibir mensagem e ícone', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              mensagem: 'Lista vazia!',
              icone: Icons.shopping_cart,
            ),
          ),
        ),
      );

      expect(find.text('Lista vazia!'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('deve exibir subtítulo quando fornecido', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              mensagem: 'Vazio',
              icone: Icons.list,
              subtitulo: 'Adicione itens',
            ),
          ),
        ),
      );

      expect(find.text('Adicione itens'), findsOneWidget);
    });

    testWidgets('deve exibir ação quando fornecida', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              mensagem: 'Vazio',
              icone: Icons.list,
              acao: ElevatedButton(
                onPressed: () {},
                child: const Text('Criar'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Criar'), findsOneWidget);
    });
  });
}
```

---

## Passo 3: Teste do ListaSummary

Criar `test/features/lista/ui/widgets/lista_summary_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_ai/features/lista/ui/widgets/lista_summary.dart';

void main() {
  group('ListaSummary', () {
    testWidgets('deve exibir progresso', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListaSummary(
              total: 10,
              comprados: 3,
              percentual: 0.3,
            ),
          ),
        ),
      );

      expect(find.text('3 de 10 itens comprados'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('deve exibir concluído quando 100%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListaSummary(
              total: 5,
              comprados: 5,
              percentual: 1.0,
            ),
          ),
        ),
      );

      expect(find.textContaining('concluídas'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });
}
```

---

## Passo 4: Teste do ConfirmDialog

Criar `test/shared/ui/confirm_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_ai/shared/ui/confirm_dialog.dart';

void main() {
  group('ConfirmDialog', () {
    testWidgets('deve exibir título e mensagem', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfirmDialog(
              titulo: 'Confirmar?',
              mensagem: 'Tem certeza?',
            ),
          ),
        ),
      );

      expect(find.text('Confirmar?'), findsOneWidget);
      expect(find.text('Tem certeza?'), findsOneWidget);
    });

    testWidgets('deve retornar true ao confirmar', (tester) async {
      bool? resultado;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  resultado = await ConfirmDialog.show(
                    context,
                    titulo: 'Teste',
                    mensagem: 'Confirmar?',
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(resultado, isTrue);
    });

    testWidgets('deve retornar false ao cancelar', (tester) async {
      bool? resultado;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  resultado = await ConfirmDialog.show(
                    context,
                    titulo: 'Teste',
                    mensagem: 'Confirmar?',
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(resultado, isFalse);
    });
  });
}
```

---

## Passo 5: Rodar testes

```bash
flutter test
```

---

## ✅ Checklist de Conclusão

- [ ] LoginPage: logo, título, campos, toggle login/registro, validações
- [ ] EmptyState: mensagem, ícone, subtítulo, ação
- [ ] ListaSummary: progresso numérico, barra, estado completo
- [ ] ConfirmDialog: título, mensagem, retorno true/false
- [ ] Todos os testes passam com `flutter test`
