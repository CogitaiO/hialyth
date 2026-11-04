# Hialyth — дизайн-контракт

**Статус:** Draft v0.1 — на утверждение  
**Дата:** 2026-11-04  
**Ветка:** `refactor/player-core`  
**Связанный документ:** [`../ux/ux-ia-contract.md`](../ux/ux-ia-contract.md)  
**Область:** визуальный язык, токены, компоненты, motion, accessibility, правила glass

---

## 1. Направление

Hialyth использует **Material 3 как структурную основу** и **контролируемые glass-акценты** только там, где они усиливают контент.

Это не полный Liquid Glass и не копирование стиля Namida. Наша формула:

> **Material 3 + тональные поверхности + редкий frosted glass над видео.**

### Почему так

- Material 3 уже поддерживается Flutter, даёт доступность, состояния, компоненты и предсказуемую адаптивность.
- Полный glass на всех поверхностях ухудшает читаемость, производительность и поведение на Linux/слабых GPU.
- Glass наиболее уместен над видео и постером, где он создаёт глубину; в библиотеке и настройках он мешает.
- Hialyth должен выглядеть спокойно и дорого, а не «эффектно любой ценой».

### Что не делаем

- Не используем размытие на прокручиваемых списках, карточках, диалогах и формах.
- Не делаем «линзы», преломление, блики и спекулярные эффекты.
- Не используем прозрачность как единственный способ выделить состояние.
- Не смешиваем несколько icon-семейств и случайные радиусы.
- Не строим визуал на красном акценте: красный зарезервирован для опасных действий.

---

## 2. Принципы

1. **Контент важнее хрома.** Постеры, кадры и названия — главное; панели не конкурируют с ними.
2. **Контраст выше эффекта.** Если glass ухудшает читаемость, glass отключается.
3. **Один акцент.** Пользовательский акцент — основной цвет действий; статусы используют отдельные семантические цвета.
4. **Спокойная глубина.** Тональные поверхности, тонкие границы и редкие тени вместо тяжёлых shadow.
5. **Предсказуемая геометрия.** Одна шкала отступов, одна шкала радиусов, один набор иконок.
6. **Motion объясняет, а не развлекает.** Анимация показывает связь состояний и не задерживает пользователя.
7. **Desktop-first.** Плотность, hover, focus, клавиатура и контекстные меню — полноценные части дизайна.
8. **Graceful degradation.** Без прозрачности, без анимации и при слабом GPU интерфейс остаётся полноценным.

---

## 3. Цвет

### 3.1. Режимы темы

- **Dark** — основной режим Hialyth.
- **System** — целевой режим после стабилизации foundation.
- **Light** — целевой режим, но не блокирует первый этап; значения ниже ориентировочные.

Для первого PR с токенами:

- реализуем dark;
- архитектура `AppTheme` сразу принимает `Brightness` и не хардкодит цвета в виджетах;
- light включаем после проверки контраста и glass fallback.

### 3.2. Семантические роли

| Токен | Назначение |
|---|---|
| `surface.base` | Фон приложения |
| `surface.raised` | Панели, title bar, sidebar |
| `surface.container` | Карточки, поля, вкладки |
| `surface.containerHigh` | Hover/active-подложки, меню |
| `surface.overlay` | Непрозрачный fallback для overlay |
| `surface.glass` | Стеклянная подложка над видео |
| `surface.scrim` | Затемнение поверх видео/постера |
| `content.primary` | Основной текст |
| `content.secondary` | Вторичный текст |
| `content.muted` | Подписи, метаданные |
| `content.disabled` | Недоступный текст |
| `border.subtle` | Тонкие разделители |
| `border.strong` | Активные границы, hover |
| `border.focus` | Кольцо фокуса |
| `accent` | Основной акцент |
| `accent.container` | Тональная подложка акцента |
| `onAccent` | Текст/иконка на акценте |
| `success` | Успех, просмотрено |
| `warning` | Предупреждение |
| `danger` | Ошибка, удаление |
| `info` | Нейтральная информация |

### 3.3. Reference dark palette

