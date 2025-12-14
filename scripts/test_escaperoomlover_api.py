#!/usr/bin/env python3
"""
Script para detectar si escaperoomlover.com tiene una API
Captura todas las llamadas de red para ver si hay endpoints de API
"""

from playwright.sync_api import sync_playwright
import time
import json

def test_api():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        # Capturar todas las peticiones de red
        requests = []
        responses = []

        def handle_request(request):
            # Filtrar solo APIs (JSON, AJAX, etc.)
            if any(keyword in request.url for keyword in ['api', 'json', 'ajax', 'graphql', 'data']):
                requests.append({
                    'url': request.url,
                    'method': request.method,
                    'headers': dict(request.headers)
                })

        def handle_response(response):
            if any(keyword in response.url for keyword in ['api', 'json', 'ajax', 'graphql', 'data']):
                try:
                    content_type = response.headers.get('content-type', '')
                    responses.append({
                        'url': response.url,
                        'status': response.status,
                        'content_type': content_type
                    })
                except:
                    pass

        page.on('request', handle_request)
        page.on('response', handle_response)

        print("🔍 Navegando a escaperoomlover.com/es/ciudad/madrid...")
        page.goto("https://www.escaperoomlover.com/es/ciudad/madrid", timeout=30000)
        time.sleep(3)

        # Scroll para activar más peticiones
        for i in range(3):
            page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
            time.sleep(1)

        browser.close()

        # Analizar resultados
        print(f"\n📋 Peticiones a APIs encontradas: {len(requests)}")
        if requests:
            print("\n🔗 URLs de API:")
            for req in requests:
                print(f"  [{req['method']}] {req['url']}")

        print(f"\n📥 Respuestas de API: {len(responses)}")
        if responses:
            print("\n📊 Detalles de respuestas:")
            for resp in responses:
                print(f"  [{resp['status']}] {resp['content_type']}")
                print(f"      {resp['url']}")

        # Intentar obtener datos de una API si existe
        if responses:
            print("\n🧪 Intentando obtener datos de la API...")
            with sync_playwright() as p2:
                browser2 = p2.chromium.launch(headless=True)
                context = browser2.new_context()
                page2 = context.new_page()

                # Probar la primera API que encontramos
                for resp in responses:
                    if 'json' in resp['content_type'].lower():
                        try:
                            print(f"\n📡 Probando: {resp['url']}")
                            response = page2.goto(resp['url'], timeout=10000)
                            if response.status == 200:
                                try:
                                    data = response.json()
                                    print(f"✅ Datos JSON recibidos:")
                                    print(json.dumps(data, indent=2, ensure_ascii=False)[:500])
                                    break
                                except:
                                    text = response.text()
                                    print(f"✅ Respuesta (primeros 500 chars):")
                                    print(text[:500])
                                    break
                        except Exception as e:
                            print(f"  ❌ Error: {e}")

                browser2.close()

if __name__ == "__main__":
    test_api()
