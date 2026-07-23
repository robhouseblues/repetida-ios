#!/usr/bin/env python3
"""Compose App Store screenshots — APPSTORE-02 narrative layout."""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "Marketing" / "AppStore" / "Screenshots"

ASSET_DIRS = [
    ROOT / "Marketing" / "AppStore" / "Captures",
]

APP_ICON_CANDIDATES = [
    "AppIcon-1024.png",
    "AppMark.png",
]
APP_MARK = ROOT / "Repetida" / "Assets.xcassets" / "AppMark.imageset" / "AppMark.png"

# App Store 6.7" display — must be exactly 1284×2778 (not 1290×2796)
CANVAS_W = 1284
CANVAS_H = 2778

BG_TOP = (8, 8, 10)
BG_BOTTOM = (3, 3, 4)
TITLE = (248, 242, 224)
SUBTITLE = (148, 148, 154)
GOLD = (237, 184, 54)
GREEN = (29, 185, 84)
SURFACE = (20, 20, 24)

FONT_DISPLAY_BOLD = "/Library/Fonts/SF-Pro-Display-Bold.otf"
FONT_TEXT_MEDIUM = "/Library/Fonts/SF-Pro-Text-Medium.otf"
FONT_TEXT_SEMIBOLD = "/Library/Fonts/SF-Pro-Text-Semibold.otf"

# System SF Pro variable font, used when the standalone SF Pro files are absent.
FONT_SYSTEM_VARIABLE = "/System/Library/Fonts/SFNS.ttf"
FONT_VARIATION_FALLBACKS = {
    FONT_DISPLAY_BOLD: "Bold",
    FONT_TEXT_MEDIUM: "Medium",
    FONT_TEXT_SEMIBOLD: "Semibold",
}


def load_font(path: str, size: int) -> ImageFont.FreeTypeFont:
    if Path(path).exists():
        return ImageFont.truetype(path, size)
    font = ImageFont.truetype(FONT_SYSTEM_VARIABLE, size)
    font.set_variation_by_name(FONT_VARIATION_FALLBACKS[path])
    return font


class LayoutKind(Enum):
    HERO = "hero"
    PHONE = "phone"
    SHARE = "share"
    CLOSING = "closing"


@dataclass
class Slide:
    output: str
    kind: LayoutKind
    title: str
    subtitle: str = ""
    capture: str | None = None
    stats: str = ""
    cta: str = ""
    headline_align: str = "center"


SLIDES = [
    Slide(
        output="01-hero-dream.png",
        kind=LayoutKind.HERO,
        title="O jeito mais fácil de\ncompletar seu álbum",
        subtitle="Progresso, faltantes e repetidas\nem um só lugar.",
        stats="980 figurinhas  ·  48 seleções  ·  100% offline",
    ),
    Slide(
        output="02-home-progresso.png",
        kind=LayoutKind.PHONE,
        capture="home.png",
        title="Acompanhe seu progresso\nem tempo real",
        subtitle="O jeito mais fácil de completar seu álbum de figurinhas!",
    ),
    Slide(
        output="03-faltando.png",
        kind=LayoutKind.PHONE,
        capture="faltando.png",
        title="Registre todas as suas\nfigurinhas!",
        subtitle="Saiba exatamente o que falta para completar seu álbum.",
        headline_align="left",
    ),
    Slide(
        output="04-selecao-brasil.png",
        kind=LayoutKind.PHONE,
        capture="team-bra.png",
        title="Veja cada seleção\nfigurinha por figurinha",
        subtitle="Acompanhe o progresso, figurinhas faltantes e repetidas.",
    ),
    Slide(
        output="05-repetidas-troca.png",
        kind=LayoutKind.PHONE,
        capture="repetidas.png",
        title="Saiba exatamente o que\nvocê tem para trocar",
        subtitle="Veja suas figurinhas repetidas para trocar",
        headline_align="left",
    ),
    Slide(
        output="06-compartilhar.png",
        kind=LayoutKind.SHARE,
        capture="share-story.png",
        title="Compartilhe suas repetidas\nem segundos",
        subtitle="Compartilhe sua lista em segundos",
    ),
    Slide(
        output="07-baixe-repetida.png",
        kind=LayoutKind.CLOSING,
        title="Pronto para completar\nseu álbum?",
        cta="Baixe Repetida",
    ),
]

