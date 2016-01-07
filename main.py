#!/usr/bin/env python3
import pyglet
from pyglet.window import key
import numpy
import random
import ezgraph

FIELDS_LIST = list(range(1,16)) + [None]

def split(l, n):
    out = []
    for x in range(0, len(l), n):
        out.append(l[x:x+n])
    return out

class board:
    def __init__(self):
        self.field = split(FIELDS_LIST, 4)
    def find_empty(self):
        for y, l in enumerate(self.field):
            try:
                x = l.index(None)
                return (x, y)
            except ValueError:
                pass

    def shuffle(self):
        lst = list(range(1,16)) + [None]
        random.shuffle(lst)
        self.field = split(lst, 4)

    def valid_field(self, x, y):
        max_x = len(self.field[0]) - 1
        max_y = len(self.field) - 1
        print(x, y)
        print(max_x, max_y)
        print("Valid field: ", x <= max_x and y <= max_y)
        return x <= max_x and y <= max_y and x >= 0 and y >= 0

    def switch_fields(self, pos_a, pos_b):
        tmp = self.field[pos_a[1]][pos_a[0]]
        self.field[pos_a[1]][pos_a[0]] = self.field[pos_b[1]][pos_b[0]]
        self.field[pos_b[1]][pos_b[0]] = tmp

    def move_to_empty(self, delta_x, delta_y):
        empty_pos = self.find_empty()
        switch_pos = (empty_pos[0] + delta_x, empty_pos[1] + delta_y)
        if self.valid_field(*switch_pos):
            self.switch_fields(empty_pos, switch_pos)

    def up(self):
        self.move_to_empty(0, 1)

    def down(self):
        self.move_to_empty(0, -1)

    def left(self):
        self.move_to_empty(1, 0)

    def right(self):
        self.move_to_empty(-1, 0)

    def __repr__(self):
        return str(self.field)

def draw_square(center_pos, size):
    x = center_pos[0] - (size // 2)
    y = center_pos[1] - (size // 2)
    pyglet.graphics.draw_indexed(4, pyglet.gl.GL_TRIANGLES,
        [0, 1, 2, 0, 2, 3],
        ('v2i', (x, y,
                 x + size, y,
                 x + size, y + size,
                 x, y + size)),
        ('c4B', (153, 204, 255, 255) * 4)
    )


window = None
game_board = None
if __name__ == '__main__':
    window = pyglet.window.Window()
    game_board = board()
    game_board.shuffle()
    labels = {x: pyglet.text.Label(str(x), color=(0, 0, 0, 255),
        anchor_x="center", anchor_y="center") for x in FIELDS_LIST}
    @window.event
    def on_key_release(symbol, mods):
        if symbol == key.LEFT:
            game_board.left()
        if symbol == key.RIGHT:
            game_board.right()
        if symbol == key.UP:
            game_board.up()
        if symbol == key.DOWN:
            game_board.down()
        print(game_board)

    @window.event
    def on_draw():
        window.clear()
        x_size, y_size = window.get_size()
        block_size = x_size * 0.1
        gap = block_size * 0.2
        for y, _ in enumerate(game_board.field):
            for x, _ in enumerate(game_board.field):
                if game_board.field[y][x]:
                    draw_square(
                        (int(x_size * 0.5 - (block_size * 1.5 + gap * 1.5) +  block_size * x),
                            int(y_size * 0.9 - block_size * y)),
                        int(block_size - gap)
                    )
                    label = labels[game_board.field[y][x]]
                    label.x = int(x_size * 0.5 - (block_size * 1.5 + gap * 1.5) +  block_size * x)
                    label.y = int(y_size * 0.9 - block_size * y)
                    label.draw()

    pyglet.app.run()