Значения ниже — стартовая точка для foundation; после glass spike и проверки контраста их можно скорректировать.

| Роль | Значение |
|---|---|
| `surface.base` | `#0E0F11` |
| `surface.raised` | `#15171A` |
| `surface.container` | `#1B1E22` |
| `surface.containerHigh` | `#22262B` |
| `surface.hover` | `#262B31` |
| `surface.overlay` | `rgba(10, 11, 13, 0.72)` |
| `surface.glass` | `rgba(20, 22, 26, 0.55)` |
| `border.subtle` | `#262B31` |
| `border.strong` | `#343A42` |
| `content.primary` | `#F4F6F8` |
| `content.secondary` | `#B9C0C9` |
| `content.muted` | `#858D98` |
| `content.disabled` | `#58606B` |
| `accent` (default) | `#8B7CF6` (Iris) |
| `onAccent` | вычисляется по контрасту; для Iris — тёмный `#14101F` |
| `success` | `#4ADE80` |
| `warning` | `#FBBF24` |
| `danger` | `#F87171` |
| `info` | `#60A5FA` |

### 3.4. Статусы

| Статус | Цвет | Не только цвет |
|---|---|---|
| В планах | `#C4B5FD` | Иконка/подпись |
| Смотрю | `#7DB7FF` | Иконка/подпись |
| Просмотрено | `#6EE7B7` | Галочка/подпись |
| Брошено | `#FCA5A5` | Иконка/подпись |
| Ошибка | `danger` | Иконка + текст |

Красный **не используется** для hover названия, обычного акцента или декоративных элементов.

### 3.5. Акцент

- Пользователь выбирает акцент из пресетов или color picker.
- Accent seed используется для `ColorScheme.fromSeed`, но ключевые роли (`primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`) проверяются на контраст.
- `onAccent` выбирается по фактическому контрасту, а не по порогу `luminance > 0.5`.
- Если постер даёт динамический цвет, он используется только для ambient-фона карточки и мягкого свечения, не для кнопок и текста.
- Fallback accent — Iris `#8B7CF6`, не красный.

### 3.6. Контраст

- Основной текст: **≥ 4.5:1**.
- Крупный текст (≥ 18 px bold / ≥ 24 px): **≥ 3:1**.
- Иконки и границы управления: **≥ 3:1**.
- Текст на glass проверяется на худшем кадре: белый и чёрный фон.
- Если контраст не проходит, glass заменяется на `surface.overlay` с непрозрачностью ≥ 0.88.
- Focus ring: 2 px, контраст ≥ 3:1 к соседним поверхностям.

---

## 4. Типографика

### 4.1. Шрифты

| Роль | Шрифт | Лицензия |
|---|---|---|
| UI / body | **Inter** | OFL |
| Display / headings | **Inter** | OFL |
| Timecodes / file metadata | **JetBrains Mono** | OFL |

- Шрифты **бандлятся в приложение**, без загрузки из сети.
- Fallback: `Roboto`, затем системный sans-serif.
- Для цифр времени используем `FontFeature.tabularFigures()`.
- Не используем более двух семейств.

### 4.2. Шкала

| Стиль | Размер / line-height | Вес | Где |
|---|---|---|---|
| Display large | 36 / 44 | 700 | Крупный заголовок карточки (max 2 строки) |
| Display | 32 / 40 | 700 | Заголовки экранов |
| Headline | 24 / 32 | 700 | Секции, пустые состояния |
| Title large | 20 / 28 | 600 | Заголовки диалогов, панелей |
| Title | 16 / 24 | 600 | Названия карточек, элементы списка |
| Body | 14 / 20 | 400 | Основной текст |
| Body small | 13 / 18 | 400 | Вторичные описания |
| Label | 12 / 16 | 600 | Кнопки, chips, подписи |
| Caption | 11 / 16 | 500 | Метаданные, tooltip |
| Mono | 13 / 20 | 500 | Время, размеры, file info |

Правила:

