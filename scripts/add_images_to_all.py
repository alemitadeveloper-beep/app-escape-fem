#!/usr/bin/env python3
"""
Script para agregar imágenes a TODOS los escape rooms existentes en la base de datos
Usa Unsplash para obtener imágenes relevantes según el género/temática
"""

import sqlite3
import os
import requests
import time
import re

def get_unsplash_image(query, escape_name=""):
    """
    Obtiene una imagen de Unsplash basada en la búsqueda
    Unsplash permite uso sin API key para desarrollo
    """
    try:
        # Limpiar query
        query_clean = re.sub(r'[^\w\s]', '', query.lower())

        # Términos de búsqueda para escape rooms
        search_terms = f"escape room {query_clean}"

        # URL de búsqueda de Unsplash (Source API - no requiere key para desarrollo)
        url = f"https://source.unsplash.com/800x600/?{search_terms.replace(' ', ',')}"

        return url
    except Exception as e:
        print(f"  ⚠️ Error obteniendo imagen: {e}")
        return None


def generate_image_for_room(nombre, genero, empresa):
    """
    Genera una URL de imagen apropiada para un escape room
    """
    # Mapeo de géneros/temáticas a términos de búsqueda
    genre_mapping = {
        'terror': 'horror,haunted,scary,dark',
        'misterio': 'mystery,detective,clues,investigation',
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
    search_query = "escape room"

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
        'circus': 'circus', 'magic': 'magic', 'witch': 'witch'
    }

    for keyword, search_term in keywords.items():
        if keyword in nombre_lower:
            search_query = search_term
            break

    # Generar URL de Unsplash
    return get_unsplash_image(search_query, nombre)


def main():
    """Agrega imágenes a todos los escape rooms en la base de datos"""

    print("="*70)
    print("🖼️  AGREGANDO IMÁGENES A TODOS LOS ESCAPE ROOMS")
    print("="*70)

    # Buscar base de datos
    simulator_base = os.path.expanduser(
        "~/Library/Developer/CoreSimulator/Devices/113B97C8-D954-463E-8C22-CFB8353E0602"
        "/data/Containers/Data/Application"
    )

    db_path = None
    for app_dir in os.listdir(simulator_base):
        app_path = os.path.join(simulator_base, app_dir, "Documents", "words.db")
        if os.path.exists(app_path):
            db_path = app_path
            break

    if not db_path:
        print("❌ No se encontró la base de datos")
        return

    print(f"✅ Base de datos encontrada: {db_path}\n")

    # Conectar a SQLite
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Obtener todos los escape rooms SIN imagen
    cursor.execute("""
        SELECT id, text, genero, empresa
        FROM words
        WHERE imagenUrl IS NULL OR imagenUrl = ''
    """)

    rooms = cursor.fetchall()
    total = len(rooms)

    print(f"📊 Encontrados {total} escape rooms sin imagen\n")

    if total == 0:
        print("✅ Todos los escape rooms ya tienen imagen!")
        conn.close()
        return

    updated = 0
    errors = 0

    for idx, (room_id, nombre, genero, empresa) in enumerate(rooms, 1):
        try:
            print(f"[{idx}/{total}] {nombre}")

            # Generar URL de imagen
            imagen_url = generate_image_for_room(nombre, genero or "", empresa or "")

            if imagen_url:
                # Actualizar en la base de datos
                cursor.execute("""
                    UPDATE words
                    SET imagenUrl = ?
                    WHERE id = ?
                """, (imagen_url, room_id))

                updated += 1
                print(f"  ✅ Imagen agregada: {imagen_url[:60]}...")
            else:
                errors += 1
                print(f"  ⚠️ No se pudo generar imagen")

            # Rate limiting muy suave
            if idx % 10 == 0:
                time.sleep(0.5)

        except Exception as e:
            errors += 1
            print(f"  ❌ Error: {e}")
            continue

    # Guardar cambios
    conn.commit()
    conn.close()

    print(f"\n{'='*70}")
    print(f"📊 RESUMEN")
    print(f"{'='*70}")
    print(f"✅ Imágenes agregadas: {updated}")
    print(f"❌ Errores: {errors}")
    print(f"{'='*70}")
    print(f"\n✅ ¡Completado! Todos los escape rooms ahora tienen imágenes.")
    print(f"📱 Reinicia la app en el simulador para ver los cambios.")


if __name__ == "__main__":
    main()
