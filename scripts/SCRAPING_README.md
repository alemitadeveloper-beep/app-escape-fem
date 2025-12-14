# 🔍 Sistema de Scraping Mejorado de Escape Rooms

Script unificado para detectar **nuevos escape rooms** en múltiples fuentes web españolas, con detección inteligente de duplicados.

## 📋 Fuentes Soportadas

1. **escaperoomlover.com** - Catálogo de escape rooms con reseñas
2. **todoescaperooms.com** - Directorio completo de salas
3. **escaperoos.es** - Listado por provincias
4. **escapeup.es** - Escape rooms en España

## ✨ Características

✅ **Detección de duplicados inteligente:**
- Compara contra la base de datos SQLite existente
- Normalización de nombres (ignora mayúsculas, acentos, símbolos)
- Similitud de texto (>85% = duplicado)
- Comparación por ciudad para mayor precisión

✅ **Extracción robusta de datos:**
- Nombres, ubicaciones, coordenadas GPS
- Web oficial, géneros, precios
- Manejo de errores y reintentos
- Rate limiting automático

✅ **Exportación lista para importar:**
- Formato JSON compatible con la app Flutter
- Estadísticas detalladas del scraping
- Logging completo en archivo

## 🚀 Instalación

### 1. Crear entorno virtual (recomendado para macOS)

```bash
cd scripts
python3 -m venv venv
source venv/bin/activate
```

### 2. Instalar dependencias Python

```bash
pip install playwright beautifulsoup4 requests lxml
playwright install chromium
```

### 3. Verificar instalación

```bash
python3 -c "import playwright; print('✅ Playwright instalado')"
```

## 📝 Uso Completo (3 pasos)

### Paso 1: Ejecutar scraping

```bash
cd scripts
source venv/bin/activate  # Activar entorno virtual
python3 scrape_all_sources.py
```

**Salida:**
- **`nuevos_escape_rooms.json`** - Escape rooms nuevos encontrados (en directorio scripts/)
- **`scraping.log`** - Log detallado del proceso

### Paso 2: Importar a SQLite

```bash
python3 import_to_database.py
```

Este script:
- Lee `nuevos_escape_rooms.json`
- Busca la base de datos SQLite del simulador iOS
- Inserta los escape rooms nuevos (detectando duplicados)
- Muestra estadísticas de importación

### Paso 3: Sincronizar con Firebase

Abre la app Flutter y:
1. Inicia sesión como administrador
2. Ve a **Cuenta** → **Admin Panel**
3. Toca **"Migrar a Firebase"**
4. Confirma la migración

Esto subirá todos los escape rooms de SQLite (incluyendo los nuevos) a Firebase.

### Ejemplo de log

```
🚀 INICIANDO SCRAPING MULTI-FUENTE DE ESCAPE ROOMS
🔍 Scraping escaperoomlover.com...
✅ escaperoomlover.com: 12 nuevos escape rooms
🔍 Scraping todoescaperooms.com...
⏭️ Duplicado: La Casa de Papel
✅ todoescaperooms.com: 8 nuevos escape rooms
...
📊 RESUMEN DE SCRAPING
✅ Total scrapeados: 45
⏭️ Duplicados omitidos: 23
🆕 Nuevos escape rooms: 22
❌ Errores: 0
```

## 🔧 Configuración Avanzada

### Modificar número máximo de salas por fuente

Edita `scrape_all_sources.py` y cambia:

```python
for idx, url in enumerate(list(room_links)[:50]):  # Cambiar 50 por tu límite
```

### Cambiar ruta de la base de datos

```python
scraper = EscapeRoomUnifiedScraper(db_path="ruta/custom/words.db")
```

### Modo headless/visible

En el método `run()`:

```python
browser = p.chromium.launch(headless=False)  # False para ver el navegador
```

## 📊 Formato de Salida JSON

```json
[
  {
    "nombre": "El Misterio del Faraón",
    "ubicacion": "Calle Gran Vía, 28 Madrid España",
    "web": "https://example-escape.com",
    "genero": "Aventura, Egipto",
    "puntuacion": "9.2",
    "precio": "Desde 20€",
    "jugadores": "2-6 jugadores",
    "duracion": "60 minutos",
    "descripcion": "Descubre los secretos del faraón...",
    "empresa": "Example Escape",
    "telefono": "912345678",
    "latitud": 40.4200,
    "longitud": -3.7010,
    "source": "escaperoomlover.com"
  }
]
```

## 🔄 Importar a la App

### Opción 1: Desde panel de admin (próximamente)

1. Abrir app Flutter
2. Ir a "Admin" → "Importar nuevos escapes"
3. Seleccionar archivo JSON
4. Confirmar importación

### Opción 2: Importación manual

```dart
// En la app Flutter
final json = await rootBundle.loadString('assets/nuevos_escape_rooms.json');
final List<dynamic> rooms = jsonDecode(json);

for (var room in rooms) {
  final word = Word(
    text: room['nombre'],
    ubicacion: room['ubicacion'],
    web: room['web'],
    // ... resto de campos
  );
  
  await repository.createEscapeRoom(word);
  await firestoreService.upsertEscapeRoom(word);
}
```

## ⚙️ Troubleshooting

### Error: "playwright not found"

```bash
pip install --force-reinstall playwright
playwright install chromium
```

### Error: "No module named 'lxml'"

```bash
pip install lxml
```

### El scraping es muy lento

- Reduce el número de salas por fuente (ver Configuración Avanzada)
- Aumenta el tiempo entre requests:
  ```python
  time.sleep(2)  # Cambiar de 1 a 2 segundos
  ```

### Muchos duplicados detectados

Esto es **normal** - significa que el sistema funciona correctamente y ya tienes la mayoría de escape rooms en tu BD.

## 📈 Mejoras Futuras

- [ ] Integración directa con la app (botón de scraping)
- [ ] Scraping incremental (solo sitios actualizados)
- [ ] Notificaciones de nuevos escapes
- [ ] Scraping programado (cronjob)
- [ ] API para consultar escapes en tiempo real

## 🤝 Contribuir

Para añadir nuevas fuentes de scraping:

1. Crear método `scrape_nueva_fuente(self, page: Page)`
2. Añadir a la lista `sources` en el método `run()`
3. Probar con pocos resultados primero

## 📄 Licencia

Este script es para uso personal/educativo. Respetar los términos de servicio de cada sitio web.

---

Creado con ❤️ para la comunidad de Escape Room lovers
