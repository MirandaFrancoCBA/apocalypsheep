# 🐑🔫 Apocalypsheep

Juego RPG mobile estilo pixel art con combate, loot y progresión, ambientado en un mundo post-apocalíptico habitado por ovejas evolucionadas que utilizan armas de fuego.

---

## 🧠 Concepto

Apocalypsheep es un RPG donde el jugador controla una oveja superviviente en un mundo devastado.  
Explorás zonas peligrosas, combatís enemigos, obtenés loot y mejorás tu equipamiento.

El juego está diseñado como una experiencia:
- 📱 Mobile-first
- 🔁 Altamente rejugable
- ⚙️ Escalable desde su arquitectura

---

## 🎯 Objetivo del MVP

Construir un juego funcional con el siguiente loop:

1. Selección de zona  
2. Combate contra enemigo  
3. Obtención de recompensas  
4. Gestión de inventario  
5. Repetición del ciclo  

---

## 🕹️ Features del MVP

- Sistema de combate básico
- Generación de enemigos por zona
- Sistema de loot
- Inventario
- Progresión del personaje (XP y niveles)
- Persistencia local (guardado de partida)

---

## 🏗️ Arquitectura

El proyecto está estructurado en capas para facilitar escalabilidad:

- **Core (Lógica del juego)**  
  Player, Enemy, CombatSystem, Item, Inventory

- **Data (Configuración)**  
  JSONs de items, enemigos y zonas

- **UI / Escenas**  
  Pantallas del juego

- **Managers (Singletons)**  
  GameManager, SaveManager, DataManager

---

## 📁 Estructura del proyecto

```text
apocalypsheep/
├── scenes/             # Escenas de Godot (.tscn)
├── scripts/            # Lógica del juego (GDScript)
│   ├── core/           # Clases base y lógica fundamental
│   ├── managers/       # Singletons (Autoloads) para música, inventario, etc.
│   ├── ui/             # Scripts de la interfaz de usuario
│   └── utils/          # Funciones de ayuda y constantes
├── data/               # Recursos (.tres) para ítems, armas y enemigos
├── assets/             # Archivos binarios
│   ├── sprites/        # Pixel art de ovejas y enemigos
│   ├── ui/             # Texturas de menús y botones
│   └── fx/             # Partículas y efectos visuales
├── save/               # Carpeta para archivos de guardado local
├── README.md
├── .gitignore
└── project.godot       # Configuración principal de Godot

## 🛠️ Tecnologías

- Engine: Godot
- Lenguaje: GDScript
- Plataforma objetivo: Android

---

## 🚀 Roadmap

### MVP
- [ ] Game Loop completo
- [ ] Combate funcional
- [ ] Inventario básico
- [ ] Loot y progresión
- [ ] Guardado local

### Futuro
- [ ] Sistema de habilidades
- [ ] Crafteo
- [ ] Sistema idle/offline
- [ ] Eventos aleatorios
- [ ] UI avanzada y animaciones
- [ ] Publicación en Play Store

---

## 📌 Estado del proyecto

🚧 En desarrollo – fase inicial (definición de arquitectura y MVP)

---

## 🤝 Contribución

Proyecto personal en desarrollo.  
Se aceptan ideas, feedback y mejoras de arquitectura.

---

## 📜 Licencia

A definir.

---

## 💡 Notas

- El proyecto está diseñado con enfoque en escalabilidad desde el inicio  
- Se prioriza lógica desacoplada de la UI  
- Se trabajará con Kanban (GitHub Projects) para organización  

---