- Заголовок карточки тайтла — не больше 36 px; 42 px из текущего UI убираем.
- Максимум 2 строки для заголовка, 4 строки для описания с «Читать далее».
- Не используем ALL CAPS для длинных заголовков; только для маленьких section labels с letter-spacing ≤ 0.8.
- Минимальный размер текста — 11 px; 10 px и меньше не используем.
- При text scale 200% интерфейс не должен обрезать критичные действия.

---

## 5. Сетка, отступы, радиусы

### 5.1. Отступы

Базовая шкала — 4 px:

`4, 8, 12, 16, 24, 32, 40, 48, 64`

| Контекст | Значение |
|---|---|
| Внутренний padding карточки | 16 |
| Padding экрана (compact) | 16 |
| Padding экрана (medium) | 24 |
| Padding экрана (expanded) | 32 |
| Расстояние между секциями | 24–32 |
| Расстояние между карточками | 16 |
| Отступ иконки от текста | 8 |
| Вертикальный ритм строк | 8 |

### 5.2. Радиусы

| Токен | Значение | Где |
|---|---|---|
| `radius.sm` | 6 | Маленькие badges, tooltip |
| `radius.md` | 8 | Input, small button |
| `radius.lg` | 12 | Карточки, кнопки, меню |
| `radius.xl` | 16 | Панели, постеры, player bar |
| `radius.2xl` | 24 | Диалоги, крупные контейнеры |
| `radius.pill` | 999 | Chips, status pills |

- Один компонент не смешивает больше двух радиусов.
- Постер: `radius.lg` (12), карточка тайтла: `radius.xl` (16).
- Кнопки: `radius.lg` (12), не pill, кроме chips.

### 5.3. Layout

| Элемент | Значение |
|---|---|
| Title bar | 40 |
| Sidebar compact/medium | 72 (icon rail) |
| Sidebar expanded | 220 |
| Sidebar wide | 240 |
| Top bar | 64 |
| Player bottom bar | 72 + progress |
| Player sidebar | 360 |
| Content max (library) | 1440 |
| Content max (details) | 1200 |
| Content max (settings) | 960 |
| Grid card min | 160 |
| Grid card max | 220 |
| Poster aspect | 2:3 |
| Grid gap | 16 |

- Карточки не растягиваются на всю ширину: используем `SliverGridDelegateWithMaxCrossAxisExtent`.
- На wide-экранах увеличиваем количество колонок, а не размер одной карточки до бесконечности.
- Контент центрируется по горизонтали с max width.

---

## 6. Поверхности и elevation

### 6.1. Уровни

| Уровень | Токен | Использование |
|---|---|---|
| 0 | `surface.base` | Фон приложения |
| 1 | `surface.raised` | Title bar, sidebar, top bar |
| 2 | `surface.container` | Карточки, поля, списки |
| 3 | `surface.containerHigh` | Hover, active, меню |
| 4 | `surface.overlay` | Диалоги, player fallback |
| Glass | `surface.glass` | Только над видео |

### 6.2. Тени

- Карточки: без shadow; используем border + tonal surface.
- Hover: border `border.strong`, лёгкий accent glow допустим только для постера.
- Диалоги: `0 12 32 rgba(0,0,0,0.38)`.
- Меню: `0 8 24 rgba(0,0,0,0.32)`.
- Не используем neumorphism и тяжёлые тени.

### 6.3. Glass

#### Токены

| Токен | Значение |
|---|---|
| `glass.blur` | 20 (диапазон 16–24) |
| `glass.tint` | `surface` с alpha 0.55 (dark), 0.65 (light) |
| `glass.saturation` | 1.15 |
| `glass.border` | white 0.12 (dark), black 0.10 (light) |
| `glass.scrim` | black 0.35 для текста поверх видео |
| `glass.fallback` | `surface.overlay` alpha ≥ 0.88 |

#### Где разрешён

