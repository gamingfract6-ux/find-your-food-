from PIL import Image, ImageDraw
import os

# Create directory if not exists
os.makedirs('../frontend/assets/icons', exist_ok=True)

# Settings
size = (1024, 1024)
start_color = (16, 185, 129)  # Emerald #10B981
end_color = (6, 182, 212)     # Cyan #06B6D4

# Create image
img = Image.new('RGB', size)
draw = ImageDraw.Draw(img)

# Gradient
for y in range(size[1]):
    r = int(start_color[0] + (end_color[0] - start_color[0]) * y / size[1])
    g = int(start_color[1] + (end_color[1] - start_color[1]) * y / size[1])
    b = int(start_color[2] + (end_color[2] - start_color[2]) * y / size[1])
    draw.line([(0, y), (size[0], y)], fill=(r, g, b))

# Draw a fork-like shape in center
center = (512, 512)

# Handle
draw.rectangle([center[0]-20, center[1]+50, center[0]+20, center[1]+250], fill='white')
# Base of fork
box = [center[0]-100, center[1]-100, center[0]+100, center[1]+100]
draw.arc(box, 0, 180, fill='white', width=40)
# Tines
draw.rectangle([center[0]-100, center[1]-150, center[0]-60, center[1]], fill='white')
draw.rectangle([center[0]-20, center[1]-150, center[0]+20, center[1]], fill='white')
draw.rectangle([center[0]+60, center[1]-150, center[0]+100, center[1]], fill='white')

img.save('../frontend/assets/icons/app_icon.png')
print("Icon generated")
