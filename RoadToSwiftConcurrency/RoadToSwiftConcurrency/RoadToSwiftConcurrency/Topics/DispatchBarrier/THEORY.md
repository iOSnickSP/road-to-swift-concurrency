# DispatchQueue.barrier — Теория / Theory

## Зачем нужен / Purpose

Когда есть **concurrent queue** и нужно **thread-safe чтение/запись** общего состояния. Barrier гарантирует: блок с `.barrier` выполняется **один**, пока все предыдущие задачи завершены; во время barrier другие задачи не выполняются.

When you have a **concurrent queue** and need **thread-safe read/write** of shared state. Barrier ensures: a block with `.barrier` runs **alone**, after all prior tasks complete; no other tasks run during the barrier.

**Ещё один способ синхронизации read/write** — наравне с `NSLock` и serial queue. Barrier даёт параллельное чтение при эксклюзивной записи.

**Another way to synchronize read/write** — alongside `NSLock` and serial queue. Barrier allows concurrent reads with exclusive writes.

---

## Применение / Application

**Когда нужен:** кэш, словарь, общее состояние — много читателей, мало писателей. Нужна thread-safety без блокировки чтения (serial queue блокирует всё).

**When to use:** cache, dictionary, shared state — many readers, few writers. Need thread-safety without blocking reads (serial queue blocks everything).

**Типичные задачи:** in-memory кэш (чтение часто, запись редко), кэш изображений, настройки приложения, shared mutable state.

**Typical tasks:** in-memory cache (read often, write rarely), image cache, app settings, shared mutable state.

---

## Паттерн / Pattern

```swift
let queue = DispatchQueue(label: "com.app.cache", attributes: .concurrent)

// Чтение — параллельно / Read — concurrent
func read() -> T {
    queue.sync { storage }
}

// Запись — эксклюзивно / Write — exclusive
func write(_ value: T) {
    queue.async(flags: .barrier) { storage = value }
}
```

**Важно / Important:** Очередь должна быть **concurrent** (`attributes: .concurrent`). На serial queue barrier не имеет смысла.

---

## Дальше / Next

- `DispatchSource.timer` — таймеры без RunLoop / timers without RunLoop

---

## Задача / Task

Реализуй демо: **thread-safe счётчик**. Concurrent queue, хранение `count` внутри. Кнопка «Increment» — `async(flags: .barrier)` увеличивает на 1. Кнопка «Read» — `sync` читает и показывает значение. После 5 нажатий Increment — счётчик 5.

Implement demo: **thread-safe counter**. Concurrent queue, store `count` inside. Button «Increment» — `async(flags: .barrier)` adds 1. Button «Read» — `sync` reads and displays value. After 5 Increment taps — counter is 5.

---

## Проверка / Verification

Запусти `DispatchBarrierDemoUITests.testDispatchBarrierCounterIncrements` и `testDispatchBarrierReadShowsValue`.

Run `DispatchBarrierDemoUITests.testDispatchBarrierCounterIncrements` and `testDispatchBarrierReadShowsValue`.
