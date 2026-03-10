# DispatchSemaphore — Теория / Theory

## Зачем нужен / Purpose

Когда нужно **ограничить количество одновременно выполняющихся задач**. Например: загрузить 10 картинок, но не более 3 параллельно — чтобы не перегрузить сеть или память.

When you need to **limit how many tasks run concurrently**. E.g.: load 10 images, but max 3 at a time — to avoid overloading network or memory.

---

## Применение / Application

**Когда нужен:** много задач, но ограниченный ресурс — сеть, память, соединения с БД. Без лимита можно исчерпать соединения или вызвать throttling.

**When to use:** many tasks but limited resource — network, memory, DB connections. Without a limit you can exhaust connections or trigger throttling.

**Типичные задачи:** массовая загрузка изображений (max N одновременно), пул соединений, rate limiting API-запросов, ограничение параллельных операций с диском.

**Typical tasks:** bulk image loading (max N at once), connection pool, API rate limiting, limiting parallel disk I/O.

---

## Основные методы / Main Methods

| Метод | Описание |
|-------|----------|
| `init(value: Int)` | Создаёт семафор. `value` = сколько «слотов» доступно / creates semaphore. `value` = available "slots" |
| `wait()` | Захватывает слот. Если слотов нет — блокирует поток до освобождения / acquires slot. If none free — blocks until one is released |
| `signal()` | Освобождает слот / releases slot |

---

## Паттерн / Pattern

```swift
let semaphore = DispatchSemaphore(value: 2)  // max 2 concurrent

for i in 0..<5 {
    DispatchQueue.global().async {
        semaphore.wait()  // ждём свободный слот / wait for free slot
        defer { semaphore.signal() }  // освобождаем при выходе / release on exit
        // работа... / work...
    }
}
```

**Важно / Important:** `signal()` должен вызываться при любом выходе (успех, ошибка, return). Используй `defer`, как с `group.leave()`.

---

## Комбинация с DispatchGroup

Часто нужны оба: **ограничить параллелизм** (semaphore) и **дождаться всех** (group).

Often you need both: **limit concurrency** (semaphore) and **wait for all** (group).

```swift
let semaphore = DispatchSemaphore(value: 2)
let group = DispatchGroup()

for i in 0..<5 {
    group.enter()
    DispatchQueue.global().async {
        semaphore.wait()
        defer {
            semaphore.signal()
            group.leave()
        }
        // работа... / work...
    }
}

group.notify(queue: .main) {
    self.allDone()
}
```

---

## Дальше / Next

- `DispatchWorkItem` — отмена задач / task cancellation

---

## Задача / Task

Реализуй демо: загрузка **5 ресурсов**, но **не более 2 одновременно**. ProgressView (1/5, 2/5, ..., 5/5). Когда все загрузятся — покажи результат. Кнопка «Load All».

Implement demo: load **5 resources**, but **max 2 concurrent**. ProgressView (1/5, 2/5, ..., 5/5). When all complete — show result. Button "Load All".

Используй `SimulatedNetworkService.fetchResourceSync(id:)` для id 0..<5.

Use `SimulatedNetworkService.fetchResourceSync(id:)` for id 0..<5.

---

## Проверка / Verification

Запусти `DispatchSemaphoreDemoUITests.testDispatchSemaphoreLoadsAllResources` — тест пройдёт только при корректной реализации.

Run `DispatchSemaphoreDemoUITests.testDispatchSemaphoreLoadsAllResources` — the test passes only when implemented correctly.
