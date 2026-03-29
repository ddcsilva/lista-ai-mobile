# Task 54 — Code Generation Workflow (build_runner)

**Fase**: DevOps / DX  
**Dependências**: Task 03 (deps instalados)  
**Resultado**: Workflow documentado e script automatizado para rodar build_runner

---

## Contexto

Com Freezed, json_serializable e @riverpod, o projeto depende fortemente de code generation. Os arquivos `.g.dart` e `.freezed.dart` precisam ser gerados e mantidos atualizados. Esta task documenta o workflow e cria scripts de conveniência.

---

## Passo 1: Quando rodar build_runner

| Situação | Comando |
|---|---|
| Após criar/editar model com `@freezed` | `dart run build_runner build` |
| Após criar/editar provider com `@riverpod` | `dart run build_runner build` |
| Desenvolvimento contínuo | `dart run build_runner watch` |
| CI/CD | `dart run build_runner build --delete-conflicting-outputs` |
| Limpar tudo e regenerar | `dart run build_runner clean` → `build` |

---

## Passo 2: Criar script de conveniência

Criar `tool/gen.sh` (Linux/macOS):

```bash
#!/bin/bash
echo "🔄 Gerando código..."
dart run build_runner build --delete-conflicting-outputs
echo "✅ Geração concluída!"
```

Criar `tool/gen.ps1` (Windows):

```powershell
Write-Host "Gerando código..." -ForegroundColor Cyan
dart run build_runner build --delete-conflicting-outputs
Write-Host "Geração concluída!" -ForegroundColor Green
```

Criar `tool/watch.ps1` (Windows):

```powershell
Write-Host "Iniciando watch mode..." -ForegroundColor Cyan
dart run build_runner watch --delete-conflicting-outputs
```

---

## Passo 3: Configurar .gitignore

Adicionar ao `.gitignore`:

```gitignore
# Build Runner - gerados automaticamente
*.g.dart
*.freezed.dart

# OU, alternativamente, NÃO ignorar para facilitar PR reviews:
# Comentar as linhas acima se preferir commitar os gerados.
```

> **Decisão**: Se o time for pequeno e quiser reviews simples, **commit os gerados**.  
> Se for um time maior ou o build_runner rodar no CI, **ignore os gerados**.

---

## Passo 4: Configurar analysis_options.yaml para gerados

Atualizar `analysis_options.yaml`:

```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  plugins:
    - custom_lint

linter:
  rules:
    # Desabilitar regras que conflitam com gerados
    lines_longer_than_80_chars: false
```

---

## Passo 5: Configurar build.yaml (otimização)

Criar `build.yaml` na raiz:

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          # Freezed options
          map: false        # Não gerar .map() por padrão
          when: false       # Não gerar .when() por padrão (mais rápido)
      json_serializable:
        options:
          # json_serializable options
          explicit_to_json: true    # Gerar toJson em nested objects
          field_rename: FieldRename.snake  # camelCase → snake_case no JSON (se necessário)
```

> **NOTA**: Ajuste `field_rename` conforme o formato do Firestore. Se o Firestore usa camelCase, remova esta opção.

---

## Passo 6: VS Code tasks (opcional)

Criar `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Runner: Build",
      "type": "shell",
      "command": "dart run build_runner build --delete-conflicting-outputs",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always"
      }
    },
    {
      "label": "Build Runner: Watch",
      "type": "shell",
      "command": "dart run build_runner watch --delete-conflicting-outputs",
      "group": "build",
      "isBackground": true,
      "presentation": {
        "echo": true,
        "reveal": "always"
      }
    },
    {
      "label": "Build Runner: Clean",
      "type": "shell",
      "command": "dart run build_runner clean",
      "group": "build"
    }
  ]
}
```

---

## ✅ Checklist de Conclusão

- [ ] Scripts `gen.ps1` e `watch.ps1` criados em `tool/`
- [ ] `.gitignore` configurado para arquivos gerados
- [ ] `analysis_options.yaml` exclui `*.g.dart` e `*.freezed.dart`
- [ ] `build.yaml` com opções de Freezed e json_serializable
- [ ] VS Code tasks para build/watch/clean
- [ ] `dart run build_runner build --delete-conflicting-outputs` roda sem erros
- [ ] Documentação de workflow no README ou CONTRIBUTING
