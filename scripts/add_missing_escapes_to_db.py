#!/usr/bin/env python3
"""
Script para agregar escape rooms faltantes (como Madland) a la base de datos SQLite
"""

import sqlite3
import json
import os

def get_db_path():
    """Encuentra la ruta de la base de datos en el simulador"""
    # Ruta típica del simulador iOS
    simulator_path = "/Users/alejandra/Library/Developer/CoreSimulator/Devices/113B97C8-D954-463E-8C22-CFB8353E0602/data/Containers/Data/Application"

    # Buscar la carpeta que contiene words.db
    for root, dirs, files in os.walk(simulator_path):
        if 'words.db' in files:
            return os.path.join(root, 'words.db')

    return None

def add_escape_rooms_to_db(json_file, db_path):
    """Agrega escape rooms desde un archivo JSON a la base de datos"""

    # Leer el archivo JSON
    with open(json_file, 'r', encoding='utf-8') as f:
        escape_rooms = json.load(f)

    print(f"\n📖 Leyendo {len(escape_rooms)} escape rooms de {json_file}")

    # Conectar a la base de datos
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    added = 0
    updated = 0

    for room in escape_rooms:
        try:
            # Verificar si ya existe
            cursor.execute("SELECT id FROM words WHERE text = ? AND empresa = ?",
                          (room['nombre'], room['empresa']))
            existing = cursor.fetchone()

            if existing:
                # Actualizar registro existente
                cursor.execute("""
                    UPDATE words SET
                        ubicacion = ?,
                        web = ?,
                        genero = ?,
                        puntuacion = ?,
                        precio = ?,
                        jugadores = ?,
                        duracion = ?,
                        descripcion = ?,
                        telefono = ?,
                        latitud = ?,
                        longitud = ?,
                        dificultad = ?,
                        imagenUrl = ?,
                        source = ?
                    WHERE id = ?
                """, (
                    room.get('ubicacion', ''),
                    room.get('web', ''),
                    room.get('genero', ''),
                    room.get('puntuacion', ''),
                    room.get('precio', ''),
                    room.get('jugadores', ''),
                    room.get('duracion', ''),
                    room.get('descripcion', ''),
                    room.get('telefono', ''),
                    room.get('latitud', 0.0),
                    room.get('longitud', 0.0),
                    room.get('dificultad', ''),
                    room.get('imagenUrl', ''),
                    room.get('source', 'escaperoomlover.com'),
                    existing[0]
                ))
                updated += 1
                print(f"  ✏️ Actualizado: {room['nombre']} - {room['empresa']}")
            else:
                # Insertar nuevo registro
                cursor.execute("""
                    INSERT INTO words (
                        text, ubicacion, web, genero, puntuacion, precio,
                        jugadores, duracion, descripcion, empresa, telefono,
                        latitud, longitud, dificultad, imagenUrl, source,
                        wordStatus, isDeleted, isSynced
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', 0, 0)
                """, (
                    room['nombre'],
                    room.get('ubicacion', ''),
                    room.get('web', ''),
                    room.get('genero', ''),
                    room.get('puntuacion', ''),
                    room.get('precio', ''),
                    room.get('jugadores', ''),
                    room.get('duracion', ''),
                    room.get('descripcion', ''),
                    room.get('empresa', ''),
                    room.get('telefono', ''),
                    room.get('latitud', 0.0),
                    room.get('longitud', 0.0),
                    room.get('dificultad', ''),
                    room.get('imagenUrl', ''),
                    room.get('source', 'escaperoomlover.com')
                ))
                added += 1
                print(f"  ✅ Agregado: {room['nombre']} - {room['empresa']}")

        except Exception as e:
            print(f"  ❌ Error con {room.get('nombre', 'Unknown')}: {e}")

    conn.commit()
    conn.close()

    return added, updated

def main():
    print("="*70)
    print("🎯 AGREGANDO ESCAPE ROOMS FALTANTES A LA BASE DE DATOS")
    print("="*70)

    # Buscar la base de datos
    db_path = get_db_path()

    if not db_path:
        print("❌ No se encontró la base de datos words.db en el simulador")
        print("   Asegúrate de que la app esté corriendo en el simulador")
        return

    print(f"\n📁 Base de datos encontrada: {db_path}")

    # Archivos JSON con escape rooms
    json_files = [
        'escaperoomlover_completo.json',
        'escaperoomlover_manual.json',
        'nuevos_escape_rooms_combinado.json'
    ]

    total_added = 0
    total_updated = 0

    for json_file in json_files:
        if os.path.exists(json_file):
            added, updated = add_escape_rooms_to_db(json_file, db_path)
            total_added += added
            total_updated += updated
        else:
            print(f"⚠️ No se encontró {json_file}")

    print(f"\n{'='*70}")
    print(f"✅ RESUMEN:")
    print(f"   • {total_added} escape rooms nuevos agregados")
    print(f"   • {total_updated} escape rooms actualizados")
    print(f"{'='*70}")

if __name__ == "__main__":
    main()
