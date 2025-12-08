#!/usr/bin/env python3
"""Script para añadir URLs de imágenes a los escape rooms"""
import json

# Cargar datos existentes
with open('../assets/escape_rooms_nuevos.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# URLs de imágenes temáticas de Unsplash
image_urls = [
    "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=400&h=300&fit=crop",  # Money heist
    "https://images.unsplash.com/photo-1548678967-f1aec58f6fb2?w=400&h=300&fit=crop",  # Vatican/church
    "https://images.unsplash.com/photo-1509248961158-e54f6934749c?w=400&h=300&fit=crop",  # Dark/vampire
    "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=400&h=300&fit=crop",  # Laboratory
    "https://images.unsplash.com/photo-1568515387631-8b650bbcdb90?w=400&h=300&fit=crop",  # Prison
    "https://images.unsplash.com/photo-1512295767273-ac109ac3acfa?w=400&h=300&fit=crop",  # Temple
    "https://images.unsplash.com/photo-1520638023360-1f2f0c871c72?w=400&h=300&fit=crop",  # Haunted mansion
    "https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=400&h=300&fit=crop",  # Antarctica/ice
    "https://images.unsplash.com/photo-1553885787-dd7b7fb2bc7c?w=400&h=300&fit=crop",  # Sherlock/detective
    "https://images.unsplash.com/photo-1551269901-5c5e14c25df7?w=400&h=300&fit=crop",  # Illuminati/secret
    "https://images.unsplash.com/photo-1589942811671-c0ec87f1ecd4?w=400&h=300&fit=crop",  # Nuclear bunker
    "https://images.unsplash.com/photo-1553913861-c0fddf2619ee?w=400&h=300&fit=crop",  # Egyptian/pharaoh
    "https://images.unsplash.com/photo-1533157710978-cdfb58672d67?w=400&h=300&fit=crop",  # Zodiac/mystery
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop",  # Magic school
    "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop",  # Submarine
]

# Añadir imagenUrl a cada escape room
for i, room in enumerate(data):
    if i < len(image_urls):
        room['imagenUrl'] = image_urls[i]
    print(f"✓ {room.get('nombre', 'Unknown')}")

# Guardar
with open('../assets/escape_rooms_nuevos.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"\n✅ {len(data)} escape rooms actualizados con imágenes")
