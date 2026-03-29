# Task 22 — Export Service

**Fase**: Application Services  
**Dependências**: Task 04, Task 05  
**Resultado**: Formata lista para clipboard/compartilhamento

---

## Passo 1: Criar ExportService

Criar `lib/features/lista_compras/application/export_service.dart`:

```dart
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/models/categoria_item.dart';
import '../domain/models/item_lista.dart';

const Map<CategoriaItem, String> _emojiCategorias = {
  CategoriaItem.hortifruti: '🥬',
  CategoriaItem.carnes: '🥩',
  CategoriaItem.laticinios: '🥛',
  CategoriaItem.padaria: '🍞',
  CategoriaItem.limpeza: '🧹',
  CategoriaItem.higiene: '🧴',
  CategoriaItem.mercearia: '🛒',
  CategoriaItem.congelados: '🧊',
  CategoriaItem.outros: '📦',
};

class ExportService {
  /// Formata a lista em texto legível com emojis e categorias.
  String formatarLista(String nomeLista, List<ItemLista> itens) {
    final pendentes = itens.where((i) => !i.comprado).toList();
    if (pendentes.isEmpty) return '';

    final grupos = <CategoriaItem, List<ItemLista>>{};
    for (final item in pendentes) {
      grupos.putIfAbsent(item.categoria, () => []).add(item);
    }

    final linhas = <String>['🛒 $nomeLista', ''];

    for (final catConfig in categorias) {
      final itensGrupo = grupos[catConfig.valor];
      if (itensGrupo == null || itensGrupo.isEmpty) continue;

      final emoji = _emojiCategorias[catConfig.valor] ?? '📦';
      linhas.add('$emoji ${catConfig.label}:');
      for (final item in itensGrupo) {
        linhas.add('- ${item.nome} (${item.quantidade})');
      }
      linhas.add('');
    }

    return linhas.join('\n').trimRight();
  }

  /// Copia texto para o clipboard.
  Future<bool> copiarParaClipboard(String texto) async {
    try {
      await Clipboard.setData(ClipboardData(text: texto));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Compartilha via share sheet nativo do Android/iOS.
  Future<void> compartilhar(String texto) async {
    await SharePlus.instance.share(ShareParams(text: texto));
  }
}
```

## Passo 2: Criar provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});
```

---

## ✅ Checklist de Conclusão

- [ ] `formatarLista()` — agrupa por categoria com emojis
- [ ] Só inclui itens pendentes (não comprados)
- [ ] `copiarParaClipboard()` — usa `Clipboard.setData`
- [ ] `compartilhar()` — usa `share_plus` para share sheet nativo
- [ ] Provider criado
