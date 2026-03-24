# TaskGroup — Теория / Theory

## Зачем нужен / Purpose

**TaskGroup** — структурированная параллельность в Swift Concurrency. Запускаешь несколько async-задач параллельно, ждёшь результаты. Аналог `DispatchGroup`, но на async/await. Появился в Swift 5.5.

**TaskGroup** — structured concurrency. Run multiple async tasks in parallel, await results. Analog of `DispatchGroup` for async/await. Introduced in Swift 5.5.

---

## Паттерн / Pattern

```swift
let results = await withTaskGroup(of: String.self) { group in
    for id in 1...3 {
        group.addTask {
            await loadResource(id: id)
        }
    }
    var collected: [String] = []
    for await result in group {
        collected.append(result)
    }
    return collected
}
```

- `withTaskGroup(of: ResultType.self)` — создаёт группу, тело — async closure
- `group.addTask { ... }` — добавляет дочернюю задачу (выполняется параллельно)
- `for await result in group` — итерация по результатам по мере готовности
- Группа автоматически ждёт завершения всех задач при выходе из `withTaskGroup`

---

## ThrowingTaskGroup

Если задачи могут кидать ошибки — `withThrowingTaskGroup`. Ошибка из любой дочерней задачи пробросится наружу.

If tasks can throw — `withThrowingTaskGroup`. Error from any child propagates out.

```swift
let results = try await withThrowingTaskGroup(of: String.self) { group in
    // ...
}
```

---

## Сравнение с DispatchGroup / Comparison

| DispatchGroup | TaskGroup |
|---------------|-----------|
| enter/leave вручную | addTask — автоматически |
| notify на queue | await — structured |
| GCD, блоки | async/await, suspension |

---

## Дальше / Next

- `async let` — тема в проекте: три параллельные загрузки без TaskGroup / in-repo topic: three parallel loads without TaskGroup
- `AsyncSequence` — асинхронная итерация по потоку данных

---

## Задача / Task

Реализуй демо: **параллельная загрузка 3 ресурсов через TaskGroup**.

**Сценарий:**
- Кнопка «Load All» — запускает загрузку 3 ресурсов параллельно
- Используй `withTaskGroup(of: String.self)` и `group.addTask { await LoadSimulators.taskGroupLoadResource(id: id) }`
- Собери результаты через `for await result in group`
- `ProgressView` — обновляй прогресс на main (1/3, 2/3, 3/3) по мере получения результатов
- Когда все готовы — `statusLabel.text = "Done"`, `resultLabel.text` — объединённый результат
- Вызов `LoadSimulators.taskGroupLoadResource(id:)` — async, симулирует задержку

**Implement demo: load 3 resources in parallel via TaskGroup.**

---

## Проверка / Verification

Запусти `TaskGroupDemoUITests.testTaskGroupLoadsAllResources`.

Run `TaskGroupDemoUITests.testTaskGroupLoadsAllResources`.
