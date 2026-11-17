#!/usr/bin/env bash
# КиберЩит: Беларусь — запуск игры (macOS / Linux)
cd "$(dirname "$0")"
if ! command -v node >/dev/null 2>&1; then
  echo "[!] Установите Node.js LTS: https://nodejs.org"; exit 1
fi
[ -d public/chars ] || echo "[i] Папки public нет — будут использованы встроенные картинки."
[ -f .env ] || { [ -f .env.example ] && cp .env.example .env; }
[ -x node_modules/.bin/next ] || { echo "[1/3] Установка зависимостей..."; npm install || exit 1; }
echo "[2/3] Проверка базы данных..."
if (exec 3<>/dev/tcp/127.0.0.1/5432) 2>/dev/null; then
  ./node_modules/.bin/drizzle-kit push --force
else
  echo "     База не запущена — игра работает без неё (без рейтинга и классов)."
fi
echo "[3/3] Запуск: http://localhost:3000"
( sleep 10; (command -v open >/dev/null && open http://localhost:3000) || (command -v xdg-open >/dev/null && xdg-open http://localhost:3000) ) >/dev/null 2>&1 &
npm run dev
