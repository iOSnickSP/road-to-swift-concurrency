# `ContinuousClock` + `Duration` — Теория / Theory

## Зачем нужен / Purpose

**`Date`** и **`Calendar`** привязаны к **календарному** времени (часовые пояса, DST, синхронизация). Для **задержек**, **таймаутов**, **замеров интервалов** в async-коде лучше **монотонные часы** и **`Duration`**: они **не** «прыгают» при смене времени на устройстве.

**`Date`** and **`Calendar`** are tied to **civil** time (time zones, DST, clock sync). For **delays**, **timeouts**, and **interval measurement** in async code, prefer **monotonic clocks** and **`Duration`**: they **do not jump** when the system clock changes.

---

## API (кратко)

```swift
let clock = ContinuousClock()
let start = clock.now
try await Task.sleep(for: .milliseconds(200), clock: clock)
let elapsed = start.duration(to: clock.now) // Duration
```

- **`ContinuousClock`** — монотонный счётчик; **останавливается**, когда система приостанавливает процесс (в отличие от «сырого» тика CPU).
- **`SuspendingClock`** — похоже, но **не** считает время, пока процесс **приостановлен** (удобно для «времени с точки зрения пользователя»).
- **`Duration`** — длительность; складывай, умножай, сравнивай **без** `TimeInterval` там, где нужна модель Swift Concurrency.

---

## `Task.sleep` и часы / `Task.sleep` and clocks

```swift
try await Task.sleep(for: .seconds(1), clock: ContinuousClock())
```

Это **явная** связка «сколько ждать» + «по каким часам», вместо неявного сочетания наносекунд и глобального поведения.

---

## Важно / Important

- Не используй **`Date().addingTimeInterval`** как **единственный** способ «подождать в async» — для задержек в concurrency предпочтительнее **`Clock`** + **`Duration`**.
- Для **UI-дедлайнов** по календарю по-прежнему **`Date`**, для **интервалов между шагами** — **`ContinuousClock`**.

---

## Дальше / Next

- **AsyncStream** — построить `AsyncSequence` из колбэков / build `AsyncSequence` from callbacks
- Тема **`AsyncSequence`** в проекте — [`../AsyncSequence/THEORY.md`](../AsyncSequence/THEORY.md)

---

## Задача / Task

Реализуй демо: **`Task`** на **MainActor**, цикл **5** шагов; на каждом шаге **`try Task.checkCancellation()`**, затем **`try await Task.sleep(for: .milliseconds(200), clock: ContinuousClock())`** (или один общий экземпляр `ContinuousClock`); обновление **`continuousClock.progress`** в формате **`0 / 5` … `5 / 5`**.

После цикла вычисли **`Duration`** от **`clock.now`** в начале до **`clock.now`** в конце (через **`start.duration(to: clock.now)`**), выведи в **`continuousClock.result`** строку с **`Elapsed:`** и представлением длительности (например **`String(describing:)`** или **`formatted`**).

**UI:** `continuousClock.start`, `continuousClock.cancel`, `continuousClock.status`, `continuousClock.progress`, `continuousClock.result`.

**Поведение:**
- **Start:** отмени предыдущий `Task`; `status` = **`Running...`**, `progress` = **`0 / 5`**, `result` = **`—`**.
- После успеха: `status` = **`Completed`**, последний `progress` = **`5 / 5`**, `result` начинается с **`Elapsed:`**.
- **Cancel:** отмена `Task` → `status` = **`Cancelled`**, `result` = **`—`**.
- **`deinit` / Done:** отмена активной работы.

**Implement demo: `Task.sleep(for:clock:)` + elapsed `Duration`.**

---

## Проверка / Verification

Запусти `ContinuousClockDemoUITests`.

Run `ContinuousClockDemoUITests`.
