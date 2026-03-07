# GCD (Grand Central Dispatch) — Теория / Theory

## Введение / Introduction

GCD — низкоуровневый API Apple для многопоточности. Основан на очередях (queues) и блоках кода (closures). Работает на всех платформах Apple.

GCD is Apple's low-level API for concurrency. Based on queues and closures. Works on all Apple platforms.

---

## Очереди (Queues)

### Main Queue
- **Единственная очередь на главном потоке** — все операции с UI должны выполняться здесь
- **The only queue on the main thread** — all UI operations must run here
- Serial (последовательная)
- Доступ / Access: `DispatchQueue.main`

### Global Queues
- Системные фоновые очереди с разными приоритетами QoS
- System background queues with different QoS priorities
- Concurrent (параллельные)
- Доступ / Access: `DispatchQueue.global(qos: .userInitiated)` и т.д.

**QoS (Quality of Service):**
- `.userInteractive` — анимации, UI feedback / animations, UI feedback
- `.userInitiated` — действия пользователя, ожидающие результат / user actions expecting result
- `.utility` — загрузки, прогресс / downloads, progress
- `.background` — задачи, не требующие немедленного результата / tasks not needing immediate result

### Custom Queues
- Создаёшь сам / Create your own: `DispatchQueue(label: "com.app.myqueue")`
- По умолчанию serial — добавь `attributes: .concurrent` для параллельной
- Default is serial — add `attributes: .concurrent` for parallel

---

## Синхронный vs Асинхронный dispatch

| Метод | Поведение | Блокирует вызывающий поток? |
|-------|-----------|-----------------------------|
| `async` | Запускает задачу и сразу возвращает управление | Нет |
| `sync` | Ждёт завершения задачи, потом возвращает | Да |

**Важно / Important:** `sync` на main queue из main thread = deadlock. Никогда не делай `DispatchQueue.main.sync { }` из main thread.

---

## Serial vs Concurrent

- **Serial**: задачи выполняются одна за другой / tasks run one after another
- **Concurrent**: задачи могут выполняться параллельно / tasks can run in parallel

---

## Паттерн для UI / UI Pattern

```swift
// Тяжёлая работа — в фоне / Heavy work — in background
DispatchQueue.global(qos: .userInitiated).async {
    let data = self.loadData()  // долгая операция / long operation
    
    // Обновление UI — только на main / UI update — main only
    DispatchQueue.main.async {
        self.updateUI(with: data)
    }
}
```

---

## Дальше (для следующих тем) / Next Topics

- `DispatchGroup` — ожидание завершения нескольких задач / waiting for multiple tasks
- `DispatchWorkItem` — отмена задач / task cancellation
- `DispatchQueue.async(flags: .barrier)` — барьеры для thread-safe записи / barriers for thread-safe writes
- `DispatchSemaphore` — ограничение параллелизма / limiting concurrency

---

## Swift Concurrency (контекст)

С Swift 5.5 появились `async/await`, `Task`, `Actor` — современная замена GCD для многих сценариев. Но GCD всё ещё актуален для низкоуровневого контроля и legacy кода.

Swift 5.5 introduced `async/await`, `Task`, `Actor` — modern replacement for GCD in many scenarios. GCD is still relevant for low-level control and legacy code.

---

## Проверка / Verification

Запусти `GCDDemoUITests.testGCDLoadUpdatesResult` — тест пройдёт только при корректной реализации.

Run `GCDDemoUITests.testGCDLoadUpdatesResult` — the test passes only when implemented correctly.
