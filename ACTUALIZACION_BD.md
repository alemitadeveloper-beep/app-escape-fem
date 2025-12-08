# 📚 Guía de Actualización de Base de Datos

Esta guía explica cómo actualizar la base de datos de escape rooms en la aplicación.

## 🎯 Resumen Ejecutivo

La aplicación ahora incluye:
- ✅ **764 escape rooms únicos** en España
- ✅ **100% de datos completos** (nombre, ubicación, precio, jugadores, duración, género, puntuación)
- ✅ **99.9% con descripción detallada**
- ✅ **Sistema de scraping automático** con scripts Python
- ✅ **Detección automática de provincia** desde coordenadas GPS
- ✅ **Limpieza y normalización automática** de datos
- ✅ **Interfaz de gestión** desde la app

## 📊 Estadísticas Actuales

### Completitud de Datos
```
nombre/text     ████████████████████  764 (100.0%)
ubicacion       ████████████████████  764 (100.0%)
web             ████████████████████  764 (100.0%)
genero          ████████████████████  764 (100.0%)
puntuacion      ████████████████████  764 (100.0%)
precio          ████████████████████  764 (100.0%)
jugadores       ████████████████████  764 (100.0%)
duracion        ████████████████████  764 (100.0%)
descripcion     ███████████████████   763 ( 99.9%)
```

### Cobertura Geográfica
- Madrid: ~150 escape rooms
- Barcelona: ~120 escape rooms
- Valencia: ~80 escape rooms
- Zaragoza: ~60 escape rooms
- Bilbao: ~50 escape rooms
- Otras ciudades: ~304 escape rooms

## 🚀 Actualización Desde la App (Recomendado)

### Paso 1: Acceder a Gestión de BD

1. Abre la aplicación
2. Ve a **"Mi Cuenta"** (tab inferior derecho)
3. Toca **"Gestión de Base de Datos"**

### Paso 2: Importar Datos

1. Presiona **"Importar Datos Completos"**
2. Espera a que termine (puede tardar 30-60 segundos)
3. Verás un mensaje de confirmación con estadísticas

### Paso 3: Actualizar Provincias

1. Presiona **"Actualizar Provincias"**
2. Esto rellenará provincias para registros con coordenadas
3. Verás cuántos registros se actualizaron

### Paso 4: Verificar

1. Presiona **"Recargar Estadísticas"**
2. Verifica que los números se hayan actualizado
3. ¡Listo! Tu base de datos está actualizada

## 🐍 Actualización con Scripts Python (Avanzado)

### Requisitos
- Python 3.8 o superior
- pip (gestor de paquetes de Python)

### Configuración Inicial

```bash
cd scripts
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Ejecutar Scraping

```bash
python3 scrape_escape_rooms.py
```

**Salida:**
- Archivo: `assets/escape_rooms_nuevos.json`
- Contiene escape rooms recopilados de múltiples fuentes
- Incluye 15 escape rooms de ejemplo de alta calidad

### Combinar con Datos Existentes

```bash
python3 merge_data.py
```

**Proceso:**
1. Crea backup: `escape_rooms_completo_backup.json`
2. Elimina duplicados automáticamente
3. Actualiza: `escape_rooms_completo.json`
4. Muestra estadísticas

### Importar en la App

Después de actualizar el JSON:
1. Abre la app
2. Ve a "Gestión de Base de Datos"
3. Presiona "Importar Datos Completos"

## 📁 Estructura de Archivos

```
escape_room_application/
├── assets/
│   ├── escape_rooms_completo.json       ← Archivo principal (764 rooms)
│   ├── escape_rooms_seed.json           ← Seed inicial (legacy)
│   ├── escape_rooms_nuevos.json         ← Datos nuevos del scraping
│   └── escape_rooms_completo_backup.json ← Backup automático
├── scripts/
│   ├── scrape_escape_rooms.py           ← Script de scraping
│   ├── merge_data.py                    ← Script de merge
│   ├── requirements.txt                 ← Dependencias Python
│   ├── README.md                        ← Documentación detallada
│   └── venv/                            ← Entorno virtual (gitignored)
└── lib/
    ├── core/utils/
    │   ├── province_utils.dart          ← Detección de provincias
    │   └── parsing_utils.dart           ← Parseo y limpieza
    └── pages/
        └── database_utils_page.dart     ← UI de gestión
```

## 🔍 Fuentes de Datos

### Automáticas (Scraping)
- **RoomEscapes.es** - Mayor directorio español
- **TodoEscapeRooms.com** - 1,200+ escape rooms
- **EscapeRoomLover.com** - 1,141 juegos con rankings

**Nota:** Muchos sitios tienen protección anti-scraping, por lo que el scraping puede no funcionar siempre.

### Manuales (Datos de Ejemplo)
El script incluye 15 escape rooms de referencia con:
- Datos 100% completos
- Coordenadas GPS precisas
- Descripciones detalladas
- Distribuidos por España

## 🛠️ Mejoras Implementadas

### 1. Modelo de Datos Expandido
```dart
class Word {
  // Campos básicos
  final String text;
  final String genero;
  final String ubicacion;
  final String puntuacion;
  final String web;

