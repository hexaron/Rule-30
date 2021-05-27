_lines = [
    [1]  # the first line
]


"""
Calculates until the value is known.
"""
# row:      0 being initial row.
# column:   0 being center column.
def get(row, column):
    compute_until_row(row)

    return soft_get(row, column)


"""
Throws exception if cell has not been calculated yet.
"""
def soft_get(row, column):
    return _lines[row][column + row]


def has_row(row):
    return len(_lines) > row


# row:  0 being initial row.
def get_row(row):
    compute_until_row(row)

    return _lines[row]


"""
A diagonal is an inner diagonal.
I.e. right diagonals always start with 1, not to sequence of 0's.
"""
def get_right_diagonal(index):
    diagonal = []
    column_offset = -int(index / 2)
    row_offset = int(index / 2) + index % 2  # go 1 down for odd index

    for i in range(get_number_of_rows()):
        row = i + row_offset
        column = i + column_offset

        if has_row(row):
            diagonal.append(soft_get(row, column))
        else:
            break

    return diagonal


def get_left_diagonal(index):
    diagonal = []
    # column_offset = int(index / 2)
    # row_offset = int(index / 2) + index % 2  # go 1 down for odd index

    for i in range(get_number_of_rows()):
        # row = i + row_offset
        # column = -i + column_offset

        if has_row(i + index):
            diagonal.append(_lines[i + index][index])
        else:
            break

    return diagonal


def get_number_of_rows():
    return len(_lines)


def compute_until_row(row):
    while len(_lines) <= row:
        compute_next_line()


def compute_next_line():
    last_line = _lines[-1]
    next_line = []

    for i in range(-1, len(last_line) + 1):
        next_line.append(apply_rule_to(
            _safe_get_line_at(last_line, i - 1),
            _safe_get_line_at(last_line, i),
            _safe_get_line_at(last_line, i + 1)
        ))

    _lines.append(next_line)


def _safe_get_line_at(line, at):
    if 0 <= at < len(line):
        return line[at]

    return 0


def apply_rule_to(x, y, z):
    pattern = [x, y, z]

    if pattern == [0, 0, 0]:
        return 0
    elif pattern == [0, 0, 1]:
        return 1
    elif pattern == [0, 1, 0]:
        return 1
    elif pattern == [0, 1, 1]:
        return 1
    elif pattern == [1, 0, 0]:
        return 1
    elif pattern == [1, 0, 1]:
        return 0
    elif pattern == [1, 1, 0]:
        return 0
    elif pattern == [1, 1, 1]:
        return 0
    else:
        raise ValueError(f"Not a valid pattern: {pattern}")


"""
The shape for the input is:
    ? y z
      q
"""
def left_bijection_inverse(y, z, q):
    right_corner = [y, z, q]

    if right_corner == [0, 0, 0]:
        return 0
    elif right_corner == [0, 0, 1]:
        return 1
    elif right_corner == [0, 1, 0]:
        return 1
    elif right_corner == [0, 1, 1]:
        return 0
    elif right_corner == [1, 0, 0]:
        return 1
    elif right_corner == [1, 0, 1]:
        return 0
    elif right_corner == [1, 1, 0]:
        return 1
    elif right_corner == [1, 1, 1]:
        return 0
    else:
        raise ValueError(f"Not a valid right corner: {right_corner}")