CAPTURE_ALIASES: dict[str, list[str]] = {
    "home.png": ["home-screen-10f5374a-e09c-415b-a4f5-9b88e251307c.png"],
    "faltando.png": ["faltando-screen-d7e5653d-69a5-4659-9632-5c6ce795c16d.png"],
    "repetidas.png": ["repetidas-screen-19ac0bc8-819d-462f-a160-66ca0a4c8c51.png"],
    "team-bra.png": ["bra-team-screen-3c133976-0a33-46e9-ac84-433d9c783aa6.png"],
    "share-story.png": [
        "PNG_image-4569-937D-81-0-6c4cbeae-6967-4e3f-add1-1c30035ddd39.png",
        "share-card-story.png",
    ],
}


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def resolve_asset(name: str) -> Path:
    candidates = [name, *(CAPTURE_ALIASES.get(name, []))]
    for directory in ASSET_DIRS:
        for candidate in candidates:
            path = directory / candidate
            if path.exists():
                return path
    raise FileNotFoundError(f"Missing capture '{name}' (tried {candidates})")


def resolve_app_icon() -> Path:
    for directory in ASSET_DIRS:
        for candidate in APP_ICON_CANDIDATES:
            path = directory / candidate
            if path.exists():
                return path
    if APP_MARK.exists():
        return APP_MARK
    raise FileNotFoundError("App icon not found")


def make_background(*, sticker_watermark: bool = False) -> Image.Image:
    base = Image.new("RGB", (CANVAS_W, CANVAS_H))
    draw = ImageDraw.Draw(base)
    for y in range(CANVAS_H):
        t = y / CANVAS_H
        color = (
            lerp(BG_TOP[0], BG_BOTTOM[0], t),
            lerp(BG_TOP[1], BG_BOTTOM[1], t),
            lerp(BG_TOP[2], BG_BOTTOM[2], t),
        )
        draw.line([(0, y), (CANVAS_W, y)], fill=color)

    overlay = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    o_draw = ImageDraw.Draw(overlay)

    spacing = 56
    for y in range(0, CANVAS_H, spacing):
        o_draw.line([(0, y), (CANVAS_W, y)], fill=(0, 122, 50, 10), width=1)

    # Subtle vignette — dark edges, no green blob
    o_draw.ellipse(
        (CANVAS_W // 2 - 700, CANVAS_H // 2 - 900, CANVAS_W // 2 + 700, CANVAS_H // 2 + 900),
        fill=(0, 0, 0, 35),
    )

    if sticker_watermark:
        draw_sticker_watermark(o_draw)

    return Image.alpha_composite(base.convert("RGBA"), overlay).convert("RGB")


def draw_sticker_watermark(draw: ImageDraw.ImageDraw) -> None:
    """Faint Panini-style card silhouettes."""
    cards = [
        (180, 420, 300, 520, 18),
        (920, 380, 1040, 500, 14),
        (1040, 620, 1160, 740, 12),
        (120, 720, 240, 840, 10),
        (980, 180, 1100, 300, 16),
    ]
    for x1, y1, x2, y2, alpha in cards:
        draw.rounded_rectangle(
            (x1, y1, x2, y2),
            radius=10,
            fill=(237, 184, 54, alpha),
            outline=(237, 184, 54, alpha + 8),
            width=1,
        )


def wrap_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.FreeTypeFont,
    max_width: int,
) -> str:
    lines: list[str] = []
    for paragraph in text.split("\n"):
        words = paragraph.split()
        if not words:
            lines.append("")
            continue
        current = words[0]
        for word in words[1:]:
            candidate = f"{current} {word}"
            if draw.textlength(candidate, font=font) <= max_width:
                current = candidate
            else:
                lines.append(current)
                current = word
        lines.append(current)
    return "\n".join(lines)


