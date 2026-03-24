# async let — Теория / Theory

## Зачем нужен / Purpose

**`async let`** — объявление **дочерней async-подзадачи** с тем же синтаксисом, что и обычный `let`, но с `async`. Подзадачи, объявленные так, **запускаются параллельно** до первого `await`, который их «связывает». Удобно, когда число шагов **известно заранее** и не нужен динамический `TaskGroup`.

**`async let`** declares a **child async task** with the same syntax as `let`, but `async`. Such bindings **run in parallel** until an `await` that binds them. Handy when the number of steps is **fixed** and you don't need a dynamic `TaskGroup`.

---

## Синтаксис / Syntax

```swift
async let first = loadA()
async let second = loadB()
async let third = loadC()

let (a, b, c) = await (first, second, third)
```

- После `async let` выражение справа **начинает выполняться** (подзадача).
- Пока не дойдёшь до `await`, несколько `async let` **идут параллельно**.
- `await (first, second, third)` ждёт **все** результаты (как кортеж).

---

## Когда async let, когда TaskGroup / When async let vs TaskGroup

| async let | TaskGroup |
|-----------|-----------|
| Фиксированное число задач (2, 3, …) | Динамическое число (цикл по массиву) |
| Короткий, читаемый код | `addTask` + `for await` |
| Ошибки: общий `try await` при throwing API | `withThrowingTaskGroup` |

Если нужно добавить задачи в цикле по `items.count` — бери **TaskGroup**. Если три известных вызова — часто проще **`async let`**.

If you add tasks in a loop over dynamic data — use **TaskGroup**. For three known calls — **async let** is often simpler.

---

## Ошибки / Errors

Если функции `throws`, используй `try await`:

```swift
async let a = f()  // f throws
let (x, y) = try await (a, b)
```

---

## Ограничения / Limitations

- Имена `async let` живут в области видимости блока; нельзя «добавить ещё одну» динамически без TaskGroup.
- Порядок в `await (a, b, c)` не гарантирует порядок **завершения** — только ожидание всех.

---

## Дальше / Next

- `AsyncSequence` — поток значений с `for await`
- Отмена родительского `Task` — дочерние `async let` отменяются вместе с ним

---

## Задача / Task

Реализуй демо: **три параллельные загрузки через `async let`**.

**Сценарий:**
- Кнопка «Load All» (`asyncLet.loadAll`), статус (`asyncLet.status`), результат (`asyncLet.result`), прогресс (`ProgressView`).
- При нажатии: `Loading...`, сброс прогресса, пустой результат.
- Реализуй **три** `async let` для `LoadSimulators.taskGroupLoadResource(id:)` с `id` **0, 1, 2** (как в теме TaskGroup).
- Дождись всех значений одним `await` (удобно через кортеж: `await (r0, r1, r2)`).
- Затем: `progressView` = 1.0, `statusLabel` = `"Done"`, `resultLabel` = строка с тремя результатами (например через `joined(separator: ", ")`).
- Оберни в `Task { }` с `@MainActor` контроллером — обновление UI на main.

**Implement demo: three parallel loads with async let.**

---

## Проверка / Verification

Запусти `AsyncLetDemoUITests.testAsyncLetLoadsAllResources`.

Run `AsyncLetDemoUITests.testAsyncLetLoadsAllResources`.
