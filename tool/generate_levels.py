import heapq
from typing import List, Tuple, Dict, Optional


class TileType:
    NORMAL = "normal"
    WALL = "wall"
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

    def is_wall(self, r, c):
        t = self.get_special(r, c)
        return t is not None and t.type == TileType.WALL


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

    open_heap = [(heuristic(start_tile.row, start_tile.col), 0, start_tile.row, start_tile.col, 0)]
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
            if level.is_wall(nr, nc):
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


def make_level(id, rows, cols, sr, sc, er, ec, buffer, extras):
    tiles = [
        Tile(sr, sc, TileType.START),
        Tile(er, ec, TileType.END),
        *extras,
    ]
    temp = Level(id, rows, cols, 0, 0, tiles)
    optimal = solve_a_star(temp)
    if optimal is None:
        return None
    return Level(id, rows, cols, optimal, optimal + buffer, tiles)


def W(r, c):
    return Tile(r, c, TileType.WALL)


def K(r, c):
    return Tile(r, c, TileType.KEY)


def L(r, c):
    return Tile(r, c, TileType.LOCK)


def T(r, c, tid):
    return Tile(r, c, TileType.TELEPORT, tid)


def build_levels():
    levels = []
    n = 0

    # === 第1-3关: 3x3 教学 ===
    # 第1关: 一面墙挡住直路
    r = make_level(f'level_{++n}', 3, 3, 0, 0, 2, 2, 5, [W(1, 1)])
    if r: levels.append(r)

    # 第2关: 两面墙
    r = make_level(f'level_{++n}', 3, 3, 0, 2, 2, 0, 4, [W(0, 1), W(2, 1)])
    if r: levels.append(r)

    # 第3关: 3x4 横向绕墙
    r = make_level(f'level_{++n}', 3, 4, 1, 0, 1, 3, 4, [W(1, 1), W(1, 2)])
    if r: levels.append(r)

    # === 第4-6关: 4x4 ===
    # 第4关: 中间一列墙
    r = make_level(f'level_{++n}', 4, 4, 0, 0, 3, 3, 5, [W(1, 2), W(2, 2)])
    if r: levels.append(r)

    # 第5关: L形墙
    r = make_level(f'level_{++n}', 4, 4, 0, 3, 3, 0, 4, [W(1, 1), W(1, 2), W(2, 1)])
    if r: levels.append(r)

    # 第6关: 墙+钥匙锁
    r = make_level(f'level_{++n}', 4, 4, 0, 0, 3, 3, 4, [W(1, 1), W(2, 2), K(0, 2), L(2, 3)])
    if r: levels.append(r)

    # === 第7-10关: 5x5 ===
    # 第7关: 十字墙
    r = make_level(f'level_{++n}', 5, 5, 0, 0, 4, 4, 5, [W(2, 1), W(2, 2), W(2, 3), W(1, 2), W(3, 2)])
    if r: levels.append(r)

    # 第8关: 走廊
    r = make_level(f'level_{++n}', 5, 5, 0, 0, 4, 4, 4, [W(1, 1), W(1, 2), W(1, 3), W(3, 1), W(3, 2), W(3, 3)])
    if r: levels.append(r)

    # 第9关: 墙+传送
    r = make_level(f'level_{++n}', 5, 5, 0, 4, 4, 0, 3, [W(1, 2), W(2, 2), W(3, 2), T(1, 1, 'a'), T(3, 3, 'a')])
    if r: levels.append(r)

    # 第10关: 墙+钥匙锁
    r = make_level(f'level_{++n}', 5, 5, 0, 0, 4, 4, 3, [W(1, 3), W(2, 3), W(3, 1), K(1, 1), L(3, 3)])
    if r: levels.append(r)

    # === 第11-20关: 6x6 ===
    r = make_level(f'level_{++n}', 6, 6, 0, 0, 5, 5, 5, [W(1, 2), W(2, 2), W(3, 2), W(2, 4), W(3, 4), W(4, 4)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 6, 6, 0, 5, 5, 0, 4, [W(1, 3), W(2, 3), W(3, 3), W(3, 1), W(3, 2)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 6, 6, 5, 0, 0, 5, 4, [W(1, 1), W(1, 2), W(2, 4), W(3, 4), W(4, 1), W(4, 2)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 6, 6, 0, 2, 5, 3, 4, [W(1, 0), W(1, 1), W(2, 3), W(2, 4), W(4, 2), W(4, 3)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 6, 6, 2, 0, 3, 5, 4, [W(0, 2), W(1, 2), W(4, 3), W(5, 3), W(2, 4), W(3, 1)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 6, 6, 0, 0, 5, 5, 3, [W(1, 2), W(2, 2), W(3, 4), W(4, 4), K(1, 4), L(4, 1)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 6, 6, 0, 5, 5, 0, 3, [W(2, 1), W(2, 2), W(3, 3), W(3, 4), K(1, 3), L(4, 2)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 6, 6, 0, 0, 5, 5, 3, [W(2, 0), W(2, 1), W(2, 2), T(1, 1, 'b'), T(4, 4, 'b')])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 6, 6, 5, 5, 0, 0, 3, [W(1, 1), W(1, 3), W(3, 1), W(3, 3), T(2, 2, 'c'), T(4, 4, 'c'), K(1, 4), L(4, 0)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 6, 6, 0, 0, 5, 5, 2, [W(1, 3), W(2, 3), W(3, 1), W(4, 1), K(0, 4), L(3, 4), K(2, 0), L(5, 3)])
    if r: levels.append(r)

    # === 第21-35关: 7x7 ===
    # 蛇形走廊
    r = make_level(f'level_{++n}', 7, 7, 0, 0, 6, 6, 4, [W(1, 0), W(1, 1), W(1, 2), W(1, 3), W(1, 4), W(3, 2), W(3, 3), W(3, 4), W(3, 5), W(3, 6), W(5, 0), W(5, 1), W(5, 2), W(5, 3), W(5, 4)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 6, 6, 0, 4, [W(1, 2), W(1, 3), W(1, 4), W(2, 4), W(3, 4), W(4, 2), W(4, 3), W(4, 4), W(5, 2)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 6, 0, 0, 6, 4, [W(0, 3), W(1, 3), W(2, 3), W(4, 3), W(5, 3), W(6, 3), W(3, 0), W(3, 1)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 3, 6, 3, 3, [W(1, 1), W(1, 2), W(1, 4), W(1, 5), W(3, 1), W(3, 2), W(3, 4), W(3, 5), W(5, 1), W(5, 2), W(5, 4), W(5, 5)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 3, 0, 3, 6, 3, [W(0, 2), W(1, 2), W(2, 2), W(4, 4), W(5, 4), W(6, 4), W(0, 5), W(1, 5), W(5, 1), W(6, 1)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 0, 6, 6, 3, [W(1, 2), W(2, 2), W(3, 4), W(4, 4), W(1, 5), W(2, 5), K(0, 4), L(4, 3)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 6, 6, 0, 3, [W(1, 1), W(2, 1), W(4, 5), W(5, 5), T(3, 3, 'd'), T(4, 2, 'd')])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 0, 6, 6, 3, [W(2, 1), W(2, 2), W(2, 3), W(4, 3), W(4, 4), W(4, 5), T(1, 4, 'e'), T(5, 1, 'e'), K(3, 5), L(4, 0)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 6, 6, 0, 0, 2, [W(1, 3), W(2, 3), W(4, 3), W(5, 3), K(1, 5), L(5, 1), T(3, 4, 'f'), T(3, 2, 'f')])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 0, 6, 6, 2, [W(1, 2), W(2, 2), W(4, 4), W(5, 4), K(0, 5), L(3, 5), K(3, 0), L(6, 2)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 0, 6, 6, 2, [W(1, 1), W(1, 5), W(3, 3), W(5, 1), W(5, 5), T(2, 2, 'g'), T(4, 4, 'g')])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 6, 6, 0, 2, [W(0, 3), W(2, 3), W(4, 3), W(6, 3), T(1, 4, 'h'), T(5, 2, 'h')])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 3, 0, 3, 6, 2, [W(0, 2), W(1, 2), W(5, 4), W(6, 4), K(2, 4), L(4, 2), T(0, 5, 'i'), T(6, 1, 'i')])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 0, 6, 6, 2, [W(1, 3), W(2, 3), W(4, 3), W(5, 3), T(1, 1, 'j1'), T(5, 5, 'j1'), T(1, 5, 'j2'), T(5, 1, 'j2')])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 7, 7, 0, 3, 6, 3, 2, [W(1, 0), W(1, 1), W(1, 5), W(1, 6), W(5, 0), W(5, 1), W(5, 5), W(5, 6), K(3, 1), L(3, 5), T(2, 3, 'k'), T(4, 3, 'k')])
    if r: levels.append(r)

    # === 第36-50关: 8x8 ===
    # 蛇形
    r = make_level(f'level_{++n}', 8, 8, 0, 0, 7, 7, 4, [W(1, 0), W(1, 1), W(1, 2), W(1, 3), W(1, 4), W(1, 5), W(3, 2), W(3, 3), W(3, 4), W(3, 5), W(3, 6), W(3, 7), W(5, 0), W(5, 1), W(5, 2), W(5, 3), W(5, 4), W(5, 5)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 7, 7, 0, 3, [W(1, 2), W(1, 3), W(1, 4), W(2, 4), W(3, 4), W(4, 2), W(4, 3), W(4, 4), W(5, 2), W(6, 2), W(6, 3)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 7, 0, 0, 7, 3, [W(0, 3), W(1, 3), W(2, 3), W(5, 4), W(6, 4), W(7, 4), W(3, 1), W(4, 6)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 3, 7, 4, 3, [W(1, 1), W(1, 2), W(1, 5), W(1, 6), W(3, 1), W(3, 2), W(3, 5), W(3, 6), W(5, 1), W(5, 2), W(5, 5), W(5, 6)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 3, 0, 4, 7, 3, [W(0, 2), W(1, 2), W(2, 2), W(5, 5), W(6, 5), W(7, 5), W(0, 6), W(1, 6), W(6, 1), W(7, 1)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 0, 7, 7, 3, [W(1, 3), W(2, 3), W(5, 4), W(6, 4), K(0, 5), L(4, 3)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 7, 7, 0, 2, [W(1, 4), W(2, 4), W(5, 3), W(6, 3), K(3, 5), L(4, 2)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 0, 7, 7, 2, [W(2, 1), W(2, 2), W(2, 3), W(5, 4), W(5, 5), W(5, 6), T(1, 4, 'l'), T(6, 3, 'l')])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 7, 7, 0, 0, 2, [W(1, 2), W(2, 2), W(5, 5), W(6, 5), T(3, 3, 'm'), T(4, 4, 'm'), K(1, 5), L(6, 2)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 0, 7, 7, 2, [W(1, 3), W(2, 3), W(5, 4), W(6, 4), K(0, 5), L(3, 5), K(4, 2), L(7, 3)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 0, 7, 7, 2, [W(1, 1), W(1, 6), W(3, 3), W(3, 4), W(6, 1), W(6, 6), T(2, 2, 'n1'), T(5, 5, 'n1'), T(2, 5, 'n2'), T(5, 2, 'n2')])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 7, 7, 0, 2, [W(0, 4), W(1, 4), W(6, 3), W(7, 3), T(2, 5, 'o'), T(5, 2, 'o'), K(3, 5), L(4, 2)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 0, 7, 7, 1, [W(2, 2), W(2, 3), W(2, 4), W(5, 3), W(5, 4), W(5, 5), T(1, 5, 'p1'), T(6, 2, 'p1'), K(0, 6), L(4, 2), K(3, 1), L(7, 4)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 7, 0, 0, 7, 1, [W(1, 1), W(1, 6), W(3, 2), W(3, 5), W(6, 1), W(6, 6), T(2, 3, 'q1'), T(5, 4, 'q1'), T(2, 4, 'q2'), T(5, 3, 'q2'), K(4, 1), L(3, 6)])
    if r: levels.append(r)

    r = make_level(f'level_{++n}', 8, 8, 0, 0, 7, 7, 1, [W(1, 3), W(2, 3), W(3, 3), W(4, 4), W(5, 4), W(6, 4), T(1, 5, 'r1'), T(6, 2, 'r1'), T(3, 1, 'r2'), T(4, 6, 'r2'), K(0, 6), L(4, 3), K(3, 5), L(7, 2)])
    if r: levels.append(r)

    return levels


def main():
    levels = build_levels()
    print(f'Total levels: {len(levels)}')
    failures = 0
    for i, lv in enumerate(levels):
        computed = solve_a_star(lv)
        match = computed == lv.optimal_steps
        if not match:
            failures += 1
        wall_count = sum(1 for t in lv.special_tiles if t.type == TileType.WALL)
        special_count = sum(1 for t in lv.special_tiles if t.type not in (TileType.START, TileType.END, TileType.NORMAL))
        print(f'Level {i+1:3d}: optimal={lv.optimal_steps:3d}, allowed={lv.allowed_steps:3d}, walls={wall_count}, specials={special_count-2}, match={match}')

    print()
    print(f'Failures: {failures} / {len(levels)}')
    if failures == 0:
        print('ALL CHECKS PASSED')

    # Generate Dart code
    print('\n--- DART CODE ---\n')
    for i, lv in enumerate(levels):
        extras = []
        for t in lv.special_tiles:
            if t.type == TileType.START or t.type == TileType.END:
                continue
            if t.type == TileType.WALL:
                extras.append(f'        Tile(row: {t.row}, col: {t.col}, type: TileType.wall),')
            elif t.type == TileType.KEY:
                extras.append(f'        Tile(row: {t.row}, col: {t.col}, type: TileType.key),')
            elif t.type == TileType.LOCK:
                extras.append(f'        Tile(row: {t.row}, col: {t.col}, type: TileType.lock),')
            elif t.type == TileType.TELEPORT:
                extras.append(f"        Tile(row: {t.row}, col: {t.col}, type: TileType.teleport, teleportId: '{t.teleport_id}'),")

        extras_str = '\n'.join(extras) if extras else '        // no extras'
        print(f'    // Level {i+1}: optimal={lv.optimal_steps}, allowed={lv.allowed_steps}')
        print(f'    levels.add(_makeLevel(\'level_{i+1}\', {lv.rows}, {lv.cols}, {lv.special_tiles[0].row}, {lv.special_tiles[0].col}, {lv.special_tiles[1].row}, {lv.special_tiles[1].col}, {lv.allowed_steps - lv.optimal_steps}, [')
        print(extras_str)
        print(f'    ]));')
        print()


if __name__ == '__main__':
    main()
