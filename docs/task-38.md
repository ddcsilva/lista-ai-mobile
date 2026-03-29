# Task 38 — Voice Input Integration (UI)

**Fase**: UI  
**Dependências**: Task 24 (VoiceInputService), Task 33 (ItemForm)  
**Resultado**: Botão mic funcional no ItemForm com feedback visual

---

## Passo 1: Criar VoiceInputOverlay widget

Criar `lib/features/lista/ui/widgets/voice_input_overlay.dart`:

```dart
import 'package:flutter/material.dart';

class VoiceInputOverlay extends StatelessWidget {
  final bool isListening;
  final String textoReconhecido;
  final VoidCallback onCancel;

  const VoiceInputOverlay({
    super.key,
    required this.isListening,
    required this.textoReconhecido,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isListening) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone pulsante
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.3),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  Icons.mic,
                  size: 48,
                  color: colorScheme.error,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Ouvindo...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          if (textoReconhecido.isNotEmpty)
            Text(
              textoReconhecido,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
```

---

## Passo 2: Integrar voice input no ItemForm

Atualizar o handler do botão mic no `item_form.dart`:

```dart
// Adicionar ao estado do _ItemFormState:
bool _isListening = false;
String _textoVoz = '';

// Atualizar o botão mic:
IconButton.filled(
  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
  style: IconButton.styleFrom(
    backgroundColor: _isListening
        ? Theme.of(context).colorScheme.error
        : null,
  ),
  onPressed: _isListening ? _pararVoz : _iniciarVoz,
  tooltip: _isListening ? 'Parar' : 'Entrada por voz',
),

// Handlers:
Future<void> _iniciarVoz() async {
  final voiceService = ref.read(voiceInputServiceProvider);
  
  final disponivel = await voiceService.inicializar();
  if (!disponivel) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reconhecimento de voz não disponível')),
      );
    }
    return;
  }
  
  setState(() {
    _isListening = true;
    _textoVoz = '';
  });
  
  voiceService.ouvir(
    onResult: (texto, isFinal) {
      setState(() => _textoVoz = texto);
      if (isFinal && texto.isNotEmpty) {
        _processarVoz(texto);
      }
    },
    onError: (erro) {
      setState(() => _isListening = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $erro')),
        );
      }
    },
    onDone: () {
      setState(() => _isListening = false);
    },
  );
}

void _pararVoz() {
  final voiceService = ref.read(voiceInputServiceProvider);
  voiceService.parar();
  setState(() => _isListening = false);
  
  // Se tem texto parcial, processar
  if (_textoVoz.isNotEmpty) {
    _processarVoz(_textoVoz);
  }
}

void _processarVoz(String texto) {
  setState(() => _isListening = false);
  
  // Usar o mesmo parser do input manual
  // Pode ter múltiplos itens separados por "e" ou vírgula
  final partes = texto.split(RegExp(r'\s*[,e]\s*'));
  
  final store = ref.read(listaStoreProvider.notifier);
  final parser = ref.read(commandParserServiceProvider);
  
  for (final parte in partes) {
    final trimmed = parte.trim();
    if (trimmed.isEmpty) continue;
    
    final resultado = parser.parse(trimmed);
    store.adicionarItem(
      nome: resultado.nome,
      quantidade: resultado.quantidade,
      categoria: resultado.categoria,
      nota: resultado.nota,
    );
    ref.read(historicoServiceProvider).adicionar(resultado.nome);
  }
  
  // Feedback
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${partes.length} item(s) adicionado(s)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
```

---

## Passo 3: Adicionar overlay na ListaPage

No `lista_page.dart`, exibir overlay de voz sobre a lista:

```dart
// Usar Stack para sobrepor o overlay
Stack(
  children: [
    Column(
      children: [
        ListaSummary(...),
        ItemForm(...),
        Expanded(child: ListView(...)),
        ModoMercadoBar(),
      ],
    ),
    // Overlay voice
    if (_isListening)
      Positioned.fill(
        child: GestureDetector(
          onTap: _pararVoz,
          child: Container(
            color: Colors.black38,
            child: VoiceInputOverlay(
              isListening: true,
              textoReconhecido: _textoVoz,
              onCancel: _pararVoz,
            ),
          ),
        ),
      ),
  ],
)
```

> **Nota**: O estado de `_isListening` pode ser elevado para um provider
> ou usar callbacks entre ItemForm e ListaPage.

---

## Passo 4: Permissões de microfone

Verificar que a permissão do microfone já foi configurada na Task 24:

- **Android**: `AndroidManifest.xml` — `<uses-permission android:name="android.permission.RECORD_AUDIO"/>`
- **iOS**: `Info.plist` — `NSSpeechRecognitionUsageDescription` e `NSMicrophoneUsageDescription`

---

## ✅ Checklist de Conclusão

- [ ] Botão mic inicia reconhecimento de voz
- [ ] Indicador visual "Ouvindo..." com ícone pulsante
- [ ] Texto reconhecido exibido em tempo real
- [ ] Cancelar reconhecimento
- [ ] Resultado: parse e adiciona item(s)
- [ ] Suporte a múltiplos itens ("leite, pão e ovos")
- [ ] SnackBar de feedback
- [ ] Troca de ícone mic ↔ mic_off
- [ ] Cor do botão muda quando ativo (erro/vermelho)
- [ ] Tratamento de erro quando voz não disponível
