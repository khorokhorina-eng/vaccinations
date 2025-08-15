# VaccineCalendar (SwiftUI)

Minimal SwiftUI app: "Календарь прививок ребёнка".

## Функционал
- Онбординг: дата рождения и страна
- Загрузка календаря из `Resources/Catalogs/{COUNTRY}.json`
- Список обязательных и добавленных необязательных прививок
- Отметка "Сделано", заметки по каждой прививке
- Добавление необязательных прививок
- Локальное сохранение (UserDefaults)

## Структура
- `VaccineCalendarApp.swift` — входная точка
- `Models/` — модели (`ChildProfile`, `VaccineCatalog`, `VaccineScheduleEntry`, `AgeOffset`)
- `Services/` — `CatalogService`, `LocalStore`, `CountryService`
- `Store/` — `AppStore` (ObservableObject)
- `Views/` — `RootView`, `OnboardingView`, `CalendarHomeView`
- `Resources/Catalogs/` — тестовые JSON (`RU.json`, `US.json`)

## Сборка
- Xcode 15+, iOS 17 target (можно ниже при необходимости)
- Убедитесь, что папка `Resources` добавлена в Target Membership как ресурс
- Запуск: Build & Run в симуляторе или на устройстве

## Добавление стран/календарей
- Скопировать JSON в `Resources/Catalogs/XX.json` (где `XX` — код страны)
- Добавить страну в `CountryService.supported`

## Примечания
- Для продакшена можно заменить UserDefaults на Core Data
- Данные пока тестовые; интеграция с реальными источниками делается в `CatalogService`