extends Node2D

const SHAPES = {
    "I": [
        [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],
        [Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)],
    ],
    "O": [
        [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)],
    ],
    "T": [
        [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)],
        [Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(1, 0)],
        [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, -1)],
        [Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(-1, 0)],
    ],
    "L": [
        [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)],
        [Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(1, -1)],
        [Vector2(-1, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)],
        [Vector2(-1, 1), Vector2(0, -1), Vector2(0, 0), Vector2(0, 1)],
    ],
    "S": [
        [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1)],
        [Vector2(0, -1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)],
    ],
}

const COLORS = {
    "I": Color.CYAN,
    "O": Color.YELLOW,
    "T": Color.MAGENTA,
    "L": Color.ORANGE,
    "S": Color.GREEN,
}

@export var type: String
var rotation: int = 0
var blocks: Array

func _ready():
    blocks = []
    for i in range(4):
        var block = preload("res://Block.tscn").instantiate()
        block.set_color(COLORS[type])
        add_child(block)
        blocks.append(block)
    update_blocks()

func update_blocks():
    var shape = SHAPES[type][rotation % SHAPES[type].size()]
    for i in range(4):
        blocks[i].position = shape[i] * 24

func rotate():
    rotation = (rotation + 1) % SHAPES[type].size()
    update_blocks()

func get_block_positions(pos: Vector2) -> Array:
    var shape = SHAPES[type][rotation % SHAPES[type].size()]
    var positions = []
    for i in range(4):
        positions.append(pos + shape[i])
    return positions