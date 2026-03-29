# Lista-AI Mobile — Guia de Setup e Pré-requisitos

> Documento de referência para configurar todo o ambiente de desenvolvimento Flutter antes de iniciar as tasks.

---

## 📋 Visão Geral do Projeto

**Lista-AI Mobile** é a versão Android/iOS do app web Lista-AI — uma lista de compras colaborativa com:
- Entrada por voz (Speech-to-Text em PT-BR)
- Leitura em voz alta (TTS por categoria)
- Compartilhamento colaborativo (até 5 membros, convites com 24h validade)
- Múltiplas listas por usuário
- Histórico e favoritos
- Modo mercado (tela sempre ligada)
- Inferência automática de categoria por nome do item
- Importação/exportação de listas
- Sincronização real-time via Firestore
- Autenticação (Google + Email/Senha)

---

## 🛠️ Software Necessário

### 1. Flutter SDK

- **Versão mínima**: Flutter 3.24+ (stable channel)
- **Download**: https://docs.flutter.dev/get-started/install/windows/mobile
- Adicionar `flutter/bin` ao PATH do sistema
- Verificar instalação:
  ```powershell
  flutter --version
  flutter doctor
  ```

### 2. Android Studio

- **Versão**: Android Studio Ladybug (2024.2+) ou mais recente
- **Download**: https://developer.android.com/studio
- Instalar os seguintes componentes via SDK Manager:
  - Android SDK Platform 34 (Android 14)
  - Android SDK Build-Tools 34.0.0
  - Android SDK Command-line Tools
  - Android Emulator
  - Google Play services (para Auth Google)
- Configurar `ANDROID_HOME` no PATH

### 3. JDK

- **Versão**: JDK 17 (incluído no Android Studio)
- Verificar: `java -version`

### 4. VS Code (opcional, mas recomendado)

- Extensões:
  - **Flutter** (Dart-Code.flutter)
  - **Dart** (Dart-Code.dart-code)
  - **Awesome Flutter Snippets**

### 5. Git

- Já instalado (presumido)

### 6. Firebase CLI

- Instalar: `npm install -g firebase-tools`
- Instalar FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Login: `firebase login`

---

## 📱 Dispositivo de Teste

### Opção A: Emulador Android
- Abrir Android Studio → Device Manager → Create Virtual Device
- Recomendado: Pixel 7 com API 34 (Android 14) + Google Play
- Habilitar Hardware Acceleration (HAXM/Hyper-V)

### Opção B: Dispositivo Físico
- Habilitar **Opções de Desenvolvedor** no celular
- Ativar **Depuração USB**
- Conectar via cabo USB
- Verificar: `flutter devices`

---

## 🔥 Projeto Firebase Existente

O projeto já tem o Firebase configurado:

| Campo | Valor |
|-------|-------|
| Project ID | `lista-ai-5d666` |
| Auth Domain | `lista-ai-5d666.firebaseapp.com` |
| Storage Bucket | `lista-ai-5d666.firebasestorage.app` |

### Serviços Firebase utilizados:
- **Firebase Authentication** (Google Sign-In + Email/Senha)
- **Cloud Firestore** (banco de dados real-time)
- **Firebase Analytics** (eventos de uso e navegação)
- **Firebase Crashlytics** (relatórios de crash e erros)

### Coleções Firestore:
```
listas/{listaId}                    → ListaCompras (com itens[] embutidos)
users/{uid}/minhasListas/{listaId}  → MinhaListaRef (índice otimizado)
convites/{conviteId}                → Convite (pendentes/aceitos/expirados)
usuarios/{uid}                      → { email, nome } (lookup de e-mail)
```

---

## 📦 Dependências Flutter (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.0
  cloud_firestore: ^5.5.0
  firebase_analytics: ^11.3.0
  google_sign_in: ^6.2.0

  # Firebase
  firebase_crashlytics: ^4.3.0

  # State Management
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0

  # Code Generation (Annotations)
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # Routing
  go_router: ^14.6.0

  # Voice / TTS
  speech_to_text: ^7.0.0
  flutter_tts: ^4.1.0

  # Utilidades
  uuid: ^4.5.0
  shared_preferences: ^2.3.0
  connectivity_plus: ^6.1.0
  wakelock_plus: ^1.2.0
  share_plus: ^10.1.0

  # UI
  google_fonts: ^6.2.0
  flutter_svg: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  riverpod_generator: ^2.6.0
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_lint: ^2.6.0
  custom_lint: ^0.7.0
  mockito: ^5.4.0
  fake_cloud_firestore: ^3.1.0
  build_verify: ^3.1.0
