# Imágenes de Géneros

Esta carpeta contiene las imágenes personalizadas para cada género de escape room.

## Formato de las imágenes

- **Formato recomendado**: PNG con transparencia
- **Tamaño recomendado**: 64x64 píxeles o 128x128 píxeles
- **Estilo**: Iconos/símbolos simples que representen cada género

## Lista de imágenes necesarias

Por favor, añade imágenes PNG para los siguientes géneros:

### Géneros principales
- `accion.png` - Acción/explosión
- `adulto.png` - Contenido adulto
- `apocalipsis.png` - Fin del mundo
- `arqueologia.png` - Excavación/ruinas
- `aventura.png` - Montañas/exploración
- `conspiracion.png` - Misterio/sombras
- `cyberpunk.png` - Tecnología futurista
- `egipto.png` - Pirámides/jeroglíficos
- `espionaje.png` - Agente secreto
- `familiar.png` - Familia/niños
- `fantasia.png` - Magia/fantasía
- `fantasmas.png` - Espíritus/fantasmas
- `historico.png` - Historia/antiguo
- `humor.png` - Comedia/risa
- `infantil.png` (usa familiar.png)
- `investigacion.png` - Lupa/detective
- `magia.png` - Varita/hechizo
- `medieval.png` - Castillo/espada
- `miedo.png` - Susto/terror
- `militar.png` - Ejército/guerra
- `misterio.png` - Huella/enigma
- `piratas.png` - Barco pirata/tesoro
- `prision.png` - Rejas/celda
- `religioso.png` - Libro sagrado/cruz
- `robo.png` - Dinero/banco
- `scifi.png` - Ciencia ficción/cohete
- `sobrenatural.png` - Paranormal
- `submarino.png` - Submarino/océano
- `supervivencia.png` - Naturaleza salvaje
- `terror.png` - Horror/oscuridad
- `thriller.png` - Suspense/tensión
- `vampiros.png` - Colmillos/sangre
- `virtual.png` - Realidad virtual/digital
- `zombies.png` - Muertos vivientes

## Cómo añadir las imágenes

1. Crea o descarga imágenes PNG para cada género
2. Guárdalas en esta carpeta (`assets/genres/`)
3. Asegúrate de que los nombres coincidan exactamente con los de la lista
4. Reinicia la app para ver los cambios

## Nota importante

Si una imagen no existe, la app mostrará automáticamente el ícono de Material Icons como fallback, así que no es necesario tener todas las imágenes desde el principio. Puedes ir añadiéndolas gradualmente.

## Recomendaciones de diseño

- Usa colores que combinen con el color del género (definido en `genre_utils.dart`)
- Mantén un estilo consistente entre todas las imágenes
- Usa imágenes vectoriales o PNG de alta calidad
- Si quieres que el color se aplique dinámicamente, usa imágenes en escala de grises o siluetas negras