| Поверхность | Glass | Комментарий |
|---|---|---|
| Player top overlay | Нет | Только scrim + прозрачный title bar |
| Player bottom control bar | **Да** | Плавающая панель с radius 16 |
| Player sidebar | **Да** | Панель над видео |
| Skip/next floating button | **Да** | Небольшая pill-кнопка |
| PiP overlay | **Да** | Компактный режим |
| Library shell | Нет | Непрозрачные поверхности |
| Details | Нет | Ambient gradient, без blur |
| Settings | Нет | Непрозрачные поверхности |
| Dialogs/menus | Нет | Читаемость важнее |
| Cards/posters | Нет | Только gradient scrim |

#### Правила

- Glass всегда имеет непрозрачный fallback.
- Не вкладываем glass в glass.
- Не анимируем blur; анимируем opacity.
- `BackdropFilter` только на ограниченной области, не на весь экран.
- На экране одновременно не больше двух glass-слоёв.
- На Linux/слабом GPU glass можно отключить настройкой «Уменьшить прозрачность».
- При `reduce transparency` используем `surface.overlay` и обычную тень/границу.
- Текст на glass всегда имеет scrim; не полагаемся только на blur.

#### Производительность

- Цель: 60 fps при 1280×720 и 1920×1080.
- Если blur стоит больше 2–3 ms на кадр, уменьшаем радиус/область или отключаем.
- Не используем blur в списках, grid и на прокручиваемых поверхностях.
- Изображения декодируются с `cacheWidth`/`memCacheWidth`; не грузим оригинал 4K в карточку.

---

## 7. Иконки

- Одно семейство: **Iconsax** (уже используется).
- Размеры: 16 (inline), 20 (кнопки/меню), 24 (основные действия), 28–32 (player transport).
- Активное состояние — filled; неактивное — outline, если пара существует.
- Не смешиваем Iconsax с Material Icons в одном компоненте.
- Иконка без текста обязана иметь tooltip и `semanticLabel`.
- Статусы используют иконку + цвет + текст, не только цвет.

---

## 8. Компоненты

### 8.1. Title bar

- Высота 40.
- В библиотеке/настройках/карточке — непрозрачный `surface.raised`.
- В плеере — прозрачный, поверх scrim.
- Слева: app mark/название или back.
- Центр/слева: заголовок экрана (опционально).
- Справа: minimize/maximize/close (Windows/Linux).
- Drag-зона — всё свободное пространство.
- Кнопки окна: 46×40, hover-фон; close — `danger` при hover.
- В fullscreen кнопки окна и drag-зона скрыты.

### 8.2. Sidebar / navigation rail

- Expanded: 220–240, логотип, подписи, counts, collections.
- Medium: 72, иконки + tooltip.
- Compact: drawer/верхняя навигация.
- Item: высота 40, radius 12, padding 12, icon 20, label 14.
- Selected: `accent.container`, accent icon/text, optional 2 px accent bar.
- Hover: `surface.hover`.
- Focus: 2 px ring.
- Settings закреплены внизу.

### 8.3. Top bar

- Высота 64.
- Заголовок 24–32, count 13 muted.
- Search: 40 высота, radius 12, `surface.container`, icon 20, clear 18.
- Sort/view: icon button 40×40, tooltip.
- Add folder: primary button 40, icon + label.
- На compact search переносится на вторую строку.

### 8.4. Кнопки

| Тип | Высота | Радиус | Стиль |
|---|---|---|---|
| Primary | 40 | 12 | accent fill, onAccent |
| Secondary | 40 | 12 | `surface.containerHigh`, border |
| Tertiary | 40 | 12 | transparent, accent text |
| Icon | 40×40 | 12 | transparent/hover |
| Destructive | 40 | 12 | danger fill только в confirm |
| Chip | 32 | pill | tonal, selected accent container |

- Горизонтальный padding: 16.
- Icon + label: gap 8.
- Disabled: `content.disabled` + `surface.container` без акцента.
- Loading: spinner 16 вместо иконки, label остаётся.
- Focus: 2 px ring с offset 2.

### 8.5. Карточка тайтла