```

---

## 🏗️ Estrutura de Pastas do Projeto Flutter

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp + GoRouter
├── core/
│   ├── auth/
│   │   ├── auth_service.dart
│   │   └── auth_provider.dart
│   ├── infra/
│   │   └── firebase/
│   │       ├── firebase_config.dart
│   │       └── firebase_providers.dart
│   └── services/
│       └── connection_service.dart
├── features/
│   ├── auth/
│   │   └── ui/
│   │       └── login_page.dart
│   └── lista_compras/
│       ├── domain/
│       │   ├── models/
│       │   │   ├── categoria_item.dart
│       │   │   ├── item_lista.dart
│       │   │   ├── lista_compras.dart
│       │   │   ├── membro_lista.dart
│       │   │   ├── minha_lista_ref.dart
│       │   │   └── convite.dart
│       │   ├── ports/
│       │   │   ├── lista_repository.dart
│       │   │   ├── lista_index_repository.dart
│       │   │   └── convite_repository.dart
│       │   └── rules/
│       │       ├── item_rules.dart
│       │       └── lista_compartilhada_rules.dart
│       ├── application/
│       │   ├── lista_store.dart
│       │   ├── command_parser_service.dart
│       │   ├── voice_input_service.dart
│       │   ├── tts_service.dart
│       │   ├── compartilhamento_service.dart
│       │   ├── export_service.dart
│       │   ├── favoritos_service.dart
│       │   ├── historico_service.dart
│       │   ├── text_import_service.dart
│       │   └── migracao_service.dart
│       ├── infra/
│       │   ├── firestore_lista_repository.dart
│       │   ├── firestore_lista_index_repository.dart
│       │   └── firestore_convite_repository.dart
│       └── ui/
│           ├── lista_page.dart
│           ├── widgets/
│           │   ├── item_form.dart
│           │   ├── item_card.dart
│           │   ├── lista_summary.dart
│           │   ├── empty_state.dart
│           │   ├── confirm_dialog.dart
│           │   ├── share_dialog.dart
│           │   ├── convite_pendente.dart
│           │   └── text_import_dialog.dart
│           └── header/
│               └── header.dart
└── shared/
    ├── ui/
    │   └── help_drawer.dart
    └── utils/
        ├── id_generator.dart
        └── text_utils.dart
```

---

## 🗺️ Mapa de Migração Angular → Flutter

| Angular | Flutter Equivalente |
|---------|-------------------|
| `signal()` / `computed()` | Riverpod `@riverpod Notifier` / provider derivado |
| `Observable` (RxJS) | `Stream` (Dart nativo) |
| `@Injectable()` | Riverpod `Provider` / `@riverpod` |
| `inject()` | `ref.watch()` / `ref.read()` |
| `DestroyRef.onDestroy()` | `ref.onDispose()` no Riverpod |
| `Router` + Guards | `GoRouter` + `redirect` |
| `localStorage` | `SharedPreferences` |
| `navigator.onLine` | `connectivity_plus` |
| `SpeechRecognition API` | `speech_to_text` package |
| `SpeechSynthesis API` | `flutter_tts` package |
| `Wake Lock API` | `wakelock_plus` package |
| `navigator.clipboard` | `share_plus` / `Clipboard.setData()` |

---

## ✅ Checklist Antes de Começar

> **Última verificação**: 29/03/2026

- [x] Flutter instalado e `flutter doctor` sem erros críticos — **Flutter 3.41.6 (stable), Dart 3.11.4**
- [x] Android Studio instalado com SDK 34 — **Android SDK 36.1.0, Build-Tools 36.1.0, Emulator 36.4.10**
- [x] Emulador Android funcionando OU celular físico conectado — **Emulador: sdk gphone16k x86_64 (API 37)**
- [x] `flutter create` funciona corretamente — **Testado com sucesso**
- [x] Firebase CLI instalado e logado (`firebase login`) — **Firebase CLI 15.12.0, logado**
- [x] FlutterFire CLI instalado (`flutterfire --version`) — **FlutterFire CLI 1.3.1** *(PATH corrigido: `%LOCALAPPDATA%\Pub\Cache\bin` adicionado ao PATH do usuário)*
- [x] Acesso ao projeto Firebase `lista-ai-5d666` no console Firebase — **Confirmado via `firebase projects:list`**
- [x] Git configurado — **Git 2.53.0, user: Danilo Silva**

