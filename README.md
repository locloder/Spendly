# Spendly — трекер расходов для iPhone (SwiftUI, iOS 17+)

Баланс, траты, подписки с напоминаниями, голосовой ввод, чек по фото, Siri («Добавить трату в Spendly»).

## Сборка без Mac (через GitHub + Windows)
1. В `project.yml` замените `com.changeme.spendly` на свой уникальный идентификатор.
2. Создайте репозиторий на GitHub (лучше публичный) и загрузите ВСЁ содержимое этой папки,
   включая скрытую папку `.github`.
3. Вкладка Actions → Build IPA → Run workflow. Через 5–10 минут в разделе Artifacts появится `Spendly-ipa`.
4. Скачайте и распакуйте artifact — внутри `Spendly.ipa`.
5. На Windows установите iTunes и iCloud (версии с сайта Apple, не из Microsoft Store) и Sideloadly.
6. На iPhone включите Настройки → Конфиденциальность и безопасность → Режим разработчика.
7. Подключите iPhone кабелем, в Sideloadly выберите `Spendly.ipa`, введите свой Apple ID, нажмите Start.
8. На iPhone: Настройки → Основные → VPN и управление устройством → доверять своему Apple ID.
Бесплатный Apple ID: приложение работает 7 дней, потом переустановите тем же способом.

## Сборка на Mac
`brew install xcodegen && xcodegen generate`, откройте `Spendly.xcodeproj`, выберите свою команду подписи и нажмите Run.

## Настройки
- Язык голоса: `Sources/SpeechRecognizer.swift` (`ru-RU`)
- Ключевые слова категорий: `Sources/Models.swift`
- Siri на русском: фразы берутся для языка разработки проекта. Если не сработает, говорите «Add expense in Spendly»
  или запускайте ярлык через приложение «Команды».
