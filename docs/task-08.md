# Task 08 — Criar Regras de Negócio: Lista Compartilhada Rules

**Fase**: Domain Layer  
**Dependências**: Task 06 (MembroLista)  
**Resultado**: Constantes e funções de regras de compartilhamento

---

## Passo 1: Criar lista_compartilhada_rules.dart

Criar `lib/features/lista_compras/domain/rules/lista_compartilhada_rules.dart`:

```dart
import '../models/membro_lista.dart';

/// Máximo de membros por lista (incluindo o dono).
const int maxMembrosPorLista = 5;

/// Máximo de listas compartilhadas por usuário.
const int maxListasCompartilhadas = 3;

/// Duração em horas de um convite.
const int conviteDuracaoHoras = 24;

/// Verifica se é possível criar mais listas compartilhadas.
bool podeCriarListaCompartilhada(int totalListasCompartilhadas) {
  return totalListasCompartilhadas < maxListasCompartilhadas;
}

/// Verifica se é possível convidar mais membros para a lista.
bool podeConvidarMembro(Map<String, MembroLista> membros) {
  return membros.length < maxMembrosPorLista;
}

/// Verifica se o uid é dono da lista.
bool isDono(Map<String, MembroLista> membros, String uid) {
  return membros[uid]?.papel == PapelMembro.dono;
}

/// Verifica se o uid é membro da lista.
bool isMembro(Map<String, MembroLista> membros, String uid) {
  return membros.containsKey(uid);
}

/// Verifica se a lista é compartilhada (mais de 1 membro).
bool isListaCompartilhada(Map<String, MembroLista>? membros) {
  if (membros == null) return false;
  return membros.length > 1;
}

/// Calcula a data de expiração de um convite.
DateTime criarConviteExpiresAt(DateTime criadoEm) {
  return criadoEm.add(const Duration(hours: conviteDuracaoHoras));
}

/// Verifica se um convite está expirado.
bool isConviteExpirado(DateTime expiresAt) {
  return expiresAt.isBefore(DateTime.now());
}
```

---

## ✅ Checklist de Conclusão

- [ ] Constantes: `maxMembrosPorLista` = 5, `maxListasCompartilhadas` = 3, `conviteDuracaoHoras` = 24
- [ ] `podeCriarListaCompartilhada()` — verifica limite
- [ ] `podeConvidarMembro()` — verifica limite
- [ ] `isDono()` / `isMembro()` — verifica papel
- [ ] `isListaCompartilhada()` — mais de 1 membro
- [ ] `criarConviteExpiresAt()` / `isConviteExpirado()` — lógica de expiração
