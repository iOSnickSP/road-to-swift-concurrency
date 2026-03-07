# DispatchWorkItem — Теория / Theory

## Зачем нужен / Purpose

Когда нужно **отменить задачу до её выполнения**. `DispatchWorkItem` можно отменить — тогда блок не выполнится. Уже запущенная задача не остановится (отмена не прерывает выполняющийся код).

When you need to **cancel a task before it runs**. `DispatchWorkItem` can be cancelled — then the block won't execute. Already-running work won't stop (cancel doesn't interrupt executing code).

---

## Основные методы / Main Methods

| Метод/свойство | Описание |
|----------------|----------|
| `cancel()` | Отменяет work item. Не влияет на уже выполняющийся / cancels work item. No effect on already-running |
| `isCancelled` | `true` если отменён / true if cancelled |
| `DispatchQueue.async(execute: workItem)` | Запускает work item на очереди / runs work item on queue |

---

## Паттерн / Pattern

```swift
var workItem: DispatchWorkItem!
workItem = DispatchWorkItem {
    guard !workItem.isCancelled else { return }
    // работа... / work...
}

queue.async(execute: workItem)

// Позже / Later:
workItem.cancel()
```

**Важно / Important:** Отмена действует только на задачи, которые ещё не начали выполняться. Serial queue гарантирует порядок — отмена следующих в очереди сработает.

Cancel only affects tasks that haven't started. Serial queue guarantees order — cancelling queued items works.

---

## Комбинация с DispatchGroup

При отмене work item'ов, которые ещё не запустились, нужно вручную вызвать `group.leave()` для каждого отменённого — иначе `notify` никогда не сработает.

When cancelling work items that haven't started, manually call `group.leave()` for each cancelled one — otherwise `notify` never fires.

---

## Задача / Task

Реализуй демо: загрузка **3 ресурсов последовательно** (serial queue). Кнопки Load и Cancel. При Load — запуск 3 work item'ов. При Cancel — отмена оставшихся, `leave()` для отменённых. ProgressView, статус, результат. В конце — "Done" или "Cancelled".

Implement demo: load **3 resources sequentially** (serial queue). Load and Cancel buttons. On Load — start 3 work items. On Cancel — cancel remaining, `leave()` for cancelled. ProgressView, status, result. Finally — "Done" or "Cancelled".

Используй `LoadSimulators.dispatchGroupLoadResource(id:)` для id 0, 1, 2.

---

## Проверка / Verification

Запусти `DispatchWorkItemDemoUITests.testDispatchWorkItemLoadsAllResources` и `testDispatchWorkItemCancelStopsRemaining`.

Run `DispatchWorkItemDemoUITests.testDispatchWorkItemLoadsAllResources` and `testDispatchWorkItemCancelStopsRemaining`.
