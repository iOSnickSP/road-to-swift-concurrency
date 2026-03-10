# async/await — Введение / Introduction

## Что это / What is it

**async/await** — способ писать асинхронный код **линейно**, без колбэков и вложенных замыканий. Появился в Swift 5.5 (2021).

**async/await** — a way to write async code **linearly**, without callbacks and nested closures. Introduced in Swift 5.5 (2021).

---

## Сравнение с GCD / Comparison with GCD

**GCD (как мы делали):**
```swift
DispatchQueue.global().async {
    let data = loadData()  // фон / background
    DispatchQueue.main.async {
        self.label.text = data  // main для UI / main for UI
    }
}
```
Два замыкания, нужно помнить про main для UI.

**async/await:**
```swift
Task {
    let data = await loadData()
    label.text = data  // уже на main, если Task создан из UI / already on main if Task from UI
}
```
Один блок, код читается сверху вниз.

---

## Ключевые понятия / Key Concepts

### async
Функция помечена `async` — она может **приостанавливаться** (в точках `await`). Не блокирует поток: пока ждём, система может делать другое.

A function marked `async` — it can **suspend** (at `await` points). Doesn't block the thread: while waiting, the system can do other work.

### await
`await` — точка приостановки. «Подожди результат, потом продолжай». Поток не блокируется — он освобождается.

`await` — suspension point. "Wait for result, then continue". Thread is not blocked — it's released.

### Task
`Task { }` — создаёт асинхронный контекст. Вызываешь из обычного (sync) кода, например из обработчика кнопки. Внутри Task можно использовать `await`.

`Task { }` — creates async context. Call from regular (sync) code, e.g. button handler. Inside Task you can use `await`.

---

## MainActor и UI / MainActor and UI

`UIViewController` по умолчанию на **MainActor** — все его методы выполняются на main thread. Когда создаёшь `Task` из кнопки (на main), код внутри Task **до первого await** — на main. После `await` выполнение **продолжается на main** (компилятор это обеспечивает для MainActor).

`UIViewController` is on **MainActor** by default — its methods run on main thread. When you create `Task` from a button (on main), code inside Task **before first await** — on main. After `await` execution **resumes on main** (compiler ensures this for MainActor).

Поэтому можно писать `label.text = data` после await — мы на main.

---

## Паттерн: загрузка / Pattern: loading

```swift
// async функция — можно вызывать только с await
func loadData() async -> String {
    try? await Task.sleep(nanoseconds: 2_000_000_000)  // 2 сек
    return "Loaded"
}

// В UIViewController (MainActor)
@objc func loadTapped() {
    Task {
        let result = await loadData()
        resultLabel.text = result  // UI update — мы на main
    }
}
```

**Важно:** `Task.sleep` — async-версия задержки. Не блокирует поток. `2_000_000_000` наносекунд = 2 секунды.

---

## Применение / Application

**Когда нужен:** любой асинхронный код — сеть, файлы, БД. Замена GCD. Меньше вложенности, проще ошибки (`throws`), отмена через `Task.cancel()`.

**When to use:** any async code — network, files, DB. GCD replacement. Less nesting, easier errors (`throws`), cancellation via `Task.cancel()`.

---

## Дальше / Next

- `Task` — отмена, приоритеты / cancellation, priorities
- `Actor` — изоляция состояния / state isolation

---

## Задача / Task

Реализуй демо: **загрузка данных** через async/await. Добавь `private func loadData() async -> String { await LoadSimulators.asyncSimulateLoad(delay: 2) }`. Кнопка «Load» — внутри `Task { let result = await loadData(); update UI }`. Покажи индикатор загрузки и результат.

Implement demo: **data loading** via async/await. Add `private func loadData() async -> String { await LoadSimulators.asyncSimulateLoad(delay: 2) }`. Button «Load» — inside `Task { let result = await loadData(); update UI }`. Show loading indicator and result.

---

## Проверка / Verification

Запусти `AsyncAwaitDemoUITests.testAsyncAwaitLoadUpdatesResult`.

Run `AsyncAwaitDemoUITests.testAsyncAwaitLoadUpdatesResult`.
