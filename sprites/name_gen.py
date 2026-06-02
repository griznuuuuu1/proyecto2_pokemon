from PIL import Image, ImageDraw, ImageFont

# Configuración técnica corregida al estándar que espera la ROM
ANCHO = 128
ALTO_CELDA = 16
CANTIDAD_NOMBRES = 11  

NOMBRES = ["LEAFEON", "ZERAORA", "VAPOREON", "SANDSLASH", "ODDISH", 
           "LAPRAS", "JOLTEON", "GARCHOMP", "FLAREON", "CHARIZARD",
           "????????"]

# Creamos la imagen en modo "L" (8-bit grayscale) con ancho real de 128
imagen = Image.new("L", (ANCHO, ALTO_CELDA * CANTIDAD_NOMBRES), 255)
draw = ImageDraw.Draw(imagen)

try:
    font = ImageFont.truetype("GB_P_FONT.ttf", 10) 
except:
    print("No se encontró GB_P_FONT.ttf, usando fuente por defecto.")
    font = ImageFont.load_default()

for i, nombre in enumerate(NOMBRES):
    y_offset = i * ALTO_CELDA
    
    # Ajustamos pos_x a 8 para que no quede pegado al borde izquierdo de los 128px
    pos_x = 8 
    pos_y = y_offset + 2
    
    # Borde (Color 1 - Negro)
    for dx, dy in [(-1,0), (1,0), (0,-1), (0,1)]:
        draw.text((pos_x + dx, pos_y + dy), nombre, fill=1, font=font)
    
    # Texto principal (Color 0 - Si tu transparencia de la paleta del MIF mapea 255 a transparente)
    draw.text((pos_x, pos_y), nombre, fill=0, font=font)

# Guardar imagen
imagen.save("PK_NAMES_TILES.png")

print(f"Imagen generada con éxito.")
print(f"Dimensiones Reales: {imagen.size[0]}x{imagen.size[1]} (Debe ser 128x176)")