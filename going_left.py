import automata

import itertools


def run():
    for a in itertools.product([0, 1], [0, 1], [0, 1], [0, 1]):  # get the cartesian product
        for b in itertools.product([0, 1], [0, 1], [0, 1], [0, 1]):
            # One of the two starts has to be stable!
            for start in [0, 1]:
                next = start

                for ab in zip(a, b):  # get the list of pairings of a and b (i.e. (a0, b0), (a1, b1), ...)
                    next = automata.apply_rule_to(ab[0], ab[1], start)

                # If the result loops back, we have a period of 4.
                if start == next:
                    print(f"{a}, {b} -> {start}")
                else:
                    print(f"{a}, {b} -> {start} ----")
