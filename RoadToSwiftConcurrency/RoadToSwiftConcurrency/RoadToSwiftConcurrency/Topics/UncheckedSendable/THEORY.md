# @unchecked Sendable — Теория / Theory

## Зачем нужен / Purpose

**@unchecked Sendable** — ручная конформность к Sendable, когда компилятор **не может вывести** её автоматически. Разработчик берёт ответственность за потокобезопасность на себя. Компилятор не проверяет — ошибка приведёт к data race.

**@unchecked Sendable** — manual Sendable conformance when the compiler **can't infer** it. Developer takes responsibility for thread safety. Compiler doesn't verify — a mistake leads to data race.

---

## Когда использовать / When to Use

- **final class** с lock/queue внутри — потокобезопасен, но компилятор не видит внутреннюю синхронизацию
- Обёртки над C/Objective-C API
- Legacy-код, который нельзя переписать в value type

- **final class** with internal lock/queue — thread-safe, but compiler doesn't see the sync
- Wrappers over C/Objective-C API
- Legacy code that can't be rewritten as value type

---

## Когда НЕ использовать / When NOT to Use

- Если можно сделать тип Sendable «честно» (struct, actor) — делай так
- Не используй как «костыль» чтобы заглушить ошибку компилятора
- Убедись, что тип **действительно** потокобезопасен

- If you can make the type Sendable properly (struct, actor) — do that
- Don't use as a workaround to silence compiler errors
- Ensure the type is **actually** thread-safe

---

## Сравнение / Comparison

| Sendable | @unchecked Sendable |
|----------|---------------------|
| Компилятор проверяет все поля | Компилятор не проверяет |
| Безопасно по умолчанию | Ответственность на тебе |
| struct, enum, примитивы | final class с ручной синхронизацией |

---

## Пример / Example

```swift
final class ThreadSafeBox<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: T?

    func get() -> T? {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func set(_ value: T?) {
        lock.lock()
        defer { lock.unlock() }
        _value = value
    }
}
```

Lock защищает доступ к `_value`. Класс потокобезопасен. Компилятор не видит lock — поэтому `@unchecked Sendable`.

Lock protects access to `_value`. Class is thread-safe. Compiler doesn't see the lock — hence `@unchecked Sendable`.

---

## Дальше / Next

- `SerialExecutor` — привязка actor к конкретной очереди / binding actor to a queue

---

## Задача / Task

Реализуй демо: **ThreadSafeBox** — обёртка над значением с lock.

**ThreadSafeBox:**
- `final class ThreadSafeBox<T>` — хранит `T?`, доступ через `get()` и `set()`
- Внутри: `NSLock` и `private var _value: T?`
- Добавь `: @unchecked Sendable` — иначе не передать Box между Task/actor. Обоснование: lock защищает все обращения к `_value`

**UI:**
- TextField (`uncheckedSendable.input`), кнопки «Store» (`uncheckedSendable.store`) и «Retrieve» (`uncheckedSendable.retrieve`), Label (`uncheckedSendable.result`)
- Store: сохранить текст из TextField в Box (вызвать `box.set(...)`). Можно в Task, чтобы показать передачу через границу
- Retrieve: получить из Box, показать в Label

**Implement demo: ThreadSafeBox with @unchecked Sendable.**

**ThreadSafeBox:**
- `final class ThreadSafeBox<T>` — stores `T?`, access via `get()` and `set()`
- Inside: `NSLock` and `private var _value: T?`
- Add `: @unchecked Sendable` — otherwise can't pass Box between Task/actor. Justification: lock protects all access to `_value`

**UI:**
- TextField (`uncheckedSendable.input`), buttons «Store» (`uncheckedSendable.store`) and «Retrieve» (`uncheckedSendable.retrieve`), Label (`uncheckedSendable.result`)
- Store: save text from TextField to Box (call `box.set(...)`)
- Retrieve: get from Box, show in Label

---

## Проверка / Verification

Запусти `UncheckedSendableDemoUITests.testUncheckedSendableStoreAndRetrieve`.

Run `UncheckedSendableDemoUITests.testUncheckedSendableStoreAndRetrieve`.
