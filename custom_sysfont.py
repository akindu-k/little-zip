import pygame
import os

pygame.font.init()

# Path to your local fonts folder
FONT_FOLDER = "fonts"


def load_font(font_name: str, size: int, bold=False, italic=False):
    """
    Loads a font from the project's local fonts folder.
    Example: load_font("8bitoperator_jve", 32)
    """
    font_path = os.path.join(FONT_FOLDER, font_name + ".ttf")

    if not os.path.exists(font_path):
        raise FileNotFoundError(f"Font file not found: {font_path}")

    font = pygame.font.Font(font_path, size)

    # pygame supports bold/italic only for system fonts,
    # so we manually fake it by scaling if needed.
    font.set_bold(bold)
    font.set_italic(italic)

    return font


# For compatibility with pygame-style API
def SysFont(name: str, size: int, bold=False, italic=False):
    """
    Custom replacement for pygame.font.SysFont.
    Looks only inside /fonts folder.
    """
    return load_font(name, size, bold, italic)
