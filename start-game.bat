@echo off
chcp 65001 >nul
title КиберЩит: Беларусь
cd /d "%~dp0"
echo.
echo  ==========================================
echo     КИБЕРЩИТ: БЕЛАРУСЬ - запуск игры
echo  ==========================================
echo.

where node >nul 2>nul
if errorlevel 1 goto nonode

if not exist "public\chars" echo  [i] Папки public нет - будут использованы встроенные картинки. Это нормально.
if not exist ".env" if exist ".env.example" copy ".env.example" ".env" >nul

if exist "node_modules\.bin\next.cmd" goto deps_ok
echo  [1/3] Установка зависимостей, это займёт 1-3 минуты...
call npm install
if errorlevel 1 goto npmfail
:deps_ok

echo  [2/3] Проверка базы данных...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$c=New-Object Net.Sockets.TcpClient; try { $null=$c.ConnectAsync('127.0.0.1',5432).Wait(1500) } catch {}; if ($c.Connected) { exit 0 } else { exit 1 }" >nul 2>nul
if errorlevel 1 goto nodb
echo        База найдена - создаю таблицы...
call "node_modules\.bin\drizzle-kit.cmd" push --force
goto run

:nodb
echo        База данных не запущена - игра работает без неё.
echo        Не будут доступны только рейтинг и режим для школ.

:run
echo.
echo  [3/3] Запуск игры. Браузер откроется сам примерно через 15 секунд...
echo        Если не открылся - откройте вручную: http://localhost:3000
echo        Чтобы остановить игру - закройте это окно.
echo.
start "" cmd /c "timeout /t 15 >nul & start http://localhost:3000"
call npm run dev
pause
exit /b 0

:nonode
echo  [!] Не установлен Node.js. Сейчас откроется сайт - скачайте версию LTS,
echo      установите её, перезагрузите компьютер и снова запустите этот файл.
start https://nodejs.org
pause
exit /b 1

:npmfail
echo  [!] Не удалось установить зависимости. Проверьте интернет и попробуйте снова.
pause
exit /b 1
