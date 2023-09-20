use zellij_tile::prelude::{InputMode, Palette, PaletteColor, ThemeHue};

pub const LIGHTER_GRAY: PaletteColor = PaletteColor::Rgb((62, 68, 82));
pub const DARKER_GRAY: PaletteColor = PaletteColor::Rgb((44, 50, 60));

pub struct ModeColor {
    pub fg: PaletteColor,
    pub bg: PaletteColor,
}

impl ModeColor {
    pub fn new(mode: InputMode, palette: Palette) -> Self {
        let fg = match palette.theme_hue {
            ThemeHue::Dark => palette.black,
            ThemeHue::Light => palette.white,
        };

        let bg = match mode {
            InputMode::Locked => palette.cyan,
            InputMode::Normal => palette.green,
            _ => palette.orange,
        };

        Self { fg, bg }
    }
}
