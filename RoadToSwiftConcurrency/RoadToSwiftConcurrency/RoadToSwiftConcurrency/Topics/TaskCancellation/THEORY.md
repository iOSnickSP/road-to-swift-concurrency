# Task — отмена / Task cancellation

## Зачем нужен / Purpose

**Отмена Task** — способ остановить длительную async-работу, когда она больше не нужна (пользователь закрыл экран, нажал Cancel, сменил фильтр). Отмена **кооперативная**: рантайм только помечает задачу; код должен **периодически проверять** отмену и выходить.

**Task cancellation** stops long async work when it's no longer needed. Cancellation is **cooperative**: the runtime only marks the task; your code must **check** cancellation and exit.

---

## API

| Способ | Когда |
|--------|--------|
| `task.cancel()` | Снаружи — запросить отмену |
| `Task.isCancelled` | Быстрая проверка `Bool` |
| `try Task.checkCancellation()` | В `async` контексте; бросает `CancellationError`, если отменено |
| `try? await Task.sleep(...)` | При отмене sleep может завершиться с отменой (зависит от версии; для явности после sleep проверяй `checkCancellation`) |

После `cancel()` дочерние `Task` и `async let`, привязанные к родителю, тоже получают отмену.

After `cancel()`, child tasks and `async let` tied to the parent are cancelled too.

---

## Паттерн / Pattern

```swift
var work: Task<Void, Never>?

func start() {
    work?.cancel()
    work = Task {
        for i in 1...10 {
            try Task.checkCancellation()
            try? await Task.sleep(nanoseconds: 100_000_000)
            await MainActor.run { updateUI(i) }
        }
        await MainActor.run { finish() }
    }
}

func cancel() {
    work?.cancel()
}
```

Обработка отмены: `catch` для `CancellationError` или проверка `Task.isCancelled` после `try?`.

Handle cancellation: `catch CancellationError` or check `Task.isCancelled` after `try?`.

---

## Важно / Important

- Синхронный код внутри Task **не** прерывается сам — нужны точки с `await` или явные проверки.
- Не игнорируй отмену и не делай тяжёлую работу после `cancel()` без проверок.

---

## Дальше / Next

- Тема в проекте: **`WithTaskCancellationHandler`** — [`../WithTaskCancellationHandler/THEORY.md`](../WithTaskCancellationHandler/THEORY.md) — `withTaskCancellationHandler`, cleanup в `onCancel` (закрыть файл, отменить URLSession task)
- `Task.yield()` — уступить поток

---

## Задача / Task

Реализуй демо: **длинный цикл с возможностью отмены**.

**UI:** кнопки `taskCancellation.start`, `taskCancellation.cancel`, статус `taskCancellation.status`, прогресс `taskCancellation.progress` (текст вида `3 / 10`).

**Поведение:**
- **Start:** отмени предыдущую задачу, если была; запусти новый `Task`, в котором цикл **10** шагов, между шагами `try? await Task.sleep(nanoseconds: 250_000_000)` (0.25 с).
- В начале каждой итерации вызови **`try Task.checkCancellation()`** (оберни тело Task в `do/catch` и при `CancellationError` выставь статус **«Cancelled»** и выйди; на MainActor обнови лейблы).
- Обновляй прогресс: `current / 10` на main.
- Если цикл дошёл до конца без отмены — статус **«Completed»**.
- **Cancel:** вызови `task?.cancel()` на сохранённой ссылке.

**Implement demo: cancellable loop with Task.checkCancellation.**

---

## Проверка / Verification

Запусти `TaskCancellationDemoUITests`.

Run `TaskCancellationDemoUITests`.