- Постер 2:3, `radius.lg`, `surface.container`.
- Hover: scale 1.02 (не 1.05), gradient scrim снизу, play-кнопка 40, меню.
- Focus: ring 2 px вокруг всей карточки.
- Title: 13/18, 2 строки, ellipsis.
- Progress: 3 px, accent, внизу постера.
- No cover: заглушка с иконкой, не пустой прозрачный блок.
- Missing: badge/иконка, но карточка остаётся открываемой.
- Контекстное меню — по правому клику и `Shift+F10`.

### 8.6. Список

- Row height 72–80.
- Poster thumb 48×72, radius 8.
- Title 16/24, secondary 13/18 muted.
- Status chip 32, progress 3.
- Hover/focus как у карточки.
- Колонки: title, status, episodes, progress, last watched.

### 8.7. Поля ввода

- Высота 40 (однострочные), 44+ для textarea.
- Radius 12.
- Fill `surface.container`.
- Border: transparent; focus — accent 2 px; error — danger.
- Placeholder `content.muted`.
- Label — floating или сверху; не дублируем placeholder.
- Ошибка — текст 12 danger под полем + иконка.

### 8.8. Диалоги

- Max width 480 (confirm — 420).
- Radius 24.
- Padding 24.
- Заголовок 20/28, body 14/20.
- Действия справа, gap 8; destructive — справа, danger.
- Backdrop `scrim(0.60)`.
- `Esc` и клик по backdrop закрывают, кроме destructive confirm.
- Destructive confirm: явное описание последствий; кнопка «Удалить» не disabled, но требует осознанного клика.

### 8.9. Меню и tooltip

- Menu: min width 220, radius 12, padding 8, item 40, icon 18, divider.
- Tooltip: 300–500 ms, radius 8, padding 8/12, caption 11.
- Tooltip не содержит единственный способ понять действие; для icon-only кнопок — обязателен.

### 8.10. Snackbar и inline-ошибки

- Snackbar: bottom 24, max width 480, radius 12, 4 s, одно действие.
- Не используем snackbar для ошибок, требующих выбора.
- Inline banner: `surface.container`, border, icon, текст, действие; может быть dismissible.

### 8.11. Прогресс и слайдеры

- Linear progress: 3 px, radius pill.
- Circular: 20 (inline), 48 (empty/loading).
- Slider: track 2 idle / 4 hover, thumb 0 idle / 6 hover, focus ring.
- Skip markers: светлые полупрозрачные сегменты; не конкурируют с прогрессом.
- Время: mono, tabular.

### 8.12. Пустые состояния

- Иконка 48, `content.muted`.
- Заголовок 20/28.
- Body 14/20, max width 480, center.
- Primary + secondary action.
- Не используем декоративные иллюстрации, которые увеличивают вес приложения без пользы.

### 8.13. Skeleton

- `surface.container` с мягким pulse.
- Форма повторяет контент: постер, строки, кнопки.
- Reduced motion: статичный skeleton.
- Не показываем skeleton дольше, чем нужно; при ошибке заменяем на error state.

### 8.14. Player overlay

- Верх: scrim сверху, прозрачный title bar; back и title.
- Низ: scrim + floating glass bar (radius 16, margin 16).
- Progress bar над транспортом.
- Транспорт: play/pause 32, next 28, volume 24 + slider 80, time 13 mono, speed, tracks, PiP, episodes, fullscreen.
- На compact: volume slider и второстепенные действия в overflow.
- Skip button: floating glass pill, accent icon, label 14; не перекрывает progress.
- Sidebar: glass panel 360, tabs 40, list rows 56.
- Next episode overlay: scrim 0.70, countdown 48 mono, две кнопки.
- Focus ring видим на glass.

---

## 9. Motion

### 9.1. Токены

| Токен | Длительность | Где |
|---|---|---|
| `motion.fast` | 100 ms | Цвет, opacity, hover |
| `motion.normal` | 150 ms | Кнопки, chips, focus |
| `motion.medium` | 200 ms | Overlay, sidebar, меню |
| `motion.slow` | 300 ms | Hero, page transition |
| `motion.page` | 250 ms | Переход между экранами |
| `motion.countdown` | 5000 ms | Автопереход эпизода |

### 9.2. Кривые

