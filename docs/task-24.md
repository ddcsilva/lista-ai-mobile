# Task 24 — Voice Input Service (com @riverpod)

**Fase**: Application Services  
**Dependências**: Task 03 (speech_to_text), Task 17 (CommandParser)  
**Resultado**: Serviço de entrada por voz com reconhecimento de fala em PT-BR

---

## Contexto

No Angular, usa-se Web Speech API. No Flutter, usamos o plugin `speech_to_text`. O serviço orquestra: iniciar mic → transcrever → parsear com CommandParser.

> **NOTA**: Usamos `@riverpod` Notifier em vez do deprecado `StateNotifier`.

---

## Passo 1: Criar VoiceInputService

Criar `lib/features/lista_compras/application/voice_input_service.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'command_parser_service.dart';

part 'voice_input_service.freezed.dart';
part 'voice_input_service.g.dart';

/// Resultado de uma sessão de voz.
class VoiceResult {
  final String transcript;
  final List<ItemParseado> itens;

  const VoiceResult({required this.transcript, required this.itens});
}

@freezed
class VoiceInputState with _$VoiceInputState {
  const factory VoiceInputState({
    @Default(true) bool isSupported,
    @Default(false) bool gravando,
    @Default('') String erro,
    @Default('') String transcriptParcial,
  }) = _VoiceInputState;
}

@riverpod
class VoiceInputNotifier extends _$VoiceInputNotifier {
  late final SpeechToText _speech;
  late final CommandParserService _parser;

  @override
  VoiceInputState build() {
    _speech = SpeechToText();
    _parser = ref.watch(commandParserProvider);
    return const VoiceInputState();
  }

  /// Verifica se o dispositivo suporta reconhecimento de fala.
  Future<bool> verificarSupporte() async {
    try {
      final disponivel = await _speech.initialize(
        onError: (error) {
          state = state.copyWith(
            gravando: false,
            erro: _traduzirErro(error.errorMsg),
          );
        },
      );
      state = state.copyWith(isSupported: disponivel);
      return disponivel;
    } catch (e) {
      state = state.copyWith(isSupported: false, erro: 'Erro ao inicializar: $e');
      return false;
    }
  }

  /// Inicia gravação e retorna resultado quando parar.
  Future<VoiceResult?> iniciar() async {
    state = state.copyWith(gravando: true, erro: '');

    if (!_speech.isAvailable) {
      final ok = await verificarSupporte();
      if (!ok) {
        state = state.copyWith(
          gravando: false,
          erro: 'Reconhecimento de voz não disponível neste dispositivo.',
        );
        return null;
      }
    }

    String transcriptFinal = '';

    await _speech.listen(
      onResult: (result) {
        transcriptFinal = result.recognizedWords;
        state = state.copyWith(transcriptParcial: transcriptFinal);

        if (result.finalResult) {
          state = state.copyWith(gravando: false);
        }
      },
      localeId: 'pt_BR',
      listenMode: ListenMode.dictation,
      cancelOnError: true,
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
    );

    // Aguardar até que finalResult seja recebido
    // O speech_to_text chama onResult com finalResult = true quando termina.
    // Precisamos retornar após isso.
    await _speech.statusStream.firstWhere(
      (status) => status == 'notListening' || status == 'done',
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () => 'timeout',
    );

    state = state.copyWith(gravando: false);

    if (transcriptFinal.isEmpty) {
      state = state.copyWith(erro: 'Nenhuma fala detectada. Tente novamente.');
      return null;
    }

    final itens = _parser.parse(transcriptFinal);
    if (itens.isEmpty) {
      state = state.copyWith(
        erro: 'Não foi possível identificar itens. Tente novamente.',
      );
      return VoiceResult(transcript: transcriptFinal, itens: []);
    }

    return VoiceResult(transcript: transcriptFinal, itens: itens);
  }

  /// Para a gravação.
  void parar() {
    _speech.stop();
    state = state.copyWith(gravando: false);
  }

  String _traduzirErro(String code) {
    switch (code) {
      case 'error_permission':
        return 'Permissão de microfone negada. Habilite nas configurações.';
      case 'error_no_match':
      case 'error_speech_timeout':
        return 'Nenhuma fala detectada. Tente novamente.';
      case 'error_network':
        return 'Erro de rede. Verifique sua conexão.';
      default:
        return 'Erro ao reconhecer voz. Tente novamente.';
    }
  }
}

## Notas

- `localeId: 'pt_BR'` — garante reconhecimento em português
- `listenFor: 15s` — tempo máximo de escuta
- `pauseFor: 3s` — pausa entre falas para considerar finalizado
- `ListenMode.dictation` — modo ditado (mais preciso para listas)
- Estado gerenciado por `@riverpod Notifier` (não StateNotifier)

---

## ✅ Checklist de Conclusão

- [ ] `VoiceInputState` com Freezed
- [ ] `VoiceInputNotifier` com `@riverpod` (não StateNotifier!)
- [ ] `verificarSupporte()` com try-catch
- [ ] `iniciar()` com locale `pt_BR`
- [ ] `parar()` para interromper gravação
- [ ] Tradução de erros para português
- [ ] Integração com `CommandParserService`
- [ ] `build_runner build` gera .g.dart e .freezed.dart
