extends Node
## EventBus — global signal hub for cross-module events.
##
## Autoloaded as `EventBus`. Owned by Devin-1 (Engine / Core).
##
## Use this to fire events that span modules, e.g.:
##   EventBus.emit("artifact_picked_up", {"artifact_id": "skull", "by_player": 12345})
##   EventBus.connect_event("artifact_picked_up", _on_artifact_picked_up)
##
## Devin-5 (trigger programmer) registers one-shot listeners via this.

# event_name -> Array[Callable]
var _listeners: Dictionary = {}

func emit(event_name: String, payload: Dictionary = {}) -> void:
	if not _listeners.has(event_name):
		return
	var callables: Array = _listeners[event_name].duplicate()
	for cb in callables:
		if cb is Callable and cb.is_valid():
			cb.call(payload)

func connect_event(event_name: String, callable: Callable) -> void:
	if not _listeners.has(event_name):
		_listeners[event_name] = []
	_listeners[event_name].append(callable)

func disconnect_event(event_name: String, callable: Callable) -> void:
	if not _listeners.has(event_name):
		return
	_listeners[event_name].erase(callable)

func clear_event(event_name: String) -> void:
	_listeners.erase(event_name)

func clear_all() -> void:
	_listeners.clear()