- Enter: `easeOutCubic`.
- Exit: `easeInCubic`.
- Move: `easeInOutCubic`.
- Emphasized: `Curves.easeOutQuart` для крупных переходов.
- Не используем `easeOutBack`/bounce для основных контролов; допустимо только для маленького skip-элемента.

### 9.3. Правила

- Page transition: fade + slide 8 px, 250 ms.
- Hero постера: 300 ms, без деформации.
- Hover карточки: 120–150 ms, scale ≤ 1.02.
- Overlay плеера: 200 ms fade; auto-hide 3 s.
- Sidebar: 250 ms slide.
- Меню/диалог: 150–200 ms fade/scale 0.98→1.
- Countdown: линейный, 5 s; отмена мгновенная.
- Не анимируем blur, layout-размеры и большие списки.
- Reduced motion: 0 ms для декоративных анимаций; переходы — мгновенные или короткий fade 80 ms; без scale/slide.

---

## 10. Accessibility

### 10.1. Контраст

- Text: 4.5:1; large text: 3:1.
- Icons/controls: 3:1.
- Glass: проверка на белом и чёрном видео; при провале — opaque fallback.
- Не используем цвет как единственный индикатор статуса.

### 10.2. Фокус

- Все интерактивные элементы доступны по `Tab`.
- Focus ring: 2 px accent + 2 px offset; виден на glass и постерах.
- Фокус не теряется при открытии/закрытии меню и sidebar.
- `Esc` возвращает фокус на предыдущий элемент.

### 10.3. Клавиатура

- Полный сценарий: библиотека → карточка → плеер → назад.
- `Enter` активирует, `Space` — play/pause в плеере; в библиотеке `Space` не должен скроллить при фокусе на карточке.
- Shortcuts не срабатывают в текстовых полях.
- Tooltip и `semanticLabel` для icon-only.

### 10.4. Размеры и scaling

- Hit target: минимум 40×40 (desktop), 44×44 (будущий touch).
- Text scale 100–200%: критические действия не обрезаются; layout перестраивается.
- Не фиксируем высоту текстовых контейнеров без необходимости.
- Постеры и видео сохраняют пропорции.

### 10.5. Screen reader

- Карточка: «<Название>, <статус>, просмотрено N из M эпизодов».
- Прогресс-бар: значение и время.
- Постер: alt = название тайтла.
- Иконки статусов: семантические подписи.
- Диалоги: focus trap, заголовок как label.
- Ошибки: `liveRegion` для важных изменений.

### 10.6. Reduced motion / transparency

- Настройки: «Уменьшить движение», «Уменьшить прозрачность».
- Reduced motion: без scale, slide, bounce; только fade/instant.
- Reduced transparency: glass → `surface.overlay` alpha ≥ 0.88; убрать blur.
- Настройки должны применяться без перезапуска.

### 10.7. Субтитры

- Плеер поддерживаетASS/SRT; треки выбираются в диалоге.
- Субтитры не перекрываются управлением; при появлении overlay поднимаем `sub-pos` (текущее поведение сохранить).
- Размер/позиция субтитров — P1.

---

## 11. Локализация и контент

- `AppStrings`/ARB; русский по умолчанию, английский вторым.
- Все строки, включая ошибки, tooltip, пустые состояния и семантические labels.
- Плюрализация через ICU.
- Даты и числа — locale-aware.
- Не смешиваем RU/EN в одном экране.
- Названия кнопок — глаголы; ошибки — что случилось + что сделать.
- Технические детали — в логах, не в основном UI.

---

## 12. Performance budget

- 60 fps в библиотеке, карточке, настройках и плеере при 1280×720.
- 60 fps при 1920×1080; 4K — деградация качества blur, не FPS.
- Blur: максимум 2 слоя, только в плеере.
- Изображения: `cacheWidth`/`memCacheWidth`; не декодируем 4K постер в карточку.
- Списки: `builder`/slivers, без `Column` на всю библиотеку.
- Не перестраиваем всю сетку при hover одной карточки.
- Skeleton не должен вызывать layout shift.
- Анимации не должны запускать `saveLayer` на большой области без необходимости.

