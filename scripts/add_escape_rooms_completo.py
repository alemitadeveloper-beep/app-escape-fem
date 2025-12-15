#!/usr/bin/env python3
"""
Script mejorado para agregar escape rooms con TODOS los datos incluyendo imágenes
"""

from playwright.sync_api import sync_playwright
import json
import time
import re

def scrape_complete_game(page, url):
    """Scrapea un juego con TODOS los datos incluyendo imagen"""
    try:
        print(f"\n🔍 Scrapeando: {url}")
        page.goto(url, timeout=20000)
        time.sleep(2)

        # Extraer nombre
        nombre = ""
        try:
            h1_text = page.locator('h1').first.inner_text().strip()
            nombre = h1_text.split('0 Opiniones')[0].strip()
            nombre = re.sub(r'\s+\d+\s*$', '', nombre).strip()
        except:
            print(f"  ❌ No se pudo extraer nombre")
            return None

        # Extraer empresa
        empresa = ""
        try:
            h2_elements = page.query_selector_all('h2')
            if h2_elements:
                empresa = h2_elements[0].inner_text().strip()
        except:
            pass

        # Extraer IMAGEN principal
        imagen_url = ""
        try:
            # Buscar la imagen principal del juego
            img_selectors = [
                'img[class*="main"]',
                'img[class*="hero"]',
                'img[class*="game"]',
                'img[class*="cover"]',
                '.game-image img',
                'article img',
                'img[alt*="' + nombre[:20] + '"]' if nombre else 'img'
            ]

            for selector in img_selectors:
                try:
                    img = page.locator(selector).first
                    src = img.get_attribute('src')
                    if src and ('http' in src or src.startswith('/')):
                        if src.startswith('/'):
                            imagen_url = f"https://www.escaperoomlover.com{src}"
                        else:
                            imagen_url = src
                        break
                except:
                    continue

            # Si no encontramos con selectores, buscar la primera imagen grande
            if not imagen_url:
                all_imgs = page.query_selector_all('img')
                for img in all_imgs:
                    src = img.get_attribute('src')
                    if src and 'logo' not in src.lower() and 'icon' not in src.lower():
                        if src.startswith('/'):
                            imagen_url = f"https://www.escaperoomlover.com{src}"
                        else:
                            imagen_url = src
                        break

        except Exception as e:
            print(f"  ⚠️ No se pudo extraer imagen: {e}")

        # Extraer ubicación/ciudad
        ubicacion = ""
        ciudad = ""
        try:
            page_text = page.content()
            ciudades_principales = {
                'madrid': 'Madrid', 'barcelona': 'Barcelona', 'valencia': 'Valencia',
                'sevilla': 'Sevilla', 'zaragoza': 'Zaragoza', 'málaga': 'Málaga',
                'bilbao': 'Bilbao', 'murcia': 'Murcia', 'alicante': 'Alicante',
                'granada': 'Granada', 'córdoba': 'Córdoba', 'valladolid': 'Valladolid',
                'algete': 'Algete', 'alcalá': 'Alcalá de Henares'
            }

            for ciudad_key, ciudad_nombre in ciudades_principales.items():
                if ciudad_key in page_text.lower():
                    ciudad = ciudad_nombre
                    ubicacion = f"{ciudad}, España"
                    break

            if not ubicacion:
                ubicacion = "España"
        except:
            ubicacion = "España"

        # Extraer jugadores, duración, precio, género, dificultad
        jugadores = ""
        duracion = ""
        precio = ""
        genero = ""
        dificultad = ""
        descripcion = ""

        try:
            content = page.content()

            # Jugadores
            jugadores_match = re.search(r'(\d+)-(\d+)\s*(?:jugadores?|personas?)', content, re.IGNORECASE)
            if jugadores_match:
                jugadores = f"{jugadores_match.group(1)}-{jugadores_match.group(2)} jugadores"

            # Duración
            duracion_match = re.search(r'(\d+)\s*min', content, re.IGNORECASE)
            if duracion_match:
                duracion = f"{duracion_match.group(1)} min"

            # Precio
            precio_match = re.search(r'(\d+)-(\d+)€', content)
            if precio_match:
                precio = f"{precio_match.group(1)}-{precio_match.group(2)}€"
            else:
                precio_match = re.search(r'Desde\s+(\d+)€', content, re.IGNORECASE)
                if precio_match:
                    precio = f"Desde {precio_match.group(1)}€"

            # Género/Temática
            tematicas = ['fantasía', 'terror', 'misterio', 'aventura', 'ciencia ficción',
                        'histórico', 'familiar', 'zombies', 'magia', 'medieval', 'futurista']
            generos_encontrados = []
            for tematica in tematicas:
                if tematica in content.lower():
                    generos_encontrados.append(tematica.title())
            genero = ", ".join(generos_encontrados[:3])  # Máximo 3

            # Dificultad
            if 'dificultad' in content.lower():
                if 'alta' in content.lower():
                    dificultad = "Alta"
                elif 'media' in content.lower():
                    dificultad = "Media"
                elif 'baja' in content.lower():
                    dificultad = "Baja"

            # Descripción
            try:
                desc_selectors = [
                    'div[class*="description"]',
                    'div[class*="synopsis"]',
                    'p[class*="description"]',
                    '.game-description',
                    'article p'
                ]

                for selector in desc_selectors:
                    try:
                        desc_elem = page.locator(selector).first
                        desc_text = desc_elem.inner_text().strip()
                        if desc_text and len(desc_text) > 50:
                            descripcion = desc_text[:500]  # Máximo 500 chars
                            break
                    except:
                        continue
            except:
                pass

        except Exception as e:
            print(f"  ⚠️ Error extrayendo detalles: {e}")

        # Crear registro completo
        room = {
            'nombre': nombre,
            'ubicacion': ubicacion,
            'web': url,
            'genero': genero,
            'puntuacion': "",
            'precio': precio,
            'jugadores': jugadores,
            'duracion': duracion,
            'descripcion': descripcion,
            'empresa': empresa,
            'telefono': "",
            'latitud': 0.0,
            'longitud': 0.0,
            'dificultad': dificultad,
            'imagenUrl': imagen_url,
            'source': 'escaperoomlover.com'
        }

        print(f"  ✅ {nombre} - {empresa}")
        if jugadores:
            print(f"     👥 {jugadores}")
        if duracion:
            print(f"     ⏱️ {duracion}")
        if precio:
            print(f"     💰 {precio}")
        if imagen_url:
            print(f"     🖼️ Imagen: {imagen_url[:60]}...")
        if genero:
            print(f"     🎭 {genero}")

        return room

    except Exception as e:
        print(f"  ❌ Error: {e}")
        return None


def main():
    """Agrega manualmente los escape rooms más populares con TODOS los datos"""

    # URLs de escape rooms populares de escaperoomlover.com
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
    print("🎯 SCRAPING COMPLETO DE ESCAPEROOMLOVER.COM (CON IMÁGENES)")
    print("="*70)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        for url in popular_urls:
            room = scrape_complete_game(page, url)
            if room:
                results.append(room)
            time.sleep(1.5)  # Rate limiting

        browser.close()

    # Guardar en archivo JSON
    if results:
        output_file = "escaperoomlover_completo.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)

        print(f"\n{'='*70}")
        print(f"✅ {len(results)} escape rooms guardados en {output_file}")
        print(f"{'='*70}")
        print("\n📋 Escape rooms agregados:")
        for room in results:
            print(f"  - {room['nombre']} ({room['empresa']})")
            if room['imagenUrl']:
                print(f"    🖼️ Con imagen")
    else:
        print("\n⚠️ No se pudo agregar ningún escape room")


if __name__ == "__main__":
    main()
