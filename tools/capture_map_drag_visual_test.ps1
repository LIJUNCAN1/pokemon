param(
    [string]$ProjectRoot = "D:\pokemon",
    [string]$GodotPath = "D:\Godot_v4.7.1-stable_win64.exe"
)

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class MapDragNative {
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extraInfo);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

function Save-Screen([string]$Name) {
    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = [System.Drawing.Bitmap]::new($bounds.Width, $bounds.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
        $bitmap.Save((Join-Path $ProjectRoot $Name), [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$process = Start-Process -FilePath $GodotPath -ArgumentList @(
    "--path", $ProjectRoot,
    "--scene", "res://tools/map_drag_visual_test.tscn"
) -PassThru
try {
    for ($attempt = 0; $attempt -lt 50 -and $process.MainWindowHandle -eq 0; $attempt++) {
        Start-Sleep -Milliseconds 100
        $process.Refresh()
    }
    [MapDragNative]::SetForegroundWindow($process.MainWindowHandle) | Out-Null
    Start-Sleep -Milliseconds 3200
    Save-Screen "map_drag_before.png"
    [MapDragNative]::SetCursorPos(1200, 500) | Out-Null
    [MapDragNative]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
    for ($x = 1150; $x -ge 500; $x -= 50) {
        [MapDragNative]::SetCursorPos($x, 500) | Out-Null
        Start-Sleep -Milliseconds 35
    }
    [MapDragNative]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 400
    Save-Screen "map_drag_after.png"
} finally {
    [MapDragNative]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
    if (-not $process.HasExited) { $process.WaitForExit(5000) | Out-Null }
}
