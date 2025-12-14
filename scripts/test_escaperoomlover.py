#!/usr/bin/env python3
"""
Script de prueba para verificar la estructura de escaperoomlover.com
"""

from playwright.sync_api import sync_playwright
import time

def test_escaperoomlover():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)  # Headless mode
        page = browser.new_page()

        print("🔍 Navegando a escaperoomlover.com/es/juegos...")
        page.goto("https://www.escaperoomlover.com/es/juegos", timeout=30000)
        time.sleep(3)

        # Aceptar cookies
        try:
            page.locator("button:has-text('Aceptar')").first.click(timeout=3000)
            time.sleep(1)
        except:
            print("⚠️ No se encontró botón de cookies")

        # Scroll
        for i in range(3):
            page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
            time.sleep(1)
            print(f"📜 Scroll {i+1}/3")

        # Buscar todos los enlaces
        all_links = page.query_selector_all('a[href]')
        print(f"\n📋 Total de enlaces en la página: {len(all_links)}")

        # Mostrar TODOS los enlaces únicos para entender la estructura
        print("\n🔗 Todos los enlaces únicos en la página:")
        unique_links = set()
        for link in all_links:
            href = link.get_attribute('href')
            if href:
                unique_links.add(href)

        for i, link in enumerate(sorted(unique_links)[:30], 1):  # Primeros 30
            print(f"  {i}. {link}")

        # Filtrar enlaces que contienen "juego"
        juego_links = []
        for link in all_links:
            href = link.get_attribute('href')
            if href and '/juego/' in href:
                juego_links.append(href)

        print(f"\n🎮 Enlaces que contienen '/juego/': {len(juego_links)}")

        # Probar a navegar a uno específico
        test_url = "https://www.escaperoomlover.com/es/juego/madland-algete-magic-universe"
        print(f"\n🧪 Probando URL específica: {test_url}")
        page.goto(test_url, timeout=20000)
        time.sleep(2)

        # Extraer título
        try:
            titulo = page.locator('h1').first.inner_text()
            print(f"✅ Título encontrado: {titulo}")
        except:
            print("❌ No se pudo extraer el título")

        # Buscar h2/h3
        print("\n📌 Headings encontrados:")
        try:
            for heading in page.query_selector_all('h2, h3, h4'):
                text = heading.inner_text().strip()
                if text and len(text) < 100:  # Solo textos cortos
                    print(f"  - {text}")
        except:
            pass

        browser.close()
        print("\n✅ Test completado")

if __name__ == "__main__":
    test_escaperoomlover()
