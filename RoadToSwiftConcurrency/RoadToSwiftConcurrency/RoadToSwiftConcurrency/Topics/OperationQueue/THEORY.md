# OperationQueue — Теория / Theory

## Зачем нужен / Purpose

**OperationQueue** — надстройка над GCD. Управляет очередью `Operation` с поддержкой **зависимостей** (operation B начнётся только после A), **отмены**, **приоритетов**. `BlockOperation` — простой способ обернуть closure в Operation.

**OperationQueue** — abstraction over GCD. Manages queue of `Operation` with **dependencies** (B starts only after A), **cancellation**, **priorities**. `BlockOperation` — simple way to wrap a closure in Operation.

---

## Применение / Application

**Когда нужен:** цепочки операций с зависимостями — «сначала загрузить, потом обработать, потом сохранить». Отмена всей цепочки через `queue.cancelAllOperations()`. Ограничение параллелизма через `maxConcurrentOperationCount`.

**When to use:** operation chains with dependencies — "load first, then process, then save". Cancel entire chain via `queue.cancelAllOperations()`. Limit concurrency via `maxConcurrentOperationCount`.

**Типичные задачи:** пайплайны обработки, загрузка → парсинг → кэш, последовательные шаги с прогрессом.

**Typical tasks:** processing pipelines, load → parse → cache, sequential steps with progress.

---

## Паттерн / Pattern

```swift
let queue = OperationQueue()

let opA = BlockOperation { /* work A */ }
let opB = BlockOperation { /* work B */ }
let opC = BlockOperation { /* work C */ }

opB.addDependency(opA)  // B после A / B after A
opC.addDependency(opB)  // C после B / C after B

queue.addOperations([opA, opB, opC], waitUntilFinished: false)

// Отмена / Cancel
queue.cancelAllOperations()
```

**Важно / Important:** Зависимости задаются до добавления в очередь. `addDependency` создаёт порядок A → B → C.

Dependencies are set before adding to queue. `addDependency` creates order A → B → C.

---

## Дальше / Next

- `concurrentPerform` — параллельная итерация по диапазону / parallel iteration

---

## Задача / Task

Реализуй демо: **3 операции с зависимостями** (A → B → C). Каждая симулирует загрузку 1 сек (`delay: 1`). ProgressView (1/3, 2/3, 3/3). Когда все завершатся — покажи результат (Resource 0, Resource 1, Resource 2). Кнопка «Load». Используй `SimulatedNetworkService.fetchResourceSync(id:delay:)` для id 0, 1, 2.

Implement demo: **3 operations with dependencies** (A → B → C). Each simulates 1 sec load (`delay: 1`). ProgressView (1/3, 2/3, 3/3). When all complete — show result (Resource 0, Resource 1, Resource 2). Button «Load». Use `SimulatedNetworkService.fetchResourceSync(id:delay:)` for id 0, 1, 2.

---

## Проверка / Verification

Запусти `OperationQueueDemoUITests.testOperationQueueLoadsInOrder` и `testOperationQueueShowsResult`.

Run `OperationQueueDemoUITests.testOperationQueueLoadsInOrder` and `testOperationQueueShowsResult`.
