class_name RingBuffer
extends RefCounted

var _content := []
var _capacity: int = 0
var _capacityCounter: int = 0
var _initValue

func _init(capacity: int, initValue = 0):
	_capacity = capacity
	_initValue = initValue
	for i in range(_capacity):
		_content.append(_initValue)

func clear():
	_content = []
	for i in range(_capacity):
		_content.append(_initValue)

func add(content):
	_content[_capacityCounter] = content
	_capacityCounter = (_capacityCounter + 1) % _capacity

func getAll() -> Array:
	return _content

func getAt(index):
	if index < 0 or index >= _capacity:
		return null
	return _content[index]
