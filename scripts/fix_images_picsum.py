#!/usr/bin/env python3
"""
Script para actualizar las URLs de imágenes usando Picsum Photos (más confiable que Unsplash)
"""

import json
import hashlib

def get_picsum_image(seed_text):
    """Obtiene una URL de imagen de Picsum Photos con seed para consistencia"""
    # Usar hash del texto como seed para obtener siempre la misma imagen
    seed_hash = int(hashlib.md5(seed_text.encode()).hexdigest()[:8], 16)
    # Picsum usa un rango de ~1000 imágenes, usamos módulo para no salir del rango
    image_id = (seed_hash % 1000) + 1
    url = f"https://picsum.photos/id/{image_id}/800/600"
    return url


def main():
    """Actualiza las imágenes en el JSON a URLs de Picsum"""

    print("="*70)
    print("🖼️  ACTUALIZANDO IMÁGENES A PICSUM PHOTOS")
    print("="*70)

    # Leer JSON original
    json_path = "/Users/alejandra/escape_room_application/assets/escape_rooms_completo.json"

    with open(json_path, 'r', encoding='utf-8') as f:
        escape_rooms = json.load(f)

    print(f"📊 {len(escape_rooms)} escape rooms encontrados\n")

    # Actualizar imágenes
    updated = 0

    for idx, room in enumerate(escape_rooms, 1):
        nombre = room.get('nombre', room.get('text', ''))

        # Generar URL de imagen usando el nombre como seed para consistencia
        seed = f"{nombre}"
        imagen_url = get_picsum_image(seed)
        room['imagenUrl'] = imagen_url

        updated += 1

        if idx % 100 == 0:
            print(f"[{idx}/{len(escape_rooms)}] Procesados...")

    # Guardar JSON actualizado
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(escape_rooms, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ {updated} imágenes actualizadas a Picsum Photos")
    print(f"{'='*70}")
    print(f"\n📱 Las imágenes de Picsum son más confiables y se cargarán correctamente.")


if __name__ == "__main__":
    main()
