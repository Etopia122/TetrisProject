extends Node2D

const BOARD_WIDTH = 10
const BOARD_HEIGHT = 20
const BLOCK_SIZE = 24
const TETROMINOS = ["I", "O", "T", "L", "S"]

var board = []
var current_tetromino = null
var current_pos = Vector2(4, 0)
var score = 0
var game_over = false
var fall_timer = 0.0
var fall_delay = 0.5

func _ready():
    reset_board()
    spawn_tetromino()
    set_process(true)

func reset_board():
    board.clear()
    for y in range(BOARD_HEIGHT):
        board.append([])
        for x in range(BOARD_WIDTH):
            board[y].append(null)
    score = 0
    game_over = false
    fall_timer = 0.0

func spawn_tetromino():
    var type = TETROMINOS[randi() % TETROMINOS.size()]
    current_tetromino = preload("res://Tetromino.tscn").instantiate()
    current_tetromino.type = type
    current_tetromino.position = board_to_screen(current_pos)
    add_child(current_tetromino)
    if !can_move(current_pos, 0):
        game_over = true
        current_tetromino.queue_free()
        current_tetromino = null

func can_move(pos: Vector2, rotation_delta: int) -> bool:
    if !current_tetromino:
        return false
    var old_rot = current_tetromino.rotation
    var new_rot = (old_rot + rotation_delta) % current_tetromino.SHAPES[current_tetromino.type].size()
    var shape = current_tetromino.SHAPES[current_tetromino.type][new_rot]
    for i in range(4):
        var block_pos = pos + shape[i]
        if block_pos.x < 0 or block_pos.x >= BOARD_WIDTH or block_pos.y < 0 or block_pos.y >= BOARD_HEIGHT:
            return false
        if board[block_pos.y][block_pos.x]:
            return false
    return true

func lock_tetromino():
    var shape = current_tetromino.SHAPES[current_tetromino.type][current_tetromino.rotation % current_tetromino.SHAPES[current_tetromino.type].size()]
    for i in range(4):
        var block_pos = current_pos + shape[i]
        var block = preload("res://Block.tscn").instantiate()
        block.set_color(current_tetromino.COLORS[current_tetromino.type])
        block.position = board_to_screen(block_pos)
        add_child(block)
        board[block_pos.y][block_pos.x] = block
    current_tetromino.queue_free()
    current_tetromino = null
    clear_lines()
    spawn_tetromino()
    current_pos = Vector2(4, 0)

func clear_lines():
    var lines_cleared = 0
    for y in range(BOARD_HEIGHT-1, -1, -1):
        var full = true
        for x in range(BOARD_WIDTH):
            if !board[y][x]:
                full = false
                break
        if full:
            lines_cleared += 1
            for x in range(BOARD_WIDTH):
                board[y][x].queue_free()
            board.remove_at(y)
            var new_row = []
            for x in range(BOARD_WIDTH):
                new_row.append(null)
            board.insert(0, new_row)
            for yy in range(y, 0, -1):
                for x in range(BOARD_WIDTH):
                    if board[yy][x]:
                        board[yy][x].position.y += BLOCK_SIZE
    score += lines_cleared * 100

func _process(delta):
    if game_over:
        return
    fall_timer += delta
    if fall_timer >= fall_delay:
        fall_timer = 0
        if can_move(current_pos + Vector2(0, 1), 0):
            current_pos.y += 1
            current_tetromino.position = board_to_screen(current_pos)
        else:
            lock_tetromino()

func _input(event):
    if game_over:
        if event.is_action_pressed("ui_accept") or event.is_action_pressed("restart"):
            reset_board()
            spawn_tetromino()
            current_pos = Vector2(4, 0)
        return
    if !current_tetromino:
        return
    if event.is_action_pressed("ui_left"):
        if can_move(current_pos + Vector2(-1, 0), 0):
            current_pos.x -= 1
            current_tetromino.position = board_to_screen(current_pos)
    elif event.is_action_pressed("ui_right"):
        if can_move(current_pos + Vector2(1, 0), 0):
            current_pos.x += 1
            current_tetromino.position = board_to_screen(current_pos)
    elif event.is_action_pressed("ui_down"):
        if can_move(current_pos + Vector2(0, 1), 0):
            current_pos.y += 1
            current_tetromino.position = board_to_screen(current_pos)
    elif event.is_action_pressed("ui_up"):
        if can_move(current_pos, 1):
            current_tetromino.rotate()
    elif event.is_action_pressed("ui_select"):
        while can_move(current_pos + Vector2(0, 1), 0):
            current_pos.y += 1
        current_tetromino.position = board_to_screen(current_pos)
        lock_tetromino()

def board_to_screen(pos: Vector2) -> Vector2:
    return Vector2(pos.x * BLOCK_SIZE, pos.y * BLOCK_SIZE)

func _draw():
    draw_rect(Rect2(Vector2.ZERO, Vector2(BOARD_WIDTH * BLOCK_SIZE, BOARD_HEIGHT * BLOCK_SIZE)), Color.DIM_GRAY)
    draw_string(get_font("font"), Vector2(260, 40), "Score: %d" % score, Color.WHITE)
    if game_over:
        draw_string(get_font("font"), Vector2(80, 240), "GAME OVER", Color.RED)
        draw_string(get_font("font"), Vector2(60, 280), "Press Enter to Restart", Color.WHITE)