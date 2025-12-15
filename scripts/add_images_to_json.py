#!/usr/bin/env python3
"""
Script para agregar URLs de imágenes al archivo JSON de escape rooms
"""

import json
import re

def get_unsplash_image(query):
    """Obtiene una URL de imagen de Unsplash basada en la búsqueda"""
    query_clean = re.sub(r'[^\w\s]', '', query.lower())
    search_terms = f"escape,room,{query_clean}"
    url = f"https://source.unsplash.com/800x600/?{search_terms.replace(' ', ',')}"
    return url


def generate_image_for_room(nombre, genero):
    """Genera una URL de imagen apropiada para un escape room"""
    # Mapeo de géneros/temáticas a términos de búsqueda
    genre_mapping = {
        'terror': 'horror,haunted,scary,dark',
        'misterio': 'mystery,detective,clues,investigation',
        'investigación': 'detective,investigation,mystery',
        'aventura': 'adventure,treasure,exploration',
        'fantasía': 'fantasy,magic,mystical',
        'ciencia ficción': 'scifi,futuristic,space,technology',
        'zombies': 'zombie,apocalypse,undead',
        'medieval': 'medieval,castle,knights',
        'egipto': 'egypt,pharaoh,pyramid,ancient',
        'magia': 'magic,wizard,spell,enchanted',
        'histórico': 'historical,vintage,antique',
        'prison': 'prison,jail,cell,escape',
        'bunker': 'bunker,military,underground',
        'space': 'space,spaceship,astronaut',
        'detective': 'detective,noir,investigation',
        'pirata': 'pirate,ship,treasure,ocean',
        'naval': 'submarine,navy,ocean,sea'
    }

    # Buscar en el género
    search_query = "escape,room"

    if genero:
        genero_lower = genero.lower()
        for key, value in genre_mapping.items():
            if key in genero_lower:
                search_query = value.split(',')[0]  # Primer término
                break

    # Buscar en el nombre
    nombre_lower = nombre.lower()
    for key, value in genre_mapping.items():
        if key in nombre_lower:
            search_query = value.split(',')[0]
            break

    # Palabras clave específicas en el nombre
    keywords = {
        'zombie': 'zombie', 'prison': 'prison', 'bunker': 'bunker',
        'space': 'space', 'detective': 'detective', 'sherlock': 'detective',
        'pirata': 'pirate', 'treasure': 'treasure', 'egypt': 'egypt',
        'templo': 'temple', 'castle': 'castle', 'mansion': 'mansion',
        'lab': 'laboratory', 'hospital': 'hospital', 'orfanato': 'asylum',
        'circus': 'circus', 'magic': 'magic', 'witch': 'witch',
        'magia': 'magic', 'vampiro': 'vampire', 'faraon': 'egypt',
        'tumba': 'tomb', 'cripta': 'crypt', 'embrujada': 'haunted',
        'submarino': 'submarine', 'asesino': 'killer', 'maldita': 'cursed'
    }

    for keyword, search_term in keywords.items():
        if keyword in nombre_lower:
            search_query = search_term
            break

    # Generar URL de Unsplash
    return get_unsplash_image(search_query)


def main():
    """Agrega imágenes al archivo JSON de escape rooms"""

    print("="*70)
    print("🖼️  AGREGANDO IMÁGENES AL JSON DE ESCAPE ROOMS")
    print("="*70)

    # Leer JSON original
    json_path = "/Users/alejandra/escape_room_application/assets/escape_rooms_completo.json"

    with open(json_path, 'r', encoding='utf-8') as f:
        escape_rooms = json.load(f)

    print(f"📊 {len(escape_rooms)} escape rooms encontrados\n")

    # Agregar imágenes
    updated = 0

    for idx, room in enumerate(escape_rooms, 1):
        nombre = room.get('nombre', room.get('text', ''))
        genero = room.get('genero', '')

        # Si ya tiene imagen, saltar
        if room.get('imagenUrl'):
            continue

        # Generar URL de imagen
        imagen_url = generate_image_for_room(nombre, genero)
        room['imagenUrl'] = imagen_url

        updated += 1

        if idx % 100 == 0:
            print(f"[{idx}/{len(escape_rooms)}] Procesados...")

    # Guardar JSON actualizado
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(escape_rooms, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ {updated} imágenes agregadas al JSON")
    print(f"{'='*70}")
    print(f"\n📱 Reinicia la app en el simulador para ver los cambios.")


if __name__ == "__main__":
    main()
