extends Node
## Net — multiplayer connection facade.
##
## Autoloaded as `Net`. Owned by Devin-2 (Network / Steam).
##
## STUB: full implementation comes from Devin-2's Issue #2 PR.
## This file only declares the public interface so other modules can compile.

signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)

func host_match() -> int:
	push_warning("Net.host_match() — STUB. Implement in src/network/.")
	return 0

func join_match(_lobby_id: int) -> bool:
	push_warning("Net.join_match() — STUB. Implement in src/network/.")
	return false

func leave_match() -> void:
	push_warning("Net.leave_match() — STUB. Implement in src/network/.")

func send_rpc(_method: String, _args: Array) -> void:
	push_warning("Net.send_rpc() — STUB.")

func send_to_director(_method: String, _args: Array) -> void:
	push_warning("Net.send_to_director() — STUB.")
