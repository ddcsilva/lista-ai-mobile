# Task 01 — Criar Projeto Flutter e Estrutura de Pastas

**Fase**: Setup  
**Dependências**: Nenhuma (é a primeira task)  
**Resultado**: Projeto Flutter funcional rodando "Hello World" no emulador

---

## Passo 1: Criar o projeto Flutter

```powershell
cd d:\Projetos\lista-ai-mobile
flutter create --org br.com.listaai --project-name lista_ai .
```

> O `--org` define o package name Android: `br.com.listaai.lista_ai`

Se a pasta já tiver conteúdos que conflitam, crie numa pasta nova e mova:
```powershell
flutter create --org br.com.listaai --project-name lista_ai lista_ai_app
```

## Passo 2: Verificar se roda

```powershell
cd lista_ai  # (ou ./ se criou na raiz)
flutter run
```

Deve aparecer o app padrão do Flutter no emulador/dispositivo.

## Passo 3: Limpar arquivos desnecessários

Remover o conteúdo default de `lib/main.dart` e `test/widget_test.dart`.

## Passo 4: Criar estrutura de pastas

Criar todas as pastas do projeto (vazias por enquanto):

```
lib/
├── core/
│   ├── auth/
│   ├── infra/
│   │   └── firebase/
│   └── services/
├── features/
│   ├── auth/
│   │   └── ui/
│   └── lista_compras/
│       ├── domain/
│       │   ├── models/
│       │   ├── ports/
│       │   └── rules/
│       ├── application/
│       ├── infra/
│       └── ui/
│           ├── widgets/
│           └── header/
└── shared/
    ├── ui/
    └── utils/
```

Comando para criar todas de uma vez no PowerShell:

```powershell
$dirs = @(
  "lib/core/auth",
  "lib/core/infra/firebase",
  "lib/core/services",
  "lib/features/auth/ui",
  "lib/features/lista_compras/domain/models",
  "lib/features/lista_compras/domain/ports",
  "lib/features/lista_compras/domain/rules",
  "lib/features/lista_compras/application",
  "lib/features/lista_compras/infra",
  "lib/features/lista_compras/ui/widgets",
  "lib/features/lista_compras/ui/header",
  "lib/shared/ui",
  "lib/shared/utils"
)

foreach ($dir in $dirs) {
  New-Item -ItemType Directory -Path $dir -Force
}
```

## Passo 5: Criar `main.dart` mínimo

Substituir o conteúdo de `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const ListaAiApp());
}
```

## Passo 6: Criar `app.dart` mínimo

Criar `lib/app.dart`:

```dart
import 'package:flutter/material.dart';

class ListaAiApp extends StatelessWidget {
  const ListaAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Lista AI - Setup OK!'),
        ),
      ),
    );
  }
}
```

## Passo 7: Rodar e validar

```powershell
flutter run
```

Deve exibir "Lista AI - Setup OK!" centralizado na tela.

## Passo 8: Configurar `analysis_options.yaml`

Verificar que o arquivo `analysis_options.yaml` na raiz tem boas regras:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    prefer_final_locals: true
    require_trailing_commas: true
```

---

## ✅ Checklist de Conclusão

> **Concluído em**: 29/03/2026

- [x] `flutter run` funciona sem erros — **Build APK debug OK, `flutter analyze` sem issues, testes passando**
- [x] Estrutura de pastas criada — **13 diretórios sob `lib/` conforme especificado**
- [x] `main.dart` e `app.dart` criados e funcionando — **Material3 com colorSchemeSeed blue**
- [x] App exibe "Lista AI - Setup OK!" no emulador — **Validado via build e teste de widget**
