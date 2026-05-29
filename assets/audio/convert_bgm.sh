#!/bin/bash
# 강남드림 BGM 변환 스크립트
# Suno에서 다운로드한 MP3 → OGG 변환 후 게임 폴더로 이동
#
# 사용법: bash convert_bgm.sh
#
# Downloads 폴더에 있는 "Gangnam Dream - *.mp3" 파일을
# 자동으로 감지해서 변환합니다.

FFMPEG="/tmp/ffmpeg_bin/ffmpeg"
GAME_AUDIO="$(dirname "$0")"
DOWNLOADS=~/Downloads

if [ ! -f "$FFMPEG" ]; then
  echo "❌ ffmpeg 없음. 다운로드 중..."
  curl -L "https://evermeet.cx/ffmpeg/getrelease/ffmpeg/zip" -o /tmp/ffmpeg_arm.zip
  unzip -o /tmp/ffmpeg_arm.zip -d /tmp/ffmpeg_bin
  chmod +x /tmp/ffmpeg_bin/ffmpeg
fi

echo "🎵 강남드림 BGM 변환 시작"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

convert_track() {
  local mp3_name="$1"
  local ogg_name="$2"
  local src="$DOWNLOADS/$mp3_name"
  local dst="$GAME_AUDIO/$ogg_name"

  if [ ! -f "$src" ]; then
    echo "⏭  건너뜀 (파일 없음): $mp3_name"
    return
  fi

  if [ -f "$dst" ]; then
    echo "✅ 이미 있음: $ogg_name"
    return
  fi

  echo "🔄 변환 중: $mp3_name → $ogg_name"
  "$FFMPEG" -i "$src" -vn -c:a libvorbis -q:a 6 "$dst" -y -loglevel error

  if [ -f "$dst" ]; then
    DURATION=$("$FFMPEG" -i "$dst" 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//')
    SIZE=$(ls -lh "$dst" | awk '{print $5}')
    echo "   ✅ $ogg_name ($SIZE, $DURATION)"
  else
    echo "   ❌ 변환 실패: $ogg_name"
  fi
}

# 7개 트랙 변환
convert_track "Gangnam Dream - Menu BGM (bgm_menu).mp3"          "bgm_menu.ogg"
convert_track "Gangnam Dream - Gosiwon BGM (bgm_gosiwon).mp3"    "bgm_gosiwon.ogg"
convert_track "Gangnam Dream - Main BGM (bgm_main).mp3"          "bgm_main.ogg"
convert_track "Gangnam Dream - Apartment BGM (bgm_apartment).mp3" "bgm_apartment.ogg"
convert_track "Gangnam Dream - Crisis BGM (bgm_crisis).mp3"      "bgm_crisis.ogg"
convert_track "Gangnam Dream - Victory Jingle (bgm_victory).mp3" "bgm_victory.ogg"
convert_track "Gangnam Dream - Ending BGM (bgm_ending).mp3"      "bgm_ending.ogg"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 게임 오디오 폴더:"
ls -lh "$GAME_AUDIO"/*.ogg 2>/dev/null | awk '{print "   " $5 "  " $9}' | xargs -I{} echo {}
echo ""
echo "✅ 완료! Godot에서 프로젝트를 다시 불러오세요."
