# Script para compilar obs-screenshot-plugin
# Compatible con OBS Studio 32.0.1

Write-Host "=== Compilador de obs-screenshot-plugin ===" -ForegroundColor Cyan
Write-Host ""

# Configuración
$OBS_STUDIO_PATH = "D:\Repos\obs-studio"
$PLUGIN_PATH = "D:\Repos\obs-screenshot-plugin"
$BUILD_PATH = "$PLUGIN_PATH\build"

# Verificar que OBS Studio existe
if (-not (Test-Path $OBS_STUDIO_PATH)) {
    Write-Host "ERROR: No se encontró OBS Studio en $OBS_STUDIO_PATH" -ForegroundColor Red
    Write-Host "Por favor clona OBS Studio primero:" -ForegroundColor Yellow
    Write-Host "  cd D:\Repos" -ForegroundColor White
    Write-Host "  git clone --recursive https://github.com/obsproject/obs-studio.git" -ForegroundColor White
    exit 1
}

Write-Host "[1/5] Limpiando directorio de compilación..." -ForegroundColor Yellow
if (Test-Path $BUILD_PATH) {
    Remove-Item -Recurse -Force $BUILD_PATH
}
New-Item -ItemType Directory -Path $BUILD_PATH | Out-Null

Write-Host "[2/5] Verificando dependencias de OBS Studio..." -ForegroundColor Yellow

# Verificar si OBS Studio ya está compilado
$OBS_BUILD_PATH = "$OBS_STUDIO_PATH\build64"
if (-not (Test-Path "$OBS_BUILD_PATH\libobs\libobs.lib")) {
    Write-Host ""
    Write-Host "OBS Studio no está compilado. Para compilar el plugin necesitas:" -ForegroundColor Red
    Write-Host ""
    Write-Host "1. Compilar OBS Studio primero:" -ForegroundColor Cyan
    Write-Host "   cd $OBS_STUDIO_PATH" -ForegroundColor White
    Write-Host "   mkdir build64" -ForegroundColor White
    Write-Host "   cd build64" -ForegroundColor White
    Write-Host "   cmake .. -G `"Visual Studio 17 2022`" -A x64 -DCMAKE_PREFIX_PATH=`"C:/obs-build-dependencies/windows-deps-2024-11-18-x64`"" -ForegroundColor White
    Write-Host "   cmake --build . --config Release" -ForegroundColor White
    Write-Host ""
    Write-Host "2. O descargar dependencias precompiladas de:" -ForegroundColor Cyan
    Write-Host "   https://github.com/obsproject/obs-studio/releases/tag/32.0.1" -ForegroundColor White
    Write-Host ""
    Write-Host "ALTERNATIVA MÁS RÁPIDA:" -ForegroundColor Green
    Write-Host "Instala OBS Studio con archivos de desarrollo desde:" -ForegroundColor White
    Write-Host "https://obsproject.com/downloads" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "[3/5] Configurando proyecto con CMake..." -ForegroundColor Yellow
Set-Location $BUILD_PATH

$cmakeCommand = "cmake .. -G `"Visual Studio 17 2022`" -A x64 -DCMAKE_PREFIX_PATH=`"$OBS_BUILD_PATH`""
Write-Host "Ejecutando: $cmakeCommand" -ForegroundColor Gray
Invoke-Expression $cmakeCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Falló la configuración de CMake" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[4/5] Compilando plugin..." -ForegroundColor Yellow
cmake --build . --config Release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Falló la compilación" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[5/5] Verificando compilación..." -ForegroundColor Yellow

$dllPath = "$BUILD_PATH\Release\obs-screenshot-filter.dll"
if (Test-Path $dllPath) {
    Write-Host ""
    Write-Host "=== ¡COMPILACIÓN EXITOSA! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Plugin compilado en:" -ForegroundColor Cyan
    Write-Host "  $dllPath" -ForegroundColor White
    Write-Host ""
    Write-Host "Para instalar el plugin:" -ForegroundColor Cyan
    Write-Host "  1. Copia el archivo .dll a:" -ForegroundColor White
    Write-Host "     C:\Program Files\obs-studio\obs-plugins\64bit\" -ForegroundColor White
    Write-Host "  2. Reinicia OBS Studio" -ForegroundColor White
    Write-Host ""
    
    # Información del archivo
    $fileInfo = Get-Item $dllPath
    Write-Host "Tamaño: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray
    Write-Host "Fecha: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ERROR: No se encontró el archivo compilado" -ForegroundColor Red
    Write-Host "Ruta esperada: $dllPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "Presiona Enter para continuar..."
Read-Host
