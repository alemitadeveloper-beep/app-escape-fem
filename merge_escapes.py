# scrape_escaperoos.py
import json
import os
import re
import time
from urllib.parse import urlparse, parse_qs

from playwright.sync_api import sync_playwright

# Librerías opcionales/extra
try:
    import tldextract  # pip install tldextract
except Exception:
    tldextract = None

try:
    import requests  # pip install requests (solo si activas SerpAPI)
except Exception:
    requests = None


# =============== Ajustes de prueba ===============
MAX_ROOMS = 5          # <-- Solo 5 salas para probar
USE_SERPAPI = False    # <-- Pon True si quieres usar SerpAPI
OUTPUT_FILE = "escape_rooms_scraped_test.json"
# =================================================


# Hosts/fragmentos que NO queremos como "web oficial"
BAD_HOST_SNIPPETS = {
    "facebook.com", "instagram.com", "twitter.com", "x.com",
    "tiktok.com", "youtube.com", "wa.me", "web.whatsapp.com",
    "goo.gl", "bit.ly", "linktr.ee", "forms.gle",
    "google.com/maps", "maps.google", "google.com/search",
    "escaperoos.es"
}


def _looks_like_valid_host(host: str) -> bool:
    """Acepta hosts con dominio y TLD reales; rechaza 'escape-room-espana', 'localhost', etc."""
    if not host:
        return False
    host = host.strip().lower()
    if host.startswith("www."):
        host = host[4:]

    if host in {"escape-room-espana"}:
        return False

    # Debe tener al menos un punto si no tenemos tldextract
    if tldextract is None:
        return "." in host

    ext = tldextract.extract(host)
    # ext.domain => 'example', ext.suffix => 'com'
    if not ext.domain or not ext.suffix:
        return False
    if len(ext.suffix) < 2:
        return False
    return True


def _normalize_url(url: str) -> str:
    """Normaliza una URL y la invalida si no es útil como web oficial."""
    if not url:
        return ""
    u = url.strip()
    if u in ("/", "#") or u.startswith("#") or u.lower().startswith("javascript:"):
        return ""
    if u.startswith("//"):
        u = "https:" + u
    if not u.startswith("http"):
        if u.startswith("#"):
            return ""
        u = "https://" + u.lstrip("/")
    pu = urlparse(u)
    if not pu.hostname or not _looks_like_valid_host(pu.hostname):
        return ""
    return u


def _is_bad_external(href: str) -> bool:
    """Filtra enlaces externos que no sirven como 'web' del escape."""
    h = (href or "").strip().lower()
    if not h:
        return True
    if h.startswith("mailto:") or h.startswith("tel:"):
        return True
    if any(s in h for s in BAD_HOST_SNIPPETS):
        return True
    pu = urlparse(h)
    if not pu.hostname or not _looks_like_valid_host(pu.hostname):
        return True
    if "escaperoos.es" in (pu.hostname or ""):
        return True
    # Solo fragmento
    if pu.fragment and not pu.path and not pu.query:
        return True
    return False


def _pick_best_external(candidates):
    """
    Elige la mejor candidata como web oficial:
    - Debe pasar _normalize_url y _is_bad_external
    - Heurísticas simples de puntuación
    """
    scored = []
    seen = set()
    for c in candidates:
        u = _normalize_url(c)
        if not u or _is_bad_external(u):
            continue
        if u in seen:
            continue
        seen.add(u)

        score = 0
        pu = urlparse(u)
        host = (pu.hostname or "").lower()

        # https suma
        if u.startswith("https://"):
            score += 2
        # Palabras clave
        if "escape" in u.lower():
            score += 2
        if "room" in u.lower():
            score += 1
        # Home simples
        if pu.path in ("", "/", "/es", "/inicio", "/home"):
            score += 1
        # Menos query → mejor
        if not pu.query:
            score += 1
        # Penaliza subdominios típicos no-home
        if host.startswith("blog.") or host.startswith("store."):
            score -= 1

        scored.append((score, u))

    if not scored:
        return ""
    scored.sort(key=lambda x: x[0], reverse=True)
    return scored[0][1]


def _hostname_to_brand(url: str) -> str:
    """Deducción de 'empresa' a partir del hostname."""
    try:
        pu = urlparse(url)
        host = (pu.hostname or "").lower()
        host = host.replace("www.", "")
        base = host.split(".")[0]
        name = base.replace("-", " ").replace("_", " ").strip()
        return " ".join([w.capitalize() for w in name.split() if w])
    except Exception:
        return ""


def _extract_lat_lng_from_links(hrefs):
    """
    Busca patrones lat,lng en enlaces típicos de Google Maps:
    - .../maps/place/lat,lng
    - ...maps?q=lat,lng
    """
    for href in hrefs:
        h = (href or "").strip()
        if not h:
            continue
        # Si es URL, parsea query también
        try:
            pu = urlparse(h if h.startswith("http") else "https://" + h.lstrip("/"))
        except Exception:
            continue

        # 1) /maps/place/lat,lng
        m = re.search(r"/maps/place/([\-0-9.]+),([\-0-9.]+)", pu.path)
        if m:
            try:
                lat = float(m.group(1))
                lng = float(m.group(2))
                return lat, lng
            except Exception:
                pass

        # 2) ...maps
