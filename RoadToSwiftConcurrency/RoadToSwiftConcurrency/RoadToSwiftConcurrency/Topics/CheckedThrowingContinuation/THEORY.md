# CheckedThrowingContinuation — Теория / Theory

## Зачем / Purpose

Колбэк часто приходит как **`Result<Value, Error>`**, две ветки **`(value, error)`**, или **`completion: (Error?) -> Void`**. После **`withCheckedContinuation`** следующий шаг — **`withCheckedThrowingContinuation`**: один **`resume(returning:)`** при успехе или **`resume(throwing:)`** при ошибке (ровно один раз).

Callbacks often deliver **`Result`** or success/failure pairs. After **`withCheckedContinuation`**, **`withCheckedThrowingContinuation`** maps that to **`async throws`** with **`resume(returning:)`** or **`resume(throwing:)`** (exactly once).

---

## API (кратко)

```swift
func legacyLoad(completion: @escaping (Result<String, Error>) -> Void) { ... }

func load() async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
        legacyLoad { result in
            switch result {
            case .success(let value):
                continuation.resume(returning: value)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}
```

- Тип continuation — **`CheckedContinuation<T, any Error>`**; компилятор связывает `throws` с **`Failure`**.
- Смешивать **`resume(returning:)`** и **`resume(throwing:)`** в одном вызове нельзя; на один `withChecked…` — ровно один `resume*`.

---

## Связь с обычным CheckedContinuation

Сначала освой **`withCheckedContinuation`** (без `throws`), затем тот же паттерн с ветвлением по ошибке — см. [`../CheckedContinuation/THEORY.md`](../CheckedContinuation/THEORY.md).

---

## Дальше / Next

- **`AsyncThrowingStream`** — много значений + ошибки / many values + errors
- Тема **`AsyncSequence`** в проекте — [`../AsyncSequence/THEORY.md`](../AsyncSequence/THEORY.md)

---

## Задача / Task

**1. Легаси‑слой**

В демо есть `LegacyResultLoader.loadText(shouldFail:delay:completion:)` — вызывай его **только** из моста (не подменяй на прямой `await SimulatedNetworkService`).

**2. Мост**

Реализуй **`fetchBridged(shouldFail:) async throws -> String`**: **`withCheckedThrowingContinuation`**, в колбэке по **`Result`** — либо **`resume(returning:)`**, либо **`resume(throwing:)`**.

**3. UI**

В **`fetchTapped`**: **`Task { @MainActor in … }`** — `status` = «Running…», затем `try await fetchBridged(shouldFail: failSwitch.isOn)`; при успехе — строка в **`checkedThrowingContinuation.result`**, `status` = «Done»; при ошибке — текст ошибки в **`result`**, `status` = «Failed».

**Accessibility:** `checkedThrowingContinuation.fetch`, `checkedThrowingContinuation.failSwitch`, `checkedThrowingContinuation.status`, `checkedThrowingContinuation.result`.

**Implement: bridge `Result`-style callback to `async throws` via `withCheckedThrowingContinuation`.**

---

## Проверка / Verification

Запусти `CheckedThrowingContinuationDemoUITests`.

Run `CheckedThrowingContinuationDemoUITests`.
