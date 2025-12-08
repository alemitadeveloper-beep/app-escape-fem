# Sistema de Grupos de Escape Rooms

Este módulo implementa un sistema completo de grupos para organizar sesiones de escape rooms con amigos.

## Características principales

### 1. Gestión de Grupos
- **Crear grupos**: Los administradores pueden crear grupos con nombre, descripción y opcionalmente un nombre de ruta (ej: "Ruta País Vasco")
- **Unirse a grupos**: Cualquier usuario puede unirse a grupos existentes
- **Ver miembros**: Lista de todos los participantes del grupo
- **Roles**: Administrador (creador) y miembros regulares

### 2. Sesiones de Escape Rooms
- **Crear sesiones**: Los administradores programan sesiones de escape rooms específicos
- **Múltiples escapes**: Un grupo puede tener varias sesiones (diferentes escape rooms o repeticiones)
- **Fecha y hora**: Cada sesión tiene una fecha programada
- **Notas**: Información adicional (punto de encuentro, etc.)
- **Estado**: Pendiente o Completada

### 3. Sistema de Valoraciones
- **Valoración individual**: Cada miembro puede valorar una sesión completada
- **Valoración general**: Puntuación del 1 al 5
- **Valoraciones detalladas** (opcional):
  - Historia
  - Ambientación
  - Jugabilidad
  - Game Master
  - Nivel de miedo
- **Comentarios**: Texto libre para compartir la experiencia
- **Puntuación promedio**: Se calcula automáticamente con todas las valoraciones

### 4. Galería de Fotos
- **Subir fotos**: Los miembros pueden compartir fotos de las sesiones
- **Descripciones**: Cada foto puede tener una descripción
- **Galería por sesión**: Todas las fotos organizadas por sesión

### 5. Ranking del Grupo
- **Clasificación**: Basada en el promedio de valoraciones de cada usuario
- **Estadísticas**: Número de sesiones valoradas por cada miembro
- **Medallas**: Reconocimiento visual para los primeros 3 lugares

## Estructura del código

```
lib/features/groups/
├── data/
│   ├── models/              # Modelos de datos
│   │   ├── group.dart
│   │   ├── group_member.dart
│   │   ├── group_session.dart
│   │   ├── session_rating.dart
│   │   └── session_photo.dart
│   └── datasources/
│       └── groups_database.dart  # Operaciones de base de datos
├── domain/
│   └── services/
│       └── group_service.dart    # Lógica de negocio
└── presentation/
    └── pages/               # Páginas UI
        ├── groups_page.dart           # Lista de grupos
        ├── create_group_page.dart     # Crear grupo
        ├── group_detail_page.dart     # Detalle del grupo
        ├── create_session_page.dart   # Crear sesión
        └── session_detail_page.dart   # Detalle de sesión con valoraciones
```

## Base de datos

El sistema utiliza SQLite con las siguientes tablas:

### `groups`
- Información básica del grupo
- Administrador y estado

### `group_members`
- Relación usuario-grupo
- Fecha de ingreso
- Rol (admin/miembro)

### `group_sessions`
- Sesiones programadas
- Escape room asociado
- Fecha y estado

### `session_ratings`
- Valoraciones individuales
- Puntuaciones generales y detalladas
- Comentarios

### `session_photos`
- Fotos compartidas
- Usuario que las subió
- Descripciones

## Flujo de uso

### Crear un grupo (Administrador)
1. Ir a "Mi Cuenta" → "Mis Grupos"
2. Pulsar "Crear Grupo"
3. Rellenar nombre, descripción y ruta (opcional)
4. Confirmar

### Unirse a un grupo
1. Ir a "Mis Grupos"
2. Pestaña "Descubrir"
3. Seleccionar grupo y pulsar "Unirse"

### Programar una sesión (Administrador)
1. Abrir el grupo
2. Pulsar "Nueva Sesión"
3. Seleccionar escape room
4. Elegir fecha y hora
5. Añadir notas (opcional)
6. Confirmar

### Valorar una sesión
1. Abrir el grupo
2. Seleccionar sesión completada
3. Pestaña "Valoraciones"
4. Pulsar "Valorar"
5. Rellenar puntuaciones y comentario
6. Guardar

### Subir fotos
1. Abrir sesión completada
2. Pestaña "Fotos"
3. Pulsar "Subir Foto"
4. Seleccionar imagen de galería
5. Añadir descripción (opcional)
6. Confirmar

## Permisos

### Administrador del grupo puede:
- Crear/editar/eliminar el grupo
- Crear/editar/eliminar sesiones
- Marcar sesiones como completadas
- Eliminar cualquier foto
- Todas las funciones de miembro

### Miembros pueden:
- Ver información del grupo
- Ver sesiones programadas
- Valorar sesiones completadas
- Subir fotos a sesiones
- Ver ranking del grupo
- Salir del grupo

## Próximas mejoras

- [ ] Notificaciones de nuevas sesiones
- [ ] Invitaciones por enlace
- [ ] Exportar datos del grupo
- [ ] Estadísticas avanzadas
- [ ] Grupos privados/públicos
- [ ] Chat por grupo
- [ ] Integración con calendario

## Uso del servicio

```dart
import 'package:escape_room_application/features/groups/domain/services/group_service.dart';

final groupService = GroupService();

// Crear grupo
final groupId = await groupService.createGroup(
  name: 'Mi Grupo',
  description: 'Grupo de escape rooms',
  adminUsername: AuthService.username,
  routeName: 'Ruta Madrid',
);

// Crear sesión
await groupService.createSession(
  groupId: groupId,
  escapeRoomId: 1,
  escapeRoomName: 'La Casa de Papel',
  scheduledDate: DateTime.now().add(Duration(days: 7)),
  notes: 'Punto de encuentro: Metro Sol',
  requestingUsername: AuthService.username,
);

// Valorar sesión
await groupService.rateSession(
  sessionId: sessionId,
  username: AuthService.username,
  overallRating: 5,
  historiaRating: 5,
  ambientacionRating: 4,
  jugabilidadRating: 5,
  review: '¡Increíble experiencia!',
);
```
