# Task 04 — Criar Model: CategoriaItem (com mapeamento de palavras)

**Fase**: Domain Layer  
**Dependências**: Task 01  
**Resultado**: Enum de categorias, config visual, inferência automática por nome

---

## Contexto

No app Angular, `CategoriaItem` é um tipo string union com 9 categorias. Cada categoria tem:
- Label em português
- Cores Tailwind (que vamos converter para cores Flutter)
- SVG path (que vamos converter para ícones Material/custom)
- Mapeamento de palavras-chave para inferência automática

---

## Passo 1: Criar o enum CategoriaItem

Criar `lib/features/lista_compras/domain/models/categoria_item.dart`:

```dart
/// Categorias disponíveis para itens da lista de compras.
enum CategoriaItem {
  hortifruti,
  carnes,
  laticinios,
  padaria,
  limpeza,
  higiene,
  mercearia,
  congelados,
  outros,
}
```

## Passo 2: Criar CategoriaConfig

No mesmo arquivo, adicionar a classe de configuração:

```dart
import 'package:flutter/material.dart';

class CategoriaConfig {
  final CategoriaItem valor;
  final String label;
  final Color cor;
  final Color corBadge;
  final Color corBadgeTexto;
  final IconData icone;

  const CategoriaConfig({
    required this.valor,
    required this.label,
    required this.cor,
    required this.corBadge,
    required this.corBadgeTexto,
    required this.icone,
  });
}
```

## Passo 3: Definir a lista de categorias

```dart
const categoriaDefault = CategoriaItem.outros;

final List<CategoriaConfig> categorias = [
  CategoriaConfig(
    valor: CategoriaItem.hortifruti,
    label: 'Hortifruti',
    cor: Colors.green.shade600,
    corBadge: Colors.green.shade100,
    corBadgeTexto: Colors.green.shade700,
    icone: Icons.eco,
  ),
  CategoriaConfig(
    valor: CategoriaItem.carnes,
    label: 'Carnes',
    cor: Colors.red.shade600,
    corBadge: Colors.red.shade100,
    corBadgeTexto: Colors.red.shade700,
    icone: Icons.restaurant,
  ),
  CategoriaConfig(
    valor: CategoriaItem.laticinios,
    label: 'Laticínios',
    cor: Colors.blue.shade500,
    corBadge: Colors.blue.shade100,
    corBadgeTexto: Colors.blue.shade700,
    icone: Icons.water_drop,
  ),
  CategoriaConfig(
    valor: CategoriaItem.padaria,
    label: 'Padaria',
    cor: Colors.amber.shade600,
    corBadge: Colors.amber.shade100,
    corBadgeTexto: Colors.amber.shade700,
    icone: Icons.bakery_dining,
  ),
  CategoriaConfig(
    valor: CategoriaItem.limpeza,
    label: 'Limpeza',
    cor: Colors.cyan.shade600,
    corBadge: Colors.cyan.shade100,
    corBadgeTexto: Colors.cyan.shade700,
    icone: Icons.cleaning_services,
  ),
  CategoriaConfig(
    valor: CategoriaItem.higiene,
    label: 'Higiene',
    cor: Colors.pink.shade500,
    corBadge: Colors.pink.shade100,
    corBadgeTexto: Colors.pink.shade700,
    icone: Icons.sanitizer,
  ),
  CategoriaConfig(
    valor: CategoriaItem.mercearia,
    label: 'Mercearia',
    cor: Colors.orange.shade600,
    corBadge: Colors.orange.shade100,
    corBadgeTexto: Colors.orange.shade700,
    icone: Icons.shopping_cart,
  ),
  CategoriaConfig(
    valor: CategoriaItem.congelados,
    label: 'Congelados',
    cor: Colors.lightBlue.shade500,
    corBadge: Colors.lightBlue.shade100,
    corBadgeTexto: Colors.lightBlue.shade700,
    icone: Icons.ac_unit,
  ),
  CategoriaConfig(
    valor: CategoriaItem.outros,
    label: 'Outros',
    cor: Colors.grey.shade500,
    corBadge: Colors.grey.shade100,
    corBadgeTexto: Colors.grey.shade600,
    icone: Icons.inventory_2,
  ),
];
```

## Passo 4: Criar o mapeamento de palavras-chave

