# Task 25 — TTS Service (Text-to-Speech) com @riverpod

**Fase**: Application Services  
**Dependências**: Task 03 (flutter_tts), Task 18 (lista_providers)  
**Resultado**: Leitura em voz alta dos itens pendentes por categoria

---

## Passo 1: Criar TtsService

Criar `lib/features/lista_compras/application/tts_service.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../domain/models/models.dart';
import 'lista_providers.dart';

part 'tts_service.freezed.dart';
part 'tts_service.g.dart';

@freezed
class TtsState with _$TtsState {
  const factory TtsState({
    @Default(false) bool isSupported,
    @Default(false) bool lendo,
  }) = _TtsState;
}

@riverpod
class TtsNotifier extends _$TtsNotifier {
  late final FlutterTts _tts;
  bool _stopped = false;

  @override
  TtsState build() {
    _tts = FlutterTts();
    _configurar();
    ref.onDispose(() => _tts.stop());
    return const TtsState();
  }

  Future<void> _configurar() async {
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setErrorHandler((msg) {
      state = state.copyWith(lendo: false);
    });

    state = state.copyWith(isSupported: true);
  }

  /// Inicia a leitura dos itens pendentes por categoria.
  Future<void> iniciarLeitura({required String listaId}) async {
    if (!state.isSupported) return;

    _stopped = false;
    state = state.copyWith(lendo: true);

    final listaAsync = ref.read(listaStreamProvider(listaId: listaId));
    final lista = listaAsync.valueOrNull;
    if (lista == null) {
      state = state.copyWith(lendo: false);
      return;
    }

    final pendentes = lista.itens.where((i) => !i.comprado).toList();
    
    // Agrupar por categoria
    final grupos = <CategoriaItem, List<ItemLista>>{};
    for (final item in pendentes) {
      grupos.putIfAbsent(item.categoria, () => []).add(item);
    }

    for (final entry in grupos.entries) {
      if (_stopped) break;

      final itensTexto = entry.value
          .map((i) => '${i.quantidade} ${i.nome}')
          .join(', ');

      final frase = '${entry.key.name}: $itensTexto';

      try {
        await _tts.speak(frase);
        await _tts.awaitSpeakCompletion(true);
      } catch (_) {
        break;
      }
    }

    state = state.copyWith(lendo: false);
  }

  /// Toggle leitura/parada.
  void toggle({required String listaId}) {
    if (state.lendo) {
      parar();
    } else {
      iniciarLeitura(listaId: listaId);
    }
  }

  /// Para a leitura.
  void parar() {
    _stopped = true;
    _tts.stop();
    state = state.copyWith(lendo: false);
  }
}
```

---

## ✅ Checklist de Conclusão

- [ ] `TtsState` com Freezed (isSupported, lendo)
- [ ] `TtsNotifier` com `@riverpod` (não StateNotifier!)
- [ ] Configuração: idioma `pt-BR`, rate 0.5, volume 1.0
- [ ] `iniciarLeitura` recebe `listaId` e lê de `listaStreamProvider`
- [ ] `toggle` e `parar` funcionais
- [ ] `ref.onDispose` para cleanup do FlutterTts
- [ ] `_stopped` flag para interromper no meio
- [ ] `build_runner build` sem erros
