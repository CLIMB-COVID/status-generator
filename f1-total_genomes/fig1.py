from PIL import Image, ImageFont, ImageDraw, ImageColor
import sys

SAMPLE_COUNT = sys.argv[1]

# Setup slide
SLIDE_W = 1200
SLIDE_H = 675
slide = Image.new("RGB", (SLIDE_W, SLIDE_H), "white")

# Dump graph
graph = Image.open('dat/fig1.png', 'r')
climb_logo = Image.open('assets/public/climb-covid-patch.png', 'r')
cog_logo   = Image.open('assets/public/cog-uk.png', 'r')

graph.thumbnail((SLIDE_W, SLIDE_H), Image.ANTIALIAS)
offset = (0, SLIDE_H - graph.height)
slide.paste(graph, offset)

# Logos
MARGIN = 15
logo_max = (125, 125)
climb_logo.thumbnail(logo_max, Image.ANTIALIAS)
slide.paste(climb_logo, (MARGIN, MARGIN), climb_logo)

logo_max = (250, 125)
cog_logo.thumbnail(logo_max, Image.ANTIALIAS)
slide.paste(cog_logo, (SLIDE_W - (cog_logo.width + MARGIN), MARGIN + 25), cog_logo)

# Text
climb_covid_colour = ImageColor.getrgb("#8B7968")
extra_push = 3

draw = ImageDraw.Draw(slide)
font = ImageFont.truetype("assets/private/Fonts/bahnschrift.ttf", 80)
draw.text((MARGIN+climb_logo.width+MARGIN, MARGIN+extra_push), "{:,}".format(int(SAMPLE_COUNT)), climb_covid_colour, font=font)

font = ImageFont.truetype("assets/private/Fonts/bahnschrift.ttf", 30)
draw.text((MARGIN+climb_logo.width+MARGIN+1, MARGIN+extra_push+70),"SARS-CoV-2 genomes processed", climb_covid_colour, font=font)

font = ImageFont.truetype("assets/private/Fonts/bahnschrift.ttf", 20)
draw.text((MARGIN+climb_logo.width+MARGIN+1, MARGIN+extra_push+97),"by CLIMB-COVID since March 2020", climb_covid_colour, font=font)


# Save
slide.save("build/graphs/fig1.assembled.png")
