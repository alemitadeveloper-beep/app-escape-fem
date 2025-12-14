#!/usr/bin/env python3
"""
Script mejorado de scraping multi-fuente para detectar escape rooms nuevos en España.
Soporta: escaperoomlover.com, todoescaperooms.com, escaperoos.es, escapeup.es

Características:
- Detección inteligente de duplicados por nombre + ubicación
- Integración con SQLite local para verificar escapes existentes
- Exportación a JSON para importar en la app Flutter
- Scraping robusto con reintentos y manejo de errores
- Extracción mejorada de coordenadas y metadatos
"""

import json
import os
import sqlite3
import time
import re
import hashlib
from typing import List, Dict, Optional, Set, Tuple
from urllib.parse import urljoin, urlparse
from difflib import SequenceMatcher
from playwright.sync_api import sync_playwright, Page, TimeoutError as PlaywrightTimeoutError
import logging

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('scraping.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class EscapeRoomUnifiedScraper:
    """Scraper unificado y mejorado para múltiples fuentes"""

    def __init__(self, db_path: str = None):
        """
        Inicializa el scraper

        Args:
            db_path: Ruta a la base de datos SQLite para verificar duplicados
        """
        self.db_path = db_path or "assets/database/words.db"
        self.existing_rooms: Set[str] = set()
        self.scraped_rooms: List[Dict] = []
        self.stats = {
            'total_scraped': 0,
            'duplicates': 0,
            'new_rooms': 0,
            'errors': 0
        }

        # Filtros de URLs no deseadas
        self.bad_domains = {
            'facebook.com', 'instagram.com', 'twitter.com', 'x.com',
            'tiktok.com', 'youtube.com', 'wa.me', 'whatsapp.com',
            'google.com/maps', 'maps.google', 'tripadvisor', 'booking.com'
        }

        # Cargar escapes existentes de la BD
        self._load_existing_rooms()

    def _load_existing_rooms(self):
        """Carga los escape rooms existentes de SQLite para evitar duplicados"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()

            # Obtener nombres y ubicaciones existentes
            cursor.execute("SELECT text, ubicacion FROM word")

            for nombre, ubicacion in cursor.fetchall():
                # Crear clave normalizada para comparación
                key = self._normalize_key(nombre, ubicacion)
                self.existing_rooms.add(key)

            conn.close()
            logger.info(f"✅ Cargados {len(self.existing_rooms)} escape rooms existentes de la BD")

        except Exception as e:
            logger.warning(f"⚠️ No se pudo cargar la BD existente: {e}")
            logger.info("ℹ️ Se continuará sin verificación de duplicados en BD")

    def _normalize_key(self, nombre: str, ubicacion: str) -> str:
        """
        Normaliza nombre + ubicación para detectar duplicados

        Args:
            nombre: Nombre del escape room
            ubicacion: Ubicación/ciudad

        Returns:
            Clave normalizada única
        """
        # Limpieza agresiva
        nombre = re.sub(r'[^\w\s]', '', nombre.lower().strip())
        nombre = re.sub(r'\s+', ' ', nombre)

        # Extraer ciudad de la ubicación
        ciudad = self._extract_city(ubicacion)

        # Crear hash para comparación rápida
        key = f"{nombre}_{ciudad}".lower()
        return hashlib.md5(key.encode()).hexdigest()

    def _extract_city(self, ubicacion: str) -> str:
        """Extrae la ciudad principal de una dirección completa"""
        if not ubicacion:
            return ""

        # Ciudades españolas comunes
        ciudades = [
            'madrid', 'barcelona', 'valencia', 'sevilla', 'zaragoza',
            'málaga', 'murcia', 'bilbao', 'alicante', 'córdoba',
            'valladolid', 'vigo', 'gijón', 'hospitalet', 'coruña',
            'granada', 'vitoria', 'elche', 'oviedo', 'santander',
            'salamanca', 'pamplona', 'toledo', 'león', 'cádiz'
        ]

        ubicacion_lower = ubicacion.lower()
        for ciudad in ciudades:
            if ciudad in ubicacion_lower:
                return ciudad.capitalize()

        # Si no encuentra ciudad conocida, tomar primera palabra significativa
        words = re.findall(r'\b[A-ZÁÉÍÓÚa-záéíóú]{3,}\b', ubicacion)
        return words[0] if words else ""

    def _is_duplicate(self, nombre: str, ubicacion: str) -> bool:
        """
        Verifica si un escape room es duplicado

        Args:
            nombre: Nombre del escape room
            ubicacion: Ubicación

        Returns:
            True si es duplicado, False si es nuevo
        """
        key = self._normalize_key(nombre, ubicacion)

        # Verificar contra BD existente
        if key in self.existing_rooms:
            return True

        # Verificar contra lo ya scrapeado en esta sesión
        for room in self.scraped_rooms:
            existing_key = self._normalize_key(room['nombre'], room['ubicacion'])
            if key == existing_key:
                return True

            # Similitud de nombre (85% o más = duplicado)
            similarity = SequenceMatcher(None, nombre.lower(), room['nombre'].lower()).ratio()
            if similarity >= 0.85 and self._extract_city(ubicacion) == self._extract_city(room['ubicacion']):
                return True

        return False

    def _clean_text(self, text: Optional[str]) -> str:
        """Limpia y normaliza texto"""
        if not text:
            return ""
        text = text.strip()
        text = re.sub(r'\s+', ' ', text)
        text = re.sub(r'[\r\n\t]+', ' ', text)
        return text if text not in ['No disponible', '/', '#', 'null', 'N/A'] else ""

    def _is_valid_url(self, url: str) -> bool:
        """Verifica si una URL es válida para web oficial"""
        if not url:
            return False

        try:
            parsed = urlparse(url)
            if not parsed.hostname:
                return False

            # Filtrar dominios no deseados
            for bad in self.bad_domains:
                if bad in parsed.hostname.lower():
                    return False

            return True
        except:
            return False

    def _extract_coordinates(self, page: Page) -> Tuple[float, float]:
        """Extrae coordenadas GPS de enlaces de Google Maps"""
        try:
            # Buscar todos los enlaces
            links = page.query_selector_all('a[href*="maps"]')

            for link in links:
                href = link.get_attribute('href')
                if not href:
                    continue

                # Patrón 1: @lat,lng,zoom
                match = re.search(r'@(-?\d+\.\d+),(-?\d+\.\d+),', href)
                if match:
                    return float(match.group(1)), float(match.group(2))

                # Patrón 2: /place/lat,lng
                match = re.search(r'/place/(-?\d+\.\d+),(-?\d+\.\d+)', href)
                if match:
                    return float(match.group(1)), float(match.group(2))

                # Patrón 3: ?q=lat,lng
                match = re.search(r'[?&]q=(-?\d+\.\d+),(-?\d+\.\d+)', href)
                if match:
                    return float(match.group(1)), float(match.group(2))

        except Exception as e:
            logger.debug(f"Error extrayendo coordenadas: {e}")

        return 0.0, 0.0

    # ===========================================
    # SCRAPER: escaperoomlover.com
    # ===========================================

    def scrape_escaperoomlover(self, page: Page) -> List[Dict]:
        """Scraping mejorado de escaperoomlover.com - navega por ciudades principales"""
        logger.info("🔍 Scraping escaperoomlover.com...")
        results = []

        try:
            # Principales ciudades españolas a scrapear
            ciudades = ['madrid', 'barcelona', 'valencia', 'sevilla', 'zaragoza', 'bilbao', 'granada']

            room_links = set()

            for ciudad in ciudades:
                try:
                    city_url = f"https://www.escaperoomlover.com/es/ciudad/{ciudad}"
                    logger.info(f"🏙️ Scraping ciudad: {ciudad}")
                    page.goto(city_url, timeout=30000)
                    time.sleep(2)

                    # Aceptar cookies (solo en la primera página)
                    if ciudad == ciudades[0]:
                        try:
                            page.locator("button:has-text('Aceptar')").first.click(timeout=3000)
                            time.sleep(1)
                        except:
                            pass

                    # Scroll para cargar más contenido
                    for _ in range(3):
                        try:
                            page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
                            time.sleep(1)
                        except:
                            pass

                    # Buscar enlaces a juegos (patrón: /es/juego/*)
                    for link in page.query_selector_all('a[href]'):
                        href = link.get_attribute('href')
                        if href and '/juego/' in href:
                            full_url = urljoin("https://www.escaperoomlover.com", href)
                            if '/es/juego/' in full_url and not full_url.endswith('/es/juego/'):
                                room_links.add(full_url)

                except Exception as e:
                    logger.error(f"Error scrapeando ciudad {ciudad}: {e}")
                    continue

            logger.info(f"📋 Encontrados {len(room_links)} enlaces en escaperoomlover.com")

            # Visitar cada sala
            for idx, url in enumerate(list(room_links)[:100]):  # Aumentar a 100
                try:
                    logger.info(f"[{idx+1}/{min(len(room_links), 100)}] Visitando {url}")
                    page.goto(url, timeout=20000)
                    time.sleep(1)

                    # Extraer nombre del juego
                    nombre = ""
                    try:
                        nombre = self._clean_text(page.locator('h1').first.inner_text())
                    except:
                        continue

                    if not nombre or nombre == "":
                        continue

                    # Extraer ubicación y empresa
                    ubicacion = ""
                    empresa = ""
                    try:
                        # En escaperoomlover, el h2 o h3 suele tener el local/empresa
                        for heading in page.query_selector_all('h2, h3'):
                            text = self._clean_text(heading.inner_text())
                            if text and text != nombre:
                                empresa = text
                                break

                        # Buscar elementos con ubicación
                        for el in page.query_selector_all('div, span, p'):
                            text = self._clean_text(el.inner_text())
                            # Buscar patrones de ciudades españolas
                            if any(city in text for city in ['Madrid', 'Barcelona', 'Valencia', 'Sevilla', 'Zaragoza', 'Málaga', 'Bilbao', 'Murcia', 'Alicante', 'Granada', 'Córdoba']):
                                if len(text) < 200:  # Evitar textos muy largos
                                    ubicacion = text
                                    break
                    except:
                        pass

                    if not ubicacion:
                        ubicacion = "España"

                    # Verificar duplicado
                    if self._is_duplicate(nombre, ubicacion):
                        logger.info(f"⏭️ Duplicado: {nombre}")
                        self.stats['duplicates'] += 1
                        continue

                    # Web - usar la URL de escaperoomlover
                    web = url

                    # Coordenadas
                    lat, lng = self._extract_coordinates(page)

                    # Crear registro
                    room = {
                        'nombre': nombre,
                        'ubicacion': ubicacion,
                        'web': web,
                        'genero': "",
                        'puntuacion': "",
                        'precio': "",
                        'jugadores': "",
                        'duracion': "",
                        'descripcion': "",
                        'empresa': empresa,
                        'telefono': "",
                        'latitud': lat,
                        'longitud': lng,
                        'source': 'escaperoomlover.com'
                    }

                    results.append(room)
                    self.stats['new_rooms'] += 1
                    logger.info(f"✅ Nuevo: {nombre}")

                    time.sleep(1.5)  # Rate limiting más conservador

                except Exception as e:
                    logger.error(f"Error procesando {url}: {e}")
                    self.stats['errors'] += 1
                    continue

        except Exception as e:
            logger.error(f"Error en escaperoomlover.com: {e}")

        return results

    # ===========================================
    # SCRAPER: todoescaperooms.com
    # ===========================================

    def scrape_todoescaperooms(self, page: Page) -> List[Dict]:
        """Scraping mejorado de todoescaperooms.com"""
        logger.info("🔍 Scraping todoescaperooms.com...")
        results = []

        try:
            base_url = "https://www.todoescaperooms.com"
            page.goto(f"{base_url}/salas", timeout=30000)
            page.wait_for_load_state('networkidle')

            # Aceptar cookies
            try:
                page.locator("button:has-text('Aceptar')").first.click(timeout=3000)
            except:
                pass

            # Buscar listado de salas
            room_cards = page.query_selector_all('[class*="sala"], [class*="escape"], [class*="card"]')
            logger.info(f"📋 Encontradas {len(room_cards)} salas en todoescaperooms.com")

            for idx, card in enumerate(room_cards[:50]):
                try:
                    # Nombre
                    nombre_el = card.query_selector('h2, h3, h4, .title, .nombre')
                    if not nombre_el:
                        continue

                    nombre = self._clean_text(nombre_el.inner_text())
                    if not nombre:
                        continue

                    # Ubicación
                    ubicacion = ""
                    ubicacion_el = card.query_selector('[class*="ciudad"], [class*="location"]')
                    if ubicacion_el:
                        ubicacion = self._clean_text(ubicacion_el.inner_text())

                    # Verificar duplicado
                    if self._is_duplicate(nombre, ubicacion):
                        logger.info(f"⏭️ Duplicado: {nombre}")
                        self.stats['duplicates'] += 1
                        continue

                    # Web oficial
                    web = ""
                    link_el = card.query_selector('a[href]')
                    if link_el:
                        href = link_el.get_attribute('href')
                        if href and self._is_valid_url(href):
                            web = urljoin(base_url, href)

                    room = {
                        'nombre': nombre,
                        'ubicacion': ubicacion,
                        'web': web,
                        'genero': "",
                        'puntuacion': "",
                        'precio': "",
                        'jugadores': "",
                        'duracion': "",
                        'descripcion': "",
                        'empresa': "",
                        'telefono': "",
                        'latitud': 0.0,
                        'longitud': 0.0,
                        'source': 'todoescaperooms.com'
                    }

                    results.append(room)
                    self.stats['new_rooms'] += 1
                    logger.info(f"✅ Nuevo: {nombre}")

                except Exception as e:
                    logger.debug(f"Error procesando card: {e}")
                    continue

        except Exception as e:
            logger.error(f"Error en todoescaperooms.com: {e}")

        return results

    # ===========================================
    # SCRAPER: escaperoos.es
    # ===========================================

    def scrape_escaperoos(self, page: Page) -> List[Dict]:
        """Scraping mejorado de escaperoos.es"""
        logger.info("🔍 Scraping escaperoos.es...")
        results = []

        try:
            base_url = "https://escaperoos.es/escape-room-espana"
            page.goto(base_url, timeout=30000)
            page.wait_for_load_state('networkidle')

            # Aceptar cookies
            try:
                page.locator("button:has-text('Aceptar')").first.click(timeout=3000)
            except:
                pass

            # Obtener provincias
            province_links = set()
            for link in page.query_selector_all('a[href*="/escape-rooms-"]'):
                href = link.get_attribute('href')
                if href:
                    full_url = urljoin("https://escaperoos.es", href)
                    province_links.add(full_url)

            logger.info(f"📋 Encontradas {len(province_links)} provincias en escaperoos.es")

            # Por cada provincia, obtener salas
            all_room_links = set()
            for prov_url in list(province_links)[:10]:  # Limitar provincias
                try:
                    page.goto(prov_url, timeout=20000)
                    page.wait_for_load_state('networkidle')

                    for link in page.query_selector_all('a[href*="/escape-room/"]'):
                        href = link.get_attribute('href')
                        if href and not href.endswith('-espana'):
                            full_url = urljoin("https://escaperoos.es", href)
                            all_room_links.add(full_url)

                    time.sleep(0.5)
                except Exception as e:
                    logger.debug(f"Error en provincia {prov_url}: {e}")

            logger.info(f"📋 Total de {len(all_room_links)} salas encontradas")

            # Visitar cada sala
            for idx, url in enumerate(list(all_room_links)[:50]):
                try:
                    logger.info(f"[{idx+1}/{len(all_room_links)}] Visitando {url}")
                    page.goto(url, timeout=20000)
                    page.wait_for_load_state('networkidle')

                    nombre = self._clean_text(page.locator('h1').first.inner_text())
                    if not nombre:
                        continue

                    # Ubicación
                    ubicacion = ""
                    try:
                        for span in page.query_selector_all('span'):
                            text = span.inner_text()
                            if 'España' in text:
                                ubicacion = text.replace('Abrir mapa', '').strip()
                                break
                    except:
                        pass

                    # Verificar duplicado
                    if self._is_duplicate(nombre, ubicacion):
                        logger.info(f"⏭️ Duplicado: {nombre}")
                        self.stats['duplicates'] += 1
                        continue

                    # Coordenadas
                    lat, lng = self._extract_coordinates(page)

                    room = {
                        'nombre': nombre,
                        'ubicacion': ubicacion,
                        'web': "",
                        'genero': "",
                        'puntuacion': "",
                        'precio': "",
                        'jugadores': "",
                        'duracion': "",
                        'descripcion': "",
                        'empresa': "",
                        'telefono': "",
                        'latitud': lat,
                        'longitud': lng,
                        'source': 'escaperoos.es'
                    }

                    results.append(room)
                    self.stats['new_rooms'] += 1
                    logger.info(f"✅ Nuevo: {nombre}")

                    time.sleep(1)

                except Exception as e:
                    logger.error(f"Error procesando {url}: {e}")
                    self.stats['errors'] += 1

        except Exception as e:
            logger.error(f"Error en escaperoos.es: {e}")

        return results

    # ===========================================
    # SCRAPER: escapeup.es
    # ===========================================

    def scrape_escapeup(self, page: Page) -> List[Dict]:
        """Scraping mejorado de escapeup.es"""
        logger.info("🔍 Scraping escapeup.es...")
        results = []

        try:
            base_url = "https://escapeup.es"
            page.goto(f"{base_url}/salas-escape-room", timeout=30000)
            page.wait_for_load_state('networkidle')

            # Aceptar cookies
            try:
                page.locator("button:has-text('Aceptar')").first.click(timeout=3000)
            except:
                pass

            # Buscar salas
            room_links = set()
            for link in page.query_selector_all('a[href*="/sala/"], a[href*="/escape-room/"]'):
                href = link.get_attribute('href')
                if href:
                    full_url = urljoin(base_url, href)
                    room_links.add(full_url)

            logger.info(f"📋 Encontradas {len(room_links)} salas en escapeup.es")

            for idx, url in enumerate(list(room_links)[:50]):
                try:
                    logger.info(f"[{idx+1}/{len(room_links)}] Visitando {url}")
                    page.goto(url, timeout=20000)
                    page.wait_for_load_state('networkidle')

                    nombre = self._clean_text(page.locator('h1').first.inner_text())
                    if not nombre:
                        continue

                    # Ubicación
                    ubicacion = ""
                    try:
                        ubicacion_el = page.locator('[class*="location"], [class*="ciudad"]').first
                        ubicacion = self._clean_text(ubicacion_el.inner_text())
                    except:
                        pass

                    # Verificar duplicado
                    if self._is_duplicate(nombre, ubicacion):
                        logger.info(f"⏭️ Duplicado: {nombre}")
                        self.stats['duplicates'] += 1
                        continue

                    # Coordenadas
                    lat, lng = self._extract_coordinates(page)

                    room = {
                        'nombre': nombre,
                        'ubicacion': ubicacion,
                        'web': "",
                        'genero': "",
                        'puntuacion': "",
                        'precio': "",
                        'jugadores': "",
                        'duracion': "",
                        'descripcion': "",
                        'empresa': "",
                        'telefono': "",
                        'latitud': lat,
                        'longitud': lng,
                        'source': 'escapeup.es'
                    }

                    results.append(room)
                    self.stats['new_rooms'] += 1
                    logger.info(f"✅ Nuevo: {nombre}")

                    time.sleep(1)

                except Exception as e:
                    logger.error(f"Error procesando {url}: {e}")
                    self.stats['errors'] += 1

        except Exception as e:
            logger.error(f"Error en escapeup.es: {e}")

        return results

    # ===========================================
    # MÉTODO PRINCIPAL
    # ===========================================

    def run(self) -> List[Dict]:
        """Ejecuta el scraping completo de todas las fuentes"""
        logger.info("=" * 70)
        logger.info("🚀 INICIANDO SCRAPING MULTI-FUENTE DE ESCAPE ROOMS")
        logger.info("=" * 70)

        with sync_playwright() as p:
            # Lanzar navegador
            browser = p.chromium.launch(headless=True)
            context = browser.new_context(
                user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
            )
            page = context.new_page()

            try:
                # Scraping de cada fuente
                sources = [
                    ('escaperoomlover.com', self.scrape_escaperoomlover),
                    ('todoescaperooms.com', self.scrape_todoescaperooms),
                    ('escaperoos.es', self.scrape_escaperoos),
                    ('escapeup.es', self.scrape_escapeup),
                ]

                for source_name, scraper_func in sources:
                    try:
                        logger.info(f"\n🌐 Iniciando {source_name}...")
                        results = scraper_func(page)
                        self.scraped_rooms.extend(results)
                        self.stats['total_scraped'] += len(results)
                        logger.info(f"✅ {source_name}: {len(results)} nuevos escape rooms")
                    except Exception as e:
                        logger.error(f"❌ Error en {source_name}: {e}")
                        self.stats['errors'] += 1

            finally:
                browser.close()

        logger.info("\n" + "=" * 70)
        logger.info("📊 RESUMEN DE SCRAPING")
        logger.info("=" * 70)
        logger.info(f"✅ Total scrapeados: {self.stats['total_scraped']}")
        logger.info(f"⏭️ Duplicados omitidos: {self.stats['duplicates']}")
        logger.info(f"🆕 Nuevos escape rooms: {self.stats['new_rooms']}")
        logger.info(f"❌ Errores: {self.stats['errors']}")

        return self.scraped_rooms

    def export_to_json(self, filename: str = "nuevos_escape_rooms.json"):
        """Exporta los resultados a JSON"""
        # Si ya es una ruta absoluta, usarla directamente
        if os.path.isabs(filename):
            output_path = filename
        else:
            output_path = f"assets/{filename}"

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(self.scraped_rooms, f, ensure_ascii=False, indent=2)

        logger.info(f"\n💾 Exportado a: {output_path}")
        logger.info(f"📁 Total de registros: {len(self.scraped_rooms)}")


def main():
    """Función principal"""
    # Buscar la base de datos
    db_paths = [
        "assets/database/words.db",
        "../assets/database/words.db",
        "words.db"
    ]

    db_path = None
    for path in db_paths:
        import os
        if os.path.exists(path):
            db_path = path
            break

    # Crear scraper
    scraper = EscapeRoomUnifiedScraper(db_path=db_path)

    # Ejecutar scraping
    results = scraper.run()

    # Exportar resultados
    if results:
        # Escribir en el directorio scripts donde se ejecuta el script
        output_path = os.path.join(os.path.dirname(__file__), "nuevos_escape_rooms.json")
        scraper.export_to_json(output_path)
        logger.info("\n🎉 ¡Scraping completado exitosamente!")
    else:
        logger.warning("\n⚠️ No se encontraron escape rooms nuevos")


if __name__ == "__main__":
    main()
