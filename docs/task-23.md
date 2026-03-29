# Task 23 — Text Import Service

**Fase**: Application Services  
**Dependências**: Task 17 (CommandParser), Task 19 (ListaStore), Task 21 (Historico)  
**Resultado**: Serviço de importação de texto colado

---

## Passo 1: Criar TextImportService

Criar `lib/features/lista_compras/application/text_import_service.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/categoria_item.dart';
import 'command_parser_service.dart';
import 'historico_service.dart';
import 'lista_store.dart';

class TextImportService {
  final CommandParserService _parser;
  final ListaNotifier _store;
  final HistoricoNotifier _historico;

  TextImportService(this._parser, this._store, this._historico);

  /// Retorna preview dos itens reconhecidos no texto.
  List<ItemParseado> preview(String texto) {
    return _parser.parse(texto);
  }

  /// Importa os itens para o store e registra no histórico.
  /// Retorna o número de itens adicionados.
  Future<int> importar(List<ItemParseado> itens) async {
    var adicionados = 0;
    for (final item in itens) {
      try {
        final categoria = inferirCategoria(item.nome);
        await _store.adicionarItem(item.nome, item.quantidade, categoria: categoria);
        _historico.registrar(item.nome);
        adicionados++;
      } catch (_) {
        // Item inválido — ignorar
      }
    }
    return adicionados;
  }
}

final textImportServiceProvider = Provider<TextImportService>((ref) {
  return TextImportService(
    ref.watch(commandParserProvider),
    ref.read(listaStoreProvider.notifier),
    ref.read(historicoProvider.notifier),
  );
});
```

---

## ✅ Checklist de Conclusão

- [ ] `preview()` — parseia texto e retorna itens
- [ ] `importar()` — adiciona ao store + registra no histórico
- [ ] Inferência automática de categoria
- [ ] Items inválidos são ignorados silenciosamente
- [ ] Provider criado
