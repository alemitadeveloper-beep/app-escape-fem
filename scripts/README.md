# Scripts de Scraping de Escape Rooms

Este directorio contiene scripts de Python para hacer scraping de escape rooms en España y actualizar la base de datos de la aplicación.

## 📋 Contenido

- `scrape_escape_rooms.py` - Script principal de scraping
- `merge_data.py` - Script para combinar datos nuevos con existentes
- `venv/` - Entorno virtual de Python (no incluido en Git)

## 🚀 Uso

### 1. Configurar entorno virtual

```bash
cd scripts
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Ejecutar scraping

```bash
python3 scrape_escape_rooms.py
```

Este script:
- Intenta hacer scraping de múltiples fuentes (RoomEscapes, TodoEscapeRooms, EscapeRoomLover)
- Genera datos de ejemplo de 15 escape rooms conocidos
- Guarda el resultado en `../assets/escape_rooms_nuevos.json`

**Nota:** Muchas páginas web tienen protección anti-scraping (Cloudflare, reCAPTCHA), por lo que el scraping automático puede fallar. En ese caso, el script genera datos de ejemplo de alta calidad.

### 3. Combinar con datos existentes

```bash
python3 merge_data.py
```

Este script:
- Carga los datos existentes de `escape_rooms_completo.json`
- Carga los datos nuevos de `escape_rooms_nuevos.json`
- Crea un backup del archivo original
- Combina ambos eliminando duplicados
- Actualiza `escape_rooms_completo.json`

## 📊 Estadísticas Actuales

Después de la última actualización:
- **Total de escape rooms:** 764 únicos
- **Con descripción:** 99.9%
- **Con precio:** 100%
- **Con jugadores:** 100%
- **Con coordenadas GPS:** 2%

## 🛠️ Fuentes de Datos

### Sitios Web Scrapeados (automático)
1. **RoomEscapes.es** - Mayor directorio de escape rooms
2. **TodoEscapeRooms.com** - Más de 1,200 escape rooms
3. **EscapeRoomLover.com** - 1,141 juegos con rankings

### Datos de Ejemplo (manual)
El script incluye 15 escape rooms de alta calidad con datos completos:
- Madrid (4)
- Barcelona (2)
- Valencia (2)
- Zaragoza (2)
- Bilbao (2)
- Sevilla (1)
- Málaga (1)
- Murcia (1)
- Salamanca (1)
- A Coruña (1)

Todos con:
- ✅ Nombre
- ✅ Ubicación completa
- ✅ Coordenadas GPS precisas
- ✅ Descripción detallada
- ✅ Precio
- ✅ Número de jugadores
- ✅ Duración
- ✅ Género/temática
- ✅ Puntuación
- ✅ Teléfono
- ✅ Web

## 🔧 Configuración

### Agregar más fuentes de datos

Edita `scrape_escape_rooms.py` y añade un nuevo método:

```python
def scrape_nueva_fuente(self) -> List[Dict]:
    """Scraping de nuevafuente.com"""
    logger.info("🔍 Scraping nuevafuente.com...")
    results = []

    try:
        url = "https://www.nuevafuente.com/escape-rooms"
        response = self.session.get(url, timeout=10)
        soup = BeautifulSoup(response.content, 'html.parser')

        # Tu lógica de scraping aquí

    except Exception as e:
        logger.error(f"Error: {e}")

    return results
```

Luego añade la llamada en el método `run()`:

```python
results_nueva = self.scrape_nueva_fuente()
all_results.extend(results_nueva)
```

### Agregar datos manualmente

Edita el método `generate_sample_data()` en `scrape_escape_rooms.py` y añade más entradas al array `sample_data`.

## 📝 Estructura de Datos

Cada escape room debe tener esta estructura:

```json
{
  "nombre": "Nombre del Escape Room",
  "ubicacion": "Dirección completa con código postal y ciudad",
  "web": "https://www.ejemplo.com",
  "genero": "Género o temática",
  "puntuacion": "9.0",
  "precio": "Desde 20€ por persona",
  "jugadores": "De 2 a 6 jugadores",
  "duracion": "60 minutos",
  "descripcion": "Descripción detallada de la experiencia",
  "telefono": "912345678",
  "latitud": 40.4168,
  "longitud": -3.7038
}
```

## 🧹 Limpieza Automática

El sistema de importación de Flutter incluye limpieza automática:

### Filtrado
- Registros con "Oops!", "404", "Error" en el nombre
- Campos con "No disponible", "/", "#"
- Descripciones muy cortas o genéricas

### Normalización
- **Precio:** "€ Desde 15€ por persona" → "Desde 15€"
- **Duración:** "1 hora" → "60 min"
- **Jugadores:** Extrae min/max automáticamente

### Enriquecimiento
- **Provincia:** Se determina automáticamente desde coordenadas o ubicación
- **Empresa:** Se deduce desde URL o nombre
- **numJugadoresMin/Max:** Se parsea desde el campo jugadores

## 🔄 Flujo de Actualización

1. **Scraping** → `escape_rooms_nuevos.json`
2. **Merge** → `escape_rooms_completo.json` (actualizado)
3. **Backup** → `escape_rooms_completo_backup.json`
4. **Flutter App** → Importar desde la app usando "Gestión de Base de Datos"

## 🐛 Problemas Comunes

### Error 404 al hacer scraping
**Causa:** Protección anti-scraping (Cloudflare, reCAPTCHA)
**Solución:** El script usa datos de ejemplo automáticamente

### "externally-managed-environment"
**Causa:** Python de sistema protegido en macOS
**Solución:** Usar entorno virtual (venv) como se indica arriba

### Duplicados en los datos
**Causa:** Mismo escape room con pequeñas variaciones en nombre/ubicación
**Solución:** El script `merge_data.py` elimina duplicados automáticamente

## 📈 Mejoras Futuras

- [ ] Integración con API oficial de directorios
- [ ] Scraping con Selenium para sitios dinámicos
- [ ] Geocodificación automática de direcciones
- [ ] Validación de URLs y teléfonos
- [ ] Actualización periódica automática
- [ ] Machine learning para categorización de géneros

## 📄 Licencia

Scripts para uso interno del proyecto. Los datos de escape rooms pertenecen a sus respectivos propietarios.

## 🤝 Contribuir

Para añadir más escape rooms:
1. Ejecuta el scraping
2. Verifica los datos en `escape_rooms_nuevos.json`
3. Ejecuta el merge
4. Crea un commit con los cambios

## 📞 Contacto

Para reportar problemas o sugerencias, crea un issue en el repositorio.
