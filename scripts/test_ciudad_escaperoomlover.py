#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import time

def test_ciudad():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        print("🔍 Navegando a madrid...")
        page.goto("https://www.escaperoomlover.com/es/ciudad/madrid", timeout=30000)

        # Esperar a que se cargue el contenido dinámico
        try:
            page.wait_for_selector('[class*="game"]', timeout=5000)
            print("✅ Elementos 'game' cargados")
        except:
            print("⚠️ No se detectaron elementos 'game'")

        time.sleep(3)

        # Scroll más agresivo
        for i in range(5):
            page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
            time.sleep(2)
            print(f"📜 Scroll {i+1}/5")

        # Ver el HTML completo
        html = page.content()

        # Buscar elementos con clase que contengan "card", "game", "room", "juego"
        print("\n📦 Elementos con clases relevantes:")
        for selector in ['[class*="card"]', '[class*="game"]', '[class*="room"]', '[class*="juego"]', '[class*="item"]']:
            elements = page.query_selector_all(selector)
            if elements:
                print(f"  - {selector}: {len(elements)} elementos")
                # Mostrar el primero
                if elements:
                    try:
                        first = elements[0]
                        print(f"    Primera clase: {first.get_attribute('class')}")
                        # Buscar enlaces dentro
                        links = first.query_selector_all('a')
                        for link in links[:2]:
                            href = link.get_attribute('href')
                            if href:
                                print(f"      Link: {href}")
                    except:
                        pass

        # Buscar todos los enlaces nuevamente
        all_links = page.query_selector_all('a[href]')
        print(f"\n🔗 Total de enlaces: {len(all_links)}")

        # Ver los que tienen href relativo
        relative_links = []
        for link in all_links:
            href = link.get_attribute('href')
            if href and href.startswith('/') and not href.startswith('//'):
                relative_links.append(href)

        print(f"\n📝 Enlaces relativos únicos ({len(set(relative_links))}):")
        for link in sorted(set(relative_links))[:50]:
            print(f"  - {link}")

        # Inspeccionar los elementos .game más de cerca
        print("\n🎮 Inspeccionando elementos con clase 'game':")
        game_elements = page.query_selector_all('[class*="game"]')
        for i, elem in enumerate(game_elements[:5]):  # Primeros 5
            try:
                # Ver todos los atributos
                data_attrs = {}
                for attr in ['data-url', 'data-id', 'data-slug', 'data-href', 'onclick']:
                    value = elem.get_attribute(attr)
                    if value:
                        data_attrs[attr] = value

                if data_attrs:
                    print(f"\n  Elemento {i+1}:")
                    for key, val in data_attrs.items():
                        print(f"    {key}: {val[:100]}")
            except:
                pass

        browser.close()

if __name__ == "__main__":
    test_ciudad()