def draw_multiline(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.FreeTypeFont,
    *,
    x: int,
    y: int,
    fill: tuple[int, int, int],
    align: str = "center",
    line_spacing: float = 1.06,
    max_width: int | None = None,
) -> int:
    if max_width:
        text = wrap_text(draw, text, font, max_width)

    lines = text.split("\n")
    bbox = font.getbbox("Ay")
    line_height = int((bbox[3] - bbox[1]) * line_spacing)
    cursor_y = y
    for line in lines:
        width = draw.textlength(line, font=font)
        if align == "center":
            line_x = x - width // 2
        elif align == "right":
            line_x = x - width
        else:
            line_x = x
        draw.text((line_x, cursor_y), line, font=font, fill=fill)
        cursor_y += line_height
    return cursor_y


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def paste_image(
    canvas: Image.Image,
    image: Image.Image,
    *,
    x: int,
    y: int,
    radius: int = 0,
    shadow: bool = True,
) -> None:
    layer = image.convert("RGBA")
    if radius > 0:
        mask = rounded_mask(layer.size, radius)
        layer.putalpha(mask)

    canvas_rgba = canvas.convert("RGBA")
    if shadow:
        shadow_layer = Image.new("RGBA", (layer.width + 60, layer.height + 60), (0, 0, 0, 0))
        ImageDraw.Draw(shadow_layer).rounded_rectangle(
            (24, 24, layer.width + 24, layer.height + 24),
            radius=max(radius, 20),
            fill=(0, 0, 0, 120),
        )
        shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(22))
        canvas_rgba.alpha_composite(shadow_layer, (x - 12, y - 6))

    canvas_rgba.alpha_composite(layer, (x, y))
    canvas.paste(canvas_rgba.convert("RGB"))


