from PIL import Image, ImageDraw, ImageFont

# Configuración técnica
ANCHO = 128
ALTO_CELDA = 16
CANTIDAD_NOMBRES = 11  # Actualizado a 11 espacios

# Lista de nombres (Asegúrate de que tengan 11 elementos)
NOMBRES = ["LEAFEON", "ZERAORA", "VAPOREON", "SANDSLASH", "ODDISH", 
           "LAPRAS", "JOLTEON", "GARCHOMP", "FLAREON", "CHARIZARD",
           "????????"]

# Creamos la imagen en modo "L" (8-bit grayscale)
# Fondo inicializado en 255 (X"FF") para transparencia
imagen = Image.new("L", (ANCHO, ALTO_CELDA * CANTIDAD_NOMBRES), 255)
draw = ImageDraw.Draw(imagen)

try:
    # Carga tu fuente .ttf. Tamaño 10 suele ir bien para 16px de alto
    font = ImageFont.truetype("GB_P_FONT.ttf", 10) 
except:
    print("No se encontró pokemon_gb.ttf, usando fuente por defecto.")
    font = ImageFont.load_default()

for i, nombre in enumerate(NOMBRES):
    y_offset = i * ALTO_CELDA
    
    # Coordenadas para centrar el texto en el bloque de 64x16
    # Puedes ajustar estos valores según cómo se vea tu fuente
    pos_x = 2 
    pos_y = y_offset + 2
    
    # Dibujamos un borde en color 1 (Casi negro)
    # Esto es opcional, si no quieres borde, comenta estas 2 líneas
    for dx, dy in [(-1,0), (1,0), (0,-1), (0,1)]:
        draw.text((pos_x + dx, pos_y + dy), nombre, fill=1, font=font)
    
    # Dibujamos el texto principal en color 254 (X"FE")
    # Es visualmente blanco pero NO activa tu transparencia X"FF"
    draw.text((pos_x, pos_y), nombre, fill=254, font=font)

# Guardar para procesar con tu script .mif
imagen.save("PK_NAMES_TILES.png")

print(f"Imagen generada con {CANTIDAD_NOMBRES} espacios.")
print("Dimensiones: 64x176. Fondo=255, Texto=254.")