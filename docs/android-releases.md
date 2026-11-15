# Android-сборки и релизы

## Тестовая сборка

`Android checks and debug APK` запускается при push в `develop`/`release/**` и
pull request в `develop`/`master`. Он проверяет release-скрипт, запускает анализатор
и Flutter-тесты, затем сохраняет debug APK для ARM64 как artifact на 14 дней.
Это не публичный релиз: идентификатор debug-приложения заканчивается на `.debug`,
данные отделены от release-установки. Ключи релизной подписи ему не нужны.

Локально:

```bash
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
python3 -m unittest discover -s tool -p 'test_*.py'
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`.

## Постоянная подпись

Публичные APK требуют постоянного ключа: обновления Android должны быть подписаны
тем же ключом, что предыдущая установка. Ключ и пароли не входят в Git.
Автоматической подмены release-подписи debug-ключом больше нет.

В GitHub → Settings → Secrets and variables → Actions используются secrets:

| Secret | Значение |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Содержимое постоянного `.jks`/keystore, закодированное base64 одной строкой |
| `ANDROID_KEYSTORE_PASSWORD` | Пароль хранилища |
| `ANDROID_KEY_ALIAS` | Alias ключа |
| `ANDROID_KEY_PASSWORD` | Пароль ключа |

Создание и резервное копирование постоянного ключа остаётся за владельцем проекта.
Не отправляйте его или пароли в issues, чаты, логи либо коммиты. На runner ключ
декодируется в приватный временный файл и удаляется после сборки, включая сбой.
Без полного набора secrets релиз завершается ошибкой, а не создаёт APK с другой
подписью. Secrets не используются в workflow для pull request.

Для локального release задаются переменные окружения `ANDROID_KEYSTORE_PATH`
(абсолютный путь к keystore), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` и
`ANDROID_KEY_PASSWORD`, затем выполняется:

```bash
flutter build apk --release --split-per-abi
```

Пароли не требуется вписывать в исходники или `build.gradle.kts`.
Текущий release application ID — `com.example.nekaido_pre`; это существующая
идентичность приложения, не переименованная в рамках настройки сборок.

## Публикация

`Android release` запускается по **новому тегу** `vVERSION`. Номер тега должен
совпадать с `version` в `pubspec.yaml` без `+buildNumber`; build number должен быть
положительным и увеличиваться при обновлении приложения. Старый `v0.1.0` остаётся
историческим desktop-релизом: этот workflow не переиспользует и не перезаписывает
его assets.

После установки secrets и изменения версии проверенный release-коммит можно
пометить, например, тегом `v0.2.0` для `version: 0.2.0+2` и отправить этот тег.
Новая версия и тег в этой задаче автоматически не создаются.

Workflow повторяет проверки, собирает split APK, проверяет их подписи и публикует
GitHub Release со следующими файлами:

- `Hialyth-VERSION-android-arm64-v8a.apk` — большинство современных телефонов;
- `Hialyth-VERSION-android-armeabi-v7a.apk` — совместимые 32-битные устройства;
- `Hialyth-VERSION-android-x86_64.apk` — совместимые эмуляторы/устройства;
- `SHA256SUMS` — контрольные суммы скачиваемых APK.

Версии с суффиксом, например `0.2.0-beta.1`, отмечаются как prerelease. Ручной
`workflow_dispatch` на ветке собирает только подписанные artifacts, без публикации;
GitHub предоставляет ручной запуск после появления workflow в default branch.
Windows/Linux больше не входят в текущий release workflow; существующие архивы
и исходники этих платформ сохранены.
