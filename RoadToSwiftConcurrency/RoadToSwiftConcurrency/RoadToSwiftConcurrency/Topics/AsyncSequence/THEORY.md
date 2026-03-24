# AsyncSequence — Теория / Theory

## Зачем нужен / Purpose

**AsyncSequence** — протокол для **асинхронного потока значений**: элементы приходят по одному, между ними может быть ожидание (сеть, диск, таймер). В отличие от обычного `Sequence`, следующий элемент получают через `await`.

**AsyncSequence** — protocol for an **asynchronous stream of values**: elements arrive one at a time, with possible waiting between them (network, disk, timer). Unlike `Sequence`, the next element is obtained via `await`.

---

## AsyncIteratorProtocol

Итератор реализует `AsyncIteratorProtocol`:

```swift
mutating func next() async -> Element?
```

Пока возвращаешь не-`nil`, `for await` продолжает цикл. `nil` — конец последовательности.

While you return non-`nil`, `for await` continues. `nil` — end of sequence.

---

## AsyncSequence

Тип объявляет `associatedtype AsyncIterator` и:

```swift
func makeAsyncIterator() -> AsyncIterator
```

Компилятор разворачивает `for await x in sequence` в вызовы `next()` у итератора.

---

## Отличие от Sequence / Difference from Sequence

| Sequence | AsyncSequence |
|----------|----------------|
| `IteratorProtocol.next() -> Element?` | `next() async -> Element?` |
| Синхронно, сразу все шаги в теории | Между шагами — suspension points |
| `for x in` | `for await x in` |

---

## AsyncStream (кратко)

**AsyncStream** / **AsyncThrowingStream** — удобно, когда источник данных приходит из колбэков (например URLSession). В этой задаче ты реализуешь **свой** тип с `AsyncIteratorProtocol` вручную.

**AsyncStream** — handy when data comes from callbacks. In this task you implement **your own** type with `AsyncIteratorProtocol` manually.

---

## Дальше / Next

- `TaskCancellation` — тема в проекте: отмена длительного `Task` / in-repo topic: cancelling long-running `Task`
- `AsyncChannel` / очереди в распределённых системах (вне стандартной библиотеки Swift)
- Комбинаторы: `map`, `filter` для AsyncSequence (Swift Algorithms)

---

## Задача / Task

Реализуй демо: **последовательность из трёх шагов** и обход через `for await`.

**1. Итератор `StepsAsyncSequence.Iterator`**

В `next() async -> String?`:

- Верни **ровно три** строки: `"1"`, `"2"`, `"3"` (в таком порядке).
- Между шагами добавь небольшую задержку: `try? await Task.sleep(nanoseconds: …)` (например 200_000_000 — 0.2 с), чтобы было видно пошаговый прогресс.
- После третьего значения следующий вызов — `nil`.

**2. View controller**

В `startTapped` внутри `Task { }`:

- `for await step in StepsAsyncSequence()` — накапливай шаги в массив, обновляй `progressView` (прогресс = `количество / 3`).
- В конце: `statusLabel` = `"Done"`, `resultLabel` = объединённые шаги (например `joined(separator: ", ")`).

**Accessibility:** `asyncSequence.start`, `asyncSequence.status`, `asyncSequence.result`.

**Implement demo: three-step async sequence and for await loop.**

---

## Проверка / Verification

Запусти `AsyncSequenceDemoUITests.testAsyncSequenceCompletesWithSteps`.

Run `AsyncSequenceDemoUITests.testAsyncSequenceCompletesWithSteps`.
