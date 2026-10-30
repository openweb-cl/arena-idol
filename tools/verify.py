#!/usr/bin/env python3
"""Verificación reproducible sin dependencias Python externas.
Godot puede devolver cero ante algunos errores de script: revisar también el log.
"""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", default="godot", help="Ruta al ejecutable Godot 4 estable")
    parser.add_argument("--pack", action="store_true", help="Exportar y arrancar un PCK Linux temporal")
    args = parser.parse_args()
    engine = shutil.which(args.godot)
    if not engine:
        sys.exit("Godot no encontrado; usar --godot /ruta/al/ejecutable")
    with tempfile.TemporaryDirectory(prefix="arena-verify-") as work:
        env = os.environ.copy()
        for kind in ("DATA", "CONFIG", "CACHE"):
            folder = Path(work) / kind.lower()
            folder.mkdir()
            env[f"XDG_{kind}_HOME"] = str(folder)

        def run(label, *flags):
            command = [engine, "--headless", "--path", str(ROOT / "game"), *flags]
            result = subprocess.run(command, env=env, text=True, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, timeout=90)
            print(f"\n[{label}]\n{result.stdout}", flush=True)
            if result.returncode or "SCRIPT ERROR:" in result.stdout or "ERROR:" in result.stdout:
                sys.exit(f"Fallo: {label} (exit={result.returncode})")
            return result.stdout

        run("importación", "--editor", "--import")
        for script in sorted((ROOT / "game").rglob("*.gd")):
            if ".godot" not in script.parts:
                resource = "res://" + script.relative_to(ROOT / "game").as_posix()
                run(f"parse {resource}", "--check-only", "--script", resource)
        log = run("reglas y física", "--fixed-fps", "60", "--script", "res://tests/run_tests.gd")
        if "0 fallos" not in log or "RESULTADO:" not in log:
            sys.exit("La suite no confirmó ejecución y finalización")
        shots = run("proyectiles y apuntado", "--fixed-fps", "60", "--script", "res://tests/test_projectiles.gd")
        if "PROYECTILES:" not in shots or "0 fallos" not in shots:
            sys.exit("La suite de proyectiles no confirmó finalización")
        run("campo de tiro", "res://scenes/training/projectile_range.tscn", "--quit-after", "30")
        run("menú", "--quit-after", "10")
        run("arena", "res://scenes/arena/arena.tscn", "--quit-after", "30")
        if args.pack:
            pack = str(Path(work) / "arena.pck")
            run("exportación PCK", "--export-pack", "Linux", pack)
            run("PCK menú", "--main-pack", pack, "--quit-after", "10")
            run("PCK campo de tiro", "--main-pack", pack, "res://scenes/training/projectile_range.tscn", "--quit-after", "30")
            run("PCK arena", "--main-pack", pack, "res://scenes/arena/arena.tscn", "--quit-after", "30")
    print("Verificación completada. No acredita GPU/Android ni calidad comercial.")


if __name__ == "__main__":
    main()
