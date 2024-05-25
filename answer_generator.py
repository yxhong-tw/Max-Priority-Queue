from math import ceil
from typing import List


def insert_data(tree: List[int], value: int) -> List[int]:
    tree.append(value)
    tree = build_queue(tree)

    return tree


def increase_value(tree: List[int], i: int, value: int) -> List[int]:
    tree[i] = value
    tree = build_queue(tree)

    return tree


def extract_max(tree: List[int]) -> List[int]:
    max_value = tree[0]
    tree[0] = tree[-1]
    tree.pop()
    tree = build_queue(tree)

    return max_value, tree


def max_heapify(tree: List[int], i: int) -> List[int]:
    left = 2 * (i + 1) - 1
    right = 2 * (i + 1)
    largest = i

    if left < len(tree) and tree[left] > tree[largest]:
        largest = left

    if right < len(tree) and tree[right] > tree[largest]:
        largest = right

    if largest != i:
        tree[i], tree[largest] = tree[largest], tree[i]
        tree = max_heapify(tree, largest)

    return tree


def build_queue(tree: List[int]) -> List[int]:
    for i in range(ceil(len(tree) / 2), -1, -1):
        tree = max_heapify(tree, i)

    return tree


if __name__ == "__main__":
    tree = [2, 5, 7, 9, 100, 50, 250, 21, 54, 6, 79, 80]
    tree = build_queue(tree)

    # P1
    # tree = extract_max(tree)
    # tree = extract_max(tree[1])
    # tree = extract_max(tree[1])
    # tree = tree[1]

    # P2
    # tree = extract_max(tree)
    # tree = extract_max(tree[1])
    # tree = tree[1]
    # tree = increase_value(tree, 8, 55)
    # tree = increase_value(tree, 1, 90)
    # tree = extract_max(tree)
    # tree = tree[1]
    # tree = increase_value(tree, 6, 52)

    # P3
    # tree = extract_max(tree)
    # tree = tree[1]
    # tree = increase_value(tree, 8, 55)
    # tree = insert_data(tree, 27)
    # tree = extract_max(tree)
    # tree = tree[1]
    # tree = increase_value(tree, 1, 90)
    # tree = insert_data(tree, 68)
    # tree = extract_max(tree)
    # tree = tree[1]
    # tree = increase_value(tree, 6, 52)
    # tree = insert_data(tree, 100)
    # tree = insert_data(tree, 69)

    for node in tree:
        print(f"{hex(node)} // {node}")
