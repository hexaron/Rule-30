ctypedef struct _ListItem:
  bint data
  _ListItem* next
  _ListItem* previous

cdef class List:
  cdef _ListItem* _head  # `_head` is right
  cdef _ListItem* _tail  # `_tail` is left
  cdef int _length

  def __cinit__(self, bint data):
    cdef _ListItem* init

    init.data = data
    init.next = NULL
    init.previous = NULL

    self._head = init
    self._tail = init

    self._length = 1

  cdef void append(self, bint data):
    cdef _ListItem item

    item.data = data
    item.next = NULL

    item.previous = self._head
    self._head.next = item

    # New head
    self._head = item

    self._length += 1

  cdef void prepend(self, bint data):
    cdef _ListItem *item

    item.data = data
    item.previous = NULL

    item.next = self._tail
    self._tail.previous = item

    # New tail
    self._tail = item

    self._length += 1

  cdef int length(self):
    return self._length

  cdef bint get(self, int index):
    cdef _ListItem *item

    if 0 <= index < self._length:
      if index == self._length - 1:
        return self._head.data
      elif index == self._length - 2:
        return self._head.previous.data
      else:
        item = self._tail

        for i in range(index):
          item = item.next

        return item.data
