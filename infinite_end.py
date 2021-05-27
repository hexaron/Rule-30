import automata

from PIL import Image


MAX_LINES_WIDTH = 5000
MAX_NUMBER_OF_LINES = 5000

# Lines are created in _opposite_ order.
# Each line stops at the 1
_lines = [
    [1 for i in range(MAX_LINES_WIDTH - 2)] + [0]  # inital row: 0...010
]


def run():
    while len(_lines) < MAX_NUMBER_OF_LINES:
        compute_next_line()

    # Debug print of `_lines`
    # print("\n".join(["".join(["##" if x == 1 else "  " for x in line]) for line in _lines]))

    # Now create the image
    image = Image.new(mode='1', size=(MAX_LINES_WIDTH, MAX_NUMBER_OF_LINES))

    for y in range(MAX_NUMBER_OF_LINES):
        for x in range(MAX_LINES_WIDTH):
            values = 1

            if len(_lines[y]) > x:
                value = 1 - _lines[y][x]  # 1 is black and 0 is white

            image.putpixel((x, y), value)

    image = image.resize((3 * MAX_LINES_WIDTH, 3 * MAX_NUMBER_OF_LINES), Image.NEAREST)

    image.save(f"out_{MAX_LINES_WIDTH}_{MAX_NUMBER_OF_LINES}.png")


def compute_next_line(verbose=False):
    last_line = _lines[0]

    if len(last_line) <= 2:
        next_line = [0]
    else:
        next_line = [1, 0]

        if verbose: print(f"Extending along line {last_line}:")

        while len(next_line) < len(last_line) - 1:
            next_line.insert(0, automata.left_bijection_inverse(
                next_line[0],
                next_line[1],
                last_line[-(len(next_line) + 1)]
            ))

            if verbose: print(f"Extending right corner\n  ({next_line[0]}) {next_line[0]}  {next_line[1]}\n      {last_line[-(len(next_line) + 1)]}")

    _lines.insert(0, next_line)

    if verbose: print(f"New line: {next_line}\n")
