# `MainActor` — Теория / Theory

## Зачем нужен / Purpose

**`MainActor`** — **глобальный актор** в Swift Concurrency: вся работа с **UIKit** (и большей частью SwiftUI) должна выполняться на **главном потоке**. Типы и методы помечают **`@MainActor`**, чтобы компилятор не давал обращаться к UI из произвольного потока.

**`MainActor`** is a **global actor** in Swift Concurrency: **UIKit** (and most SwiftUI) work must run on the **main thread**. Types and methods are marked **`@MainActor`** so the compiler blocks UI access from arbitrary threads.

Из **фонового** `Task` (или `Task.detached`) обновляй UI через **`await MainActor.run { … }`**, **`await` на `@MainActor`-метод** или **`Task { @MainActor in … }`**. Если запускаешь несколько задач подряд, храни **идентификатор операции** и перед записью в UI проверяй, что результат ещё актуален.

From a **background** `Task` (or `Task.detached`), update the UI with **`await MainActor.run { … }`**, **`await` on an `@MainActor` method**, or **`Task { @MainActor in … }`**. If you can start overlapping work, keep an **operation id** and guard UI updates so stale tasks cannot overwrite newer state.

---

## API (кратко)

```swift
@MainActor
class MyViewController: UIViewController { }

await MainActor.run {
    label.text = "…"
}

Task { @MainActor in
    label.text = "…"
}
```

- **`DispatchQueue.main.async`** — по смыслу близко, но без интеграции с async/await и проверками изоляции.
- **`nonisolated`** / **`nonisolated(unsafe)`** — выход из изоляции (осторожно; в этой задаче не обязательно).

---

## Отличие от `actor` / Difference from `actor`

| `actor Counter` | `@MainActor` |
|-----------------|--------------|
| Свой изолятор | Один глобальный изолятор для UI |
| Произвольная логика | Главный поток, UIKit |

Тема **`Actor`** в проекте — [`../Actor/THEORY.md`](../Actor/THEORY.md) (отдельный тип `actor`).

---

## Важно / Important

- Не вызывай `MainActor.assumeIsolated` без уверенности, что ты уже на main — иначе краш в рантайме.
- Фоновая работа — `await` вне main; **один hop** на main для обновления лейблов.

---

## Дальше / Next

- Тема в проекте: **ContinuousClock** — [`../ContinuousClock/THEORY.md`](../ContinuousClock/THEORY.md) (`Duration`, монотонные часы, `Task.sleep(for:clock:)`)
- **AsyncStream** — мост из колбэков в async

---

## Задача / Task

Реализуй демо: **фоновая работа** в **`Task.detached`** (или эквивалент без привязки к `@MainActor` у тела `Task`), затем обновление UI **только** через **`await MainActor.run { … }`**.

**UI:** `mainActor.start`, `mainActor.cancel`, `mainActor.status`, `mainActor.result`.

**Поведение:**
- **Start:** отмени предыдущую задачу; `status` = **`Running...`**, `result` = **`—`**.
- Запусти **`Task.detached`** или **`Task(priority:)`** без `@MainActor` у всего тела (главное — сон **вне** main): один раз **`try await Task.sleep`** (например 1 с для UI-тестов), затем **`try Task.checkCancellation()`** перед UI.
- По желанию: **счётчик / id операции** на каждый Start: перед обновлением лейблов на main проверяй, что результат относится к **текущему** id (чтобы старая отменённая задача не перезаписала «Running…» нового запуска).
- После сна на **MainActor** выставь: `status` = **`Done`**, `result` = **`OK`**.
- **Cancel:** отмени сохранённый `Task` до завершения — `status` = **`Cancelled`**, `result` можно оставить **`—`** или **`Cancelled`** (согласуй с тестами).
- **`deinit` / Done:** отмена задачи.

**Implement demo: background `Task` + `MainActor.run` for UI.**

---

## Проверка / Verification

Запусти `MainActorDemoUITests`.

Run `MainActorDemoUITests`.
