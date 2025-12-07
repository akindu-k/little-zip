import pygame
import sys

# Initialize Pygame and set up the display
pygame.init()
cell_size = 100
cols, rows = 5, 5
width, height = cell_size * cols, cell_size * rows
screen = pygame.display.set_mode((width, height))

pygame.display.set_caption("Zip Puzzle Game")
clock = pygame.time.Clock()
print(type(screen))
print(type(clock))

# Hardcoded level grid: 0 = empty, 1–10 are clue numbers
level = [
    [ 1,  0,  0,  0,  7],
    [ 0,  0,  0,  6,  0],
    [ 0,  3,  4,  0,  8],
    [ 2,  0,  0,  0,  9],
    [ 0,  0,  0,  5, 10]
]

# Track which cells have been visited
visited = [[False] * cols for _ in range(rows)]
path_cells = []   # List of (col, row) tuples for the current path
error_cells = []  # Cells where invalid moves were attempted
path_active = False  # True while the player is dragging to draw
next_number = 2      # Next number we expect after starting at 1

# Colors and font
bg_color = (255, 255, 255)
grid_color = (0, 0, 0)
path_color = (0, 200, 0)      # green for correct path segments
error_color = (200, 0, 0)     # red highlight for invalid moves
text_color = (0, 0, 0)
font = pygame.font.SysFont(None, 40)

def draw_grid():
    """Draw the grid cells, highlights, and numbers."""
    screen.fill(bg_color)
    for row in range(rows):
        for col in range(cols):
            x, y = col * cell_size, row * cell_size
            rect = pygame.Rect(x, y, cell_size, cell_size)
            # Highlight visited path cells in green background
            if (col, row) in path_cells:
                pygame.draw.rect(screen, (220, 255, 220), rect)
            # Highlight error cells in red background
            if (col, row) in error_cells:
                pygame.draw.rect(screen, (255, 220, 220), rect)
            # Draw cell border
            pygame.draw.rect(screen, grid_color, rect, 1)
            # Draw clue number if present
            num = level[row][col]
            if num != 0:
                text = font.render(str(num), True, text_color)
                text_rect = text.get_rect(center=(x + cell_size/2, y + cell_size/2))
                screen.blit(text, text_rect)

def draw_path():
    """Draw line segments connecting the centers of visited cells."""
    if len(path_cells) > 1:
        points = []
        for (col, row) in path_cells:
            cx = col * cell_size + cell_size // 2
            cy = row * cell_size + cell_size // 2
            points.append((cx, cy))
        # Draw continuous line through all visited points:contentReference[oaicite:9]{index=9}
        pygame.draw.lines(screen, path_color, False, points, 5)

# Main game loop
running = True
while running:
    for event in pygame.event.get():
        # Exit on window close
        if event.type == pygame.QUIT:
            running = False

        # Start or continue the path on mouse events
        elif event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
            mx, my = pygame.mouse.get_pos()
            col, row = mx // cell_size, my // cell_size
            # If not yet drawing, require clicking on '1' to start
            if not path_active:
                if 0 <= col < cols and 0 <= row < rows and level[row][col] == 1:
                    path_cells = [(col, row)]
                    visited[row][col] = True
                    path_active = True
                    next_number = 2
                    error_cells.clear()
        elif event.type == pygame.MOUSEMOTION and path_active:
            mx, my = pygame.mouse.get_pos()
            col, row = mx // cell_size, my // cell_size
            if 0 <= col < cols and 0 <= row < rows:
                last_col, last_row = path_cells[-1]
                print("last_col", type(last_col))
                # If moved to a new adjacent cell
                if (col, row) != (last_col, last_row):
                    # Check orthogonal adjacency (no diagonals)
                    if abs(col - last_col) + abs(row - last_row) == 1:
                        if not visited[row][col]:
                            cell_val = level[row][col]
                            print("col",type(col))
                            # Allow move if empty or the next correct number
                            if cell_val == 0 or cell_val == next_number:
                                path_cells.append((col, row))
                                visited[row][col] = True
                                if cell_val == next_number:
                                    next_number += 1
                            else:
                                # Wrong number (skipped or out of order)
                                error_cells.append((col, row))
                        else:
                            # Already visited cell
                            error_cells.append((col, row))
                    else:
                        # Not adjacent (invalid move)
                        error_cells.append((col, row))

        # Stop drawing on mouse release
        elif event.type == pygame.MOUSEBUTTONUP and event.button == 1:
            path_active = False

    # Render everything
    draw_grid()
    draw_path()
    pygame.display.flip()
    clock.tick(30)


pygame.quit()
sys.exit()
