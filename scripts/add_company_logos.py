#!/usr/bin/env python3
"""
Script para agregar logos de empresas a los escape rooms
Usa Clearbit Logo API que proporciona logos basados en el dominio de la empresa
"""

import json
import re
from urllib.parse import urlparse

def extract_domain(url):
    """Extrae el dominio limpio de una URL"""
    if not url or url in ['/', '#', '']:
        return None

    # Agregar https si no tiene protocolo
    if not url.startswith('http'):
        url = 'https://' + url

    try:
        parsed = urlparse(url)
        domain = parsed.netloc or parsed.path
        # Limpiar www.
        domain = domain.replace('www.', '')
        # Tomar solo el dominio principal
        parts = domain.split('/')
        domain = parts[0] if parts else domain
        return domain if domain else None
    except:
        return None


def get_company_logo_url(web_url, company_name=None):
    """
    Obtiene la URL del logo de la empresa usando Clearbit Logo API
    https://clearbit.com/logo
    """
    domain = extract_domain(web_url)

    if not domain:
        # Si no hay dominio válido, usar un logo genérico basado en el nombre
        if company_name:
            # Logo genérico con las iniciales
            initials = ''.join([word[0].upper() for word in company_name.split()[:2]])
            return f"https://ui-avatars.com/api/?name={initials}&size=400&background=001F54&color=fff&bold=true"
        else:
            # Logo genérico de escape room
            return "https://ui-avatars.com/api/?name=ER&size=400&background=001F54&color=fff&bold=true"

    # Usar Clearbit Logo API
    # Tamaño 400x400 para buena calidad
    return f"https://logo.clearbit.com/{domain}?size=400"


def main():
    """Agrega logos de empresas a todos los escape rooms"""

    print("="*70)
    print("🏢 AGREGANDO LOGOS DE EMPRESAS")
    print("="*70)

    # Leer JSON
    json_path = "/Users/alejandra/escape_room_application/assets/escape_rooms_completo.json"

    with open(json_path, 'r', encoding='utf-8') as f:
        escape_rooms = json.load(f)

    print(f"📊 {len(escape_rooms)} escape rooms encontrados\n")

    # Estadísticas
    with_valid_domain = 0
    with_company_name = 0
    generic_logo = 0

    for idx, room in enumerate(escape_rooms, 1):
        web = room.get('web', '')
        empresa = room.get('empresa', '')
        nombre = room.get('nombre', room.get('text', ''))

        # Generar URL del logo
        logo_url = get_company_logo_url(web, empresa or nombre)
        room['imagenUrl'] = logo_url

        # Estadísticas
        if extract_domain(web):
            with_valid_domain += 1
        elif empresa:
            with_company_name += 1
        else:
            generic_logo += 1

        if idx % 100 == 0:
            print(f"[{idx}/{len(escape_rooms)}] Procesados...")

    # Guardar JSON actualizado
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(escape_rooms, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ Logos agregados a {len(escape_rooms)} escape rooms")
    print(f"{'='*70}")
    print(f"\n📊 Estadísticas:")
    print(f"  🌐 Con dominio web válido: {with_valid_domain}")
    print(f"  🏢 Con nombre de empresa: {with_company_name}")
    print(f"  📦 Con logo genérico: {generic_logo}")
    print(f"\n💡 Los logos se obtienen de:")
    print(f"  - Clearbit Logo API (para dominios web)")
    print(f"  - UI Avatars (para empresas sin web)")


if __name__ == "__main__":
    main()
