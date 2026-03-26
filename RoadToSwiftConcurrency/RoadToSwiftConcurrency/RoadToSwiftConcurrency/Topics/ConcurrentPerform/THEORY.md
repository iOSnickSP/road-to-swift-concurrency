# concurrentPerform — Теория / Theory

## Зачем нужен / Purpose

**DispatchQueue.concurrentPerform(iterations:execute:)** — выполняет блок N раз **параллельно** на concurrent queue. Каждый вызов получает свой индекс (0..<N). Блокирует вызывающий поток до завершения всех итераций.

**DispatchQueue.concurrentPerform(iterations:execute:)** — runs a block N times **in parallel** on a concurrent queue. Each call receives its index (0..<N). Blocks the calling thread until all iterations complete.

---

## Применение / Application

**Когда нужен:** параллельная обработка массива или диапазона — каждый индекс обрабатывается отдельным «потоком». Проще, чем вручную создавать N async-задач. Подходит для CPU-bound задач (вычисления, обработка пикселей).

**When to use:** parallel processing of array or range — each index handled by a separate "thread". Simpler than manually creating N async tasks. Good for CPU-bound work (computations, pixel processing).

**Типичные задачи:** параллельная обработка изображения, batch-обработка данных, перебор с независимыми итерациями.

**Typical tasks:** parallel image processing, batch data processing, iteration with independent items.

---

## Паттерн / Pattern

```swift
let queue = DispatchQueue.global(qos: .userInitiated)
var results = [String](repeating: "", count: 5)

queue.async {
    DispatchQueue.concurrentPerform(iterations: 5) { index in
        let value = process(index)
        results[index] = value  // каждый индекс пишет один поток / each index written by one thread
    }
    DispatchQueue.main.async {
        self.updateUI(with: results)
    }
}
```

**Важно / Important:** Каждый индекс обрабатывается ровно одной итерацией — можно писать в `results[index]` без синхронизации. Вызов `concurrentPerform` **блокирует** — не вызывай с main thread для долгих задач.

Each index is processed by exactly one iteration — safe to write to `results[index]` without sync. `concurrentPerform` **blocks** — don't call from main thread for long work.

---

## Дальше / Next

- `async/await` — современная замена GCD / modern replacement for GCD

---

## Задача / Task

Реализуй демо: **параллельная обработка 5 элементов** через `concurrentPerform`. Кнопка «Process» — `global().async { concurrentPerform(iterations: 5) { index in ... } }`. Каждый индекс — `SimulatedNetworkService.fetchResourceSync(id: index, delay: 0.5)`. Результаты в массив, затем main.async — ProgressView (5/5), result. Покажи сумму или список (Item 0, Item 1, ...).

Implement demo: **parallel processing of 5 items** via `concurrentPerform`. Button «Process» — `global().async { concurrentPerform(iterations: 5) { index in ... } }`. Each index — `SimulatedNetworkService.fetchResourceSync(id: index, delay: 0.5)`. Collect results, then main.async — ProgressView (5/5), result. Show sum or list (Item 0, Item 1, ...).

---

## Проверка / Verification

Запусти `ConcurrentPerformDemoUITests.testConcurrentPerformProcessesAll` и `testConcurrentPerformShowsResult`.

Run `ConcurrentPerformDemoUITests.testConcurrentPerformProcessesAll` and `testConcurrentPerformShowsResult`.
