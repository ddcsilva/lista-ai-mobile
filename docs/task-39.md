# Task 39 — TTS Integration (Ler Lista)

**Fase**: UI  
**Dependências**: Task 25 (TtsService), Task 37 (ModoMercadoBar)  
**Resultado**: Ler lista por voz, agrupada por categoria, com controle start/stop

---

## Passo 1: Implementar leitura de lista no TtsService

Verificar/completar no `lib/application/tts_service.dart`:

```dart
/// Lê a lista completa agrupada por categoria
Future<void> lerLista(ListaCompras lista) async {
  final itensNaoComprados = lista.itens.where((i) => !i.comprado).toList();
  
  if (itensNaoComprados.isEmpty) {
    await falar('Todos os itens já foram comprados!');
    return;
  }
  
  // Agrupar por categoria
  final porCategoria = <CategoriaItem, List<ItemLista>>{};
  for (final item in itensNaoComprados) {
    porCategoria.putIfAbsent(item.categoria, () => []).add(item);
  }
  
  // Intro
  await falar('Você tem ${itensNaoComprados.length} itens para comprar.');
  
  // Ler por categoria
  for (final entry in porCategoria.entries) {
    final categoria = entry.key;
    final itens = entry.value;
    
    await falar('${categoria.label}:');
    
    for (final item in itens) {
      final qtd = item.quantidade > 1 ? '${item.quantidade} ' : '';
      await falar('$qtd${item.nome}');
    }
  }
  
  await falar('Fim da lista.');
}

/// Fala um texto
Future<void> falar(String texto) async {
  await _flutterTts.speak(texto);
  // Esperar completar antes de falar o próximo
  await _completar.future; // usar Completer pattern
}

/// Parar fala
Future<void> parar() async {
  await _flutterTts.stop();
}

bool _isFalando = false;
bool get isFalando => _isFalando;
```

---

## Passo 2: Adicionar provider de estado TTS

Criar ou atualizar provider para estado reativo:

```dart
// No tts_service.dart ou em providers separado:
final ttsIsFalandoProvider = StateProvider<bool>((ref) => false);
```

---

## Passo 3: Integrar na ModoMercadoBar

Atualizar o botão de TTS na `modo_mercado_bar.dart`:

```dart
// Trocar o botão TTS por:
Consumer(
  builder: (context, ref, _) {
    final isFalando = ref.watch(ttsIsFalandoProvider);
    return IconButton(
      icon: Icon(
        isFalando ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
      ),
      onPressed: () {
        if (isFalando) {
          ref.read(ttsServiceProvider).parar();
          ref.read(ttsIsFalandoProvider.notifier).state = false;
        } else {
          _lerLista();
        }
      },
      tooltip: isFalando ? 'Parar leitura' : 'Ler lista em voz alta',
    );
  },
),
```

---

## Passo 4: Configuração de idioma pt-BR

No TtsService `inicializar()`:

```dart
Future<void> inicializar() async {
  await _flutterTts.setLanguage('pt-BR');
  await _flutterTts.setSpeechRate(0.5);  // velocidade moderada
  await _flutterTts.setVolume(1.0);
  await _flutterTts.setPitch(1.0);
  
  _flutterTts.setStartHandler(() {
    _isFalando = true;
  });
  
  _flutterTts.setCompletionHandler(() {
    _isFalando = false;
  });
  
  _flutterTts.setErrorHandler((msg) {
    _isFalando = false;
  });
}
```

---

## ✅ Checklist de Conclusão

- [ ] TTS lê lista agrupada por categoria
- [ ] Intro: "Você tem X itens para comprar"
- [ ] Cada categoria: nome da categoria + itens
- [ ] Quantidade falada quando > 1
- [ ] Botão toggle entre ler/parar
- [ ] Idioma pt-BR configurado
- [ ] Speech rate moderada (0.5)
- [ ] Estado `isFalando` reativo no UI
- [ ] "Fim da lista" ao completar
