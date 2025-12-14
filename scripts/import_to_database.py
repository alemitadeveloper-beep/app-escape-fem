#!/usr/bin/env python3
"""
Script para importar los escape rooms scrapeados desde JSON a SQLite y Firebase.
Lee el archivo nuevos_escape_rooms.json y los inserta en la base de datos local SQLite.
"""

import json
import sqlite3
import os
import sys
import re
from difflib import SequenceMatcher


def similarity_ratio(text1: str, text2: str) -> float:
    """Calcula la similitud entre dos textos (0.0 a 1.0)"""
    return SequenceMatcher(None, text1.lower(), text2.lower()).ratio()


def normalize_text(text: str) -> str:
    """Normaliza un texto eliminando acentos, símbolos y convirtiendo a minúsculas"""
    if not text:
        return ""
    # Quitar acentos
    replacements = {
        'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
        'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u',
        'ñ': 'n', 'Ñ': 'n', 'ü': 'u', 'Ü': 'u'
    }
    normalized = text
    for old, new in replacements.items():
        normalized = normalized.replace(old, new)

    # Quitar símbolos y convertir a minúsculas
    normalized = re.sub(r'[^\w\s]', '', normalized.lower())
    normalized = re.sub(r'\s+', ' ', normalized).strip()
    return normalized


def extract_city(ubicacion: str) -> str:
    """Extrae la ciudad de una ubicación completa"""
    if not ubicacion:
        return ""

    # Patrones comunes: "Calle X, Ciudad" o "Ciudad, Provincia"
    # Tomar la última palabra antes de "España" o la penúltima parte
    parts = [p.strip() for p in ubicacion.split(',')]

    # Si tiene "España" al final, tomar la parte anterior
    if parts and 'españa' in parts[-1].lower():
        if len(parts) >= 2:
            return normalize_text(parts[-2])

    # Si no, tomar la última parte significativa
    if len(parts) >= 2:
        return normalize_text(parts[-1])

    return normalize_text(ubicacion)


def get_db_path():
    """Encuentra la ruta de la base de datos SQLite del simulador iOS"""
    # Ruta típica del simulador iOS
    simulator_base = os.path.expanduser(
        "~/Library/Developer/CoreSimulator/Devices/113B97C8-D954-463E-8C22-CFB8353E0602"
        "/data/Containers/Data/Application"
    )

    if not os.path.exists(simulator_base):
        print(f"⚠️ No se encontró el directorio del simulador en: {simulator_base}")
        return None

    # Buscar el directorio de la aplicación que contiene words.db
    for app_dir in os.listdir(simulator_base):
        app_path = os.path.join(simulator_base, app_dir, "Documents", "words.db")
        if os.path.exists(app_path):
            print(f"✅ Base de datos encontrada: {app_path}")
            return app_path

    print(f"⚠️ No se encontró words.db en ningún directorio de aplicación")
    return None


