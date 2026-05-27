# 🐑🔫 Apocalypsheep

Juego RPG mobile estilo pixel art con combate, loot y progresión, ambientado en un mundo post-apocalíptico habitado por ovejas evolucionadas que utilizan armas de fuego.

---

## 📖 Descripción

Apocalypsheep es un RPG desarrollado con Godot Engine y GDScript, diseñado con una arquitectura modular y escalable desde el inicio.

El jugador controla una oveja superviviente en un mundo devastado, explorando distintas zonas peligrosas, enfrentando enemigos, obteniendo loot y mejorando su equipamiento para sobrevivir.

El proyecto está pensado como una experiencia:

- 📱 Mobile-first
- 🔁 Altamente rejugable
- ⚙️ Escalable y mantenible
- 🎮 Basada en game loop clásico de RPG por turnos

---

## 🎯 Objetivo del MVP

El MVP busca implementar el siguiente loop principal de gameplay:

1. Selección de zona
2. Combate contra enemigos
3. Obtención de recompensas
4. Gestión de inventario
5. Progresión del personaje
6. Repetición del ciclo

---

# ✨ Features Implementadas

## ⚔️ Sistema de Combate

- Combate por turnos
- Ataque y defensa
- Estados alterados:
  - 🩸 Bleed
  - ☠️ Poison
  - 🔥 Burn
  - ⚡ Stun
- Historial de combate
- Popups de resultado
- Números de daño animados
- Sistema de Game Over

---

## 🎒 Inventario

- Equipamiento de armas
- Uso de consumibles
- Eliminación de ítems
- Sistema de loot
- Rarezas:
  - Common
  - Rare
  - Epic

---

## 📈 Progresión

- Sistema de experiencia (XP)
- Niveles
- Mejora de estadísticas
- Equipamiento que modifica daño

---

## 🌍 Zonas y Enemigos

### Zonas disponibles

- 🏙️ Ciudad destruida
- 🧪 Laboratorio abandonado
- ☣️ Pantano tóxico
- 🪖 Base militar caída

### Enemigos

- Saqueador
- Rata mutante
- Robot defectuoso
- Científico infectado
- Babosa tóxica
- Bestia del pantano
- Soldado élite
- Torreta automática

---

## 🔊 Sistema de Audio

AudioManager centralizado con:

- Música por escenas
- Efectos de sonido
- Cooldowns anti-spam
- Control de volumen:
  - Master
  - Música
  - SFX
- Sistema mute
- Límite de sonidos simultáneos
- Cache de recursos de audio

---

## 💾 Persistencia

Sistema de guardado local usando JSON:

- Guardado automático
- Carga de partida
- Validación de save corrupto
- Eliminación de save
- Reset seguro del juego

---

## 🧱 Arquitectura del Proyecto

El proyecto está dividido en capas desacopladas para facilitar mantenimiento y escalabilidad.

### Core

Lógica principal del juego:

- Player
- Enemy
- Item
- CombatSystem

### Managers

Singletons globales:

- GameManager
- AudioManager
- SaveSystem
- SceneManager
- ThemeManager
- DataManager

### UI

Pantallas y popups:

- Main Menu
- Combat Screen
- Inventory
- Result Screen
- Zone Select
- Settings Popup
- Combat History Popup
- Loot Popup
- Game Over Popup

### Data

Archivos JSON configurables:

- enemies.json
- items.json
- zones.json

---

# 📁 Estructura del Proyecto

```text
apocalypsheep/
├── scenes/
│   ├── ui/
│   └── *.tscn
│
├── scripts/
│   ├── core/
│   ├── managers/
│   ├── ui/
│   └── utils/
│
├── data/
│   ├── enemies.json
│   ├── items.json
│   └── zones.json
│
├── README.md
├── project.godot
└── .editorconfig

# 🛠️ Tecnologías

- 🎮 Engine: Godot 4.6
- 💻 Lenguaje: GDScript
- 📱 Plataforma objetivo: Android
- 🧠 Arquitectura modular basada en managers y recursos desacoplados

---

# 🚀 Instalación

## 1️⃣ Clonar repositorio

```bash
git clone https://github.com/yourusername/apocalypsheep.git
cd apocalypsheep
```

---

## 2️⃣ Abrir proyecto

Abrir el proyecto desde Godot Engine 4.x usando el archivo:

```text
project.godot
```

---

## 3️⃣ Ejecutar

Presionar:

```text
F5
```

o ejecutar la escena principal:

```text
main_menu.tscn
```

---

# 🎮 Controles

| Acción | Descripción |
|---|---|
| Atacar | Realiza daño al enemigo |
| Defender | Reduce daño recibido |
| Inventario | Gestiona armas y consumibles |
| Historial | Muestra log de combate |
| Ajustes | Configuración de audio |

---

# 🧪 Estado del Proyecto

🚧 En desarrollo activo.

Actualmente el proyecto se encuentra en fase de expansión del MVP con foco en:

- Mejoras de arquitectura
- Pulido de UI
- Más contenido
- Optimización mobile
- Nuevos sistemas RPG

---

# 🛣️ Roadmap

## MVP

- [x] Sistema de combate
- [x] Inventario
- [x] Loot
- [x] Persistencia
- [x] Sistema de niveles
- [x] Audio manager
- [x] Pantallas principales

## Futuro

- [ ] Sistema de habilidades
- [ ] Crafteo
- [ ] Sistema idle/offline
- [ ] Eventos aleatorios
- [ ] Animaciones avanzadas
- [ ] Enemigos especiales
- [ ] Boss fights
- [ ] Publicación en Play Store
- [ ] Multiplayer async
- [ ] Cloud Save

---

# 🧠 Decisiones Técnicas

- Arquitectura desacoplada entre lógica y UI
- Uso de JSON para facilitar expansión de contenido
- Managers globales mediante Autoloads
- Diseño mobile-first
- Sistema preparado para escalabilidad futura

---

# 🤝 Contribuciones

Proyecto personal en desarrollo.

Se aceptan:

- Ideas
- Feedback
- Mejoras de arquitectura
- Optimización
- Sugerencias de gameplay

---

# 📜 Licencia

Licencia a definir.

---

# 👨‍💻 Autor

Franco Rodrigo Miranda

- GitHub: https://github.com/MirandaFrancoCBA
- LinkedIn: www.linkedin.com/in/franco-rodrigo-miranda-993710248

---

# 💡 Notas

- Proyecto desarrollado con enfoque educativo y profesional
- Código organizado para facilitar mantenimiento
- Pensado para evolucionar hacia un RPG mobile completo
- Uso intensivo de patrones desacoplados y managers reutilizables
