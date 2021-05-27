import automata


def calculate_repeat(line):
    # for power in range(8):
    power = 0

    while True:
        repeat = 2**power

        # contains lists of values
        # values = [0: [0, 1, 1, 1], 1: [1, 0, 1, 0]]
        values = [[] for p in range(repeat)]

        for i in range(len(line)):
            values[i % repeat].append(line[i])

        # Now average
        averages = [
            (sum(value_list) / len(value_list) if len(value_list) != 0 else -1)
            for value_list in values
        ]

        # Compute the metric
        metric = sum([
            (min(average - 0, 1 - average) if average != -1 else 0)
            for average in averages
        ])

        if metric == 0:
            return repeat
        else:
            power += 1


def run():
    for n in range(2048):
        automata.compute_next_line()

    for i in range(2048):
        # print(f"{i}:")

        # diagonal = automata.get_right_diagonal(i)
        diagonal = automata.get_left_diagonal(i)[8 * i:]  # only use the (4 * i)th element onwards to guarantee a period

        repeat = calculate_repeat(diagonal)

        if repeat > 8:
            print(f"{i}:")

            print(f"{repeat} (based on {len(diagonal)} values)")

            print(diagonal[:20])  # print the first 20 for reference
            print()
