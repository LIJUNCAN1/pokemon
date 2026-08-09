param(
    [string]$ProjectRoot = "D:\pokemon",
    [string]$GodotPath = "D:\Godot_v4.7.1-stable_win64.exe"
)

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class CursorCaptureNative {
    [StructLayout(LayoutKind.Sequential)]
    public struct POINT { public int X; public int Y; }

    [StructLayout(LayoutKind.Sequential)]
    public struct CURSORINFO {
        public int cbSize;
        public int flags;
        public IntPtr hCursor;
        public POINT ptScreenPos;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct ICONINFO {
        [MarshalAs(UnmanagedType.Bool)] public bool fIcon;
        public uint xHotspot;
        public uint yHotspot;
        public IntPtr hbmMask;
        public IntPtr hbmColor;
    }

    [DllImport("user32.dll")] public static extern bool GetCursorInfo(ref CURSORINFO pci);
    [DllImport("user32.dll")] public static extern bool GetIconInfo(IntPtr hIcon, out ICONINFO piconinfo);
    [DllImport("user32.dll")] public static extern bool DrawIconEx(IntPtr hdc, int x, int y, IntPtr hIcon, int cx, int cy, uint step, IntPtr brush, uint flags);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extraInfo);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int command);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr insertAfter, int x, int y, int width, int height, uint flags);
    [DllImport("gdi32.dll")] public static extern bool DeleteObject(IntPtr hObject);
}
"@

function Save-CursorCapture([string]$Name) {
    $bounds = $script:captureBounds
    $bitmap = [System.Drawing.Bitmap]::new($bounds.Width, $bounds.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
        $cursorInfo = [CursorCaptureNative+CURSORINFO]::new()
        $cursorInfo.cbSize = [Runtime.InteropServices.Marshal]::SizeOf($cursorInfo)
        if ([CursorCaptureNative]::GetCursorInfo([ref]$cursorInfo) -and $cursorInfo.flags -eq 1) {
            $iconInfo = [CursorCaptureNative+ICONINFO]::new()
            if ([CursorCaptureNative]::GetIconInfo($cursorInfo.hCursor, [ref]$iconInfo)) {
                $hdc = $graphics.GetHdc()
                try {
                    [CursorCaptureNative]::DrawIconEx(
                        $hdc,
                        $cursorInfo.ptScreenPos.X - $bounds.X - [int]$iconInfo.xHotspot,
                        $cursorInfo.ptScreenPos.Y - $bounds.Y - [int]$iconInfo.yHotspot,
                        $cursorInfo.hCursor,
                        0, 0, 0, [IntPtr]::Zero, 3
                    ) | Out-Null
                } finally {
                    $graphics.ReleaseHdc($hdc)
                    if ($iconInfo.hbmMask -ne [IntPtr]::Zero) { [CursorCaptureNative]::DeleteObject($iconInfo.hbmMask) | Out-Null }
                    if ($iconInfo.hbmColor -ne [IntPtr]::Zero) { [CursorCaptureNative]::DeleteObject($iconInfo.hbmColor) | Out-Null }
                }
            }
        }
    } finally {
        $graphics.Dispose()
    }

    $fullPath = Join-Path $ProjectRoot ("cursor_{0}.png" -f $Name)
    $bitmap.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $cropRect = [System.Drawing.Rectangle]::new(
        [Math]::Max(0, $cursorInfo.ptScreenPos.X - $bounds.X - 32),
        [Math]::Max(0, $cursorInfo.ptScreenPos.Y - $bounds.Y - 32),
        64,
        64
    )
    $crop = $bitmap.Clone($cropRect, $bitmap.PixelFormat)
    $zoom = [System.Drawing.Bitmap]::new(256, 256)
    $zoomGraphics = [System.Drawing.Graphics]::FromImage($zoom)
    try {
        $zoomGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $zoomGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
        $zoomGraphics.DrawImage($crop, [System.Drawing.Rectangle]::new(0, 0, 256, 256))
    } finally {
        $zoomGraphics.Dispose()
        $crop.Dispose()
        $bitmap.Dispose()
    }
    $zoom.Save((Join-Path $ProjectRoot ("cursor_{0}_zoom.png" -f $Name)), [System.Drawing.Imaging.ImageFormat]::Png)
    $zoom.Dispose()
}

$process = Start-Process -FilePath $GodotPath -ArgumentList @(
    "--path", $ProjectRoot,
    "--scene", "res://tools/cursor_visual_test.tscn"
) -PassThru
try {
    for ($attempt = 0; $attempt -lt 50 -and $process.MainWindowHandle -eq 0; $attempt++) {
        Start-Sleep -Milliseconds 100
        $process.Refresh()
    }
    if ($process.MainWindowHandle -eq 0) { throw "Godot test window handle was not available." }
    [CursorCaptureNative]::ShowWindow($process.MainWindowHandle, 9) | Out-Null
    [CursorCaptureNative]::SetWindowPos($process.MainWindowHandle, [IntPtr](-1), 0, 0, 0, 0, 0x0043) | Out-Null
    [CursorCaptureNative]::SetForegroundWindow($process.MainWindowHandle) | Out-Null
    $script:captureBounds = [System.Windows.Forms.Screen]::FromHandle($process.MainWindowHandle).Bounds
    [CursorCaptureNative]::SetCursorPos(
        [int]($script:captureBounds.X + $script:captureBounds.Width / 2 + 400),
        [int]($script:captureBounds.Y + $script:captureBounds.Height / 2 + 250)
    ) | Out-Null
    Start-Sleep -Milliseconds 700
    Save-CursorCapture "normal"
    [CursorCaptureNative]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 120
    Save-CursorCapture "pressed"
    [CursorCaptureNative]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 3300
    Save-CursorCapture "drag_0"
    Start-Sleep -Milliseconds 1050
    Save-CursorCapture "drag_1"
} finally {
    [CursorCaptureNative]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
    if (-not $process.HasExited) { $process.WaitForExit(5000) | Out-Null }
}
