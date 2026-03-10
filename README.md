# Road to Swift Concurrency

Глубокое изучение многопоточности в Swift. От GCD до современного async/await.

A deep dive into Swift concurrency. From GCD to modern async/await.

---

## О проекте / About

Это образовательный проект для **систематического изучения многопоточности** в Swift и iOS. Каждая тема — отдельная задача с теорией и кодом-заготовкой. Решай сам, затем сравни с эталонным решением в отдельной ветке.

This is an educational project for **systematic learning of concurrency** in Swift and iOS. Each topic is a standalone task with theory and starter code. Solve it yourself, then compare with the reference solution in a separate branch.

---

## Структура репозитория / Repository Structure

### Ветка `main`

Содержит **задачи и теорию** — то, с чем ты работаешь:
- `Topics/<Topic>/THEORY.md` — теория на русском и английском
- `Topics/<Topic>/Demo/` — код с пропусками (`// TODO`), который нужно дописать

The **tasks and theory** — what you work with:
- `Topics/<Topic>/THEORY.md` — theory in Russian and English
- `Topics/<Topic>/Demo/` — code with gaps (`// TODO`) to complete

### Ветки с решениями / Solution branches

От каждого коммита в `main` отходит ветка с **эталонным решением** задачи. Эти ветки **не мержатся в main** — они существуют только для просмотра.

From each `main` commit there is a branch with the **reference solution**. These branches are **not merged into main** — they exist for viewing only.

| Тема / Topic | Ветка с решением / Solution branch |
|--------------|-------------------------------------|
| GCD | `solution/gcd` |
| DispatchGroup | `solution/dispatch-group` |
| DispatchSemaphore | `solution/dispatch-semaphore` |
| DispatchWorkItem | `solution/dispatch-work-item` |
| DispatchBarrier | `solution/dispatch-barrier` |
| DispatchSource | `solution/dispatch-source` |
| OperationQueue | `solution/operation-queue` |

**Как использовать:** реши задачу сам → застрял или хочешь сверить подход → переключись на ветку решения.

**How to use:** solve the task yourself → stuck or want to compare approaches → switch to the solution branch.

---

## Темы / Topics

- **GCD** — очереди, async/sync, паттерн «фон → main» / queues, async/sync, background → main pattern
- **DispatchGroup** — ожидание завершения нескольких задач / waiting for multiple tasks to complete
- **DispatchSemaphore** — ограничение параллелизма / limiting concurrency (5 задач, max 2 одновременно)
- **DispatchWorkItem** — отмена задач / task cancellation (3 ресурса последовательно, Cancel)
- **DispatchBarrier** — thread-safe read/write на concurrent queue / barrier for exclusive writes
- **DispatchSource** — таймеры, события системы / timers, system events (секундомер / stopwatch)
- **OperationQueue** — зависимости между операциями / operation dependencies (A → B → C)

---

## Запуск / Run

```bash
git clone <repo-url>
cd road-to-swift-concurrency
```

Открой `RoadToSwiftConcurrency/RoadToSwiftConcurrency/RoadToSwiftConcurrency.xcodeproj` в Xcode, собери и запусти на симуляторе.

Open `RoadToSwiftConcurrency/RoadToSwiftConcurrency/RoadToSwiftConcurrency.xcodeproj` in Xcode, build and run on simulator.

---

## Проверка решения / Verifying Your Solution

Запусти unit и UI тесты. Они проходят только при корректном выполнении задачи.

Run unit and UI tests. They pass only when the task is completed correctly.

```bash
xcodebuild test -scheme RoadToSwiftConcurrency -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Требования / Requirements

- Xcode 15+
- iOS 15+
