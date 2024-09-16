# Ruta temporal donde se copiarán las carpetas del USB
$destino = Join-Path $env:TEMP "BackupUSB"

# Función para copiar las carpetas del USB
function Copiar-CarpetasUSB {
    param (
        [string]$unidadUSB
    )

    # Si la unidad existe
    if (Test-Path $unidadUSB) {
        # Crear la carpeta de destino si no existe
        if (-not (Test-Path $destino)) {
            New-Item -Path $destino -ItemType Directory -ErrorAction SilentlyContinue
        }

        # Copiar las carpetas y archivos del USB al destino sin salida de mensajes
        Copy-Item -Path "$unidadUSB\*" -Destination $destino -Recurse -Force | Out-Null
    }
}

# Evento para detectar la conexión de un dispositivo USB
Register-WmiEvent -Query "SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE TargetInstance ISA 'Win32_DiskDrive' AND TargetInstance.InterfaceType='USB'" -Action {
    # Esperar un momento para que el sistema asigne una letra de unidad
    Start-Sleep -Seconds 5

    # Buscar la letra de unidad asignada al USB
    $unidadUSB = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Select-Object -First 1

    if ($unidadUSB) {
        $unidadUSBLetra = $unidadUSB.DeviceID

        # Llamar a la función para copiar las carpetas del USB
        Copiar-CarpetasUSB $unidadUSBLetra
    }
}

# Mantener el script en ejecución con WMI sin ciclo infinito
while ($true) {
    Wait-Event -Timeout 60 | Out-Null
}