# Android — checklist de QA y release del MVP

Esta guía reúne las pruebas pendientes del MVP. **No marca como aprobadas las pruebas que aún requieren un dispositivo real.** Repetirla después de cambios en guardado, audio, exportación o navegación.

## 1. Preparar una APK de prueba

1. Actualizar la rama `master` y abrir el proyecto con Godot 4.6.2.
2. Ejecutar una validación de importación/parseo sin errores.
3. Exportar el preset Android actual como APK **debug**. El preset versionado todavía apunta a `build/apocalypsheep-debug.apk`; no confundirlo con una build release.
4. Instalar la APK en el teléfono. Para probar continuidad de una partida existente, **actualizar la instalación sin desinstalar ni borrar datos**.
5. Registrar versión/commit, modelo de teléfono, versión Android, fecha y resultado de cada prueba.

## 2. Prueba integrada en dispositivo

- [ ] Arrancar la APK y verificar portrait, pantalla completa, botones y zonas seguras.
- [ ] Iniciar una partida; seleccionar una zona y completar un combate alternando ataque y defensa.
- [ ] Escuchar el ataque normal y crítico enemigo y los efectos de estado que aparezcan; comprobar que no se saturan ni se superponen excesivamente.
- [ ] Abrir/cerrar historial; verificar popups de victoria, loot y subida de nivel cuando correspondan.
- [ ] Obtener un objeto, abrir inventario, equipar/desequipar un arma y usar un consumible cuando haya HP por recuperar.
- [ ] Anotar **antes de cerrar** HP, nivel, XP, inventario, equipo y zona seleccionada.
- [ ] Cerrar la aplicación desde aplicaciones recientes (sin borrar datos), abrirla de nuevo y pulsar CONTINUAR.
- [ ] Verificar que HP, nivel, XP, inventario y equipo coincidan con lo anotado y que la navegación funcione.
- [ ] Repetir el cierre/reapertura tras seleccionar otra zona, antes de terminar el combate siguiente.
- [ ] Probar derrota y reintento; comprobar que la nueva partida no hereda inventario/equipo/estadísticas de la anterior.
- [ ] Confirmar ausencia de cierres inesperados, botones bloqueados y ralentizaciones perceptibles.

**Precaución:** no usar «Nueva partida» durante la prueba de continuidad, porque reinicia y sobrescribe el progreso. Conservar una captura de las estadísticas antes y después.

## 3. Preparación release (pendiente)

- [ ] Sustituir el identificador de paquete provisional `com.example.$genname` por uno definitivo.
- [ ] Establecer nombre visible y versión de la app; incrementar `version/code` en actualizaciones.
- [ ] Integrar icono final y splash de Apocalypsheep, incluidos los iconos Android requeridos.
- [ ] Configurar una clave de firma release **localmente**, fuera de Git; no subir keystore ni contraseñas.
- [ ] Crear un preset/ruta de exportación release separado del debug y generar una APK release firmada.
- [ ] Instalar y probar la build release; repetir persistencia y navegación.
- [ ] Preparar capturas reales de combate, inventario, loot y level up.
- [ ] Revisar ficha de tienda, requisitos de publicación y privacidad antes de distribuir.

## 4. Registro de resultados

| Prueba | Dispositivo / Android | Commit | Resultado | Evidencia / bug |
|---|---|---|---|---|
| Exportación e instalación | | | Pendiente | |
| Combate y audio enemigo | | | Pendiente | |
| Inventario y consumibles | | | Pendiente | |
| Persistencia tras cierre | | | Pendiente | |
| Derrota y reintento | | | Pendiente | |
| Release firmada | | | Pendiente | |

**Tickets relacionados:** #159, #160, #162, #163, #168, #174, #175, #176 y #179.
