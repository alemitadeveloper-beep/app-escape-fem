# scrape_escaperoos.py
import json
import time
import re
from urllib.parse import urlparse, parse_qs
from playwright.sync_api import sync_playwright

# --- Configuración de filtros de enlaces externos no deseados ---
BAD_HOST_SNIPPETS = (
    "google.com/maps", "maps.google.", "maps.app.goo.gl", "goo.gl",
    "facebook.", "instagram.", "twitter.", "tiktok.", "tripadvisor.",
    "wa.me", "api.whatsapp", "youtube.", "youtu.be", "linkedin.",
    "escaperoos.es",
)

# ---------- URL helpers ----------
def _normalize_url(url: str) -> str:
    """Normaliza urls:
      - ignora "#", "/", "javascript:"
      - añade https:// si falta
      - descarta si no hay hostname
    """
    if not url:
        return ""
    u = url.strip()
    if u in ("/", "#") or u.startswith("#") or u.lower().startswith("javascript:"):
        return ""
    if u.startswith("//"):
        u = "https:" + u
    if not u.startswith("http"):
        # evitar 'https://#opinions'
        if u.startswith("#"):
            return ""
        u = "https://" + u.lstrip("/")
    pu = urlparse(u)
    if not pu.hostname:  # evita "https://#opinions"
        return ""
    return u

def _is_bad_external(href: str) -> bool:
    """Descarta correos, tel:, redes sociales, mapas, dominios internos, etc."""
    h = (href or "").strip().lower()
    if not h:
        return True
    if h.startswith("mailto:") or h.startswith("tel:"):
        return True
    if any(s in h for s in BAD_HOST_SNIPPETS):
        return True
    pu = urlparse(h)
    if not pu.hostname:
        return True
    if "escaperoos.es" in (pu.hostname or ""):
        return True
    # enlace que solo es fragmento
    if pu.fragment and not pu.path and not pu.query:
        return True
    return False

def _hostname_to_brand(url: str) -> str:
    """Deduce la marca desde el host de la web oficial."""
    try:
        u = _normalize_url(url)
        if not u:
            return ""
        host = urlparse(u).hostname or ""
        host = host.replace("www.", "").strip()
        base = host.split(".")[0]
        base = base.replace("-", " ").replace("_", " ").strip()
        return " ".join(w.capitalize() for w in base.split())
    except Exception:
        return ""

def _pick_best_external(candidates: list[str]) -> str:
    """Elige la mejor web externa candidata (propia de la sala)."""
    scored = []
    for href in candidates:
        u = _normalize_url(href)
        if not u or _is_bad_external(u):
            continue
        pu = urlparse(u)
        host = (pu.hostname or "").replace("www.", "")
        path = (pu.path or "/")
        score = 0
        # url de raíz suele ser mejor
        if path in ("/", ""):
            score += 3
        # paths cortos mejor que muy largos
        if len(path) <= 6:
            score += 1
        text = (host + path).lower()
        # dominios/nombres que huelen a escape room
        if "escape" in text or "scaperoom" in text or "scaperooms" in text:
            score += 2
        # cosas típicas menos útiles
        if any(x in text for x in ["/shop", "/tienda", "/book", "/reserva"]):
            score -= 1
        # muchas queries suelen ser menos limpias
        if pu.query:
            score -= 1
        scored.append((score, len(u), u))
    if not scored:
        return ""
    scored.sort(key=lambda t: (-t[0], t[1]))
    return scored[0][2]

# ---------- Empresa ----------
STOP_WORDS = {
    "escape", "room", "rooms", "escaperoom", "escape room",
    "the", "la", "el", "de", "del"
}

def _clean_company_text(raw: str) -> str:
    if not raw:
        return ""
    s = re.sub(r"[\r\n]+", " ", raw.strip())
    s = re.sub(r"\s+", " ", s)
    low = s.lower()
    # evita textos de "opiniones / términos / google..." que no son nombres
    if any(k in low for k in ["opiniones", "google", "términos", "terminos", "uso", "aviso"]):
        return ""
    if len(s) > 80:  # evita párrafos largos
        return ""
    s2 = re.sub(r"[^a-zA-Z0-9\sÁÉÍÓÚÜÑáéíóúüñ&'-]", " ", s)
    s2 = re.sub(r"\s+", " ", s2).strip()
    if not s2:
        return ""
    words = [w.capitalize() for w in s2.split()]
    candidate = " ".join(words)
    if candidate.lower() in STOP_WORDS:
        return ""
    return candidate

