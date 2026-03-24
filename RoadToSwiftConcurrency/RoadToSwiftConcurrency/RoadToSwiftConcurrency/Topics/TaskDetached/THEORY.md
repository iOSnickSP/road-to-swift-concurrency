# `Task.detached` — Теория / Theory

## Зачем нужен / Purpose

**`Task.detached`** создаёт задачу **вне иерархии** текущего `Task`: она **не** является дочерней по отношению к вызывающему контексту. Отмена родительского `Task` **не** распространяется на `detached` — её нужно отменять **отдельно**, держа ссылку на `Task`.

**`Task.detached`** creates a task **outside the hierarchy** of the current `Task`: it is **not** a child of the caller. Cancelling the parent `Task` does **not** cancel a `detached` task — you must cancel it **separately** by keeping a `Task` handle.

Используют для фоновой работы, которая должна жить своей жизнью (с осторожностью: проще отслеживать отмену и утечки).

Used for background work that should run independently (with care: track cancellation and lifetime).

---

## API

```swift
Task.detached(priority: TaskPriority? = nil, operation: @Sendable () async -> Success)
```

- Возвращает `Task<Success, Failure>` (или `Never` для failure в типичном UI-коде).
- Тело — `@Sendable`; захват только Sendable / осторожно с объектами.

---

## Отличие от `Task { }` / Difference from `Task { }`

| `Task { }` | `Task.detached` |
|------------|-----------------|
| Наследует приоритет / контекст от родителя (в т.ч. actor) | Отдельный корень планирования |
| Дочерние задачи отменяются с родителем (structured) | **Не** отменяется вместе с родителем |

---

## Важно / Important

- UI обновляй с **MainActor** (`await MainActor.run`, `Task { @MainActor in }`).
- Явно храни `Task` и вызывай `cancel()` при уходе с экрана, если нужно остановить detached.

---

## Дальше / Next

- Тема в проекте: **`TaskPriority`** — [`../TaskPriority/THEORY.md`](../TaskPriority/THEORY.md) — явный приоритет у `Task` / `Task.detached`
- `TaskGroup` — структурированный параллелизм с отменой «пачкой» (тема в проекте: [`../TaskGroup/THEORY.md`](../TaskGroup/THEORY.md))

---

## Задача / Task

Реализуй демо: **параллельно** запускаются **родительский** `Task { @MainActor … }` и **`Task.detached`** с циклом. Покажи, что **отмена родителя** не останавливает detached.

**UI:**
- `taskDetached.start`
- `taskDetached.cancelParent` — только `parentTask?.cancel()`
- `taskDetached.cancelDetached` — только `detachedTask?.cancel()`
- `taskDetached.parentStatus` — строки вида **`Parent: 3/5`**, в конце **`Parent: Completed`** или **`Parent: Cancelled`**
- `taskDetached.detachedProgress` — **`Detached: 0/8`** … **`Detached: 8/8`**, в конце **`Detached: Done`** или **`Detached: Cancelled`**

**Поведение:**
- **Start:** отмени обе предыдущие задачи; **`Parent: Running`**, **`Detached: 0/8`** перед циклами (как в эталонном демо).
- Запусти **`Task.detached`** с циклом **8** шагов: `checkCancellation`, короткий `sleep` (например **100 ms**), обновление прогресса на **MainActor**; в конце без отмены — **`Detached: Done`**.
- Запусти **`parentTask`** (`Task { @MainActor … }`) с циклом **5** шагов и sleep (**~120 ms**); в конце — **`Parent: Completed`**.
- **Cancel parent:** отмени только родителя — detached **продолжает** (пока не завершится или пока не нажмут Cancel detached).
- **Cancel detached:** отмени только detached — **`Detached: Cancelled`**.
- **`deinit` / Done:** отмени обе задачи.

**Строки для UI-тестов (зафиксируй в коде):**
- Успех родителя: **`Parent: Completed`**
- Отмена родителя: **`Parent: Cancelled`**
- Успех detached: финиш **`Detached: Done`**
- Отмена detached: **`Detached: Cancelled`**
- Промежуточный прогресс родителя: **`Parent: n/5`** (`n` от 1 до 5)
- Промежуточный прогресс detached: **`Detached: n/8`**

**Implement demo: `Task.detached` vs parent cancellation.**

---

## Проверка / Verification

Запусти `TaskDetachedDemoUITests`.

Run `TaskDetachedDemoUITests`.
