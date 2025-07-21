extends Node2D

@export var color: Color = Color.WHITE

func _ready():
    if has_method("update"):
        update()

func _draw():
    draw_rect(Rect2(Vector2.ZERO, Vector2(24, 24)), color)

func set_color(c: Color):
    color = c
    if has_method("update"):
        update()