### ⚠️ Observações
- **Visual Studio**: Falta o workload "Desktop development with C++" (MSVC v142, CMake, Windows 10 SDK). Isso **não bloqueia** o desenvolvimento Android/iOS, apenas builds Windows desktop.
- **JDK**: O Android Studio inclui JDK 21 (OpenJDK 21.0.9). O JDK 17 do sistema também está disponível. Ambos são compatíveis.
- **Versões acima do especificado**: O SDK Android (36.1 vs 34) e o emulador (API 37 vs 34) estão em versões mais recentes que o mínimo documentado — totalmente compatíveis.

---

## 📚 Próximos Passos

Siga as tasks na ordem numérica:

| Task | Arquivo | Descrição |
|------|---------|-----------|
| 01 | `task-01.md` | Criar projeto Flutter e configurar estrutura |
| 02 | `task-02.md` | Configurar Firebase no projeto |
| 03 | `task-03.md` | Instalar e configurar dependências |
| 04 | `task-04.md` | Criar models do domínio (CategoriaItem) |
| 05 | `task-05.md` | Criar models do domínio (ItemLista, ListaCompras) |
| 06 | `task-06.md` | Criar models do domínio (Convite, MembroLista, MinhaListaRef) |
| 07 | `task-07.md` | Criar regras de negócio (item-rules) |
| 08 | `task-08.md` | Criar regras de negócio (lista-compartilhada-rules) |
| 09 | `task-09.md` | Criar ports (repositórios abstratos) |
| 10 | `task-10.md` | Criar utils compartilhados |
| 11 | `task-11.md` | Firebase config e providers |
| 12 | `task-12.md` | Auth Service |
| 13 | `task-13.md` | Connection Service |
| 14 | `task-14.md` | Firestore Lista Repository |
| 15 | `task-15.md` | Firestore Lista Index Repository |
| 16 | `task-16.md` | Firestore Convite Repository |
| 17 | `task-17.md` | Command Parser Service |
| 18 | `task-18.md` | ListaStore (state management — parte 1) |
| 19 | `task-19.md` | ListaStore (operações CRUD — parte 2) |
| 20 | `task-20.md` | Favoritos Service |
| 21 | `task-21.md` | Historico Service |
| 22 | `task-22.md` | Export Service |
| 23 | `task-23.md` | Text Import Service |
| 24 | `task-24.md` | Voice Input Service |
| 25 | `task-25.md` | TTS Service |
| 26 | `task-26.md` | Compartilhamento Service |
| 27 | `task-27.md` | Migracao Service |
| 28 | `task-28.md` | App routing (GoRouter + guards) |
| 29 | `task-29.md` | Login Page UI |
| 30 | `task-30.md` | Login Page Logic (Google + Email) |
| 31 | `task-31.md` | App Shell (Scaffold + Header) |
| 32 | `task-32.md` | Lista Page (container principal) |
| 33 | `task-33.md` | Item Form (input manual) |
| 34 | `task-34.md` | Item Form (autocomplete histórico/favoritos) |
| 35 | `task-35.md` | Item Card |
| 36 | `task-36.md` | Lista Summary (barra de progresso) |
| 37 | `task-37.md` | Empty State |
| 38 | `task-38.md` | Agrupamento por Categoria |
| 39 | `task-39.md` | Integração de voz no UI |
| 40 | `task-40.md` | Integração TTS no UI |
| 41 | `task-41.md` | Share Dialog |
| 42 | `task-42.md` | Convite Pendente Card |
| 43 | `task-43.md` | Text Import Dialog |
| 44 | `task-44.md` | Confirm Dialog |
| 45 | `task-45.md` | Modo Mercado (Wake Lock) |
| 46 | `task-46.md` | Multi-lista (Drawer/Switcher) |
| 47 | `task-47.md` | Offline support |
| 48 | `task-48.md` | Temas e responsividade |
| 49 | `task-49.md` | Testes unitários e de widget |
| 50 | `task-50.md` | Build, assinatura e release |
| 51 | `task-51.md` | Firebase Crashlytics + Error Boundary |
| 52 | `task-52.md` | Acessibilidade (Semantics + a11y) |
| 53 | `task-53.md` | Firebase Analytics — Eventos de uso |
| 54 | `task-54.md` | Code Generation Workflow (build_runner) |
