# Task 10 — Criar Utils Compartilhados (id_generator + text_utils)

**Fase**: Domain Layer  
**Dependências**: Task 03 (uuid package)  
**Resultado**: Utilitários usados por vários módulos

---

## Passo 1: Criar id_generator.dart

Criar `lib/shared/utils/id_generator.dart`:

```dart
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Gera um ID único (UUID v4).
/// Usado para IDs de listas, itens e convites.
String gerarId() => _uuid.v4();
```

## Passo 2: Criar text_utils.dart

Criar `lib/shared/utils/text_utils.dart`:

```dart
/// Converte texto para Title Case.
/// Exemplo: "arroz integral" → "Arroz Integral"
String toTitleCase(String texto) {
  final trimmed = texto.trim();
  if (trimmed.isEmpty) return '';
  
  return trimmed
      .split(RegExp(r'\s+'))
      .map((palavra) {
        if (palavra.isEmpty) return '';
        // Manter preposições em minúsculo (exceto se for primeira palavra)
        return palavra[0].toUpperCase() + palavra.substring(1).toLowerCase();
      })
      .join(' ');
}

/// Remove acentos de um texto (para comparações).
String removerAcentos(String texto) {
  const acentos  = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñçÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝŸÑÇ';
  const semAcento = 'aaaaaaeeeeiiiioooooouuuuyyncAAAAAAEEEEIIIIOOOOOUUUUYYNC';
  
  var resultado = texto;
  for (var i = 0; i < acentos.length; i++) {
    resultado = resultado.replaceAll(acentos[i], semAcento[i]);
  }
  return resultado;
}
```

---

## ✅ Checklist de Conclusão

- [ ] `gerarId()` gera UUIDs v4
- [ ] `toTitleCase()` converte para Title Case
- [ ] `removerAcentos()` normaliza texto sem acentos
- [ ] Ambos os arquivos compilam
