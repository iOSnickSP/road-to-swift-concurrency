# DispatchGroup — Теория / Theory

## Зачем нужен / Purpose

Когда нужно **дождаться завершения нескольких асинхронных задач** перед выполнением следующего шага. Например: загрузить 3 картинки параллельно, потом показать галерею.

When you need to **wait for multiple async tasks to complete** before the next step. E.g.: load 3 images in parallel, then show gallery.

---

## Основные методы / Main Methods

| Метод | Описание |
|-------|----------|
| `enter()` | Говорит группе: «ещё одна задача началась» / tells group: "one more task started" |
| `leave()` | Говорит группе: «одна задача завершилась» / tells group: "one task finished" |
| `notify(queue:execute:)` | Вызовется, когда счётчик enter/leave станет 0 / called when enter/leave counter reaches 0 |
| `wait()` | Блокирует поток до завершения всех задач (осторожно на main!) / blocks thread until all tasks complete (careful on main!) |

---

## Паттерн / Pattern

```swift
let group = DispatchGroup()

// Задача 1 / Task 1
group.enter()
DispatchQueue.global().async {
    defer { group.leave() }  // leave в любом случае (успех/ошибка) / always (success/error)
    // работа... / work...
}

// Задача 2 / Task 2
group.enter()
DispatchQueue.global().async {
    defer { group.leave() }
    // работа... / work...
}

// Когда все завершатся — обновить UI / When all complete — update UI
group.notify(queue: .main) {
    self.updateUI()
}
```

**Важно / Important:** количество `enter()` должно равняться количеству `leave()`. Иначе `notify` никогда не вызовется (если leave меньше) или вызовется раньше времени (если leave больше).

---

## defer { group.leave() }

`defer` гарантирует вызов `leave()` при любом выходе из блока (return, throw, конец). Без этого при ошибке или раннем return можно забыть вызвать leave — deadlock.

`defer` ensures `leave()` is called on any block exit (return, throw, end). Without it, an error or early return can skip leave — deadlock.

---

## Задача / Task

Реализуй демо: загрузка 3 «ресурсов» параллельно. Каждый симулирует задержку 1–2 сек. Используй `ProgressView` для отображения общего прогресса (1/3, 2/3, 3/3). Когда все загрузятся — покажи результат. Кнопка «Загрузить всё».

Implement demo: load 3 "resources" in parallel. Each simulates 1–2 sec delay. Use `ProgressView` for overall progress (1/3, 2/3, 3/3). When all complete — show result. Button "Load All".

---

## Проверка / Verification

Запусти `DispatchGroupDemoUITests.testDispatchGroupLoadsAllResources` — тест пройдёт только при корректной реализации.

Run `DispatchGroupDemoUITests.testDispatchGroupLoadsAllResources` — the test passes only when implemented correctly.
