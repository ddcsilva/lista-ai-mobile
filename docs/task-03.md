# Task 03 — Instalar e Configurar Todas as Dependências

**Fase**: Setup  
**Dependências**: Task 02  
**Resultado**: Todas as dependências instaladas e projeto compilando

---

## Passo 1: Atualizar pubspec.yaml completo

Substituir a seção `dependencies` e `dev_dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.0
  cloud_firestore: ^5.5.0
  firebase_analytics: ^11.3.0
  firebase_crashlytics: ^4.3.0
  google_sign_in: ^6.2.0

  # State Management (Riverpod 2.x com code generation)
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0

  # Routing
  go_router: ^14.6.0

  # Immutable Models (code generation)
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

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

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  
  # Code generation
  riverpod_generator: ^2.6.0
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  custom_lint: ^0.7.0
  riverpod_lint: ^2.6.0
  
  # Testing
  mockito: ^5.4.0
  fake_cloud_firestore: ^3.1.0
```

> **IMPORTANTE**: `freezed` + `riverpod_generator` exigem `build_runner` para gerar código.
> Após qualquer alteração nos models ou providers, rodar:
> ```powershell
> dart run build_runner build --delete-conflicting-outputs
> ```

## Passo 2: Instalar dependências

```powershell
flutter pub get
```

## Passo 3: Configurar permissões Android

Editar `android/app/src/main/AndroidManifest.xml` e adicionar **dentro da tag `<manifest>`**, antes de `<application>`:

```xml
<!-- Internet (já presente por padrão) -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Microfone para Speech-to-Text -->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>

<!-- Verificar estado da rede -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

<!-- Wake Lock para modo mercado -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

## Passo 4: Configurar Google Sign-In no Android

### 4a. Obter SHA-1 do debug keystore:
```powershell
cd android
./gradlew signingReport
```

Copiar o **SHA-1** da variante `debug`.

### 4b. Adicionar SHA-1 no Firebase Console:
1. Ir em https://console.firebase.google.com → Project Settings → General
2. Na seção "Your apps" → App Android
3. Clicar "Add fingerprint" → Colar o SHA-1
4. Baixar o `google-services.json` atualizado e substituir em `android/app/`

### 4c. Habilitar Google Sign-In no Firebase Console:
1. Authentication → Sign-in method
2. Habilitar **Google** como provedor (se ainda não estiver)
3. Habilitar **Email/Password** como provedor

## Passo 5: Configurar speech_to_text para Android

No `android/app/src/main/AndroidManifest.xml`, dentro de `<application>`, adicionar:

```xml
<queries>
    <intent>
        <action android:name="android.speech.RecognitionService" />
    </intent>
</queries>
```

## Passo 6: Configurar minSdkVersion

Confirmar em `android/app/build.gradle`:
```groovy
defaultConfig {
    minSdk = 23
    targetSdk = 34
    // ... resto
}
```

## Passo 7: Build completo

```powershell
cd ..  # voltar para raiz
flutter build apk --debug
```

Deve compilar sem erros.

## Passo 8: Gerar código Riverpod (build_runner)

```powershell
dart run build_runner build --delete-conflicting-outputs
```

> Por enquanto não vai gerar nada, mas confirma que o build_runner funciona.

## Passo 9: Rodar o app

```powershell
flutter run
```

---

## ✅ Checklist de Conclusão

- [ ] Todas as dependências em `pubspec.yaml`
- [ ] `flutter pub get` sem erros
- [ ] Permissões Android configuradas (RECORD_AUDIO, WAKE_LOCK, etc.)
- [ ] SHA-1 adicionado no Firebase Console
- [ ] Google Sign-In habilitado no Firebase Console
- [ ] Email/Senha habilitado no Firebase Console
- [ ] `google-services.json` atualizado
- [ ] `flutter build apk --debug` compila sem erros
- [ ] App roda no emulador/dispositivo
