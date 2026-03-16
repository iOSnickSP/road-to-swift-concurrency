# Sendable — Теория / Theory

## Зачем нужен / Purpose

**Sendable** — маркер-протокол для типов, которые можно **безопасно передавать** между actor'ами, Task и разными изоляциями. Компилятор проверяет: при передаче данных через `await` тип должен быть Sendable. Появился в Swift 5.5, строгая проверка — в Swift 6.

**Sendable** — a marker protocol for types that can be **safely passed** between actors, Tasks, and isolation boundaries. Compiler enforces: when passing data across `await`, the type must be Sendable. Introduced in Swift 5.5, strict checking in Swift 6.

---

## Проблема без Sendable / Problem without Sendable

```swift
actor Storage {
    func store(_ value: SomeClass) async { ... }  // SomeClass — ссылка
}

// Два Task одновременно передают один объект — data race при доступе из разных потоков
let obj = SomeClass()
Task { await storage.store(obj) }
Task { await storage.store(obj) }  // тот же объект — небезопасно
```

Ссылочные типы (class) могут быть доступны из нескольких потоков одновременно. Передача через границу actor'а без проверки — риск data race.

Reference types (class) can be accessed from multiple threads. Passing across actor boundary without checks — data race risk.

---

## Что Sendable по умолчанию / Implicitly Sendable

- **Value types** (struct, enum) — если все stored properties Sendable
- **Примитивы:** Int, String, Bool, Double, UUID, Date
- **Actor types** — сами по себе Sendable (передаётся ссылка на actor)
- **@Sendable closure** — замыкание, захватывающее только Sendable

---

## Что НЕ Sendable / Not Sendable

- **class** — по умолчанию нет (могут быть несколько ссылок)
- **UIViewController, UIView** — не Sendable
- **Closure** без @Sendable — может захватывать что угодно

---

## Явная конформность / Explicit Conformance

```swift
struct Note: Sendable {
    let id: UUID
    let text: String
    let createdAt: Date
}
```

Если struct содержит только Sendable-поля — конформность **неявная**. Но можно указать явно для ясности.

---

## @Sendable closure / @Sendable Closure

Замыкания в `Task { }` неявно `@Sendable`. Они могут захватывать только Sendable-значения:

```swift
Task {
    let x = someValue  // someValue должен быть Sendable
    await doSomething(x)
}
```

Захват `self` (UIViewController) — ошибка, если контроллер не Sendable. Решение: передавать только нужные данные (String, Int и т.д.).

---

## Применение / Application

**Когда проверяется:** передача в actor, возврат из actor, аргументы/результат async-функций, захват в Task.

**When checked:** passing into actor, returning from actor, async function args/results, Task capture.

---

## Дальше / Next

- `@unchecked Sendable` — когда компилятор не может вывести, но ты уверен (ThreadSafeBox)
- `SerialExecutor` — привязка actor к конкретной очереди

---

## Задача / Task

**Формат «исправь код»:** демо Message Relay содержит **ошибку проектирования** — `RelayMessage` хранит `source: UIViewController`. UIViewController не Sendable. Передача такой структуры через границу actor'а небезопасна (в строгом режиме Swift 6 не скомпилируется).

**Сценарий:** Actor `MessageRelay` хранит последнее сообщение. Кнопки «Send» и «Receive» передают данные через границу. Структура `RelayMessage` с полем `source: UIViewController` — нарушает Sendable.

**Твоя задача:**
1. Открой `SendableDemoViewController.swift`
2. Найди `struct RelayMessage` с полем `source: UIViewController`
3. Удали это поле или замени на Sendable-тип (например `sourceId: String`). В `sendTapped` при создании `RelayMessage(...)` — убери аргумент `source` или передай Sendable-значение.
4. Убедись, что `RelayMessage` содержит только Sendable-поля (UUID, String, Date — ок)
5. Запусти `SendableDemoUITests.testSendableSendAndReceive`

**Implement demo: fix the Sendable violation.**

**Format «fix the code»:** the Message Relay demo has a **design flaw** — `RelayMessage` stores `source: UIViewController`. UIViewController is not Sendable. Passing such a struct across the actor boundary is unsafe (won't compile in Swift 6 strict mode).

**Scenario:** Actor `MessageRelay` stores the last message. Buttons «Send» and «Receive» pass data across the boundary. Struct `RelayMessage` with field `source: UIViewController` — violates Sendable.

**Your task:**
1. Open `SendableDemoViewController.swift`
2. Find `struct RelayMessage` with field `source: UIViewController`
3. Remove this field or replace with a Sendable type (e.g. `sourceId: String`). In `sendTapped` when creating `RelayMessage(...)` — remove the `source` argument or pass a Sendable value.
4. Ensure `RelayMessage` contains only Sendable fields (UUID, String, Date — ok)
5. Run `SendableDemoUITests.testSendableSendAndReceive`

---

## Проверка / Verification

Запусти `SendableDemoUITests.testSendableSendAndReceive`.

Run `SendableDemoUITests.testSendableSendAndReceive`.