def _extract_company_from_page(page) -> str:
    """Intenta encontrar algo tipo 'Empresa: Foo' en el HTML."""
    try:
        full = (page.content() or "")
        m = re.search(r"(?:Empresa|Compañ[ií]a|Sala|Marca)\s*:\s*([^<\n\r]+)", full, flags=re.IGNORECASE)
        if m:
            val = _clean_company_text(m.group(1))
            if val:
                return val
    except Exception:
        pass
    try:
        for sel in ["li", "p", "strong", "span", "h2", "h3", "dt", "dd"]:
            for el in page.query_selector_all(sel):
                t = (el.inner_text() or "").strip()
                if ":" in t:
                    left, right = t.split(":", 1)
                    if any(k in left.lower() for k in ["empresa", "compañ", "company", "sala", "marca"]):
                        c = _clean_company_text(right)
                        if c:
                            return c
    except Exception:
        pass
    return ""

# ---------- Coordenadas ----------
def _coords_from_url(u: str):
    """Extrae lat/lng de URLs de Google Maps si están presentes."""
    try:
        pu = urlparse(u)
        q = parse_qs(pu.query)

        # 1) ...@lat,lng,zoomz
        m = re.search(r"@(-?\d+\.\d+),\s*(-?\d+\.\d+)", u)
        if m:
            return float(m.group(1)), float(m.group(2))

        # 2) .../place/lat,lng
        m = re.search(r"/place/(-?\d+\.\d+),\s*(-?\d+\.\d+)", u)
        if m:
            return float(m.group(1)), float(m.group(2))

        # 3) ?q=lat,lng o ?ll=lat,lng
        for key in ("q", "ll"):
            if key in q:
                val = q[key][0]
                mm = re.match(r"^\s*(-?\d+\.\d+),\s*(-?\d+\.\d+)\s*$", val)
                if mm:
                    return float(mm.group(1)), float(mm.group(2))
    except Exception:
        pass
    return None

def _extract_coords_from_page(page):
    """Busca links a Maps y devuelve la primera pareja (lat, lng) válida."""
    try:
        for a in page.query_selector_all("a[href]"):
            href = a.get_attribute("href") or ""
            href = _normalize_url(href)
            if not href:
                continue
            if "maps" not in href.lower():
                continue
            c = _coords_from_url(href)
            if c:
                return c[0], c[1]
    except Exception:
        pass
    return (0.0, 0.0)

