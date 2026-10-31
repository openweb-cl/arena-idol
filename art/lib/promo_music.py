"""Música original del video promocional (sintetizada por código, sin muestras ajenas).

128 BPM, La menor (Am–F–C–G): bombo, palmada, charles, bajo y arpegio.
Uso: python art/lib/promo_music.py builds/promo/musica.wav [segundos]
Provisional: no es la música oficial del juego.
"""
import array
import math
import random
import sys
import wave

RATE = 44100
BPM = 128
BEAT = 60 / BPM
OUT = sys.argv[1] if len(sys.argv) > 1 else "musica.wav"
LENGTH = float(sys.argv[2]) if len(sys.argv) > 2 else 30.5
CHORDS = [(57, 60, 64), (53, 57, 60), (48, 52, 55), (55, 59, 62)]  # Am F C G (MIDI)

random.seed(2310)
n = int(LENGTH * RATE)
mix = array.array("f", [0.0]) * n


def freq(note):
    return 440.0 * 2 ** ((note - 69) / 12)


def add(start, samples):
    i0 = int(start * RATE)
    for k, v in enumerate(samples):
        if 0 <= i0 + k < n:
            mix[i0 + k] += v


def kick():
    out, phase = [], 0.0
    for k in range(int(0.35 * RATE)):
        t = k / RATE
        phase += 2 * math.pi * (50 + 90 * math.exp(-t * 28)) / RATE
        out.append(math.sin(phase) * math.exp(-t * 9) * 0.9)
    return out


def noise(length, decay, gain, tone=0.0):
    out, last = [], 0.0
    for k in range(int(length * RATE)):
        x = random.uniform(-1, 1)
        last = last * tone + x * (1 - tone)  # filtro simple: tone alto = más grave
        out.append((x - last if tone else x) * math.exp(-k / RATE * decay) * gain)
    return out


def pluck(note, length, gain, bright=4):
    f = freq(note)
    out = []
    for k in range(int(length * RATE)):
        t = k / RATE
        v = sum(math.sin(2 * math.pi * f * h * t) / h for h in range(1, bright + 1))
        out.append(v * math.exp(-t * 6) * gain)
    return out


bar = 4 * BEAT
bars = int(LENGTH / bar) + 1
KICK = kick()
CLAP = noise(0.18, 22, 0.35, tone=0.6)
HAT = noise(0.05, 70, 0.12)
for b in range(bars):
    chord = CHORDS[b % 4]
    t0 = b * bar
    intro = b == 0
    for beat in range(4):
        tb = t0 + beat * BEAT
        if not intro:
            add(tb, KICK)
            if beat in (1, 3):
                add(tb, CLAP)
        add(tb + BEAT / 2, HAT)
        # Bajo en corcheas sobre la fundamental, una octava abajo.
        for e in range(2):
            add(tb + e * BEAT / 2, pluck(chord[0] - 12, BEAT / 2 * 0.95, 0.28 if not intro else 0.15, bright=3))
    # Arpegio en semicorcheas con las notas del acorde.
    pattern = [0, 1, 2, 1, 0, 2, 1, 2]
    for s in range(16):
        note = chord[pattern[s % 8]] + 12
        add(t0 + s * BEAT / 4, pluck(note, BEAT / 4 * 0.9, 0.09, bright=2))

# Entrada y salida suaves, y normalización.
fade = int(1.5 * RATE)
for k in range(n):
    if k > n - fade:
        mix[k] *= (n - k) / fade
peak = max(abs(v) for v in mix) or 1.0
pcm = array.array("h", (int(v / peak * 0.85 * 32767) for v in mix))
with wave.open(OUT, "wb") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(pcm.tobytes())
print("MUSIC", OUT, round(LENGTH, 2), "s")
