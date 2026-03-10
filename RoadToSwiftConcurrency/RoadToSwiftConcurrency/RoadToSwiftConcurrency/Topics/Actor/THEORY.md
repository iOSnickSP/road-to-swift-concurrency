# Actor — Теория / Theory

## Зачем нужен / Purpose

**Actor** — тип, который изолирует своё состояние. Доступ к свойствам и методам actor'а возможен только через `await` — компилятор гарантирует, что не будет data race. Появился в Swift 5.5.

**Actor** — a type that isolates its state. Access to actor's properties and methods requires `await` — compiler guarantees no data races. Introduced in Swift 5.5.

---

## Проблема без Actor / Problem without Actor

```swift
class Counter {
    var count = 0  // несколько Task могут читать/писать одновременно — data race
}

// Task 1: count += 1
// Task 2: count += 1  // может потерять обновление / race
```

С `class` и `var` — несколько потоков могут одновременно менять `count`. Результат непредсказуем.

With `class` and `var` — multiple threads can modify `count` simultaneously. Result is unpredictable.

---

## Решение: Actor / Solution: Actor

```swift
actor Counter {
    private var count = 0

    func increment() async -> Int {
        count += 1
        return count
    }
}

// Использование / Usage
let counter = Counter()
Task {
    let n = await counter.increment()  // await — доступ сериализован
}
```

Actor **сериализует** доступ: только один вызов метода выполняется в момент времени. Остальные ждут.

Actor **serializes** access: only one method call runs at a time. Others wait.

---

## Ключевые понятия / Key Concepts

### actor
Объявление `actor` — как `class`, но с изоляцией. Все свойства и методы по умолчанию изолированы.

`actor` declaration — like `class`, but with isolation. All properties and methods are isolated by default.

### await при доступе
Любой вызов метода actor'а или чтение свойства — через `await`. Это точка приостановки: если actor занят, вызывающий код ждёт.

Any call to actor's method or property read — via `await`. It's a suspension point: if actor is busy, caller waits.

### nonisolated
Метод можно пометить `nonisolated` — тогда он не требует `await`, но не может обращаться к изолированному состоянию.

Method can be marked `nonisolated` — then it doesn't require `await`, but can't access isolated state.

---

## Task.sleep и throws / Task.sleep and throws

`Task.sleep(nanoseconds:)` — `async throws`. При отмене Task выбрасывает `CancellationError`. Используй `try? await` чтобы поглотить ошибку:

`Task.sleep(nanoseconds:)` — `async throws`. Throws `CancellationError` when task is cancelled. Use `try? await` to absorb the error:

```swift
try? await Task.sleep(nanoseconds: 300_000_000)  // 0.3 сек
```

---

## Сравнение с DispatchBarrier / Comparison with DispatchBarrier

**DispatchBarrier** — ручная синхронизация на concurrent queue. Нужно помнить про barrier для записи.

**Actor** — компилятор проверяет: нельзя обратиться к состоянию без `await`. Ошибки невозможны на этапе компиляции.

**DispatchBarrier** — manual sync on concurrent queue. Must remember barrier for writes.

**Actor** — compiler enforces: can't access state without `await`. Errors impossible at compile time.

---

## Применение / Application

**Когда нужен:** shared mutable state — кэш, счётчик, буфер. Вместо locks, semaphores, barrier.

**When to use:** shared mutable state — cache, counter, buffer. Replaces locks, semaphores, barrier.

---

## Дальше / Next

- `Sendable` — что можно передавать между actor'ами / what can be passed between actors
- `@Sendable` closure — требования к замыканиям в Task / closure requirements in Task

---

## Задача / Task

Реализуй демо: **счётчик через Actor**.

**Actor:**
- `actor CounterActor` с `private var count = 0`
- Метод `func increment() async -> Int` — увеличивает count на 1, возвращает новое значение.
- Внутри добавь `try? await Task.sleep(nanoseconds: 300_000_000)` (0.3 сек) — чтобы при быстрых нажатиях видеть сериализацию. `Task.sleep` throws — используй `try?`.

**UI:**
- Кнопка «Add» (`actorDemo.add`), лейбл с текущим значением (`actorDemo.count`). Начальное: «0».
- Свойство `private let counter = CounterActor()`.
- По нажатию: `Task { let n = await counter.increment(); countLabel.text = "\(n)" }`. Обработчик `@objc` — синхронный, поэтому оберни в `Task { }`.

**Отмена при уходе с экрана:**
- Что если пользователь закроет экран (Done или swipe) во время загрузки? Task продолжит работу и попытается обновить UI уже закрытого контроллера.
- Сохрани `Task` в свойство `incrementTask` — чтобы иметь возможность вызвать `cancel()`.
- В `viewWillDisappear` отмени задачу: `incrementTask?.cancel()`.
- После `await counter.increment()` проверь `Task.isCancelled` — если отменено, не обновляй UI (`guard !Task.isCancelled else { return }`).

**Implement demo: counter via Actor.**

**Actor:**
- `actor CounterActor` with `private var count = 0`
- Method `func increment() async -> Int` — increments count by 1, returns new value.
- Add `try? await Task.sleep(nanoseconds: 300_000_000)` (0.3 sec) inside — to see serialization. `Task.sleep` throws — use `try?`.

**UI:**
- Button «Add» (`actorDemo.add`), label with current value (`actorDemo.count`). Initial: «0».
- Property `private let counter = CounterActor()`.
- On tap: `Task { let n = await counter.increment(); countLabel.text = "\(n)" }`. Handler is `@objc` — sync, so wrap in `Task { }`.

**Cancellation on dismiss:**
- What if the user dismisses the screen (Done or swipe) during load? The Task will continue and try to update UI of a dismissed controller.
- Store the `Task` in property `incrementTask` — so you can call `cancel()`.
- In `viewWillDisappear`, cancel the task: `incrementTask?.cancel()`.
- After `await counter.increment()`, check `Task.isCancelled` — if cancelled, don't update UI (`guard !Task.isCancelled else { return }`).

---

## Проверка / Verification

Запусти `ActorDemoUITests.testActorIncrementUpdatesCount`.

Run `ActorDemoUITests.testActorIncrementUpdatesCount`.
