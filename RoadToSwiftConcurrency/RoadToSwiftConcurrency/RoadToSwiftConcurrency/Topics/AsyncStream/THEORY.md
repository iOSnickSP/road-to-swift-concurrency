# AsyncStream — Теория / Theory

## Зачем / Purpose

**`AsyncStream`** (и **`AsyncThrowingStream`**) — способ превратить **поток колбэков** (таймер, сокет, прогресс загрузки) в тип, по которому можно писать **`for await`**. Внутри фабрики получаешь **`continuation`**: **`yield`** для каждого значения, **`finish()`** когда событий больше не будет.

**`AsyncStream`** (and **`AsyncThrowingStream`**) turn a **callback stream** (timer, socket, download progress) into something you **`for await`** over. Inside the builder you get a **`continuation`**: **`yield`** per value, **`finish()`** when done.

---

## Минимальный паттерн / Minimal pattern

```swift
let stream = AsyncStream<Int> { continuation in
    legacyStart { value in
        continuation.yield(value)
    } onEnd: {
        continuation.finish()
    }
}

for await x in stream {
    print(x)
}
```

- После **`finish()`** новые **`yield`** игнорируются.
- Для отмены подписки смотри **`continuation.onTermination`** (вызов отмены легаси‑слоя).

---

## Связь с другими темами / Related topics

| Тема | Роль |
|------|------|
| [`AsyncSequence`](../AsyncSequence/THEORY.md) | Свой итератор, **`next()`** |
| **`AsyncStream`** | Готовая обёртка + **`continuation`** из коробки |
| [`CheckedContinuation`](../CheckedContinuation/THEORY.md) | **Один** результат |
| [`CheckedThrowingContinuation`](../CheckedThrowingContinuation/THEORY.md) | Один результат **или** ошибка |

---

## Дальше / Next

- **`AsyncThrowingStream`** — элементы + **`throw`** / elements + errors
- Повтори **`AsyncSequence`** — [`../AsyncSequence/THEORY.md`](../AsyncSequence/THEORY.md)

---

## Задача / Task

**1. Легаси**

Используй только **`LegacyChunkTicker.start`** из демо (не заменяй на голый цикл `for` без колбэков).

**2. Поток**

Реализуй **`makeStream() -> AsyncStream<Int>`**: в замыкании **`AsyncStream`** подключи колбэки — на каждый чанк **`continuation.yield`**, в **`onFinished`** — **`continuation.finish()`**.

**3. UI**

В **`startTapped`**: **`Task { @MainActor in … }`**, **`for await value in makeStream()`** — накапливай строки в **`asyncStream.result`** (до старта «—»), в конце **`asyncStream.status`** = «Done» (старт: «Running…»).

**Accessibility:** `asyncStream.start`, `asyncStream.status`, `asyncStream.result`.

**Implement: wrap legacy ticker in `AsyncStream` and consume with `for await`.**

---

## Проверка / Verification

Запусти `AsyncStreamDemoUITests`.

Run `AsyncStreamDemoUITests`.
