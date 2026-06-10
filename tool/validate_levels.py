import heapq
from typing import List, Tuple, Dict, Optional


class TileType:
    NORMAL = "normal"
    START = "start"
    END = "end"
    TELEPORT = "teleport"
    KEY = "key"
    LOCK = "lock"


class Tile:
    def __init__(self, row, col, type=TileType.NORMAL, teleport_id=None):
        self.row = row
        self.col = col
        self.type = type
        self.teleport_id = teleport_id


class Level:
    def __init__(self, id, rows, cols, optimal_steps, allowed_steps, special_tiles):
        self.id = id
        self.rows = rows
        self.cols = cols
        self.optimal_steps = optimal_steps
        self.allowed_steps = allowed_steps
        self.special_tiles = special_tiles

    def get_special(self, r, c):
        for t in self.special_tiles:
            if t.row == r and t.col == c:
                return t
        return None


def manhattan(r1, c1, r2, c2):
    return abs(r1 - r2) + abs(c1 - c2)


def solve_a_star(level: Level) -> Optional[int]:
    start_tile = next(t for t in level.special_tiles if t.type == TileType.START)
    end_tile = next(t for t in level.special_tiles if t.type == TileType.END)

    teleport_map: Dict[str, List[Tuple[int, int]]] = {}
    key_count = sum(1 for t in level.special_tiles if t.type == TileType.KEY)
    for t in level.special_tiles:
        if t.type == TileType.TELEPORT and t.teleport_id:
            teleport_map.setdefault(t.teleport_id, []).append((t.row, t.col))

    def heuristic(r, c):
        return manhattan(r, c, end_tile.row, end_tile.col)

    start_state = (heuristic(start_tile.row, start_tile.col), 0, start_tile.row, start_tile.col, 0)
    open_heap = [start_state]
    visited: Dict[str, int] = {f"{start_tile.row}_{start_tile.col}_0": 0}
    counter = 0

    dirs = [(1, 0), (-1, 0), (0, 1), (0, -1)]

    while open_heap:
        priority, steps, r, c, keys = heapq.heappop(open_heap)
        counter += 1
        if counter > 500000:
            return None

        if r == end_tile.row and c == end_tile.col:
            return steps

        for dr, dc in dirs:
            nr, nc = r + dr, c + dc
            if nr < 0 or nr >= level.rows or nc < 0 or nc >= level.cols:
                continue

            new_keys = keys
            special = level.get_special(nr, nc)
            if special and special.type == TileType.LOCK:
                if keys <= 0:
                    continue
                new_keys = keys - 1
            elif special and special.type == TileType.KEY:
                new_keys = keys + 1
                if new_keys > key_count:
                    new_keys = key_count

            new_steps = steps + 1
            state_key = f"{nr}_{nc}_{new_keys}"
            if state_key in visited and visited[state_key] <= new_steps:
                continue
            visited[state_key] = new_steps
            heapq.heappush(open_heap, (new_steps + heuristic(nr, nc), new_steps, nr, nc, new_keys))

            special2 = level.get_special(nr, nc)
            if special2 and special2.type == TileType.TELEPORT and special2.teleport_id:
                pair = teleport_map.get(special2.teleport_id, [])
                for pr, pc in pair:
                    if pr == nr and pc == nc:
                        continue
                    tp_key = f"{pr}_{pc}_{new_keys}"
                    if tp_key in visited and visited[tp_key] <= new_steps:
                        continue
                    visited[tp_key] = new_steps
                    heapq.heappush(open_heap, (new_steps + heuristic(pr, pc), new_steps, pr, pc, new_keys))

    return None


