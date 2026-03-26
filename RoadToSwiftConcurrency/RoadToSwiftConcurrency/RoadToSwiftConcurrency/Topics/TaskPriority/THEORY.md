# `TaskPriority` — Теория / Theory

## Зачем нужен / Purpose

**`TaskPriority`** — подсказка планировщику Swift: насколько срочна задача относительно других (`.high`, `.medium`, `.low`, `.background`, `.userInitiated`, `.utility` и т.д.). Это **не** жёсткая гарантия порядка на всех ОС и устройствах, но влияет на то, как часто задача получает время CPU.

**`TaskPriority`** hints to the Swift scheduler how urgent work is relative to other tasks (`.high`, `.medium`, `.low`, `.background`, `.userInitiated`, `.utility`, etc.). It is **not** a strict ordering guarantee on every OS/device, but it affects scheduling.

---

## API

```swift
Task(priority: TaskPriority? = nil, operation: @Sendable () async -> Success)
Task.detached(priority: TaskPriority? = nil, operation: @Sendable () async -> Success)
```

- Если `priority` не указан, дочерние задачи часто **наследуют** приоритет родителя (в зависимости от контекста).
- Для UI обычно остаются на **MainActor**; приоритет задаётся на **`Task`**, который выполняет работу.

---

## Важно / Important

- Не полагайся на «высокий всегда закончится раньше низкого» в UI-тестах на симуляторе — демо показывает **API**, не бенчмарк.
- Тяжёлую работу с `.background`, отзывчивый UI — с более высоким приоритетом (по смыслу).

---

## Дальше / Next

- Тема в проекте: **MainActor** — [`../MainActor/THEORY.md`](../MainActor/THEORY.md) (изоляция UI, глобальный актор)
- **TaskGroup** — [`../TaskGroup/THEORY.md`](../TaskGroup/THEORY.md) (структурированный параллелизм)
- `ContinuousClock` / замеры интервалов для профилирования

---

## Задача / Task

Реализуй демо: **два параллельных `Task`** с разными приоритетами (например **`.high`** и **`.low`**), одинаковое число шагов и короткий `Task.sleep` между шагами; общий статус **«Completed»** только когда **оба** цикла завершились.

**UI:**
- `taskPriority.start`, `taskPriority.cancel`
- `taskPriority.status` — `Tap Start` → `Running...` → `Completed` или `Cancelled`
- `taskPriority.highProgress` — `High: 0/8` … `High: 8/8` → **`High: Done`**
- `taskPriority.lowProgress` — `Low: 0/8` … `Low: 8/8` → **`Low: Done`**

**Поведение:**
- **Start:** отмени предыдущий координирующий `Task`; выставь `Running...`, `High: 0/8`, `Low: 0/8`.
- Запусти **два** `Task(priority:)` (`.high` и `.low`), в каждом цикл **8** шагов: `checkCancellation`, `sleep` (например **100 ms**), обновление своего лейбла на **MainActor**; после последнего шага — **`High: Done`** / **`Low: Done`**.
- Координирующий `Task` **ждёт** оба дочерних (например последовательные `await task.value` после старта обоих — они уже бегут параллельно), затем **`Completed`**.
- **Cancel:** отмени **координирующий** `Task` и **оба** `Task(priority:)` по сохранённым ссылкам (надёжнее, чем полагаться только на каскад отмены).
- **`deinit` / Done:** отмена активной работы.

**Строки для UI-тестов:**
- Начало: `status` = `Tap Start`, `High: 0/8`, `Low: 0/8` (или `Tap Start` только у status — согласуй с эталоном в демо).
- Успех: `Completed`, `High: Done`, `Low: Done`.

**Implement demo: two `Task(priority:)` loops + shared completion.**

---

## Проверка / Verification

Запусти `TaskPriorityDemoUITests`.

Run `TaskPriorityDemoUITests`.
