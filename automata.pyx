import numpy as np
cimport numpy as np

# # A line is a vertical strip of the triangle.
# # In particular it does _not_ contain the 0s on both sides.
# # This allows for arbitrarily large images to be created.
# _lines = [
#     [1]  # the first line
# ]


"""
True  == 1 == "black"
False == 0 == "white"
"""


"""
Diagonals start with the sequence of 0s.
"""
list _diagonals = [
  np.array([False], dtype=bool, ndim=1),  # 0 is the diagonal on the right, outside the trangle
  np.array([True], dtype=bool, ndim=1)  # 1 is the right most diagonal of the triangle
]

list _periods = [
  1,  # The 0s have a period of 1
  1  # The 1s also have a period of 1
]


"""
The coordinate system is y down, i.e.
  (-1, 0) (0, 0) (1, 0)
  (-1, 1) (0, 1) (1, 1)
  (-1, 2) (0, 2) (1, 2)
"""
cdef bint get(int x, int y):
  cdef int diagonal_index
  cdef int index
  cdef np.ndarray[dtype=bool, ndim=1] diagonal
  cdef int period

  diagonal_index = y - x

  if diagonal_index < 0:
    return False
  else:
    diagonal = _diagonals[diagonal_index]
    period = _periods[diagonal_index]
    index = y % period

    compute_until(diagonal_index, index)

    return diagonal[index]


# """
# Calculates until the value is known.
# `row`:
# 0 being initial row.
# `column`:
# 0 being center column.
# """
# def get(row, column):
#   compute_until_row(row)
#
#   return soft_get(row, column)


cdef void compute_until(int diagonal_index, int index):
  cdef int period
  cdef int i_diagonal_index
  cdef np.ndarray[dtype=bool, ndim=1] diagonal
  cdef bint diagonal_last_value

  # Do we have to do anything?
  if has(diagonal_index, index):
    return

  # Find the first diagonal with `period == 0`.

  i_diagonal_index = 0
  period = _periods[i_diagonal_index]

  while i_diagonal_index < len(_diagonals) and not period == 0:
    i_diagonal_index += 1
    period = _periods[i_diagonal_index]

  # Now (continue to) calculate diagonal from
  # `diagonal_index - 1` and `diagonal_index - 2`.

  # New diagonal
  if i_diagonal_index == len(_diagonals):
    diagonal, period = compute_diagonal_and_period_from(i_diagonal_index - 1, i_diagonal_index - 2)

    _diagonals.append(diagonal)
    _periods.append(period)

  # Continue diagonal
  diagonal = _diagonals[i_diagonal_index]

  assert(len(diagonal) > 0)

  diagonal_last_value = diagonal[-1]

  while len(diagonal) < diagonal_index:
    diagonal
    # TODO


cdef bint has(int diagonal_index, int index):
  cdef np.ndarray[dtype=bool, ndim=1] diagonal
  cdef int period

  # Less than 0 is trivial.
  if diagonal_index < 0:
    return True

  # Do we have this diagonal?
  if len(_diagonals) < diagonal_index:
    return False

  period = _periods[diagonal_index]

  # If the period is non 0, then its length is theoretically infinite.
  if not period == 0:
    return True

  diagonal = _diagonals[diagonal_index]

  # The diagonal may nevertheless already have this value.
  if len(diagonal) >= index:
    return True

  return False


"""
Throws exception if cell has not been calculated yet.
    `row`:
        0 being initial row.
    `column`:
        0 being center column.
"""
def soft_get(row, column):
    return _lines[row][column + row]


"""
`row`:
    0 being initial row.
"""
def has_row(row):
    return len(_lines) > row


"""
`row`:
    0 being initial row.
"""
def get_row(row):
    compute_until_row(row)

    return _lines[row]


"""
A diagonal is an inner diagonal.
I.e. right diagonals always start with 1, not to sequence of 0's.
    `index`:
        0 being the right side of the triangle.
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


"""
A diagonal is an inner diagonal.
I.e. left diagonals always start with 1, not to sequence of 0's.
    `index`:
        0 being the left side of the triangle.
"""
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


"""
`row`:
    0 being initial row.
"""
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


"""
The shape for the input is:
    x y z
      ?
"""
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
