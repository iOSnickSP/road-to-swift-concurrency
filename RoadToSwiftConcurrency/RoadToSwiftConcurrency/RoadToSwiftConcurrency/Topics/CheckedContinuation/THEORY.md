# CheckedContinuation — Теория / Theory

## Зачем нужен / Purpose

Не весь код уже **`async`**: библиотеки, SDK и старый код часто отдают результат через **`completion:`**, делегаты или GCD. **`withCheckedContinuation`** / **`withCheckedThrowingContinuation`** позволяют **один раз** «поднять» колбэк в мир `async`/`await` и писать линейный код сверху.

Not everything is **`async`**: libraries and legacy code often use **`completion:`** handlers. **`withCheckedContinuation`** / **`withCheckedThrowingContinuation`** let you **resume once** and bridge callbacks into **`async`/`await`**.

---

## API (кратко)

```swift
func legacyLoad(completion: @escaping (String) -> Void) { ... }

func load() async -> String {
    await withCheckedContinuation { continuation in
        legacyLoad { value in
            continuation.resume(returning: value)
        }
    }
}
```

- Вызов **`resume`** (или **`resume(throwing:)`** в throwing-варианте) должен произойти **ровно один раз** на каждый `withChecked…`. Иначе — UB / runtime trap в checked-режиме.
- **`withUnsafeContinuation`** — без проверок дисциплины; для учебы и отладки предпочтительнее **checked**.

---

## Отмена / Cancellation

Сам continuation **не** отменяется вместе с `Task` автоматически: если колбэк всё ещё может прийти, нужен **кооперативный** дизайн (флаг, `Task.isCancelled`, отмена подписки). В простом демо колбэк срабатывает один раз — достаточно не вызывать `resume` дважды.

---

## Связь с AsyncStream / Relation to AsyncStream

**AsyncStream** с `continuation` в замыкании — родственная идея: туда «кормят» события из колбэков. Здесь — **один** результат; у **AsyncStream** — **много** значений.

---

## Дальше / Next

- **`CheckedThrowingContinuation`** — колбэк с **`Result`/`Error`** → **`async throws`** — [`../CheckedThrowingContinuation/THEORY.md`](../CheckedThrowingContinuation/THEORY.md)
- **`AsyncStream`** / **`AsyncThrowingStream`** — поток событий из колбэков / streams of events from callbacks
- Тема **`AsyncSequence`** в проекте — [`../AsyncSequence/THEORY.md`](../AsyncSequence/THEORY.md)

---

## Задача / Task

**1. Легаси‑слой**

В демо уже есть `LegacyCallbackLoader.loadText(delay:completion:)` — вызывай его **только** из твоего моста (не подменяй на прямой `await SimulatedNetworkService` в обход continuation).

**2. Мост**

Реализуй **`fetchBridged() async -> String`**: внутри **`withCheckedContinuation`**, в колбэке — **`continuation.resume(returning:)`** с строкой от легаси‑загрузки.

**3. UI**

В **`fetchTapped`**: **`Task { @MainActor in … }`** — `status` = «Running…», затем `await fetchBridged()`, вывести строку в **`checkedContinuation.result`**, **`checkedContinuation.status`** = «Done».

**Accessibility:** `checkedContinuation.fetch`, `checkedContinuation.status`, `checkedContinuation.result`.

**Implement: bridge callback API to async using `withCheckedContinuation`.**

---

## Проверка / Verification

Запусти `CheckedContinuationDemoUITests`.

Run `CheckedContinuationDemoUITests`.
