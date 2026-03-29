# Task 50 — Build, Signing e Release (Android)

**Fase**: Deploy  
**Dependências**: Todas as tasks anteriores  
**Resultado**: APK e App Bundle assinados, prontos para distribuição

---

## Passo 1: Configurar ícone do app

Adicionar ao `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#4CAF50"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
```

Criar `assets/icons/app_icon.png` (1024x1024, imagem de carrinho de compras).

Rodar:

```bash
dart run flutter_launcher_icons
```

---

## Passo 2: Configurar splash screen

Adicionar ao `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.0

flutter_native_splash:
  color: "#4CAF50"
  image: "assets/icons/app_icon.png"
  android: true
  ios: true
```

Rodar:

```bash
dart run flutter_native_splash:create
```

---

## Passo 3: Criar keystore para signing

```bash
# No terminal (PowerShell)
keytool -genkey -v -keystore lista-ai-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Responder as perguntas (nome, org, etc.).

**IMPORTANTE**: Guardar o arquivo `.jks` e a senha em local seguro!  
**Nunca** commitar o keystore no Git.

---

## Passo 4: Criar key.properties

Criar `android/key.properties` (NÃO COMMITAR):

```properties
storePassword=<sua-senha>
keyPassword=<sua-senha>
keyAlias=upload
storeFile=../../lista-ai-upload-key.jks
```

Adicionar ao `.gitignore`:

```
android/key.properties
*.jks
```

---

## Passo 5: Configurar build.gradle para signing

Editar `android/app/build.gradle`:

```groovy
// Acima de android { }
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## Passo 6: Configurar ProGuard

Criar `android/app/proguard-rules.pro`:

```proguard
## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

## Google Sign In
-keep class com.google.android.gms.auth.** { *; }
```

---

## Passo 7: Atualizar info do app

Editar `android/app/build.gradle`:

```groovy
android {
    namespace "com.seudominio.listaai"
    
    defaultConfig {
        applicationId "com.seudominio.listaai"
        minSdkVersion 23       // Mínimo para Firebase Auth + Speech
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

Editar `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="Lista AI"
    android:icon="@mipmap/ic_launcher"
    ...>
```

---

## Passo 8: Build de release

```bash
# App Bundle (recomendado para Play Store)
flutter build appbundle --release

# APK (para distribuição direta)
flutter build apk --release

# APK split por ABI (menor tamanho)
flutter build apk --split-per-abi --release
```

Os outputs ficam em:
- `build/app/outputs/bundle/release/app-release.aab`
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

## Passo 9: Teste de release

```bash
# Instalar APK no dispositivo conectado
flutter install --release

# Ou via adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

Testar:
- Login (Google + Email)
- CRUD de itens
- Voz (mic)
- TTS (ler lista)
- Compartilhar
- Modo mercado (wake lock)
- Offline → voltar online
- Dark mode
- Rotação de tela

---

## Passo 10: Preparar para Play Store (opcional)

1. Criar conta na [Google Play Console](https://play.google.com/console)
2. Criar app "Lista AI"
3. Preencher store listing (título, descrição, screenshots)
4. Fazer upload do `.aab`
5. Configurar:
   - Classificação etária
   - Política de privacidade
   - Práticas de dados
6. Enviar para revisão

---

## 🎉 Parabéns! App Completo!

Se chegou aqui, você construiu:
- ✅ Domain layer com modelos, regras e ports
- ✅ Infrastructure com Firebase (Auth, Firestore)
- ✅ Application services (Store, Parser, Voice, TTS, Share, etc.)
- ✅ UI completa com Material 3
- ✅ Offline support
- ✅ Testes unitários e de widget
- ✅ Build de release assinado

---

## ✅ Checklist de Conclusão

- [ ] Ícone do app gerado (adaptive icon)
- [ ] Splash screen configurada
- [ ] Keystore criada e guardada com segurança
- [ ] key.properties no gitignore
- [ ] build.gradle com signing config
- [ ] ProGuard rules para Firebase + Google
- [ ] applicationId definido
- [ ] minSdk 23, targetSdk 34
- [ ] `flutter build appbundle --release` sucesso
- [ ] `flutter build apk --release` sucesso
- [ ] Teste de release no dispositivo físico
- [ ] Login funciona em release
- [ ] Todas as features funcionam em release
