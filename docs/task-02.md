# Task 02 — Configurar Firebase no Projeto Flutter

**Fase**: Setup  
**Dependências**: Task 01  
**Resultado**: Firebase inicializado e conectado ao projeto `lista-ai-5d666`

---

## Passo 1: Adicionar Firebase Core ao pubspec.yaml

No `pubspec.yaml`, adicionar em `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.8.0
```

Rodar:
```powershell
flutter pub get
```

## Passo 2: Configurar FlutterFire CLI

Executar na raiz do projeto:
```powershell
flutterfire configure --project=lista-ai-5d666
```

O CLI vai:
1. Perguntar quais plataformas (selecionar **Android** e opcionalmente **iOS**)
2. Gerar o arquivo `lib/firebase_options.dart` automaticamente
3. Configurar o `android/app/google-services.json`

> Se pedir para selecionar o app Android, criar um novo com package name `br.com.listaai.lista_ai`

## Passo 3: Verificar google-services.json

Confirmar que o arquivo foi gerado em:
```
android/app/google-services.json
```

E que o `android/build.gradle` tem o plugin Google Services.

## Passo 4: Verificar android/app/build.gradle

Confirmar que contém:
```groovy
plugins {
    id "com.google.gms.google-services"
}
```

E a `minSdkVersion` deve ser pelo menos **23** (Android 6.0):
```groovy
defaultConfig {
    minSdk = 23        // Mínimo para Firebase + Speech
    targetSdk = 34
}
```

## Passo 5: Verificar android/build.gradle (raiz)

Confirmar que tem:
```groovy
plugins {
    id "com.google.gms.google-services" version "4.4.2" apply false
}
```

## Passo 6: Inicializar Firebase no main.dart

Atualizar `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ListaAiApp());
}
```

## Passo 7: Rodar e validar

```powershell
flutter run
```

Deve rodar sem erros. No console do Android Studio, não deve ter crash de Firebase.

## Passo 8: Testar conexão (opcional)

Adicionar temporariamente no `app.dart` para confirmar que Firebase está conectado:

```dart
import 'package:firebase_core/firebase_core.dart';

// No build method, antes do return:
print('Firebase App Name: ${Firebase.app().name}');
print('Firebase Project: ${Firebase.app().options.projectId}');
```

O console deve exibir `lista-ai-5d666`.

**Remover este print depois de confirmar.**

---

## ✅ Checklist de Conclusão

> **Concluído em**: 29/03/2026

- [x] `firebase_options.dart` gerado pelo FlutterFire CLI — **App ID: `1:594857065631:android:404a953db10b9743aa36aa`**
- [x] `google-services.json` presente em `android/app/` — **Gerado automaticamente pelo FlutterFire CLI**
- [x] Firebase inicializado no `main.dart` — **`WidgetsFlutterBinding.ensureInitialized()` + `Firebase.initializeApp()`**
- [x] `minSdkVersion` = 23 ou maior — **Configurado `minSdk = 23` em `android/app/build.gradle.kts`**
- [x] App roda sem erros de Firebase — **`flutter build apk --debug` + Gradle `BUILD SUCCESSFUL`**
- [x] Project ID `lista-ai-5d666` confirmado — **Registrado via `flutterfire configure --project=lista-ai-5d666`**