def compose_hero(slide: Slide) -> Image.Image:
    canvas = make_background(sticker_watermark=True)
    draw = ImageDraw.Draw(canvas)

    icon_path = resolve_app_icon()
    icon = Image.open(icon_path).convert("RGBA")
    icon_size = 220
    icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    paste_image(canvas, icon, x=(CANVAS_W - icon_size) // 2, y=340, radius=48, shadow=True)

    title_font = load_font(FONT_DISPLAY_BOLD, 68)
    subtitle_font = load_font(FONT_TEXT_MEDIUM, 38)
    stats_font = load_font(FONT_TEXT_SEMIBOLD, 30)

    title_bottom = draw_multiline(
        draw,
        slide.title,
        title_font,
        x=CANVAS_W // 2,
        y=620,
        fill=TITLE,
        max_width=CANVAS_W - 140,
    )

    subtitle_bottom = draw_multiline(
        draw,
        slide.subtitle,
        subtitle_font,
        x=CANVAS_W // 2,
        y=title_bottom + 44,
        fill=SUBTITLE,
        line_spacing=1.14,
        max_width=CANVAS_W - 160,
    )

    draw_multiline(
        draw,
        slide.stats,
        stats_font,
        x=CANVAS_W // 2,
        y=subtitle_bottom + 56,
        fill=GOLD,
        line_spacing=1.1,
    )

    # Decorative sticker row
    row_y = CANVAS_H - 520
    card_w, card_h, gap = 200, 260, 28
    total_w = card_w * 3 + gap * 2
    start_x = (CANVAS_W - total_w) // 2
    labels = ["FWC", "BRA", "ARG"]
    for index, label in enumerate(labels):
        x1 = start_x + index * (card_w + gap)
        draw.rounded_rectangle(
            (x1, row_y, x1 + card_w, row_y + card_h),
            radius=16,
            fill=(*SURFACE, 255),
            outline=(*GOLD, 80),
            width=2,
        )
        code_font = load_font(FONT_TEXT_SEMIBOLD, 34)
        name_font = load_font(FONT_TEXT_MEDIUM, 22)
        draw.text((x1 + 20, row_y + 24), label + "1", font=code_font, fill=GOLD)
        draw.text((x1 + 20, row_y + 72), "Emblem", font=name_font, fill=SUBTITLE)

    return canvas


def compose_closing(slide: Slide) -> Image.Image:
    canvas = make_background(sticker_watermark=True)
    draw = ImageDraw.Draw(canvas)

    icon_path = resolve_app_icon()
    icon = Image.open(icon_path).convert("RGBA")
    icon_size = 260
    icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    paste_image(canvas, icon, x=(CANVAS_W - icon_size) // 2, y=720, radius=56, shadow=True)

    title_font = load_font(FONT_DISPLAY_BOLD, 72)
    draw_multiline(
        draw,
        slide.title,
        title_font,
        x=CANVAS_W // 2,
        y=1080,
        fill=TITLE,
        max_width=CANVAS_W - 120,
    )

    cta_font = load_font(FONT_TEXT_SEMIBOLD, 34)
    cta = slide.cta.upper()
    padding_x, padding_y = 56, 22
    text_w = draw.textlength(cta, font=cta_font)
    pill_w = int(text_w + padding_x * 2)
    pill_h = int(cta_font.size + padding_y * 2)
    pill_x = (CANVAS_W - pill_w) // 2
    pill_y = 1380
    draw.rounded_rectangle(
        (pill_x, pill_y, pill_x + pill_w, pill_y + pill_h),
        radius=pill_h // 2,
        fill=(0, 107, 40, 255),
        outline=GOLD,
        width=2,
    )
    draw.text((pill_x + padding_x, pill_y + padding_y - 2), cta, font=cta_font, fill=TITLE)

    brand_font = load_font(FONT_TEXT_MEDIUM, 28)
    draw.text((CANVAS_W // 2 - draw.textlength("Repetida", font=brand_font) // 2, 1560), "Repetida", font=brand_font, fill=GOLD)

    return canvas


def draw_phone_headline(canvas: Image.Image, slide: Slide) -> int:
    draw = ImageDraw.Draw(canvas)
    margin = 72 if slide.headline_align == "left" else CANVAS_W // 2
    anchor = slide.headline_align

    title_font = load_font(FONT_DISPLAY_BOLD, 62)
    subtitle_font = load_font(FONT_TEXT_MEDIUM, 34)

    title_bottom = draw_multiline(
        draw,
        slide.title,
        title_font,
        x=margin,
        y=120,
        fill=TITLE,
        align=anchor,
        max_width=CANVAS_W - 144,
    )
    if slide.subtitle:
        draw_multiline(
            draw,
            slide.subtitle,
            subtitle_font,
            x=margin,
            y=title_bottom + 40,
            fill=SUBTITLE,
            align=anchor,
            max_width=CANVAS_W - 160,
        )

    return title_bottom


def compose_phone(slide: Slide) -> Image.Image:
    canvas = make_background()
    draw_phone_headline(canvas, slide)

    screenshot = Image.open(resolve_asset(slide.capture)).convert("RGB")

    header_space = 340
    bottom_pad = 48
    side_pad = 36
    target_height = int(CANVAS_H * 0.78)
    max_width = CANVAS_W - side_pad * 2

    scale = min(max_width / screenshot.width, target_height / screenshot.height)
    phone_w = int(screenshot.width * scale)
    phone_h = int(screenshot.height * scale)
    phone = screenshot.resize((phone_w, phone_h), Image.Resampling.LANCZOS)

    x = (CANVAS_W - phone_w) // 2
    y = CANVAS_H - phone_h - bottom_pad
    radius = max(32, int(40 * scale))
    paste_image(canvas, phone, x=x, y=y, radius=radius, shadow=True)
    return canvas


def compose_share(slide: Slide) -> Image.Image:
    canvas = make_background()
    draw_phone_headline(canvas, slide)

    card = Image.open(resolve_asset(slide.capture)).convert("RGB")
    header_space = 360
    bottom_pad = 80
    max_h = CANVAS_H - header_space - bottom_pad
    max_w = CANVAS_W - 80

    scale = min(max_w / card.width, max_h / card.height)
    card_w = int(card.width * scale)
    card_h = int(card.height * scale)
    card = card.resize((card_w, card_h), Image.Resampling.LANCZOS)

    x = (CANVAS_W - card_w) // 2
    y = header_space + (max_h - card_h) // 2
    paste_image(canvas, card, x=x, y=y, radius=28, shadow=True)

    draw = ImageDraw.Draw(canvas)
    hint_font = load_font(FONT_TEXT_MEDIUM, 26)
    hint = "📦 Lista pronta para WhatsApp"
    draw.text(
        ((CANVAS_W - draw.textlength(hint, font=hint_font)) // 2, y + card_h + 36),
        hint,
        font=hint_font,
        fill=GOLD,
    )
    return canvas


def compose(slide: Slide) -> Image.Image:
    if slide.kind == LayoutKind.HERO:
        return compose_hero(slide)
    if slide.kind == LayoutKind.CLOSING:
        return compose_closing(slide)
    if slide.kind == LayoutKind.SHARE:
        return compose_share(slide)
    return compose_phone(slide)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (ROOT / "Marketing" / "AppStore" / "Captures").mkdir(parents=True, exist_ok=True)

    for slide in SLIDES:
        image = compose(slide)
        out_path = OUT_DIR / slide.output
        image.save(out_path, format="PNG", optimize=True)
        print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