def build_levels() -> List[Level]:
    levels: List[Level] = []
    idx = 0

    for i in range(10):
        sr, sc, er, ec = 0, 0, 7, 7
        if i % 3 == 1:
            sr, sc, er, ec = 0, 7, 7, 0
        elif i % 3 == 2:
            sr, sc, er, ec = 3, 0, 3, 7
        buffer = max(5, 10 - i)
        levels.append(_make_level(idx, sr, sc, er, ec, buffer, [], "basic"))
        idx += 1

    for i in range(10):
        tiles = []
        if i % 2 == 0:
            tiles = [
                Tile(2, 3, TileType.KEY),
                Tile(5, 4, TileType.LOCK),
            ]
        else:
            tiles = [
                Tile(4, 2, TileType.KEY),
                Tile(3, 5, TileType.LOCK),
            ]
        buffer = max(4, 8 - (i // 3))
        levels.append(_make_level(idx, 0, 0, 7, 7, buffer, tiles, "key+lock"))
        idx += 1

    for i in range(10):
        tiles = []
        tp_id = f"tp_{i}"
        if i % 2 == 0:
            tiles = [
                Tile(1, 3, TileType.TELEPORT, tp_id),
                Tile(6, 4, TileType.TELEPORT, tp_id),
            ]
        else:
            tiles = [
                Tile(2, 2, TileType.TELEPORT, tp_id),
                Tile(5, 5, TileType.TELEPORT, tp_id),
            ]
        buffer = max(3, 7 - (i // 4))
        levels.append(_make_level(idx, 0, 0, 7, 7, buffer, tiles, "teleport"))
        idx += 1

    for i in range(10):
        tp_id = f"tp_comb_{i}"
        tiles = [
            Tile(2, 2, TileType.TELEPORT, tp_id),
            Tile(5, 5, TileType.TELEPORT, tp_id),
            Tile(3, 3, TileType.KEY),
            Tile(4, 4, TileType.LOCK),
        ]
        buffer = max(3, 6 - (i // 5))
        levels.append(_make_level(idx, 0, 0, 7, 7, buffer, tiles, "teleport+key+lock"))
        idx += 1

    for i in range(10):
        x_id = f"x_{i}"
        y_id = f"y_{i}"
        tiles = [
            Tile(1, 1, TileType.TELEPORT, x_id),
            Tile(6, 6, TileType.TELEPORT, x_id),
            Tile(1, 6, TileType.TELEPORT, y_id),
            Tile(6, 1, TileType.TELEPORT, y_id),
            Tile(3, 2, TileType.KEY),
            Tile(4, 5, TileType.LOCK),
            Tile(2, 5, TileType.KEY),
            Tile(5, 2, TileType.LOCK),
        ]
        buffer = max(2, 5 - (i // 5))
        levels.append(_make_level(idx, 0, 0, 7, 7, buffer, tiles, "double_teleport+2keys"))
        idx += 1

    return levels


def _make_level(idx, sr, sc, er, ec, buffer, extras, _):
    tiles = [
        Tile(sr, sc, TileType.START),
        Tile(er, ec, TileType.END),
        *extras,
    ]
    temp = Level(f"level_{idx + 1}", 8, 8, 0, 0, tiles)
    optimal = solve_a_star(temp)
    if optimal is None:
        optimal = 14
    return Level(
        f"level_{idx + 1}",
        8,
        8,
        optimal,
        optimal + buffer,
        tiles,
    )


def main():
    levels = build_levels()
    print(f"Total levels: {len(levels)}")
    failures = 0
    for i, lv in enumerate(levels):
        computed = solve_a_star(lv)
        match = computed == lv.optimal_steps
        if not match:
            failures += 1
        type_info = []
        for t in lv.special_tiles:
            if t.type != TileType.START and t.type != TileType.END:
                type_info.append(t.type)
        print(
            f"Level {i + 1:3d}: optimal={lv.optimal_steps:3d}, "
            f"allowed={lv.allowed_steps:3d}, computed={computed}, "
            f"match={match}, types=[{', '.join(type_info)}]"
        )

    print()
    print(f"Failures: {failures} / {len(levels)}")
    if failures == 0:
        print("ALL CHECKS PASSED")


if __name__ == "__main__":
    main()
