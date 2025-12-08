#!/usr/bin/env python3
"""
Script para combinar los datos nuevos con los existentes
y actualizar escape_rooms_completo.json
"""

import json
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def load_json(filepath):
    """Carga un archivo JSON"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        logger.warning(f"Archivo no encontrado: {filepath}")
        return []
    except json.JSONDecodeError as e:
        logger.error(f"Error al parsear JSON {filepath}: {e}")
        return []


def normalize_key(name, location):
    """Crea una clave normalizada para comparación"""
    name = (name or '').lower().strip()
    location = (location or '').lower().strip()[:30]
    return f"{name}::{location}"


def merge_escape_rooms(existing_data, new_data):
    """Combina datos existentes con nuevos, evitando duplicados"""
    logger.info("🔄 Combinando datos...")

    # Crear diccionario con datos existentes
    merged = {}

    for room in existing_data:
        key = normalize_key(room.get('nombre') or room.get('text'), room.get('ubicacion'))
        if key and key != '::':
            merged[key] = room

    logger.info(f"✓ Cargados {len(merged)} escape rooms existentes")

    # Agregar nuevos datos
    added = 0
    updated = 0

    for room in new_data:
        key = normalize_key(room.get('nombre') or room.get('text'), room.get('ubicacion'))

        if not key or key == '::':
            continue

        if key in merged:
            # Actualizar campos vacíos del existente con datos nuevos
            existing_room = merged[key]
            for field, value in room.items():
                if value and not existing_room.get(field):
                    existing_room[field] = value
            updated += 1
        else:
            # Agregar nuevo
            # Normalizar campos para compatibilidad
            if 'nombre' in room and 'text' not in room:
                room['text'] = room['nombre']
            merged[key] = room
            added += 1

    logger.info(f"✓ Agregados: {added} nuevos")
    logger.info(f"✓ Actualizados: {updated} existentes")

    return list(merged.values())


def main():
    logger.info("=" * 60)
    logger.info("MERGE DE DATOS DE ESCAPE ROOMS")
    logger.info("=" * 60)

    # Rutas de archivos
    existing_file = "../assets/escape_rooms_completo.json"
    new_file = "../assets/escape_rooms_nuevos.json"
    output_file = "../assets/escape_rooms_completo.json"
    backup_file = "../assets/escape_rooms_completo_backup.json"

    # Cargar datos
    logger.info(f"\n📂 Cargando datos existentes de {existing_file}...")
    existing_data = load_json(existing_file)
    logger.info(f"✓ {len(existing_data)} escape rooms cargados")

    logger.info(f"\n📂 Cargando datos nuevos de {new_file}...")
    new_data = load_json(new_file)
    logger.info(f"✓ {len(new_data)} escape rooms nuevos cargados")

    # Hacer backup
    if existing_data:
        logger.info(f"\n💾 Creando backup en {backup_file}...")
        with open(backup_file, 'w', encoding='utf-8') as f:
            json.dump(existing_data, f, ensure_ascii=False, indent=2)
        logger.info("✓ Backup creado")

    # Combinar
    merged_data = merge_escape_rooms(existing_data, new_data)

    # Guardar resultado
    logger.info(f"\n💾 Guardando resultado en {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(merged_data, f, ensure_ascii=False, indent=2)

    logger.info(f"✅ Archivo actualizado exitosamente!")
    logger.info(f"\n📊 Resumen:")
    logger.info(f"   - Total de escape rooms: {len(merged_data)}")
    logger.info(f"   - Antes: {len(existing_data)}")
    logger.info(f"   - Nuevos agregados: {len(merged_data) - len(existing_data)}")

    # Estadísticas
    with_description = sum(1 for r in merged_data if r.get('descripcion'))
    with_price = sum(1 for r in merged_data if r.get('precio'))
    with_jugadores = sum(1 for r in merged_data if r.get('jugadores'))
    with_coords = sum(1 for r in merged_data if r.get('latitud', 0) != 0 and r.get('longitud', 0) != 0)

    logger.info(f"\n📈 Estadísticas del archivo final:")
    logger.info(f"   - Con descripción: {with_description} ({with_description/len(merged_data)*100:.1f}%)")
    logger.info(f"   - Con precio: {with_price} ({with_price/len(merged_data)*100:.1f}%)")
    logger.info(f"   - Con jugadores: {with_jugadores} ({with_jugadores/len(merged_data)*100:.1f}%)")
    logger.info(f"   - Con coordenadas: {with_coords} ({with_coords/len(merged_data)*100:.1f}%)")

    logger.info("\n🎉 Merge completado!")


if __name__ == "__main__":
    main()
