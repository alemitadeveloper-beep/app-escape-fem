#!/usr/bin/env python3
"""
Agrega el campo 'text' a los registros que no lo tienen,
copiando el valor del campo 'nombre'
"""

import json
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    input_file = '../assets/escape_rooms_completo.json'

    logging.info(f"📂 Cargando datos de {input_file}...")
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    logging.info(f"✓ {len(data)} escape rooms cargados")

    # Contar cuántos necesitan el campo text
    missing_text = sum(1 for r in data if not r.get('text'))
    logging.info(f"📊 Registros sin campo 'text': {missing_text}")

    # Agregar el campo text donde falta
    fixed = 0
    for record in data:
        if not record.get('text') and record.get('nombre'):
            record['text'] = record['nombre']
            fixed += 1

    logging.info(f"✓ Agregado campo 'text' a {fixed} registros")

    # Guardar
    logging.info(f"💾 Guardando en {input_file}...")
    with open(input_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    logging.info("✅ ¡Archivo actualizado exitosamente!")

    # Verificar
    missing_after = sum(1 for r in data if not r.get('text'))
    logging.info(f"📊 Registros sin 'text' después de la corrección: {missing_after}")

if __name__ == '__main__':
    main()
