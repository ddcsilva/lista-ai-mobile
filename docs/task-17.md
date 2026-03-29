# Task 17 — Command Parser Service

**Fase**: Application Services  
**Dependências**: Task 10 (text_utils)  
**Resultado**: Parser de texto/voz que extrai itens com nome e quantidade

---

## Contexto

O `CommandParserService` é o core de inteligência do app. Ele recebe texto (digitado ou falado) e extrai uma lista de `ItemParseado` com nome e quantidade. Funciona 100% em português.

Exemplos:
- "2 tomates e 1 cebola" → [{nome: "Tomates", qtd: 2}, {nome: "Cebola", qtd: 1}]
- "quero comprar arroz, feijão e macarrão" → [{nome: "Arroz", qtd: 1}, ...]
- "três pacotes de leite" → [{nome: "Leite", qtd: 3}]

---

## Passo 1: Criar ItemParseado

Criar `lib/features/lista_compras/application/command_parser_service.dart`:

```dart
import '../../../shared/utils/text_utils.dart';

/// Item reconhecido pelo parser.
class ItemParseado {
  final String nome;
  final int quantidade;

  const ItemParseado({required this.nome, required this.quantidade});
}
```

## Passo 2: Definir os RegExp

```dart
final _prefixosRemover = RegExp(
  r'^(quero\s+comprar|adicionar|comprar|colocar|preciso\s+de|coloca|bota|põe|quero)\s+',
  caseSensitive: false,
);

final _separadores = RegExp(
  r'\s*(?:,\s*|\s+e\s+|\s+mais\s+)\s*',
  caseSensitive: false,
);

final _artigos = RegExp(
  r'^(de|do|da|dos|das|um|uma|uns|umas|o|a|os|as|e)\s+',
  caseSensitive: false,
);

final _unidades = RegExp(
  r'^(pacotes?|litros?|quilos?|kilos?|garrafas?|latas?|caixas?|sacos?|unidades?|dúzias?|potes?|kg|g|ml|l)\s+(de\s+)?',
  caseSensitive: false,
);

final _numeroRegex = RegExp(r'^(\d+)\s+');

final _numeroExtensoRegex = RegExp(
  r'^(um|uma|dois|duas|tr[êe]s|quatro|cinco|seis|sete|oito|nove|dez|onze|doze)\s+',
  caseSensitive: false,
);

const Map<String, int> _mapaNumerosPt = {
  'um': 1, 'uma': 1, 'dois': 2, 'duas': 2, 'tres': 3,
  'quatro': 4, 'cinco': 5, 'seis': 6, 'sete': 7, 'oito': 8,
  'nove': 9, 'dez': 10, 'onze': 11, 'doze': 12,
};
```

## Passo 3: Implementar normalização

```dart
String _normalizarNumero(String palavra) {
  return removerAcentos(palavra.toLowerCase());
}
```

## Passo 4: Implementar o parser

```dart
class CommandParserService {
  /// Parseia texto e retorna lista de itens reconhecidos.
  List<ItemParseado> parse(String texto) {
    if (texto.trim().isEmpty) return [];

    var textoLimpo = texto.trim();

    // Remove prefixos de comando
    textoLimpo = textoLimpo.replaceFirst(_prefixosRemover, '');

    // Separa por vírgula, "e", "mais"
    final segmentos = textoLimpo
        .split(_separadores)
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return segmentos
        .map((seg) => _parseSegmento(seg.trim()))
        .whereType<ItemParseado>()
        .toList();
  }

  ItemParseado? _parseSegmento(String segmento) {
    if (segmento.isEmpty) return null;

    var texto = segmento.trim();
    var quantidade = 1;

    // Tenta extrair número por extenso
    final matchExtenso = _numeroExtensoRegex.firstMatch(texto);
    if (matchExtenso != null) {
      final chave = _normalizarNumero(matchExtenso.group(1)!);
      quantidade = _mapaNumerosPt[chave] ?? 1;
      texto = texto.substring(matchExtenso.end);
    }

    // Se não encontrou extenso, tenta número dígito
    if (matchExtenso == null) {
      final matchNumero = _numeroRegex.firstMatch(texto);
      if (matchNumero != null) {
        quantidade = int.parse(matchNumero.group(1)!).clamp(1, 99);
        texto = texto.substring(matchNumero.end);
      }
    }

    // Remove unidades ("pacotes de", "litros de", etc.)
    texto = texto.replaceFirst(_unidades, '');

    // Remove artigos no início
    texto = texto.replaceFirst(_artigos, '');

    // Aplica Title Case
    final nome = toTitleCase(texto);

    if (nome.isEmpty) return null;

    return ItemParseado(nome: nome, quantidade: quantidade);
  }
}
```

## Passo 5: Criar provider Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commandParserProvider = Provider<CommandParserService>((ref) {
  return CommandParserService();
});
```

---

## Exemplos de parse esperados

| Input | Output |
|-------|--------|
| `"2 tomates"` | `[{nome: "Tomates", qtd: 2}]` |
| `"arroz e feijão"` | `[{nome: "Arroz", qtd: 1}, {nome: "Feijão", qtd: 1}]` |
| `"três pacotes de leite"` | `[{nome: "Leite", qtd: 3}]` |
| `"quero comprar 5 bananas, 2 maçãs e batata"` | `[{qtd: 5, "Bananas"}, {qtd: 2, "Maçãs"}, {qtd: 1, "Batata"}]` |
| `""` | `[]` |

---

## ✅ Checklist de Conclusão

- [ ] `ItemParseado` model (nome + quantidade)
- [ ] Regex para prefixos, separadores, artigos, unidades, números
- [ ] Mapa de números por extenso (um-doze)
- [ ] `parse()` — split + map + filter
- [ ] `_parseSegmento()` — extrai quantidade + limpa nome + Title Case
- [ ] Provider Riverpod criado
