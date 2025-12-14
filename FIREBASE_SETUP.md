# Configuración de Firebase Firestore

## Paso 1: Configurar las Reglas de Seguridad

1. Ve a la [Consola de Firebase](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral, ve a **Firestore Database**
4. Ve a la pestaña **Reglas**
5. Copia y pega el contenido del archivo `firestore.rules` de este proyecto
6. Haz clic en **Publicar**

## Paso 2: Crear Índices (si es necesario)

Firestore puede requerir índices compuestos para algunas consultas. Si ves errores relacionados con índices cuando uses la app, Firebase te proporcionará un enlace directo para crearlos automáticamente.

## Estructura de Datos en Firestore

### Colección: `users/{userId}`

Almacena los datos específicos de cada usuario:

```
users/
  {uid}/
    - username: string
    - email: string
    - avatarId: string
    - createdAt: timestamp
    - lastLogin: timestamp

    favorites/
      {escapeRoomId}/
        - escapeRoomId: int
        - addedAt: timestamp

    played/
      {escapeRoomId}/
        - escapeRoomId: int
        - datePlayed: string (ISO 8601)
        - personalRating: int (1-5)
        - review: string
        - historiaRating: int (1-5)
        - ambientacionRating: int (1-5)
        - jugabilidadRating: int (1-5)
        - gameMasterRating: int (1-5)
        - miedoRating: int (1-5)
        - updatedAt: timestamp

    pending/
      {escapeRoomId}/
        - escapeRoomId: int
        - addedAt: timestamp
```

### Colección: `groups/{groupId}`

Almacena información de grupos de usuarios:

```
groups/
  {groupId}/
    - name: string
    - description: string
    - adminUid: string
    - adminUsername: string
    - routeName: string (opcional)
    - createdAt: timestamp
    - isActive: boolean
    - isPublic: boolean

    members/
      {uid}/
        - username: string
        - joinedAt: timestamp
        - isAdmin: boolean

    sessions/
      {sessionId}/
        - escapeRoomId: int
        - escapeRoomName: string
        - scheduledDate: string (ISO 8601)
        - notes: string
        - isCompleted: boolean
        - createdAt: timestamp

        ratings/
          {uid}/
            - rating: int (1-5)
            - comment: string
            - createdAt: timestamp

        photos/
          {photoId}/
            - url: string
            - uploadedBy: string (uid)
            - caption: string
            - uploadedAt: timestamp
```

### Colección: `invitations/{invitationId}`

Almacena invitaciones a grupos:

```
invitations/
  {invitationId}/
    - groupId: string
    - groupName: string
    - senderUid: string
    - senderUsername: string
    - recipientUid: string
    - recipientUsername: string
    - createdAt: timestamp
    - status: string ('pending' | 'accepted' | 'declined')
    - message: string (opcional)
    - respondedAt: timestamp (cuando se acepta/rechaza)
```

## Servicios Implementados

### FirestoreUserDataService

Maneja los datos específicos del usuario (favoritos, jugados, pendientes):

```dart
// Crear instancia
final service = FirestoreUserDataService(userId: currentUserId);

// Agregar favorito
await service.addFavorite(escapeRoomId);

// Marcar como jugado
await service.markAsPlayed(
  escapeRoomId: escapeRoomId,
  datePlayed: DateTime.now().toIso8601String(),
  personalRating: 5,
  review: "¡Excelente!",
);

// Obtener favoritos
final favoriteIds = await service.getFavoriteIds();
```

### FirestoreGroupsService

Maneja grupos, sesiones e invitaciones:

```dart
// Crear instancia
final service = FirestoreGroupsService(userId: currentUserId);

// Crear grupo
final groupId = await service.createGroup(
  name: "Amigos Escape",
  description: "Grupo de amigos",
  adminUsername: "usuario123",
);

// Crear sesión
final sessionId = await service.createSession(
  groupId: groupId,
  escapeRoomId: 1,
  escapeRoomName: "La Casa de Papel",
  scheduledDate: DateTime.now().toIso8601String(),
);

// Enviar invitación
await service.sendInvitation(
  groupId: groupId,
  groupName: "Amigos Escape",
  senderUsername: "usuario123",
  recipientUid: recipientUid,
  recipientUsername: "amigo456",
);
```

## Migración de Datos

Para migrar datos existentes desde SQLite a Firestore, usa el método `syncFromSQLite`:

```dart
final userDataService = FirestoreUserDataService(userId: userId);
final allWords = await WordDatabase.instance.readAllWords();
await userDataService.syncFromSQLite(allWords);
```

## Notas Importantes

1. **Seguridad**: Las reglas de Firestore garantizan que:
   - Los usuarios solo pueden modificar sus propios datos
   - Los miembros de un grupo pueden ver y modificar datos del grupo
   - Solo los admins pueden eliminar grupos y ciertos recursos

2. **Costos**: Firestore cobra por:
   - Lecturas de documentos
   - Escrituras de documentos
   - Almacenamiento
   - Ancho de banda de red

   Consulta los [precios de Firestore](https://firebase.google.com/pricing) para más información.

3. **Límites gratuitos** (Spark Plan):
   - 50,000 lecturas/día
   - 20,000 escrituras/día
   - 20,000 eliminaciones/día
   - 1 GB almacenamiento

4. **Sincronización en tiempo real**: Usa los métodos `Stream` para escuchar cambios en tiempo real:
   ```dart
   service.getMyGroups().listen((groups) {
     // Actualizar UI con los grupos
   });
   ```
