#!/usr/bin/env python3
"""
Script para scrapear escaperoomlover.com usando su API pública
"""

import requests
import json
import time

def get_all_companies():
    """Obtiene todas las empresas/locales de escape rooms"""
    url = "https://www.escaperoomlover.com/api/es/public/company/all"
    print(f"📡 Obteniendo empresas desde API...")

    try:
        response = requests.get(url, timeout=30)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ {len(data)} empresas encontradas")
            return data
        else:
            print(f"❌ Error: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error: {e}")
        return []


def main():
    print("="*70)
    print("🚀 SCRAPING ESCAPEROOMLOVER.COM VÍA API")
    print("="*70)

    # Obtener todas las empresas (que incluyen los juegos)
    companies = get_all_companies()

    if not companies:
        print("⚠️ No se pudieron obtener datos de la API")
        return

    # Guardar datos crudos para inspección
    with open("escaperoomlover_raw_api.json", 'w', encoding='utf-8') as f:
        json.dump(companies, f, ensure_ascii=False, indent=2)

    print(f"\n💾 Datos guardados en escaperoomlover_raw_api.json")
    print(f"\n📊 Estructura de datos:")
    if companies:
        print(json.dumps(companies[0], indent=2, ensure_ascii=False)[:1000])

    # Procesar y convertir al formato de escape rooms
    escape_rooms = []

    for company in companies:
        # Cada empresa puede tener múltiples juegos
        games = company.get('games', [])

        for game in games:
            room = {
                'nombre': game.get('name', ''),
                'ubicacion': f"{company.get('address', '')}, {company.get('city', {}).get('name', '')}, España",
                'web': f"https://www.escaperoomlover.com/es/juego/{game.get('slug', '')}",
                'genero': ', '.join([theme.get('name', '') for theme in game.get('themes', [])]),
                'puntuacion': str(game.get('rating', '')),
                'precio': game.get('price', ''),
                'jugadores': f"{game.get('minPlayers', '')}-{game.get('maxPlayers', '')} jugadores" if game.get('minPlayers') else "",
                'duracion': f"{game.get('duration', '')} min" if game.get('duration') else "",
                'descripcion': game.get('description', ''),
                'empresa': company.get('name', ''),
                'telefono': company.get('phone', ''),
                'latitud': float(company.get('latitude', 0) or 0),
                'longitud': float(company.get('longitude', 0) or 0),
                'source': 'escaperoomlover.com'
            }

            escape_rooms.append(room)

    # Guardar en formato compatible
    if escape_rooms:
        with open("escaperoomlover_api.json", 'w', encoding='utf-8') as f:
            json.dump(escape_rooms, f, ensure_ascii=False, indent=2)

        print(f"\n{'='*70}")
        print(f"✅ {len(escape_rooms)} escape rooms guardados en escaperoomlover_api.json")
        print(f"{'='*70}")

        # Mostrar algunos ejemplos
        print(f"\n📋 Primeros 5 escape rooms:")
        for i, room in enumerate(escape_rooms[:5], 1):
            print(f"  {i}. {room['nombre']} - {room['empresa']} ({room['ubicacion'][:50]}...)")
    else:
        print("\n⚠️ No se encontraron escape rooms")


if __name__ == "__main__":
    main()