# ---------- Scraper principal ----------
def scrape_escaperoos(page):
    base_url = "https://escaperoos.es/escape-room-espana"
    print("\n🌍 [Escaperoos] Cargando página principal...")
    page.goto(base_url, timeout=60_000)

    # Cookies
    try:
      page.locator("button:has-text('Aceptar'), text=Aceptar").first.click(timeout=3_000)
      print("🍪 Banner de cookies aceptado.")
    except Exception:
      pass

    page.wait_for_selector("a[href^='//escaperoos.es/escape-rooms-']", timeout=30_000)

    enlaces_provincias = list({
        "https:" + (a.get_attribute("href") or "")
        for a in page.query_selector_all("a[href^='//escaperoos.es/escape-rooms-']")
    })

    print(f"🔗 Provincias encontradas: {len(enlaces_provincias)}")

    escape_room_links = set()
    for provincia_url in enlaces_provincias:
        if not provincia_url:
            continue
        print(f"🔎 Buscando salas en: {provincia_url}")
        try:
            page.goto(provincia_url, timeout=60_000)
            page.wait_for_selector("a[href*='/escape-room/']", timeout=10_000)
            for a in page.query_selector_all("a[href*='/escape-room/']"):
                href = a.get_attribute("href") or ""
                if href and "/escape-room/" in href and not href.endswith("-espana"):
                    escape_room_links.add(href)
        except Exception as e:
            print(f"⚠️ No se pudo cargar {provincia_url}: {e}")

    print(f"🏁 Total escape rooms encontrados: {len(escape_room_links)}")

    rooms = []
    for idx, raw_link in enumerate(escape_room_links):
        link = raw_link or ""
        print(f"[{idx + 1}/{len(escape_room_links)}] Visitando {link}")
        try:
            # Absolutiza
            if link.startswith("/"):
                link = "https://escaperoos.es" + link
            elif link.startswith("//"):
                link = "https:" + link

            page.goto(link, timeout=60_000)
            page.wait_for_selector("h1", timeout=10_000)

            nombre_el = page.query_selector("h1")
            nombre = (nombre_el.inner_text().strip() if nombre_el else "").strip() or "Sin título"

            # Ubicación
            ubicacion = "No disponible"
            try:
                span_texts = page.locator("span").all_inner_texts()
                for text in span_texts:
                    if "España" in text:
                        ubicacion = text.replace("Abrir mapa", "").strip()
                        break
            except Exception:
                pass

            # Candidatas de web externa
            external_candidates = []
            for a in page.query_selector_all("a[href]"):
                href = a.get_attribute("href") or ""
                href = _normalize_url(href)
                if not href:
                    continue
                external_candidates.append(href)

            web = _pick_best_external(external_candidates)
            if not web:
                # como último recurso, deja vacío (mejor que "/")
                web = ""

            # Género
            genero = "No disponible"
            try:
                for li in page.query_selector_all("li"):
                    text = (li.inner_text() or "").strip()
                    if text.lower().startswith("temática:"):
                        genero = text.split(":", 1)[1].strip()
                        break
            except Exception:
                pass

            # Puntuación
            puntuacion = "No disponible"
            try:
                puntuacion_el = page.query_selector("span[style*='font-size: 16px']")
                if puntuacion_el:
                    raw = (puntuacion_el.inner_text() or "").strip()
                    if raw and raw[0].isdigit():
                        puntuacion = raw.split()[0]
            except Exception:
                pass

            # Precio, jugadores, duración (más estrictos para evitar "Términos de uso")
            precio = "No disponible"
            jugadores = "No disponible"
            duracion = "No disponible"
            for li in page.query_selector_all("li"):
                text_full = (li.inner_text() or "").strip()
                text = text_full.lower()
                if "€" in text and "desde" in text:
                    precio = text_full
                elif "jugador" in text:
                    jugadores = text_full
                elif re.search(r"\b\d+\s*min", text):  # ej: 60 min
                    duracion = text_full

            # Descripción
            descripcion = "No disponible"
            desc_el = page.query_selector("p.room_description")
            if desc_el:
                descripcion = (desc_el.inner_text() or "").strip()

            # Empresa (desde la página o deducida del host)
            empresa = _extract_company_from_page(page)
            if not empresa and web:
                empresa = _hostname_to_brand(web)

            # Coordenadas desde enlaces de mapa
            lat, lng = _extract_coords_from_page(page)

            rooms.append({
                "nombre": nombre,
                "ubicacion": ubicacion,
                "web": web,
                "genero": genero,
                "puntuacion": puntuacion,
                "precio": precio,
                "jugadores": jugadores,
                "duracion": duracion,
                "descripcion": descripcion,
                "empresa": empresa,
                "latitud": float(lat or 0.0),
                "longitud": float(lng or 0.0),
            })

        except Exception as e:
            print(f"⚠️ Error en {link}: {e}")

        time.sleep(0.2)

    return rooms

def main():
    with sync_playwright() as p:
        # Si tienes Chrome instalado y quieres usarlo:
        # browser = p.chromium.launch(channel="chrome", headless=False, slow_mo=50)
        browser = p.chromium.launch(headless=False, slow_mo=50)
        context = browser.new_context()
        page = context.new_page()

        rooms = scrape_escaperoos(page)
        browser.close()

        with open("escape_rooms_scraped.json", "w", encoding="utf-8") as f:
            json.dump(rooms, f, ensure_ascii=False, indent=2)

        print(f"\n✅ Guardado {len(rooms)} escape rooms en escape_rooms_scraped.json")

if __name__ == "__main__":
    main()
