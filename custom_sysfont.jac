import pygame;
import os;
with entry {
    pygame.font.<>init();
}
glob FONT_FOLDER = 'fonts';
"""
    Loads a font from the project's local fonts folder.
    Example: load_font("8bitoperator_jve", 32)
    """
def load_font(
    font_name: str, size: int, bold: Any = False, italic: Any = False
) -> object {
    font_path = os.path.join(FONT_FOLDER, (font_name + '.ttf'));
    if not os.path.exists(font_path) {
        raise FileNotFoundError(f"Font file not found: {font_path}") ;
    }
    font = pygame.font.Font(font_path, size);
    font.set_bold(bold);
    font.set_italic(italic);
    return font;
}

"""
    Custom replacement for pygame.font.SysFont.
    Looks only inside /fonts folder.
    """
def SysFont(name: str, size: int, bold: Any = False, italic: Any = False) -> object {
    return load_font(name, size, bold, italic);
}