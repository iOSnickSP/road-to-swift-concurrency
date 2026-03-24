# `withTaskCancellationHandler` — Теория / Theory

## Зачем нужен / Purpose

**`withTaskCancellationHandler`** — способ выполнить **синхронный** блок **`onCancel`**, когда задачу отменили: закрыть дескриптор, вызвать `cancel()` у `URLSessionDataTask`, снять подписку. Это **не** замена `try Task.checkCancellation()` внутри цикла: основная работа по-прежнему должна уважать отмену; `onCancel` — для **быстрой** очистки ресурса.

**`withTaskCancellationHandler`** runs a **synchronous** **`onCancel`** when the task is cancelled: close a handle, cancel a `URLSessionDataTask`, unsubscribe. It does **not** replace `try Task.checkCancellation()` in loops; `onCancel` is for **quick** resource cleanup.

---

## API

```swift
func withTaskCancellationHandler<T>(
    operation: () async throws -> T,
    onCancel: @Sendable () -> Void
) async rethrows -> T
```

(В новых версиях Swift у функции может быть параметр изоляции `isolation` — суть та же.)

- **`operation`** — async-работа (цикл, сеть, и т.д.).
- **`onCancel`** — вызывается при отмене **до** или во время завершения `operation`; должен быть **коротким**, без тяжёлой работы и без `await`.

---

## Паттерн / Pattern

`onCancel` не привязан к MainActor. Чтобы обновить UI, **перепрыгни** на main:

```swift
await withTaskCancellationHandler {
    try await longWork()
} onCancel: {
    Task { @MainActor in
        cleanupLabel.text = "Cleanup: ran"
    }
}
// или DispatchQueue.main.async { … }
```

---

## Важно / Important

- Не блокируй `onCancel` и не делай там долгий sync-код.
- Если нужна только кооперативная остановка цикла — достаточно `checkCancellation` / отменяемого `sleep`; `withTaskCancellationHandler` — когда важен **явный** cleanup.

---

## Дальше / Next

- `Task.yield()` — уступить исполнение, дать другим задачам прогресс
- Отмена `URLSession` / закрытие файлов в реальном коде

---

## Задача / Task

Реализуй демо: **длинный цикл внутри `withTaskCancellationHandler`**, при отмене — **обновление лейбла cleanup через MainActor**.

**UI:** кнопки `withTaskCancellationHandler.start`, `withTaskCancellationHandler.cancel`, статус `withTaskCancellationHandler.status`, лейбл cleanup `withTaskCancellationHandler.cleanup`, прогресс `withTaskCancellationHandler.progress` (текст вида `3 / 10`).

**Поведение:**
- **Start:** отмени предыдущую задачу, если была; `status` = **«Running...»**, `progress` = **`0 / 10`**, `cleanup` = **`Cleanup: —`**.
- Запусти `Task`, внутри вызови **`await withTaskCancellationHandler(operation:onCancel:)`**:
  - **`operation`:** цикл **10** шагов; в начале каждой итерации `try Task.checkCancellation()`; между шагами `try await Task.sleep(nanoseconds: 250_000_000)`; обновляй прогресс на main.
  - **`onCancel`:** обнови `cleanup` на **`Cleanup: ran`** (через `Task { @MainActor in … }` или `DispatchQueue.main.async`).
- При **отмене** до конца цикла: после выхода из `withTaskCancellationHandler` обработай ошибку (`catch`) и выставь `status` = **`Cancelled`**.
- Если цикл завершился без отмены: `status` = **`Completed`**; `cleanup` остаётся **`Cleanup: —`** (onCancel не вызывался).
- **Cancel:** `workTask?.cancel()`.

**Implement demo: `withTaskCancellationHandler` + MainActor cleanup label.**

---

## Проверка / Verification

Запусти `WithTaskCancellationHandlerDemoUITests`.

Run `WithTaskCancellationHandlerDemoUITests`.
