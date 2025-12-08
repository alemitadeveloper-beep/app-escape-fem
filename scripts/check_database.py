#!/usr/bin/env python3
"""
Verifica el contenido de la base de datos SQLite
"""

import sqlite3
import os
from pathlib import Path

# Buscar la base de datos en el directorio de usuario
home = Path.home()
possible_paths = [
    home / "Library/Containers/com.example.escapeRoomApplication/Data/Library/Application Support/escape_rooms.db",
    home / "Library/Application Support/escape_rooms.db",
]

db_path = None
for path in possible_paths:
    if path.exists():
        db_path = path
        break

if not db_path:
    print("❌ No se encontró la base de datos")
    print("Buscando en:")
    for path in possible_paths:
        print(f"  - {path}")
    exit(1)

print(f"✅ Base de datos encontrada: {db_path}")

# Conectar
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Verificar esquema
cursor.execute("PRAGMA table_info(words)")
columns = cursor.fetchall()
print(f"\n📋 Columnas en la tabla 'words': {len(columns)}")
for col in columns:
    print(f"  - {col[1]} ({col[2]})")

# Verificar si hay imagenUrl
has_imagen = any(col[1] == 'imagenUrl' for col in columns)
print(f"\n{'✅' if has_imagen else '❌'} Campo 'imagenUrl' {'existe' if has_imagen else 'NO EXISTE'}")

# Contar registros
cursor.execute("SELECT COUNT(*) FROM words")
total = cursor.fetchone()[0]
print(f"\n📊 Total de registros: {total}")

if has_imagen:
    # Contar registros con imagen
    cursor.execute("SELECT COUNT(*) FROM words WHERE imagenUrl IS NOT NULL AND imagenUrl != ''")
    with_images = cursor.fetchone()[0]
    print(f"📸 Registros con imagenUrl: {with_images}")

    if with_images > 0:
        # Mostrar algunos ejemplos
        cursor.execute("SELECT text, empresa, imagenUrl FROM words WHERE imagenUrl IS NOT NULL AND imagenUrl != '' LIMIT 5")
        results = cursor.fetchall()
        print(f"\n🔍 Ejemplos de registros con imagen:")
        for row in results:
            print(f"  - {row[0]}")
            print(f"    Empresa: {row[1]}")
            print(f"    Imagen: {row[2][:60]}...")

conn.close()
