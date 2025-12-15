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
            h1_text = page.locator('h1').first.inner_text().strip()
            # Limpiar el nombre (quitar ratings y opiniones)
            nombre = h1_text.split('0 Opiniones')[0].strip()
            # Quitar números al final
            import re
            nombre = re.sub(r'\s+\d+\s*$', '', nombre).strip()
        except:
            print(f"  ❌ No se pudo extraer nombre")
            return None

        # Extraer empresa/local (h2 principal debajo del h1)
        empresa = ""
        try:
            # El h2 suele estar justo después del h1
            h2_elements = page.query_selector_all('h2')
            if h2_elements:
                empresa = h2_elements[0].inner_text().strip()
        except:
            pass

        # Extraer ubicación/ciudad más específica
        ubicacion = ""
        ciudad = ""
        try:
            # Buscar el texto que contiene la ciudad
            page_text = page.content()

            # Buscar patrones comunes de ciudad en el HTML
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

        # Extraer jugadores, duración, precio
        jugadores = ""
        duracion = ""
        precio = ""
        genero = ""
        dificultad = ""

        try:
            # Buscar información en el contenido de la página
            content = page.content()

            # Jugadores (ej: "2-8")
            jugadores_match = re.search(r'(\d+)-(\d+)\s*(?:jugadores?|personas?)', content, re.IGNORECASE)
            if jugadores_match:
                jugadores = f"{jugadores_match.group(1)}-{jugadores_match.group(2)} jugadores"

            # Duración (ej: "150 min")
            duracion_match = re.search(r'(\d+)\s*min', content, re.IGNORECASE)
            if duracion_match:
                duracion = f"{duracion_match.group(1)} min"

            # Precio (ej: "200-400€" o "Desde 20€")
            precio_match = re.search(r'(\d+)-(\d+)€', content)
            if precio_match:
                precio = f"{precio_match.group(1)}-{precio_match.group(2)}€"
            else:
                precio_match = re.search(r'Desde\s+(\d+)€', content, re.IGNORECASE)
                if precio_match:
                    precio = f"Desde {precio_match.group(1)}€"

            # Género/Temática
            tematicas = ['fantasía', 'terror', 'misterio', 'aventura', 'ciencia ficción',
                        'histórico', 'familiar', 'zombies', 'magia']
            for tematica in tematicas:
                if tematica in content.lower():
                    if genero:
                        genero += f", {tematica}"
                    else:
                        genero = tematica

            # Dificultad
            if 'dificultad' in content.lower():
                if 'alta' in content.lower():
                    dificultad = "Alta"
                elif 'media' in content.lower():
                    dificultad = "Media"
                elif 'baja' in content.lower():
                    dificultad = "Baja"

        except Exception as e:
            print(f"  ⚠️ Error extrayendo detalles: {e}")

        # Crear registro
        room = {
            'nombre': nombre,
            'ubicacion': ubicacion,
            'web': url,
            'genero': genero.title() if genero else "",
            'puntuacion': "",
            'precio': precio,
            'jugadores': jugadores,
            'duracion': duracion,
            'descripcion': "",
            'empresa': empresa,
            'telefono': "",
            'latitud': 0.0,
            'longitud': 0.0,
            'dificultad': dificultad,
            'source': 'escaperoomlover.com'
        }

        print(f"  ✅ {nombre} - {empresa}")
        if jugadores:
            print(f"     👥 {jugadores}")
        if duracion:
            print(f"     ⏱️ {duracion}")
        if precio:
            print(f"     💰 {precio}")

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
