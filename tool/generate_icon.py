from PIL import Image, ImageDraw

SIZE = 1024
img = Image.new('RGBA', (SIZE, SIZE), (247, 241, 245, 255))
d = ImageDraw.Draw(img, 'RGBA')

# Soft pastel atmosphere.
d.ellipse((-120, -120, 780, 780), fill=(255, 229, 235, 160))
d.ellipse((320, 260, 1100, 1040), fill=(222, 239, 248, 180))
d.ellipse((120, 500, 760, 1140), fill=(246, 224, 202, 150))

# Elegant rounded badge.
pad = 130
d.rounded_rectangle(
    (pad, pad, SIZE - pad, SIZE - pad),
    radius=190,
    fill=(255, 252, 251, 255),
    outline=(229, 211, 216, 255),
    width=10,
)

# Crescent moon + stars.
d.ellipse((300, 230, 690, 620), fill=(246, 214, 170, 255))
d.ellipse((375, 230, 740, 620), fill=(255, 252, 251, 255))
star_color = (112, 91, 110, 255)
for x, y, r in [(700, 290, 20), (750, 360, 13), (670, 370, 11)]:
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

# Open kindness card motif.
d.rounded_rectangle((250, 560, 500, 740), radius=36, fill=(186, 220, 220, 255))
d.rounded_rectangle((520, 560, 770, 740), radius=36, fill=(221, 170, 155, 255))
d.polygon([(500, 560), (520, 560), (520, 740), (500, 740)], fill=(245, 233, 236, 255))

# Heart shape.
d.pieslice((430, 430, 550, 550), 180, 360, fill=(221, 170, 155, 255))
d.pieslice((520, 430, 640, 550), 180, 360, fill=(221, 170, 155, 255))
d.polygon([(430, 490), (640, 490), (535, 625)], fill=(221, 170, 155, 255))

img.save('assets/icon/starkind_icon.png')
print('created assets/icon/starkind_icon.png')
