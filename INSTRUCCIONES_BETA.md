# Distribución Beta - Escape Fem App

## 📱 Cómo obtener el UDID de un iPhone

Para añadir dispositivos a la beta, necesitas el **UDID** de cada iPhone. Hay varias formas:

### Opción 1: Con Mac (la más fácil)
1. Conectar el iPhone al Mac con cable
2. Abrir **Finder**
3. Seleccionar el iPhone en la barra lateral
4. Hacer clic en el nombre del dispositivo (debajo del icono del iPhone)
5. Aparecerá el UDID - copiarlo

### Opción 2: Con iPhone directamente
1. Abrir la app **Configuración**
2. Ir a **General > Información**
3. Buscar "Identificador" o tocar varias veces sobre el número de serie
4. Aparecerá el UDID - mantener presionado para copiar

### Opción 3: Con iTunes/Finder
1. Conectar iPhone al ordenador
2. En Finder (Mac) o iTunes (Windows), seleccionar el dispositivo
3. En la pestaña "General", hacer clic en "Número de serie" hasta que aparezca el UDID

### Opción 4: Con web (más fácil para no técnicos)
1. Desde el iPhone, ir a: https://get.udid.io
2. Instalar el perfil temporal
3. Copiar el UDID que aparece
4. Eliminar el perfil después (Configuración > General > Perfiles)

---

## 🔧 Pasos para registrar dispositivos (Admin)

### 1. Ir a Apple Developer Portal
   - https://developer.apple.com/account/resources/devices/list
   - Iniciar sesión con alemita.developer@gmail.com

### 2. Añadir dispositivos
   - Click en el botón **"+"**
   - Seleccionar **"Register Multiple Devices"** si tienes varios
   - O **"Register a Device"** para uno solo
   - Pegar los UDIDs recibidos
   - Darle un nombre descriptivo a cada uno (ej: "iPhone Ana", "iPhone Pedro")

### 3. Crear perfil de aprovisionamiento Ad-Hoc
   - Ir a: https://developer.apple.com/account/resources/profiles/list
   - Click en **"+"**
   - Seleccionar **"Ad Hoc"** bajo Distribution
   - Elegir el App ID: `com.alemita.escapeapp`
   - Seleccionar el certificado de desarrollo
   - **IMPORTANTE:** Seleccionar TODOS los dispositivos donde quieras instalar
   - Darle nombre: "Escape Fem Ad-Hoc"
   - Descargar el perfil (.mobileprovision)

### 4. Instalar el perfil en Xcode
   - Hacer doble click en el archivo .mobileprovision descargado
   - O arrastrarlo a Xcode

---

## 📦 Compilar y distribuir (pasos automáticos)

Una vez tengas los dispositivos registrados y el perfil creado, ejecuta:

```bash
flutter build ipa --export-method ad-hoc
```

El archivo .ipa estará en:
```
build/ios/ipa/escape_room_application.ipa
```

---

## 📲 Cómo instalan los testers la app

### Opción 1: AirDrop (más fácil)
1. Enviar el .ipa por AirDrop
2. Al recibirlo, se abrirá automáticamente en iTunes/Finder
3. Sincronizar el iPhone

### Opción 2: Con cable
1. Conectar iPhone al Mac
2. Abrir Xcode
3. **Window > Devices and Simulators**
4. Seleccionar el dispositivo
5. Arrastrar el .ipa a la sección "Installed Apps"

### Opción 3: Diawi (online, más cómodo)
1. Subir el .ipa a https://www.diawi.com
2. Compartir el link generado con los testers
3. Los testers abren el link desde Safari en su iPhone
4. Hacer clic en "Install"
5. **Importante:** Confiar en el certificado:
   - Configuración > General > Gestión de dispositivos
   - Confiar en "Alejandra Sánchez Marta"

---

## ⚠️ Limitaciones
- Máximo **100 dispositivos** por año por cuenta de desarrollador
- Los dispositivos deben estar **registrados ANTES** de compilar el .ipa
- Si añades un dispositivo nuevo, hay que recompilar el .ipa
- Los certificados caducan cada año

---

## 📋 Lista de dispositivos beta actuales

1. **iPhone Ale** - UDID: `00008101-001D49441104001E` ✅ Registrado

(Añadir aquí los nuevos dispositivos según los vayas registrando)
