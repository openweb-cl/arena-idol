---
name: flujo-ramas
description: Convención de ramas, commits y PR de Arena de Ídolos. Usar SIEMPRE antes de editar archivos, crear una rama, hacer commit, push o abrir un PR.
---

# Flujo de ramas y PR

Regla del propietario (30 octubre 2026). Prevalece sobre `claude/<hito>` y
`codex/<hito>` de documentos anteriores.

## Nunca en main

1. `git fetch` y actualizar `main` (`git pull --ff-only origin main`).
2. Crear una rama nueva por cada avance, antes de editar nada.
3. Commits pequeños por hito; push de la rama; PR hacia `main`.
4. No fusionar sin aprobación explícita del propietario. Sin rebase, reset ni
   force-push sobre ramas ajenas.

## Nombre de rama: `<categoría>/<descripción>`

| Categoría | Cuándo |
|---|---|
| `novedad/` | Algo que no existía: héroe, pantalla, sistema, herramienta, skill |
| `cambio/` | Modificar o mejorar algo existente: refresh visual, ajuste, refactor |
| `correccion/` | Arreglar un fallo o un comportamiento incorrecto |

La descripción va en español, minúsculas, sin tildes ni ñ, palabras separadas por
guiones, y dice qué se hace: `novedad/principe-jugable`,
`cambio/turbo-v3-modelo-refinado`, `correccion/pantalla-negra-windows`.
Si dudas entre `cambio` y `novedad`: si el jugador ve algo que antes no estaba, es
`novedad`.

## Tamaño del PR: contundente, no excesivo

El propietario no quiere PR demasiado cortos (30 octubre 2026). Cada PR entrega un
**avance completo que se pueda ver o jugar**, no un paso intermedio:

- Bien: un héroe refinado de punta a punta (modelo, rig, clips, integración en
  Godot, capturas y docs); un héroe jugable con su kit, VFX, pruebas y selección;
  un refresh de una pantalla completa.
- Demasiado corto: solo docs, solo un ajuste de color, solo el `.blend` sin
  integrar. Eso se suma al PR del avance que corresponda.
- Excesivo: varios héroes y pantallas sin relación, o cambios que el propietario
  no puede revisar de una vez. Si mezcla temas, se divide.
- Dentro del PR, commits pequeños y ordenados por paso.

## Commits y PR

- Mensajes en español: `tipo: qué cambia` (p. ej. `arte: Turbo V3 con rostro`).
- No incluir cambios ajenos al hito (p. ej. `project.godot` reescrito por el editor
  o `.import` regenerados) salvo que sean parte del trabajo.
- El PR lista: objetivo, archivos tomados, comandos de verificación reales con sus
  resultados, capturas si hay cambio visual y límites pendientes.
- Nunca subir secretos, credenciales ni keystores.
