# 🔥 Instrucciones para Configurar Firestore

## ✅ Lo que se ha implementado:

1. **Servicios de Firestore creados:**
   - `FirestoreUserDataService`: Maneja favoritos, jugados y pendientes
   - `FirestoreGroupsService`: Maneja grupos, sesiones e invitaciones

2. **Integración con la app:**
   - Los favoritos, jugados y pendientes ahora se sincronizan automáticamente con Firestore
   - Los datos se guardan tanto en SQLite (local) como en Firestore (cloud)
   - Si falla la sincronización con Firestore, la app sigue funcionando con SQLite

3. **Sincronización automática:**
   - Se ha agregado el método `syncLocalDataToFirestore()` al servicio de autenticación
   - Este método puede ser llamado después del login para sincronizar datos existentes

## 📋 Pasos para activar Firestore:

### Paso 1: Configurar las Reglas de Seguridad

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral izquierdo, busca **"Firestore Database"**
4. Si es la primera vez, haz clic en **"Crear base de datos"**
   - Selecciona **"Iniciar en modo de prueba"** (temporal)
   - Selecciona la ubicación más cercana (ej: `europe-west1`)
5. Una vez creada, ve a la pestaña **"Reglas"**
6. Copia **TODO** el contenido del archivo `firestore.rules` de este proyecto
7. Pega el contenido en el editor de reglas de Firebase
8. Haz clic en **"Publicar"**

### Paso 2: Verificar que funciona

1. La app ya está lista para usar Firestore
2. Cuando hagas login, verás en los logs:
   ```
   ✅ Favorito agregado: 123
   ✅ Escape room marcado como jugado: 456
   ```

3. Si ves warnings como:
   ```
   ⚠️ Error al sincronizar favorito con Firestore: [cloud_firestore/permission-denied]
   ```
   Significa que las reglas no están configuradas correctamente.

### Paso 3: (Opcional) Sincronizar datos existentes

Si quieres sincronizar los datos que ya tienes en SQLite con Firestore, puedes agregar una opción en "Mi cuenta":

```dart
// En account_page.dart, agregar un botón:
ElevatedButton(
  onPressed: () async {
    final authService = FirebaseAuthService();
    await authService.syncLocalDataToFirestore();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos sincronizados con la nube')),
    );
  },
  child: const Text('Sincronizar datos con la nube'),
)
```

## 🔍 Verificar que los datos se están guardando:

1. Ve a Firebase Console > Firestore Database
2. Deberías ver las colecciones:
   - `users/{uid}/favorites`
   - `users/{uid}/played`
   - `users/{uid}/pending`
3. Al marcar un escape room como favorito en la app, verás un nuevo documento en tiempo real

## 📊 Estructura de datos en Firestore:

```
users/
  {uid}/
    favorites/
      {escapeRoomId}/
        - escapeRoomId: 123
        - addedAt: 2025-01-15T10:30:00Z

    played/
      {escapeRoomId}/
        - escapeRoomId: 456
        - datePlayed: "2025-01-15T10:30:00Z"
        - personalRating: 5
        - review: "¡Increíble experiencia!"
        - historiaRating: 5
        - ambientacionRating: 5
        - jugabilidadRating: 4
        - gameMasterRating: 5
        - miedoRating: 3

    pending/
      {escapeRoomId}/
        - escapeRoomId: 789
        - addedAt: 2025-01-15T10:30:00Z
```

## ⚡ Características:

- ✅ **Sincronización automática**: Los cambios se sincronizan automáticamente
- ✅ **Funciona offline**: Si no hay internet, usa SQLite local
- ✅ **Seguro**: Solo el usuario puede modificar sus propios datos
- ✅ **Tiempo real**: Los datos se actualizan en todos los dispositivos del usuario
- ✅ **Escalable**: Firestore maneja millones de documentos

## 🚨 Importante:

- **Sin las reglas configuradas**, verás errores de `permission-denied`
- **La app seguirá funcionando** con SQLite incluso si Firestore falla
- **Los grupos** están preparados para Firestore pero aún no integrados en la UI

## 💰 Costos de Firestore:

Plan gratuito (Spark):
- 50,000 lecturas/día
- 20,000 escrituras/día
- 1 GB almacenamiento
- Más que suficiente para desarrollo y uso personal

## ¿Dudas?

Consulta el archivo `FIREBASE_SETUP.md` para más detalles técnicos.
