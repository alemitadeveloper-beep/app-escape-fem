#!/usr/bin/env python3
"""
Mapeo manual de empresas conocidas con sus logos
"""

import json

# Mapeo de empresas conocidas con sus URLs de logo
COMPANY_LOGOS = {
    # Empresas españolas de escape rooms
    'madland': 'https://www.madlandescape.com/images/logo.png',
    'fox in a box': 'https://logo.clearbit.com/foxinabox.com',
    'escape room madrid': 'https://logo.clearbit.com/escaperoommadrid.es',
    'the escape': 'https://logo.clearbit.com/theescape.es',
    'parapark': 'https://logo.clearbit.com/parapark.com',
    'coco room': 'https://logo.clearbit.com/cocoroom.es',
    'prison island': 'https://logo.clearbit.com/prisonisland.com',
    'escape hunt': 'https://logo.clearbit.com/escapehunt.com',
    'trap': 'https://logo.clearbit.com/trap.es',
    'misterius escape': 'https://logo.clearbit.com/misteriusescape.com',
    'lock clock': 'https://logo.clearbit.com/lockclock.es',
    'mastermind': 'https://logo.clearbit.com/mastermindescaperoom.com',
    'the rombo code': 'https://logo.clearbit.com/therombocode.com',
    'clue hunter': 'https://logo.clearbit.com/cluehunter.es',
    'exit game': 'https://logo.clearbit.com/exit-game.es',
    'enigma exprés': 'https://logo.clearbit.com/enigmaexpres.com',
}


def get_logo_for_company(empresa_name, web_url=None):
    """
    Obtiene el logo para una empresa
    Prioridad:
    1. Mapeo manual de empresas conocidas
    2. Logo desde el dominio web (Clearbit)
    3. Logo genérico con iniciales
    """

    if not empresa_name:
        empresa_name = ""

    empresa_lower = empresa_name.lower().strip()

    # 1. Verificar mapeo manual
    for company_key, logo_url in COMPANY_LOGOS.items():
        if company_key in empresa_lower:
            return logo_url

    # 2. Si tiene web válida, usar Clearbit
    if web_url and web_url not in ['/', '#', '']:
        from urllib.parse import urlparse

        url = web_url if web_url.startswith('http') else f'https://{web_url}'
        try:
            parsed = urlparse(url)
            domain = (parsed.netloc or parsed.path).replace('www.', '').split('/')[0]
            if domain and '.' in domain:
                return f"https://logo.clearbit.com/{domain}?size=400"
        except:
            pass

    # 3. Logo genérico con iniciales
    if empresa_name:
        words = empresa_name.split()[:2]
        initials = ''.join([w[0].upper() for w in words if w])
        if not initials:
            initials = 'ER'
        return f"https://ui-avatars.com/api/?name={initials}&size=400&background=001F54&color=fff&bold=true&font-size=0.4"

    return "https://ui-avatars.com/api/?name=ER&size=400&background=001F54&color=fff&bold=true&font-size=0.4"


def main():
    """Actualiza los logos usando el mapeo de empresas"""

    print("="*70)
    print("🏢 ACTUALIZANDO LOGOS CON MAPEO DE EMPRESAS")
    print("="*70)

    json_path = "/Users/alejandra/escape_room_application/assets/escape_rooms_completo.json"

    with open(json_path, 'r', encoding='utf-8') as f:
        escape_rooms = json.load(f)

    print(f"📊 {len(escape_rooms)} escape rooms encontrados\n")

    # Estadísticas
    stats = {
        'manual_mapping': 0,
        'clearbit_domain': 0,
        'generic_initials': 0,
        'generic_er': 0
    }

    for idx, room in enumerate(escape_rooms, 1):
        empresa = room.get('empresa', '')
        web = room.get('web', '')
        nombre = room.get('nombre', room.get('text', ''))

        # Obtener logo
        old_logo = room.get('imagenUrl', '')
        logo_url = get_logo_for_company(empresa, web)
        room['imagenUrl'] = logo_url

        # Estadísticas
        empresa_lower = empresa.lower() if empresa else ''
        found_in_mapping = any(key in empresa_lower for key in COMPANY_LOGOS.keys())

        if found_in_mapping:
            stats['manual_mapping'] += 1
        elif web and web not in ['/', '#', ''] and 'clearbit.com' in logo_url:
            stats['clearbit_domain'] += 1
        elif empresa and 'ui-avatars' in logo_url:
            stats['generic_initials'] += 1
        else:
            stats['generic_er'] += 1

        if idx % 100 == 0:
            print(f"[{idx}/{len(escape_rooms)}] Procesados...")

    # Guardar
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(escape_rooms, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ Logos actualizados para {len(escape_rooms)} escape rooms")
    print(f"{'='*70}")
    print(f"\n📊 Distribución de logos:")
    print(f"  🎯 Empresas conocidas (mapeo manual): {stats['manual_mapping']}")
    print(f"  🌐 Logos desde dominio web: {stats['clearbit_domain']}")
    print(f"  🔤 Logos con iniciales de empresa: {stats['generic_initials']}")
    print(f"  📦 Logos genéricos: {stats['generic_er']}")


if __name__ == "__main__":
    main()
