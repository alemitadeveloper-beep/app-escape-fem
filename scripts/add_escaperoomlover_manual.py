#!/usr/bin/env python3
"""
Script para agregar manualmente escape rooms populares de escaperoomlover.com
Ya que el sitio usa JavaScript dinámico, agregamos manualmente los más populares
"""

from playwright.sync_api import sync_playwright
import json
import time

def scrape_individual_game(page, url):
    """Scrapea un juego individual de escaperoomlover"""
    try:
        print(f"🔍 Scrapeando: {url}")
        page.goto(url, timeout=20000)
        time.sleep(2)

        # Extraer nombre
        nombre = ""
        try:
            nombre = page.locator('h1').first.inner_text().strip()
            # Limpiar el nombre (quitar ratings)
            if ' 0' in nombre:
                nombre = nombre.split(' 0')[0].strip()
        except:
            print(f"  ❌ No se pudo extraer nombre")
            return None

        # Extraer empresa/local (h2 o h3)
        empresa = ""
        try:
            for heading in page.query_selector_all('h2, h3'):
                text = heading.inner_text().strip()
                if text and text != nombre and len(text) < 100:
                    empresa = text
                    break
        except:
            pass

        # Extraer ubicación (buscar textos con ciudades)
        ubicacion = "España"
        try:
            ciudades = ['Madrid', 'Barcelona', 'Valencia', 'Sevilla', 'Zaragoza',
                       'Málaga', 'Bilbao', 'Murcia', 'Alicante', 'Granada',
                       'Córdoba', 'Valladolid', 'Algete', 'Alcalá']

            for elem in page.query_selector_all('div, span, p'):
                text = elem.inner_text().strip()
                for ciudad in ciudades:
                    if ciudad in text and len(text) < 200:
                        ubicacion = text
                        break
                if ubicacion != "España":
                    break
        except:
            pass

        # Crear registro
        room = {
            'nombre': nombre,
            'ubicacion': ubicacion,
            'web': url,
            'genero': "",
            'puntuacion': "",
            'precio': "",
            'jugadores': "",
            'duracion': "",
            'descripcion': "",
            'empresa': empresa,
            'telefono': "",
            'latitud': 0.0,
            'longitud': 0.0,
            'source': 'escaperoomlover.com'
        }

        print(f"  ✅ {nombre} - {empresa}")
        return room

    except Exception as e:
        print(f"  ❌ Error: {e}")
        return None


def main():
    """Agrega manualmente los escape rooms más populares de escaperoomlover.com"""

    # URLs de escape rooms populares de escaperoomlover.com
    # Estas son algunas de las más vistas/populares del sitio
    popular_urls = [
        # Madrid
        "https://www.escaperoomlover.com/es/juego/madland-algete-magic-universe",
        "https://www.escaperoomlover.com/es/juego/the-escape-game-madrid-robo-al-casino",
        "https://www.escaperoomlover.com/es/juego/fox-in-a-box-madrid-zombies",
        "https://www.escaperoomlover.com/es/juego/parapark-madrid-delirium",
        "https://www.escaperoomlover.com/es/juego/the-x-door-madrid-proyecto-atlantis",

        # Barcelona
        "https://www.escaperoomlover.com/es/juego/lock-clock-escape-room-barcelona-orfanato",
        "https://www.escaperoomlover.com/es/juego/fox-in-a-box-barcelona-zombies",
        "https://www.escaperoomlover.com/es/juego/parapark-barcelona-sala-negra",
        "https://www.escaperoomlover.com/es/juego/chicken-banana-barcelona-la-jungla",

        # Valencia
        "https://www.escaperoomlover.com/es/juego/the-rombo-code-valencia-sala-blanca",
        "https://www.escaperoomlover.com/es/juego/clue-hunter-valencia-el-circo-maldito",

        # Otras ciudades
        "https://www.escaperoomlover.com/es/juego/escape-room-bilbao-mente-de-mono",
        "https://www.escaperoomlover.com/es/juego/coco-room-sevilla-the-terminal",
    ]

    results = []

    print("="*70)
    print("🎯 AGREGANDO ESCAPE ROOMS POPULARES DE ESCAPEROOMLOVER.COM")
    print("="*70)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        for url in popular_urls:
            room = scrape_individual_game(page, url)
            if room:
                results.append(room)
            time.sleep(1.5)  # Rate limiting

        browser.close()

    # Guardar en archivo JSON
    if results:
        output_file = "escaperoomlover_manual.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)

        print(f"\n{'='*70}")
        print(f"✅ {len(results)} escape rooms guardados en {output_file}")
        print(f"{'='*70}")
        print("\n📋 Escape rooms agregados:")
        for room in results:
            print(f"  - {room['nombre']} ({room['empresa']})")
    else:
        print("\n⚠️ No se pudo agregar ningún escape room")


if __name__ == "__main__":
    main()
