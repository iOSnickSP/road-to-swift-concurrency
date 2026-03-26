# SerialExecutor — Теория / Theory

## Зачем нужен / Purpose

По умолчанию actor выполняет работу на **cooperative thread pool** — общем пуле потоков Swift Concurrency. **SerialExecutor** позволяет привязать actor к **конкретной очереди** (например `DispatchQueue`) — работа actor'а будет выполняться только там.

By default, an actor runs on the **cooperative thread pool** — Swift Concurrency's shared pool. **SerialExecutor** lets you bind an actor to a **specific queue** (e.g. `DispatchQueue`) — the actor's work runs only there.

---

## Когда использовать / When to Use

- **Blocking I/O** — SQLite, файлы, сокеты. Blocking на cooperative pool может «занять» поток и замедлить другие Task.
- **Интеграция с GCD** — legacy-код на определённой очереди, actor должен выполнять туда же.
- **Выделенная очередь** — изолировать тяжёлую работу от основного пула.

---

## Паттерн / Pattern

1. **Класс Executor** — conforms to `SerialExecutor`, оборачивает `DispatchQueue`, диспатчит job'ы на неё.
2. **Actor** — имеет `nonisolated var unownedExecutor`, возвращает свой Executor.

```swift
final class QueueExecutor: SerialExecutor {
    private let queue = DispatchQueue(label: "com.example.actor")

    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        let unownedExec = asUnownedSerialExecutor()
        queue.async {
            unownedJob.runSynchronously(on: unownedExec)
        }
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

actor MyActor {
    private let executor = QueueExecutor()

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }
    // ...
}
```

---

## Важно / Important

- Executor должен **жить** пока жив actor — хранить как stored property.
- `asUnownedSerialExecutor()` — создаёт «обёртку» для передачи в runtime.

---

## Дальше / Next

- `TaskExecutor` — приоритет executor'а для вложенных Task
- `assumeIsolated` — когда известна изоляция

---

## Задача / Task

Реализуй демо: **счётчик на custom executor**. Скелет уже есть — допиши **2 места**.

**1. CustomQueueExecutor.enqueue** — сейчас job «съедается» и не выполняется (зависание). Реализуй паттерн:
```swift
let unownedJob = UnownedJob(job)
let unownedExec = asUnownedSerialExecutor()
queue.async {
    unownedJob.runSynchronously(on: unownedExec)
}
```

**2. QueueBoundCounter.increment** — сейчас возвращается `0`. Реализуй: `count += 1; return count`

**UI:** Кнопка «Increment», Label — уже настроены.

**Implement demo: counter on custom executor.** Skeleton exists — complete **2 places**.

**1. CustomQueueExecutor.enqueue** — job is consumed but never runs (hang). Implement the pattern above.

**2. QueueBoundCounter.increment** — currently returns `0`. Implement: `count += 1; return count`

---

## Дальше / Next

- **CheckedContinuation** — колбэки → `async` через `withCheckedContinuation` / [`../CheckedContinuation/THEORY.md`](../CheckedContinuation/THEORY.md)
- **CheckedThrowingContinuation** — `Result` / ошибки в колбэке → `async throws` / [`../CheckedThrowingContinuation/THEORY.md`](../CheckedThrowingContinuation/THEORY.md)

---

## Проверка / Verification

Запусти `SerialExecutorDemoUITests.testSerialExecutorIncrementUpdatesCount`.

Run `SerialExecutorDemoUITests.testSerialExecutorIncrementUpdatesCount`.
