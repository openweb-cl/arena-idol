#!/usr/bin/env python3
"""Renderiza fichas y carpetas de preproducción; --check comprueba sin escribir.

No importa datos a Godot ni altera Resources de combate. Solo biblioteca estándar.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs/plantel/roster_v1.json'
APPROVED_NUMBERS = {'turbo': 11, 'rey': 23, 'principe': 20, 'pitbull': 17}


def link(from_file, target, label):
    return f'[{label}]({Path(os.path.relpath(ROOT / target, from_file.parent)).as_posix()})'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def outputs(data):
    result = {}
    rows = []
    for hero in data['heroes']:
        ident = hero['id']
        folder = ROOT / 'design/personajes' / ident
        page = folder / 'README.md'
        card = ROOT / 'docs/plantel/fichas' / f'{ident}.md'
        dorsal = f"#{hero['number']}" if hero['number'] is not None else 'dorsal pendiente'
        ref = hero['existing_reference']
        ref_link = link(page, ref['path'], 'Lámina elegida por el propietario')
        new_concept = hero['concept_sheet']
        concept_path = f"{hero['concept_folder']}/{new_concept}" if new_concept else None
        concept_link = link(page, concept_path, 'Exploración, sin aprobación individual') if concept_path else 'No hay una exploración nueva individual: usar la referencia del propietario.'
        model = hero['model_path']
        runtime_model = 'game/' + model.removeprefix('res://') if model else None
        model_link = link(page, runtime_model, 'GLB provisional V1') if model else 'Sin modelo 3D entregado.'
        status = 'Jugable: comportamiento vigente, no rebalanceado aquí.' if hero['gameplay_status'] == 'implemented' else 'Ficha propuesta; gameplay sin implementar ni aprobar.'
        rows.append(f"| {hero['canonical_id']} | {link(ROOT / 'docs/plantel/README.md', str(page.relative_to(ROOT)), hero['name'])} | {dorsal} | {hero['role']} | {'GLB provisional' if model else 'Referencia 2D'} | {link(ROOT / 'docs/plantel/README.md', str(card.relative_to(ROOT)), 'Ficha')} |")
        result[page] = f'''# {hero['name']} — {dorsal}

{status} La dirección es **futbolista caricaturesco en combate arcade**.
No hay diseño final aprobado. No cambiar cara, proporciones o equipación entre
imágenes sin registrar una propuesta y la decisión del propietario.

## Punto de partida

{ref_link}: **{ref['panel']}**. Es la referencia principal de carácter,
proporción y energía. Sus números, clubes y mecánicas deportivas no se incorporan.
Dorsal vigente: **{dorsal}**.

{hero['silhouette']}

{hero['face']}

Paleta propuesta: {', '.join(f'{k} `{v}`' for k, v in hero['palette'].items())}.
La paleta es guía; no sustituye materiales actuales sin revisión.

## Evolución verificable

| Etapa | Evidencia / estado |
|---|---|
| V0 — pruebas geométricas | {'Existe evidencia histórica; ver historial.json.' if ident in ('turbo', 'rey') else 'No entregada para este personaje; no inventar una versión anterior.'} |
| V1 — GLB provisional | {model_link} |
| V2 — diseño definido | Pendiente: frente, perfil, espalda y expresiones aprobados. |
| V3 — modelo refinado | Pendiente de V2; Blender, GLB, rig y clips en Godot. |
| Candidato final | Pendiente de prueba visual, animación, legibilidad y rendimiento. |

El nombre V1 agrupa el estado del pipeline; las versiones locales de cada GLB
siguen en su documento de arte (p. ej., Turbo V1.1). No implica que todos estén
igual de avanzados. Las exploraciones recientes **no** cuentan como V2 aprobado.

## Carpetas y siguiente paso

- [Referencias](referencias/README.md): original del propietario y fuentes previas.
- [Bocetos](bocetos/README.md): exploraciones; no reemplazan la referencia elegida.
- [Modelado](modelado/README.md): fuentes, export y contrato.
- [Revisiones](revisiones/README.md): registro de decisiones y comparación.
- [Aprobado](aprobado/README.md): reservado; hoy no hay arte final aprobado.
- [Historial con hashes](historial.json).
- {link(page, str(card.relative_to(ROOT)), 'Ficha de combate')}; sus valores nuevos son hipótesis.

**Próxima muestra:** {'Turbo V2 como patrón del plantel.' if ident == 'turbo' else 'Esperar patrón Turbo V2 aprobado y adaptar este héroe sin uniformar todas las caras.'}
{concept_link}.
'''
        rp = folder / 'referencias/README.md'
        result[rp] = f'''# Referencias — {hero['name']}

{link(rp, ref['path'], 'Original del propietario')} — **{ref['panel']}**.
Conservar esta imagen intacta. Compartida por los 16: no duplicar el binario.
{link(rp, 'design/referencias/propietario_2026-10-31/README.md', 'Qué tomar de cada imagen')}.

Los dorsales impresos y símbolos no son autorizaciones. La guía vigente de
rostro/ropa es una caricatura deportiva original; no copiar retratos reales.
Dorsal de trabajo: **{dorsal}**.
'''
        bp = folder / 'bocetos/README.md'
        result[bp] = f'''# Bocetos — {hero['name']}

{link(bp, concept_path, 'Exploración reciente') + ' — ' + hero['panel'] if concept_path else 'Solo está localizada la referencia individual del propietario; no hay nuevo turnaround.'}.
Estado: **exploración pendiente; no diseño V2 ni arte final aprobado**.

Para V2 producir frente, perfil, espalda, rostro y una pose de combate, con la
misma identidad en todas las vistas. Primero aprobar Turbo V2 como patrón.
Comparar siempre con la referencia, registrar diferencias y pedir revisión de
esa muestra concreta antes del modelo refinado. No generar caras distintas para
cada pantalla.
'''
        mp = folder / 'modelado/README.md'
        source = f'art/{ident}/{ident}.blend'
        model_text = (f"Fuente actual: {link(mp, source, 'Blender')}. Export actual: {link(mp, runtime_model, 'GLB provisional')}.\n\n{link(mp, f'docs/captures/heroes-v1-1/lamina_{ident}.jpg', 'Lámina de la muestra existente')} (render Blender, no captura de gameplay)." if model else f"Todavía no hay Blender ni GLB de este héroe. Ruta futura: `{hero['planned_model_path']}`; no crear un archivo vacío para simular entrega.")
        result[mp] = f'''# Modelado — {hero['name']}

{model_text}

Antes de refinar, aprobar V2 y seguir el {link(mp, 'docs/CONTRATO_ARTE_3D.md', 'contrato de arte')}: pies en origen, ≈2 m,
frente -Z, sin root motion, clips idle/run/kick/hit/celebrate. `kick` significa
ataque, nunca pase. Collider y origen de proyectil son de gameplay.

Guardar versiones por commit antes de sobrescribir fuentes. Cambiar a pesos
suaves donde haga falta codo/rodilla fluido; demostrarlo con los clips, no con una
pose estática. El presupuesto inicial es ≤8k triángulos y ≤8 materiales, sujeto
a mediciones. No atribuir rendimiento comercial a un render de Blender.
'''
        vp = folder / 'revisiones/README.md'
        result[vp] = f'''# Revisión — {hero['name']}

Estado inicial: referencia elegida, exploraciones pendientes, final sin aprobar.

| Versión / commit | Cambio concreto | Evidencia | Decisión del propietario |
|---|---|---|---|
| Inicio del paquete | Se conserva referencia y se separan etapas | ../historial.json | Línea caricaturesca elegida; diseño individual pendiente |

En cada nueva revisión registrar fecha, autor, hash/commit, qué conservar, qué
cambiar y decisión. No borrar un rechazo ni convertir el silencio en aprobación.

- [ ] Misma cara/peinado y equipación entre vistas.
- [ ] Silueta identificable a tamaño real de juego y en gris.
- [ ] Frente/perfil/espalda/expresiones consistentes.
- [ ] Idle, carrera, giro, ataque, impacto y celebración sin deslizamientos.
- [ ] Modelo en selección y arena con Mobile y Compatibility.
- [ ] Ataques legibles, avisos previos y cabeza/PV despejados.
- [ ] Métricas en hardware real antes de prometer 60 FPS.
- [ ] Aprobación explícita para avanzar al siguiente estado.
'''
        result[folder / 'aprobado/README.md'] = '''# Arte aprobado

**Todavía no hay arte final aprobado en esta carpeta.**

La aprobación de la línea visual no aprueba automáticamente un retrato, GLB,
animación ni balance. Al aprobar una versión, registrar su commit, hash, lámina,
fecha y alcance en ../historial.json. Mantener las versiones anteriores.
'''
        assets = [{'stage': 'reference', 'path': ref['path'], 'sha256': sha(ROOT / ref['path']), 'status': 'owner_selected_style_not_final', 'panel': ref['panel']}]
        if ident in ('turbo', 'rey'):
            old = f'docs/captures/heroes-v1-1/mobile-90-referencia-placeholders-zoom-{ident}.png'
            assets.append({'stage': 'V0', 'path': old, 'sha256': sha(ROOT / old), 'status': 'historical_gameplay_placeholder'})
        if model:
            assets.extend([{'stage': 'V1', 'path': path, 'sha256': sha(ROOT / path), 'status': 'existing_provisional_not_final'} for path in [runtime_model, source, f'docs/captures/heroes-v1-1/lamina_{ident}.jpg']])
        if concept_path:
            assets.append({'stage': 'exploration_not_V2', 'path': concept_path, 'sha256': sha(ROOT / concept_path), 'status': 'pending_owner_review', 'panel': hero['panel']})
        hist = {'schema_version': 1, 'snapshot_commit': 'd88adc5', 'snapshot_date_utc': '2026-10-31', 'hero_id': ident, 'final_approved': False, 'assets': assets, 'next_stage': 'V2_design_pending_owner_review', 'discarded_exploration': hero['rejected_visual_reference'], 'note': 'Hashes preservan el estado de este paquete. Añadir versiones nuevas al historial; no reescribir aprobaciones históricas.'}
        for asset in assets:
            if asset['path'].startswith(('art/', 'game/', 'docs/captures/')):
                asset['source_commit'] = 'd88adc5'
        if ident == 'turbo':
            hist['earlier_git_version'] = {'commit': '20a4d41', 'note': 'Primera muestra Turbo V1 previa a V1.1; consultar git para fuente histórica.'}
        history_path = folder / 'historial.json'
        # La regeneración no borra decisiones ni versiones añadidas al historial.
        result[history_path] = history_path.read_text() if history_path.exists() else json.dumps(hist, ensure_ascii=False, indent=2) + '\n'
        body = f'''# {hero['name']} — {dorsal}

**{status}** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **{hero['role']}**. PV: **{hero['health']}**; velocidad: **{hero['speed']} m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

{link(card, str(page.relative_to(ROOT)), 'Carpeta visual y evolución')}.
'''
        if ident == 'principe':
            body += '\n' + link(card, 'docs/PRINCIPE_KIT.md', 'Ficha extensa del Príncipe — prevalece sobre este resumen') + '. La aprobación y gameplay siguen pendientes. Eventos VFX: `principe_shot`, `principe_buff`, `principe_field_warning`, `principe_field`.\n'
        for field, label in [('basic', 'Básico ofensivo'), ('active', 'Habilidad'), ('super', 'Súper')]:
            a = hero[field]
            body += f"\n## {label} — {a['name']}\n\n{a['summary']}\n\n| Parámetro | Valor |\n|---|---|\n"
            body += ''.join(f'| `{k}` | {v} |\n' for k, v in a['values'].items() if v is not None)
            if a['details']:
                body += '\n' + '\n'.join('- ' + item for item in a['details']) + '\n'
        body += f'''\n## Respuesta rival y bot

{hero['counterplay']}

Bot: {hero['bot']}

## Producción y aceptación

Animación propuesta: {hero['animation']}

Módulos que necesita: {', '.join('`' + m + '`' for m in hero['modules'])}.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

{link(card, 'docs/plantel/REGLAS_COMBATE.md', 'Reglas comunes')} · {link(card, 'docs/plantel/PRODUCCION.md', 'Secuencia y módulos')}.
'''
        result[card] = body
    index = ROOT / 'docs/plantel/README.md'
    result[index] = '''# Plantel — biblioteca de diseño y evolución

**16 héroes canónicos; dos jugables; cuatro GLB provisionales.** Este paquete
organiza referencias y propuestas para continuar en local. No implementa nuevos
personajes ni sustituye el diseño aprobado por una imagen recién generada.

- [Visión visual y etapas V0 → candidato final](VISUAL.md).
- [Referencias elegidas por el propietario](../../design/referencias/propietario_2026-10-31/README.md).
- [Carpetas visuales de cada personaje](../../design/personajes/README.md).
- [Reglas de combate](REGLAS_COMBATE.md) y [producción por hitos](PRODUCCION.md).
- [Contexto de continuidad](../CONTEXTO_DE_CONTINUIDAD.md).
- [Verificación y límites de esta entrega](VERIFICACION.md).

La línea elegida es caricaturesca como las primeras láminas aportadas; la última
orienta composición de pantallas, no realismo de rostros. Nuevas exploraciones
son propuestas pendientes. Primero aprobar **Turbo V2** y usarlo como patrón.
Los kits de los 14 pendientes son hipótesis, con ataque básico ofensivo en todos.
El Príncipe mantiene prioridad y necesita aprobación de su ficha antes del código;
Pitbull espera su prueba. Los otros 12 dorsales permanecen sin definir.

| ID | Personaje | Dorsal | Rol propuesto | Arte existente | Combate |
|---|---|---|---|---|---|
''' + '\n'.join(rows) + '''

Las fichas y carpetas se generan desde [roster_v1.json](roster_v1.json):

```sh
python3 tools/render_roster_design.py
python3 tools/render_roster_design.py --check
```

Ejecutar desde la raíz. El catálogo vive fuera de `game/`; no es un Resource de
Godot ni una promesa de sistemas implementados. No editar a mano los archivos
generados sin actualizar catálogo/renderizador. Referencias/manifest preservan
procedencia y hashes; los originales adjuntos permanecen intactos.
'''
    result[ROOT / 'design/personajes/README.md'] = '''# Biblioteca visual de personajes

[Índice de los 16 héroes y fichas](../../docs/plantel/README.md).
[Guía de evolución y estilo](../../docs/plantel/VISUAL.md).

Cada héroe tiene referencias, bocetos, modelado, revisiones, aprobado e historial.
Las carpetas contienen evidencia y tareas, no archivos ficticios. Las fuentes 3D
existentes siguen en `art/` y `game/assets/models/`, enlazadas sin duplicarlas.

V0 = pruebas geométricas históricas. V1 = modelos provisionales disponibles.
V2 = diseño definido pendiente de aprobación. V3 = GLB refinado y probado.
Candidato final = pulido que todavía necesita evaluación dentro del juego.
No todos los héroes tienen todas las etapas; los que no existen se indican.
'''
    return result


def validate(data):
    heroes = data['heroes']
    canonical = re.findall(r'^\| ([A-Z]{3}-\d{2}) \|', (ROOT / 'docs/ROSTER_CANONICO_V0_4.md').read_text(), re.M)
    assert [h['canonical_id'] for h in heroes] == canonical and len(heroes) == 16, 'Plantel distinto del canónico'
    assert len({h['id'] for h in heroes}) == 16, 'IDs duplicados'
    canonical_names = re.findall(r'^\| [A-Z]{3}-\d{2} \| [^|]+ \| ([^|]+) \|', (ROOT / 'docs/ROSTER_CANONICO_V0_4.md').read_text(), re.M)
    assert [h['name'] for h in heroes] == [n.strip() for n in canonical_names], 'Nombres distintos del canónico'
    assert {h['id']: h['number'] for h in heroes if h['number'] is not None} == APPROVED_NUMBERS, 'Dorsales no aprobados'
    assert {h['id'] for h in heroes if h['gameplay_status'] == 'implemented'} == {'turbo', 'rey'}
    assert {h['id'] for h in heroes if h['model_path']} == set(APPROVED_NUMBERS)
    for h in heroes:
        assert h['basic']['values']['damage_per_attack'] > 0, f"Básico no ofensivo: {h['id']}"
        assert (ROOT / h['existing_reference']['path']).is_file()
    for folder in ['design/ui/seleccion_evolucion', 'design/plantel/bocetos_deportivos_v1', 'design/plantel/rechazado_fantasia_2026-10-30', 'design/referencias/propietario_2026-10-31']:
        manifest = json.loads((ROOT / folder / 'MANIFEST.json').read_text())
        for asset in manifest.get('assets', [manifest]):
            assert sha(ROOT / folder / asset['file']) == asset['sha256'], f"Hash distinto: {asset['file']}"


    for h in heroes:
        history_path = ROOT / 'design/personajes' / h['id'] / 'historial.json'
        if not history_path.exists():
            continue  # Primera generación.
        history = json.loads(history_path.read_text())
        assert history['hero_id'] == h['id'] and isinstance(history['final_approved'], bool)
        if history['final_approved']:
            assert history.get('owner_approval_reference'), 'Falta evidencia de aprobación final'
        for asset in history['assets']:
            if asset.get('source_commit'):
                result = subprocess.run(['git', 'show', f"{asset['source_commit']}:{asset['path']}"], cwd=ROOT, capture_output=True, check=True)
                actual = hashlib.sha256(result.stdout).hexdigest()
            else:
                actual = sha(ROOT / asset['path'])
            assert actual == asset['sha256'], f"Historial alterado: {asset['path']}"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    data = json.loads(SOURCE.read_text())
    validate(data)
    rendered = outputs(data)
    failures = []
    for path, content in rendered.items():
        if args.check:
            if not path.is_file() or path.read_text() != content:
                failures.append(str(path.relative_to(ROOT)))
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)
    if failures:
        sys.exit('Archivos desactualizados: ' + ', '.join(failures))
    manual_roots = ['docs/plantel', 'design/personajes', 'design/plantel', 'design/referencias/propietario_2026-10-31', 'design/ui']
    checked = dict(rendered)
    for folder in manual_roots:
        for path in (ROOT / folder).rglob('*.md'):
            checked[path] = path.read_text()
    checked[ROOT / 'docs/CONTEXTO_DE_CONTINUIDAD.md'] = (ROOT / 'docs/CONTEXTO_DE_CONTINUIDAD.md').read_text()
    for path, content in checked.items():
        if path.suffix != '.md':
            continue
        for target in re.findall(r'\]\(([^)]+)\)', content):
            if not target.startswith(('https:', '#')):
                assert (path.parent / target.split('#')[0]).exists(), f'Enlace roto: {path} → {target}'
    print(f"Plantel: 16 IDs, 4 dorsales, 16 básicos ofensivos; {len(rendered)} archivos {'comprobados' if args.check else 'generados'}; fuentes/hashes/enlaces correctos.")


if __name__ == '__main__':
    main()
