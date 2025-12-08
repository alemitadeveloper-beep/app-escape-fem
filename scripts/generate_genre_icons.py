#!/usr/bin/env python3
"""
Script para generar íconos PNG simples para los géneros de escape rooms.
Usa PIL/Pillow para crear imágenes vectoriales simples.
"""

from PIL import Image, ImageDraw
import os

# Tamaño de los íconos
SIZE = 128
OUTPUT_DIR = "../assets/genres"

# Crear directorio si no existe
os.makedirs(OUTPUT_DIR, exist_ok=True)

def create_icon(filename, draw_func):
    """Crea un ícono PNG con transparencia"""
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_func(draw, SIZE)
    img.save(os.path.join(OUTPUT_DIR, filename))
    print(f"✓ Creado: {filename}")

# Funciones de dibujo para cada género
def draw_terror(draw, s):
    # Luna creciente
    draw.ellipse([s*0.3, s*0.2, s*0.7, s*0.6], fill='black')
    draw.ellipse([s*0.35, s*0.15, s*0.75, s*0.55], fill=(0,0,0,0))

def draw_aventura(draw, s):
    # Montañas
    draw.polygon([
        (s*0.1, s*0.8), (s*0.4, s*0.3), (s*0.6, s*0.6),
        (s*0.9, s*0.2), (s*0.9, s*0.8)
    ], fill='black')

def draw_investigacion(draw, s):
    # Lupa
    draw.ellipse([s*0.2, s*0.2, s*0.6, s*0.6], outline='black', width=6, fill=(0,0,0,0))
    draw.line([s*0.55, s*0.55, s*0.8, s*0.8], fill='black', width=8)

def draw_accion(draw, s):
    # Estrella de explosión
    center = s/2
    for i in range(8):
        angle = i * 45
        import math
        x = center + math.cos(math.radians(angle)) * s*0.4
        y = center + math.sin(math.radians(angle)) * s*0.4
        draw.line([center, center, x, y], fill='black', width=8)

def draw_fantasia(draw, s):
    # Estrella mágica
    points = []
    import math
    for i in range(5):
        angle = i * 144 - 90
        x = s/2 + math.cos(math.radians(angle)) * s*0.4
        y = s/2 + math.sin(math.radians(angle)) * s*0.4
        points.append((x, y))
    draw.polygon(points, fill='black')

def draw_misterio(draw, s):
    # Huella digital
    for i in range(4):
        y = s*0.3 + i*s*0.12
        draw.arc([s*0.3, y, s*0.7, y+s*0.1], 0, 180, fill='black', width=5)

def draw_thriller(draw, s):
    # Rayo
    draw.polygon([
        (s*0.5, s*0.1), (s*0.4, s*0.5), (s*0.55, s*0.5),
        (s*0.3, s*0.9), (s*0.6, s*0.55), (s*0.45, s*0.55)
    ], fill='black')

def draw_robo(draw, s):
    # Bolsa de dinero
    draw.ellipse([s*0.25, s*0.3, s*0.75, s*0.8], fill='black')
    draw.rectangle([s*0.4, s*0.2, s*0.6, s*0.35], fill='black')
    draw.text((s*0.43, s*0.45), "$", fill='white', font=None)

def draw_scifi(draw, s):
    # Cohete
    draw.polygon([(s*0.5, s*0.2), (s*0.4, s*0.6), (s*0.6, s*0.6)], fill='black')
    draw.rectangle([s*0.4, s*0.6, s*0.6, s*0.8], fill='black')
    draw.polygon([(s*0.3, s*0.8), (s*0.4, s*0.8), (s*0.4, s*0.9)], fill='black')
    draw.polygon([(s*0.7, s*0.8), (s*0.6, s*0.8), (s*0.6, s*0.9)], fill='black')

def draw_medieval(draw, s):
    # Castillo
    draw.rectangle([s*0.2, s*0.4, s*0.8, s*0.8], fill='black')
    draw.rectangle([s*0.25, s*0.3, s*0.4, s*0.4], fill='black')
    draw.rectangle([s*0.6, s*0.3, s*0.75, s*0.4], fill='black')

def draw_piratas(draw, s):
    # Bandera pirata
    draw.rectangle([s*0.25, s*0.2, s*0.3, s*0.8], fill='black')
    draw.polygon([(s*0.3, s*0.2), (s*0.8, s*0.35), (s*0.3, s*0.5)], fill='black')

def draw_submarino(draw, s):
    # Ola
    import math
    for x in range(int(s*0.1), int(s*0.9), 5):
        y = s/2 + math.sin(x/10) * s*0.1
        draw.ellipse([x, y, x+10, y+10], fill='black')

def draw_virtual(draw, s):
    # Joystick
    draw.rounded_rectangle([s*0.2, s*0.4, s*0.8, s*0.8], radius=10, fill='black')
    draw.ellipse([s*0.3, s*0.5, s*0.45, s*0.65], fill='white')
    draw.ellipse([s*0.55, s*0.5, s*0.7, s*0.65], fill='white')

def draw_simple_circle(draw, s):
    # Círculo simple para géneros sin diseño específico
    draw.ellipse([s*0.25, s*0.25, s*0.75, s*0.75], fill='black')

# Generar todos los íconos
genres_to_create = {
    'terror.png': draw_terror,
    'aventura.png': draw_aventura,
    'investigacion.png': draw_investigacion,
    'accion.png': draw_accion,
    'fantasia.png': draw_fantasia,
    'misterio.png': draw_misterio,
    'thriller.png': draw_thriller,
    'robo.png': draw_robo,
    'scifi.png': draw_scifi,
    'medieval.png': draw_medieval,
    'piratas.png': draw_piratas,
    'submarino.png': draw_submarino,
    'virtual.png': draw_virtual,
    # Usar diseños simples para los demás
    'humor.png': draw_simple_circle,
    'sobrenatural.png': draw_simple_circle,
    'familiar.png': draw_simple_circle,
    'religioso.png': draw_simple_circle,
    'vampiros.png': draw_simple_circle,
    'historico.png': draw_simple_circle,
    'zombies.png': draw_simple_circle,
    'magia.png': draw_simple_circle,
    'espionaje.png': draw_simple_circle,
    'militar.png': draw_simple_circle,
    'cyberpunk.png': draw_simple_circle,
    'apocalipsis.png': draw_simple_circle,
    'arqueologia.png': draw_simple_circle,
    'egipto.png': draw_simple_circle,
    'supervivencia.png': draw_simple_circle,
    'conspiracion.png': draw_simple_circle,
    'miedo.png': draw_simple_circle,
    'prision.png': draw_simple_circle,
    'fantasmas.png': draw_simple_circle,
    'adulto.png': draw_simple_circle,
}

print("Generando íconos...")
for filename, draw_func in genres_to_create.items():
    create_icon(filename, draw_func)

print(f"\n✅ {len(genres_to_create)} íconos creados en {OUTPUT_DIR}/")
