# DispatchSource — Теория / Theory

## Зачем нужен / Purpose

**DispatchSource** — механизм GCD для обработки системных событий: таймеры, мониторинг файлов, сокеты, сигналы. В отличие от `Timer` — не привязан к RunLoop, работает на своей очереди.

**DispatchSource** — GCD mechanism for system events: timers, file monitoring, sockets, signals. Unlike `Timer` — not tied to RunLoop, runs on its own queue.

---

## Применение / Application

**Когда нужен:** периодические действия (таймер), мониторинг файлов/сокетов, сигналы. `Timer` привязан к RunLoop — при скролле или в фоне может не срабатывать. DispatchSource не зависит от RunLoop.

**When to use:** periodic actions (timer), file/socket monitoring, signals. `Timer` is tied to RunLoop — may not fire during scroll or in background. DispatchSource is RunLoop-independent.

**Типичные задачи:** секундомер, таймаут, polling, мониторинг изменений файла, обработка сокетов, idle-таймер.

**Typical tasks:** stopwatch, timeout, polling, file change monitoring, socket handling, idle timer.

---

## Паттерн: Timer / Timer pattern

```swift
let queue = DispatchQueue(label: "com.app.timer")
let timer = DispatchSource.makeTimerSource(queue: queue)

timer.schedule(deadline: .now(), repeating: 1.0)  // каждую секунду / every second
timer.setEventHandler { [weak self] in
    // срабатывает на queue / fires on queue
    DispatchQueue.main.async { /* update UI */ }
}
timer.setCancelHandler { /* cleanup */ }
timer.resume()

// Остановка / Stop
timer.cancel()
```

**Важно / Important:** После `makeTimerSource` нужно вызвать `resume()`. `cancel()` — одноразовый, после него source нельзя переиспользовать.

After `makeTimerSource` you must call `resume()`. `cancel()` is one-shot, source cannot be reused after.

---

## Задача / Task

Реализуй демо: **секундомер**. Кнопка «Start» — создаёт `DispatchSource.timer`, тикает каждую секунду, увеличивает счётчик. Кнопка «Stop» — отменяет таймер. Label показывает прошедшие секунды. При повторном Start — сброс и новый таймер.

Implement demo: **stopwatch**. Button «Start» — creates `DispatchSource.timer`, fires every second, increments counter. Button «Stop» — cancels timer. Label shows elapsed seconds. On Start again — reset and new timer.

---

## Проверка / Verification

Запусти `DispatchSourceDemoUITests.testDispatchSourceTimerCountsSeconds` и `testDispatchSourceStopResets`.

Run `DispatchSourceDemoUITests.testDispatchSourceTimerCountsSeconds` and `testDispatchSourceStopResets`.
