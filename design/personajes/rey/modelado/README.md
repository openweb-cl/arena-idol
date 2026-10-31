# Modelado — El Rey

Fuente actual: [Blender](../../../../art/rey/rey.blend). Export actual: [GLB provisional](../../../../game/assets/models/rey/rey.glb).

[Lámina de la muestra existente](../../../../docs/captures/heroes-v1-1/lamina_rey.jpg) (render Blender, no captura de gameplay).

Antes de refinar, aprobar V2 y seguir el [contrato de arte](../../../../docs/CONTRATO_ARTE_3D.md): pies en origen, ≈2 m,
frente -Z, sin root motion, clips idle/run/kick/hit/celebrate. `kick` significa
ataque, nunca pase. Collider y origen de proyectil son de gameplay.

Guardar versiones por commit antes de sobrescribir fuentes. Cambiar a pesos
suaves donde haga falta codo/rodilla fluido; demostrarlo con los clips, no con una
pose estática. El presupuesto inicial es ≤8k triángulos y ≤8 materiales, sujeto
a mediciones. No atribuir rendimiento comercial a un render de Blender.
