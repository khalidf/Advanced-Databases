import psycopg2
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from shapely import wkt
from shapely.affinity import rotate, translate
from matplotlib.patches import Polygon as MplPolygon
import matplotlib.patches as mpatches

# Database connection
conn = psycopg2.connect(
    dbname="tetris",
    user="barbara"
)
cur = conn.cursor()

# --- Load tetrominoes ---
cur.execute("SELECT letter, color, ST_AsText(shape) FROM tetrominoes;")
tetrominoes = {
    row[0]: {
        "color": row[1],
        "shape": wkt.loads(row[2])
    }
    for row in cur.fetchall()
}

# --- Load puzzle board ---

print("Type in the ID of the puzzle to be visualized: ")
id = input()

cur.execute("SELECT ST_AsText(board) FROM puzzles WHERE id = " + id +";")
board_wkt = cur.fetchone()[0]
board_shape = wkt.loads(board_wkt)

# --- Load solution data ---

print("Type in the ID of the solution to be visualized: ")
id = input()

cur.execute("""
    SELECT tetromino_id, rotation, translation_x, translation_y
    FROM solutions
    WHERE solution_id = %s;
""", (id,))
solution = cur.fetchall()

minx, miny, maxx, maxy = board_shape.bounds

# --- Plot ---
fig, ax = plt.subplots()
ax.set_aspect('equal')
ax.set_xlim(minx - 1, maxx + 1)
ax.set_ylim(miny - 1, maxy + 1)
ax.set_xticks(range(int(minx) - 1, int(maxx) + 2))
ax.set_yticks(range(int(miny) - 1, int(maxy) + 2))
ax.grid(True)
plt.title("Tetromino Puzzle Board")

# Draw puzzle board
outer = list(board_shape.exterior.coords)
ax.add_patch(MplPolygon(outer, facecolor='black', edgecolor='black', linewidth=2))
for hole in board_shape.interiors:
    hole_coords = list(hole.coords)
    ax.add_patch(MplPolygon(hole_coords, facecolor='white', edgecolor='black'))

plt.show()


for step in range(len(solution)):
    fig, ax = plt.subplots()
    ax.set_aspect('equal')
    ax.set_xlim(minx - 1, maxx + 1)
    ax.set_ylim(miny - 1, maxy + 1)
    ax.set_xticks(range(int(minx) - 1, int(maxx) + 2))
    ax.set_yticks(range(int(miny) - 1, int(maxy) + 2))
    ax.grid(True)
    plt.title(f"Tetromino Puzzle - Step {step + 1}")

    # Draw puzzle board
    outer = list(board_shape.exterior.coords)
    ax.add_patch(MplPolygon(outer, facecolor='black', edgecolor='black', linewidth=2))
    for hole in board_shape.interiors:
        hole_coords = list(hole.coords)
        ax.add_patch(MplPolygon(hole_coords, facecolor='white', edgecolor='black'))

    # Draw all tetrominoes up to current step (including current)
    for i in range(step + 1):
        tetromino_id, rotation, tx, ty = solution[i]
        base_shape = tetrominoes[tetromino_id]["shape"]
        color = tetrominoes[tetromino_id]["color"]

        transformed = rotate(base_shape, rotation, origin=(0, 0))
        transformed = translate(transformed, tx, ty)

        patch = MplPolygon(list(transformed.exterior.coords), facecolor=color, edgecolor='black')
        ax.add_patch(patch)

    plt.show()

