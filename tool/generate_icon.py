from PIL import Image, ImageDraw

SIZE = 1024

def draw_core(canvas: Image.Image, background: tuple[int, int, int, int]) -> None:
    d = ImageDraw.Draw(canvas, 'RGBA')
    d.rectangle((0, 0, SIZE, SIZE), fill=background)

    # Artwork fills roughly 85% of the canvas with ~10% safe margin.
    outer = 100

    # Crescent moon.
    d.ellipse((outer + 160, outer + 120, outer + 540, outer + 500), fill=(240, 210, 160, 255))
    d.ellipse((outer + 240, outer + 120, outer + 620, outer + 500), fill=background)

    # Stars.
    star_color = (112, 91, 110, 255)
    for x, y, r in [(outer + 640, outer + 180, 24), (outer + 700, outer + 250, 15), (outer + 610, outer + 260, 12)]:
        d.polygon(
            [
                (x, y - r),
                (x + r // 3, y - r // 3),
                (x + r, y),
                (x + r // 3, y + r // 3),
                (x, y + r),
                (x - r // 3, y + r // 3),
                (x - r, y),
                (x - r // 3, y - r // 3),
            ],
            fill=star_color,
        )

    # Colored base shapes.
    d.rounded_rectangle((outer + 110, outer + 460, outer + 400, outer + 650), radius=40, fill=(166, 206, 208, 255))
    d.rounded_rectangle((outer + 430, outer + 460, outer + 720, outer + 650), radius=40, fill=(213, 163, 146, 255))
    d.rectangle((outer + 400, outer + 460, outer + 430, outer + 650), fill=background)

    # Heart shape.
    heart_color = (213, 163, 146, 255)
    d.pieslice((outer + 310, outer + 315, outer + 430, outer + 435), 180, 360, fill=heart_color)
    d.pieslice((outer + 410, outer + 315, outer + 530, outer + 435), 180, 360, fill=heart_color)
    d.polygon([(outer + 310, outer + 375), (outer + 530, outer + 375), (outer + 420, outer + 520)], fill=heart_color)


base = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw_core(base, (243, 236, 241, 255))
base.save('assets/icon/starkind_icon.png')

foreground = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw_core(foreground, (0, 0, 0, 0))
foreground.save('assets/icon/starkind_icon_foreground.png')

print('created assets/icon/starkind_icon.png')
print('created assets/icon/starkind_icon_foreground.png')