def import_to_sqlite(json_file: str, db_path: str):
    """Importa los escape rooms desde JSON a SQLite"""

    # Leer el archivo JSON
    if not os.path.exists(json_file):
        print(f"❌ No se encontró el archivo: {json_file}")
        return 0

    with open(json_file, 'r', encoding='utf-8') as f:
        escape_rooms = json.load(f)

    print(f"📖 Leyendo {len(escape_rooms)} escape rooms desde {json_file}")

    # Conectar a SQLite
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    imported = 0
    duplicates = 0
    errors = 0

    for room in escape_rooms:
        try:
            nombre = room.get('nombre', '')
            ubicacion = room.get('ubicacion', '')

            # Normalizar nombre y extraer ciudad
            nombre_norm = normalize_text(nombre)
            ciudad_new = extract_city(ubicacion)

            # Verificar si ya existe (triple verificación)
            # Obtener todos los escape rooms para comparar con normalización
            cursor.execute("SELECT id, text, ubicacion FROM words")
            existing_rooms = cursor.fetchall()

            is_duplicate = False
            duplicate_reason = ""

            for existing_id, existing_name, existing_location in existing_rooms:
                existing_norm = normalize_text(existing_name)
                ciudad_existing = extract_city(existing_location)

                # VERIFICACIÓN 1: Nombre normalizado exacto + misma ciudad
                if existing_norm == nombre_norm and ciudad_new == ciudad_existing:
                    is_duplicate = True
                    duplicate_reason = f"ya existe como '{existing_name}' en {ciudad_existing}"
                    break

                # VERIFICACIÓN 2: Similitud de nombre >90% + misma ciudad
                similarity = similarity_ratio(nombre_norm, existing_norm)
                if similarity > 0.90 and ciudad_new == ciudad_existing:
                    is_duplicate = True
                    duplicate_reason = f"muy similar ({similarity*100:.0f}%) a '{existing_name}' en {ciudad_existing}"
                    break

                # VERIFICACIÓN 3: Nombre exacto en ubicación completa (sin importar ciudad)
                if existing_norm == nombre_norm and similarity_ratio(ubicacion, existing_location) > 0.70:
                    is_duplicate = True
                    duplicate_reason = f"mismo nombre y ubicación similar a '{existing_name}'"
                    break

            if is_duplicate:
                duplicates += 1
                print(f"⏭️ Duplicado: {nombre} ({duplicate_reason})")
                continue

            # Insertar nuevo escape room
            cursor.execute("""
                INSERT INTO words (
                    text, empresa, ubicacion, genero, puntuacion, web,
                    latitud, longitud, precio, jugadores, duracion,
                    numJugadoresMin, numJugadoresMax, dificultad,
                    telefono, email, provincia, descripcion, imagenUrl
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                room.get('nombre', ''),
                room.get('empresa'),
                room.get('ubicacion', ''),
                room.get('genero', ''),
                room.get('puntuacion', ''),
                room.get('web', ''),
                room.get('latitud', 0.0),
                room.get('longitud', 0.0),
                room.get('precio'),
                room.get('jugadores'),
                room.get('duracion'),
                room.get('numJugadoresMin'),
                room.get('numJugadoresMax'),
                room.get('dificultad'),
                room.get('telefono'),
                room.get('email'),
                room.get('provincia'),
                room.get('descripcion'),
                room.get('imagenUrl')
            ))

            imported += 1
            print(f"✅ Importado: {room.get('nombre', 'Sin nombre')}")

        except Exception as e:
            errors += 1
            print(f"❌ Error importando {room.get('nombre', 'Sin nombre')}: {e}")

    # Guardar cambios
    conn.commit()
    conn.close()

    print(f"\n{'='*70}")
    print(f"📊 RESUMEN DE IMPORTACIÓN")
    print(f"{'='*70}")
    print(f"✅ Importados: {imported}")
    print(f"⏭️ Duplicados omitidos: {duplicates}")
    print(f"❌ Errores: {errors}")
    print(f"{'='*70}\n")

    return imported


def main():
    """Función principal"""
    print("="*70)
    print("🚀 IMPORTACIÓN DE ESCAPE ROOMS A SQLITE")
    print("="*70)

    # Ruta del archivo JSON
    script_dir = os.path.dirname(os.path.abspath(__file__))
    json_file = os.path.join(script_dir, "nuevos_escape_rooms.json")

    # Obtener ruta de la base de datos
    db_path = get_db_path()

    if not db_path:
        print("\n❌ No se pudo encontrar la base de datos SQLite.")
        print("Asegúrate de que:")
        print("  1. El simulador iOS está ejecutándose")
        print("  2. La aplicación Flutter se ha ejecutado al menos una vez")
        print("  3. La base de datos se ha creado en Documents/words.db")
        return

    # Importar a SQLite
    imported = import_to_sqlite(json_file, db_path)

    if imported > 0:
        print("✅ Importación completada!")
        print("\n📱 PRÓXIMOS PASOS:")
        print("  1. Abre la aplicación en el simulador")
        print("  2. Ve a la página de administración de escape rooms")
        print("  3. Los nuevos escape rooms deberían aparecer en la lista")
        print("  4. Firebase se actualizará automáticamente cuando edites o crees escape rooms")
    else:
        print("⚠️ No se importaron nuevos escape rooms (puede que todos sean duplicados)")


if __name__ == "__main__":
    main()
