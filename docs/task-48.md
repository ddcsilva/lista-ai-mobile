# Task 48 — Testes Unitários (Domain + Services)

**Fase**: Qualidade  
**Dependências**: Todas as tasks de domain e services  
**Resultado**: Testes unitários para modelos, regras de negócio e services

---

## Passo 1: Configurar dependências de teste

No `pubspec.yaml`, em `dev_dependencies` (já deve ter):

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  fake_cloud_firestore: ^3.0.0  # mock do Firestore
```

Rodar `flutter pub get`.

---

## Passo 2: Testes dos modelos de domínio

Criar `test/domain/models/categoria_item_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_ai/domain/models/categoria_item.dart';

void main() {
  group('CategoriaItem', () {
    test('inferirCategoria deve retornar Laticinios para "leite"', () {
      expect(CategoriaItem.inferir('leite'), CategoriaItem.laticinios);
    });

    test('inferirCategoria deve retornar Hortifruti para "banana"', () {
      expect(CategoriaItem.inferir('banana'), CategoriaItem.hortifruti);
    });

    test('inferirCategoria deve retornar Outros quando não encontrar', () {
      expect(CategoriaItem.inferir('xyz123'), CategoriaItem.outros);
    });

    test('inferirCategoria deve ser case-insensitive', () {
      expect(CategoriaItem.inferir('LEITE'), CategoriaItem.laticinios);
      expect(CategoriaItem.inferir('Leite'), CategoriaItem.laticinios);
    });

    test('todas as categorias devem ter emoji e label', () {
      for (final cat in CategoriaItem.values) {
        expect(cat.emoji, isNotEmpty);
        expect(cat.label, isNotEmpty);
      }
    });
  });
}
```

---

## Passo 3: Testes das regras de domínio

Criar `test/domain/rules/item_rules_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_ai/domain/rules/item_rules.dart';

void main() {
  group('ItemRules', () {
    group('validarNome', () {
      test('deve aceitar nome válido', () {
        expect(ItemRules.validarNome('Leite'), isNull);
      });

      test('deve rejeitar nome vazio', () {
        expect(ItemRules.validarNome(''), isNotNull);
        expect(ItemRules.validarNome('  '), isNotNull);
      });

      test('deve rejeitar nome > 100 caracteres', () {
        final nomeGrande = 'a' * 101;
        expect(ItemRules.validarNome(nomeGrande), isNotNull);
      });
    });

    group('validarQuantidade', () {
      test('deve aceitar quantidade entre 1 e 99', () {
        expect(ItemRules.validarQuantidade(1), isNull);
        expect(ItemRules.validarQuantidade(50), isNull);
        expect(ItemRules.validarQuantidade(99), isNull);
      });

      test('deve rejeitar quantidade fora do range', () {
        expect(ItemRules.validarQuantidade(0), isNotNull);
        expect(ItemRules.validarQuantidade(100), isNotNull);
        expect(ItemRules.validarQuantidade(-1), isNotNull);
      });
    });

    group('validarNota', () {
      test('deve aceitar nota até 200 caracteres', () {
        expect(ItemRules.validarNota('Nota válida'), isNull);
      });

      test('deve rejeitar nota > 200 caracteres', () {
        final notaGrande = 'a' * 201;
        expect(ItemRules.validarNota(notaGrande), isNotNull);
      });

      test('deve aceitar nota nula', () {
        expect(ItemRules.validarNota(null), isNull);
      });
    });
  });
}
```

Criar `test/domain/rules/lista_compartilhada_rules_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_ai/domain/rules/lista_compartilhada_rules.dart';

void main() {
  group('ListaCompartilhadaRules', () {
    test('MAX_MEMBROS deve ser 5', () {
      expect(ListaCompartilhadaRules.maxMembros, 5);
    });

    test('MAX_LISTAS_COMPARTILHADAS deve ser 3', () {
      expect(ListaCompartilhadaRules.maxListasCompartilhadas, 3);
    });

    test('CONVITE_HORAS deve ser 24', () {
      expect(ListaCompartilhadaRules.conviteHoras, 24);
    });

    test('podeAdicionarMembro deve ser true quando < max', () {
      expect(
        ListaCompartilhadaRules.podeAdicionarMembro(membrosAtuais: 4),
        isTrue,
      );
    });

    test('podeAdicionarMembro deve ser false quando >= max', () {
      expect(
        ListaCompartilhadaRules.podeAdicionarMembro(membrosAtuais: 5),
        isFalse,
      );
    });

    test('conviteExpirado deve retornar true após 24h', () {
      final criacao = DateTime.now().subtract(const Duration(hours: 25));
      expect(ListaCompartilhadaRules.conviteExpirado(criacao), isTrue);
    });

    test('conviteExpirado deve retornar false antes de 24h', () {
      final criacao = DateTime.now().subtract(const Duration(hours: 1));
      expect(ListaCompartilhadaRules.conviteExpirado(criacao), isFalse);
    });
  });
}
```

---

## Passo 4: Testes do CommandParserService

Criar `test/application/command_parser_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_ai/application/command_parser_service.dart';

void main() {
  late CommandParserService parser;

  setUp(() {
    parser = CommandParserService();
  });

  group('CommandParserService', () {
    test('deve parsear nome simples', () {
      final result = parser.parse('leite');
      expect(result.nome, 'leite');
      expect(result.quantidade, 1);
    });

    test('deve parsear quantidade + nome ("2 leite")', () {
      final result = parser.parse('2 leite');
      expect(result.nome, 'leite');
      expect(result.quantidade, 2);
    });

    test('deve parsear número por extenso ("duas bananas")', () {
      final result = parser.parse('duas bananas');
      expect(result.nome, 'bananas');
      expect(result.quantidade, 2);
    });

    test('deve parsear "um quilo de arroz"', () {
      final result = parser.parse('um quilo de arroz');
      expect(result.nome, contains('arroz'));
      expect(result.quantidade, 1);
    });

    test('deve inferir categoria quando possível', () {
      final result = parser.parse('leite');
      expect(result.categoria, isNotNull);
      // leite → laticínios
    });

    test('deve lidar com espaços extras', () {
      final result = parser.parse('  3   pão  francês  ');
      expect(result.nome.trim(), isNotEmpty);
      expect(result.quantidade, 3);
    });

    test('deve retornar quantidade 1 quando não especificada', () {
      final result = parser.parse('maçã');
      expect(result.quantidade, 1);
    });
  });
}
```

---

## Passo 5: Rodar testes

```bash
flutter test
```

Verificar que todos passam. Corrigir falhas antes de prosseguir.

---

## ✅ Checklist de Conclusão

- [ ] Dependências de teste: mockito, build_runner, fake_cloud_firestore
- [ ] Testes CategoriaItem: inferir, emoji, label
- [ ] Testes ItemRules: validarNome, validarQuantidade, validarNota
- [ ] Testes ListaCompartilhadaRules: limites, expiração
- [ ] Testes CommandParserService: parse simples, qtd, extenso, categoria
- [ ] `flutter test` passa sem erros