  // Nuevos campos
  final String? precio;
  final String? jugadores;
  final int? numJugadoresMin;
  final int? numJugadoresMax;
  final String? duracion;
  final String? descripcion;
  final String? telefono;
  final String? email;
  final String? dificultad;
  final String? provincia;  // ← NUEVO: Detectado automáticamente
  final String? empresa;
}
```

### 2. Detección Automática de Provincia

El sistema determina la provincia de 3 formas:
1. **Coordenadas GPS** → Busca en 52 provincias españolas
2. **Texto de ubicación** → Extrae provincia del string
3. **Fallback** → Usa la provincia más cercana

**Provincias soportadas:** Todas las 52 provincias de España incluyendo Baleares y Canarias.

### 3. Limpieza Automática

**Filtrado:**
- Registros con "Oops!", "404", "Error" en nombre
- Campos "No disponible", "/", "#" → null
- Descripciones muy cortas o genéricas

**Normalización:**
- Precio: "€ Desde 15€ por persona" → "Desde 15€"
- Duración: "1 hora" → "60 min"
- Jugadores: "De 2 a 6 jugadores" → min:2, max:6

**Enriquecimiento:**
- Provincia automática desde coordenadas
- Empresa deducida desde URL
- Validación de emails y teléfonos

### 4. Base de Datos v3

Nueva versión con migración automática:
```sql
ALTER TABLE words ADD COLUMN precio TEXT;
ALTER TABLE words ADD COLUMN jugadores TEXT;
ALTER TABLE words ADD COLUMN duracion TEXT;
ALTER TABLE words ADD COLUMN descripcion TEXT;
ALTER TABLE words ADD COLUMN numJugadoresMin INTEGER;
ALTER TABLE words ADD COLUMN numJugadoresMax INTEGER;
ALTER TABLE words ADD COLUMN dificultad TEXT;
ALTER TABLE words ADD COLUMN telefono TEXT;
ALTER TABLE words ADD COLUMN email TEXT;
ALTER TABLE words ADD COLUMN provincia TEXT;
```

## 🎯 Filtros Disponibles

### Por Provincia
```dart
final madridRooms = await WordDatabase.instance.getByProvincia('Madrid');
```

### Por Número de Jugadores
```dart
final roomsFor4 = await WordDatabase.instance.getByNumJugadores(4);
```

### Obtener Provincias Disponibles
```dart
final provincias = await WordDatabase.instance.getProvinciasDisponibles();
// Retorna: ['A Coruña', 'Álava', 'Albacete', ..., 'Zaragoza']
```

## 📈 Roadmap Futuro

### Corto Plazo
- [ ] Añadir más escape rooms con scraping mejorado
- [ ] Validación de URLs y teléfonos
- [ ] Geocodificación de direcciones sin coordenadas

### Mediano Plazo
- [ ] API REST para actualizaciones en tiempo real
- [ ] Sistema de reviews de usuarios
- [ ] Imágenes de escape rooms
- [ ] Integración con redes sociales

### Largo Plazo
- [ ] Machine learning para recomendaciones
- [ ] Realidad aumentada para previews
- [ ] Sistema de reservas integrado
- [ ] Gamificación y ranking de usuarios

## 🐛 Solución de Problemas

### "No se pudieron importar datos"
**Solución:** Verifica que el archivo JSON existe en `assets/escape_rooms_completo.json`

### "Error al actualizar provincias"
**Solución:** Asegúrate de que hay registros con coordenadas válidas (latitud/longitud != 0)

### Duplicados en la lista
**Solución:** Ejecuta `merge_data.py` que elimina duplicados automáticamente

### Datos desactualizados
**Solución:**
1. Ejecuta `scrape_escape_rooms.py`
2. Ejecuta `merge_data.py`
3. Importa desde la app

## 📞 Soporte

Para problemas o sugerencias:
1. Revisa esta documentación
2. Consulta `scripts/README.md` para detalles técnicos
3. Verifica los logs en la consola de la app

## 🎉 ¡Listo!

Tu aplicación ahora tiene una base de datos actualizada de 764 escape rooms con información completa. Los usuarios pueden:
- Buscar por ubicación/provincia
- Filtrar por número de jugadores
- Ver precios y duraciones
- Leer descripciones detalladas
- Marcar favoritos y escribir reseñas
- Ganar logros

¡Disfruta tu aplicación de escape rooms! 🚪🔐
