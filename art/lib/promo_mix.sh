#!/usr/bin/env bash
# Mezcla del video promocional: imagen de Godot + música + narración, con la música
# bajando cuando habla la voz. Provisional, nada oficial.
# Uso (desde la raíz, con ffmpeg en el PATH): bash art/lib/promo_mix.sh
# Entradas en builds/promo/: promo.avi, musica.wav (promo_music.py) y voz_1..7.wav
# (síntesis de Windows, voz Sabina). Salida: builds/promo/arena-de-idolos-promo.mp4
set -euo pipefail
cd "$(dirname "$0")/../../builds/promo"
DELAYS=(500 3400 8400 13100 17900 22600 27000)  # ms: portada, selección, 4 duelos, cierre
inputs=(-i promo.avi -i musica.wav)
chain=""
labels=""
for i in "${!DELAYS[@]}"; do
  n=$((i + 1))
  inputs+=(-i "voz_$n.wav")
  chain+="[$((i + 2))]aresample=44100,adelay=${DELAYS[$i]}:all=1[v$n];"
  labels+="[v$n]"
done
chain+="${labels}amix=inputs=${#DELAYS[@]}:normalize=0,volume=1.7,asplit=2[vo1][vo2];"
chain+="[1]aresample=44100,volume=0.55[m];[m][vo1]sidechaincompress=threshold=0.03:ratio=8:attack=15:release=350[md];"
chain+="[md][vo2]amix=inputs=2:normalize=0,alimiter=limit=0.95,aformat=channel_layouts=stereo[a]"
ffmpeg -v error -y "${inputs[@]}" -filter_complex "$chain" -map 0:v -map "[a]" \
  -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart -shortest \
  arena-de-idolos-promo.mp4
echo "PROMO builds/promo/arena-de-idolos-promo.mp4"