```dart
const Map<CategoriaItem, List<String>> _mapeamentoCategorias = {
  CategoriaItem.hortifruti: [
    'alface', 'tomate', 'cebola', 'batata', 'banana', 'laranja',
    'limao', 'abacaxi', 'manga', 'morango', 'pepino', 'cenoura', 'brocolis',
    'couve', 'alho', 'gengibre', 'melancia', 'uva', 'pera', 'abacate',
    'mamao', 'mandioca', 'berinjela', 'abobrinha', 'pimentao', 'salsa',
    'coentro', 'hortela', 'rucula', 'espinafre', 'cheiro-verde',
    'cheiro verde', 'beterraba', 'inhame', 'quiabo', 'jilo',
    'chuchu', 'maxixe', 'acelga', 'almeirao', 'maca fuji', 'maca verde',
    'maca gala', 'maca red',
  ],
  CategoriaItem.carnes: [
    'carne', 'frango', 'peixe', 'linguica', 'salsicha', 'hamburguer',
    'bacon', 'peito de frango', 'coxa', 'asa', 'file', 'costela', 'acem',
    'patinho', 'alcatra', 'picanha', 'contra-file', 'contrafile', 'coxao',
    'musculo', 'tilapia', 'salmao', 'sardinha', 'atum', 'camarao',
    'presunto', 'mortadela', 'salame', 'peito de peru', 'bisteca',
    'lombo', 'pernil', 'carneiro', 'cordeiro', 'vitela', 'copa',
  ],
  CategoriaItem.laticinios: [
    'leite', 'queijo', 'iogurte', 'manteiga', 'creme de leite',
    'requeijao', 'nata', 'ricota', 'mussarela', 'parmesao',
    'leite condensado', 'cream cheese', 'queijo minas', 'coalho',
    'provolone', 'gorgonzola', 'cottage',
  ],
  CategoriaItem.padaria: [
    'pao', 'pao de forma', 'bolo', 'biscoito', 'bolacha', 'torrada',
    'croissant', 'pao de queijo', 'rosquinha', 'bisnaga', 'brioche',
    'cuca', 'sonho', 'pao integral', 'pao frances',
  ],
  CategoriaItem.limpeza: [
    'detergente', 'sabao', 'agua sanitaria', 'desinfetante', 'limpador',
    'esponja', 'pano', 'vassoura', 'rodo', 'balde', 'saco de lixo',
    'amaciante', 'sabao em po', 'alvejante', 'lustra moveis',
    'limpa vidro', 'multiuso', 'cloro', 'cera',
  ],
  CategoriaItem.higiene: [
    'shampoo', 'condicionador', 'sabonete', 'pasta de dente',
    'escova de dente', 'desodorante', 'papel higienico', 'fio dental',
    'cotonete', 'absorvente', 'creme', 'protetor solar', 'perfume',
    'hidratante', 'algodao', 'fralda',
  ],
  CategoriaItem.mercearia: [
    'arroz', 'feijao', 'macarrao', 'oleo', 'azeite', 'acucar', 'sal',
    'farinha', 'cafe', 'cha', 'molho', 'ketchup', 'mostarda', 'maionese',
    'vinagre', 'tempero', 'extrato', 'milho', 'ervilha', 'atum',
    'sardinha', 'caldo', 'gelatina', 'achocolatado', 'granola', 'cereal',
    'aveia', 'mel', 'geleia', 'amendoim', 'castanha', 'suco', 'refrigerante',
    'cerveja', 'vinho',
  ],
  CategoriaItem.congelados: [
    'sorvete', 'pizza', 'lasanha', 'nuggets', 'hamburguer congelado',
    'legumes congelados', 'acai', 'polpa', 'empanado', 'batata frita',
    'coxinha', 'kibbe', 'pao de queijo congelado',
  ],
};
```

## Passo 5: Criar a função `inferirCategoria`

```dart
/// Remove acentos e normaliza texto para comparação.
String _normalizarTexto(String texto) {
  const acentos = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñç';
  const semAcento = 'aaaaaaeeeeiiiioooooouuuuyync';
  
  var resultado = texto.trim().toLowerCase();
  for (var i = 0; i < acentos.length; i++) {
    resultado = resultado.replaceAll(acentos[i], semAcento[i]);
  }
  return resultado;
}

/// Infere a categoria de um item baseado no seu nome.
/// Compara com o mapeamento de palavras-chave.
CategoriaItem inferirCategoria(String nome) {
  final normalizado = _normalizarTexto(nome);
  if (normalizado.isEmpty) return categoriaDefault;

  for (final entry in _mapeamentoCategorias.entries) {
    for (final palavra in entry.value) {
      if (normalizado.contains(_normalizarTexto(palavra))) {
        return entry.key;
      }
    }
  }

  return categoriaDefault;
}
```

## Passo 6: Criar helper `obterCategoria`

```dart
/// Retorna a configuração visual de uma categoria.
/// Se não encontrar, retorna 'outros'.
CategoriaConfig obterCategoria(CategoriaItem? valor) {
  if (valor == null) return categorias.last;
  return categorias.firstWhere(
    (c) => c.valor == valor,
    orElse: () => categorias.last,
  );
}
```

## Passo 7: Criar helper para serialização Firestore

```dart
/// Converte CategoriaItem para string (para Firestore).
String categoriaToString(CategoriaItem categoria) => categoria.name;

/// Converte string do Firestore para CategoriaItem.
CategoriaItem categoriaFromString(String? valor) {
  if (valor == null) return categoriaDefault;
  return CategoriaItem.values.firstWhere(
    (c) => c.name == valor,
    orElse: () => categoriaDefault,
  );
}
```

---

## ✅ Checklist de Conclusão

- [ ] `CategoriaItem` enum com 9 valores
- [ ] `CategoriaConfig` com cor, label, ícone Material
- [ ] Lista `categorias` com 9 configs
- [ ] Mapeamento de palavras-chave (todas as categorias)
- [ ] Função `inferirCategoria()` funcional
- [ ] Função `obterCategoria()` funcional
- [ ] Helpers de serialização `categoriaToString` / `categoriaFromString`
- [ ] Arquivo compila sem erros