---

## 13. Foundation для реализации

Первый PR после утверждения контракта — **без изменения внешнего вида**:

1. `AppTheme` — сборка `ThemeData` из `Brightness`, accent и токенов; убрать сборку темы из `main.dart`.
2. `AppTypography` — `TextTheme` на Inter/JetBrains Mono, табличные цифры.
3. `AppMotion` — длительности и кривые.
4. `AppSurfaces` — surface/elevation/glass токены и fallback.
5. `AppBreakpoints` — compact/medium/expanded/wide.
6. `AppStrings`/ARB — каркас локализации.
7. Component themes: buttons, cards, dialogs, menus, inputs, sliders, tooltips, snackbars, chips.
8. Design System Gallery — debug-маршрут `/_design` со всеми компонентами и состояниями.
9. Golden-тесты: 840×560, 1280×720, 1920×1080; dark; reduced motion/transparency.
10. Feature flag `designV2` для постепенной миграции.

Правила:

- Виджеты не читают `settingsProvider.accentColorValue` напрямую; используют `Theme.of(context).colorScheme` или `AppColors`.
- Никаких `Colors.redAccent`, `Colors.white24` и локальных `TextStyle` в экранах.
- `AppSpacing`/`AppRadii` сохраняются как compatibility-слой, но новые компоненты используют семантические токены.
- `CustomTitleBar` получает режимы `opaque`/`transparent`/`player`.
- `MediaCard` получает состояния hover/focus/missing/loading.
- `PlayerOverlay` получает glass-панель с fallback.

---

## 14. Критерии готовности дизайн-контракта

- [ ] Направление Material 3 + controlled glass подтверждено.
- [ ] Определены цветовые роли и fallback accent.
- [ ] Определены шрифты и типографическая шкала.
- [ ] Определены spacing/radii/layout.
- [ ] Определены правила glass и fallback.
- [ ] Определены motion-токены и reduced motion.
- [ ] Определены accessibility-требования.
- [ ] Определены компоненты и их состояния.
- [ ] Определён план foundation PR и golden-тестов.
- [ ] Открытые решения подтверждены.

---

## 15. Открытые решения

| # | Вопрос | Предлагаемое решение | Статус |
|---|---|---|---|
| 1 | Основной акцент | Iris `#8B7CF6` вместо красного; красный — только danger | Предложено |
| 2 | Режимы темы | Dark сейчас; System/Light — после foundation | Предложено |
| 3 | Шрифт | Inter + JetBrains Mono, локально | Предложено |
| 4 | Объём glass | Только player overlay/sidebar/floating controls | Предложено |
| 5 | Title bar в плеере | Прозрачный + scrim, без blur | Предложено |
| 6 | Плотность | Comfortable по умолчанию; Compact — P1 | Предложено |
| 7 | Динамический цвет от постера | Только ambient glow, не UI accent | Предложено |
| 8 | Светлая тема | Проектируем токены, включаем после проверки контраста | Предложено |

---

## Приложение A. Что меняется относительно текущего UI

| Сейчас | Целевое |
|---|---|
| Только dark, accent из SharedPreferences читается виджетами | `AppTheme` + `ColorScheme`, виджеты не знают о prefs |
| Красный fallback accent | Iris fallback; красный — danger |
| Нет типографической шкалы | Inter + JetBrains Mono, `AppTypography` |
| Радиусы 6/8/12/16 без системы | Семантические radius-токены |
| Hover карточки scale 1.05 | 1.02 + мягкий scrim |
| Красный hover названия | Accent/primary, без красного |
| Glass нет; только градиенты | Controlled glass в плеере + fallback |
| Фиксированные ширины 70/250/280 | Breakpoints + адаптивные панели |
| Локальные `TextStyle`/`Colors.*` | Токены и component themes |
| Нет focus ring | Единый focus ring 2 px |
| Нет reduced motion/transparency | Настройки + fallback |
| Нет design gallery/golden | `/_design` + golden-тесты |
