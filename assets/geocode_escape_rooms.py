import json
import requests
import time

API_KEY = '54f17eb794d74912a48a30537576ba99'  # ← reemplaza con tu key
URL = 'https://api.opencagedata.com/geocode/v1/json'

with open('escape_rooms_seed.json', 'r') as f:
    data = json.load(f)

for i, item in enumerate(data):
    ubicacion = item.get("ubicacion")
    if not ubicacion:
        item['latitud'] = 0.0
        item['longitud'] = 0.0
        continue

    params = {
        'q': ubicacion,
        'key': API_KEY,
        'limit': 1,
        'language': 'es'
    }

    try:
        response = requests.get(URL, params=params)
        results = response.json().get('results')
        if results:
            coords = results[0]['geometry']
            item['latitud'] = coords['lat']
            item['longitud'] = coords['lng']
            print(f"[{i}] OK: {ubicacion} → {coords['lat']}, {coords['lng']}")
        else:
            print(f"[{i}] Sin resultados: {ubicacion}")
            item['latitud'] = 0.0
            item['longitud'] = 0.0
    except Exception as e:
        print(f"[{i}] ERROR: {ubicacion} ({e})")
        item['latitud'] = 0.0
        item['longitud'] = 0.0

    time.sleep(1.1)  # evita pasarte del límite gratuito

# Guarda el nuevo archivo
with open('escape_rooms_seed_con_coords.json', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("✔ Coordenadas añadidas y archivo guardado como escape_rooms_seed_con_coords.json")
