# `Task.yield()` — Теория / Theory

## Зачем нужен / Purpose

**`await Task.yield()`** — явная **точка уступки планировщику**: текущая задача приостанавливается, рантайм может выполнить другую работу (другие `Task`, обработка событий и т.д.). Это **не** задержка по времени и **не** отмена — только кооперативная передача хода.

**`await Task.yield()`** is an explicit **scheduler yield**: the current task suspends so the runtime can run other work (other `Task`s, event processing, etc.). It is **not** a time delay and **not** cancellation — only cooperative handoff.

Полезно в **плотных циклах** без `await`, чтобы не монополизировать исполнитель дольше необходимого, и чтобы чаще проверять отмену / реагировать на окружение.

Useful in **tight loops** without `await` so you do not monopolize the executor, and to interleave with cancellation checks.

---

## API

```swift
await Task.yield()
```

Доступно в `async` контексте. После `yield` задача снова ставится в очередь готовых к выполнению.

Available in `async` context. After `yield`, the task is re-queued as ready to run.

---

## Отличие от `Task.sleep` / Difference from `Task.sleep`

| | `Task.yield()` | `Task.sleep` |
|---|----------------|--------------|
| Назначение | Уступить ход без ожидания «времени» | Ждать интервал |
| Длительность | Не гарантирует паузу в миллисекундах | Задаётся явно |

На практике в UI-демо иногда добавляют **короткий `sleep`** после `yield`, чтобы успевали обновляться лейблы и был зазор для **Cancel**.

In UI demos a **short `sleep`** after `yield` is sometimes added so labels update and **Cancel** has a window.

---

## Важно / Important

- `yield` не заменяет `checkCancellation` — для отмены по-прежнему нужны проверки / отменяемые `await`.
- Слишком мелкий цикл без ни `suspend`, ни `yield` — риск долго не отдавать управление.

---

## Дальше / Next

- Тема в проекте: **`TaskDetached`** — [`../TaskDetached/THEORY.md`](../TaskDetached/THEORY.md) — `Task.detached`, отмена не наследуется от родителя
- `TaskPriority` / приоритеты задач

---

## Задача / Task

Реализуй демо: **цикл с `await Task.yield()`** и кооперативной отменой.

**UI:** `taskYield.start`, `taskYield.cancel`, `taskYield.status`, `taskYield.progress` (текст вида `4 / 12`).

**Поведение:**
- **Start:** отмени предыдущую задачу; `status` = **«Running...»**, прогресс **`0 / 12`**.
- В `Task { @MainActor … }` (или с hop на main) цикл **12** итераций:
  - в начале **`try Task.checkCancellation()`**;
  - затем **`await Task.yield()`**;
  - затем **`try await Task.sleep(nanoseconds: 100_000_000)`** (0.1 с) — чтобы UI и тесты успевали;
  - обнови прогресс **`step / 12`**.
- Успех: **`Completed`**.
- Отмена: **`Cancelled`**.
- **Cancel:** `workTask?.cancel()`.

**Implement demo: loop with `Task.yield()` + cancellation.**

---

## Проверка / Verification

Запусти `TaskYieldDemoUITests`.

Run `TaskYieldDemoUITests`.
