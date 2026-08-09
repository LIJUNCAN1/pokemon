param(
    [string]$ProjectRoot = "D:\pokemon"
)

Add-Type -AssemblyName System.Drawing

$sourceRoot = Join-Path $ProjectRoot "素材\地图"
$outputRoot = Join-Path $sourceRoot "cursor"
$displayScale = 3
$scaledFrameSize = 16 * $displayScale
[System.IO.Directory]::CreateDirectory($outputRoot) | Out-Null

$exports = @(
    [ordered]@{ source = "mouse.png"; frame = 0; output = "normal.png"; state = "normal"; hotspot = @(12, 12) },
    [ordered]@{ source = "mouse.png"; frame = 1; output = "pressed.png"; state = "pressed"; hotspot = @(12, 12) },
    [ordered]@{ source = "mouse2.png"; frame = 0; output = "drag_0.png"; state = "drag"; hotspot = @(21, 3) },
    [ordered]@{ source = "mouse2.png"; frame = 1; output = "drag_1.png"; state = "drag"; hotspot = @(21, 3) }
)

foreach ($export in $exports) {
    $sourcePath = Join-Path $sourceRoot $export.source
    $outputPath = Join-Path $outputRoot $export.output
    $source = [System.Drawing.Bitmap]::new($sourcePath)
    try {
        $rect = [System.Drawing.Rectangle]::new([int]$export.frame * 16, 0, 16, 16)
        $nativeFrame = $source.Clone($rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $frame = [System.Drawing.Bitmap]::new(16 * $displayScale, 16 * $displayScale, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            try {
                for ($sourceY = 0; $sourceY -lt 16; $sourceY++) {
                    for ($sourceX = 0; $sourceX -lt 16; $sourceX++) {
                        $color = $nativeFrame.GetPixel($sourceX, $sourceY)
                        for ($offsetY = 0; $offsetY -lt $displayScale; $offsetY++) {
                            for ($offsetX = 0; $offsetX -lt $displayScale; $offsetX++) {
                                $frame.SetPixel($sourceX * $displayScale + $offsetX, $sourceY * $displayScale + $offsetY, $color)
                            }
                        }
                    }
                }
                $frame.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
            } finally {
                $frame.Dispose()
            }
        } finally {
            $nativeFrame.Dispose()
        }
    } finally {
        $source.Dispose()
    }
    $frameX = [int]$export.frame * 16
    $export.source_rect = @($frameX, 0, 16, 16)
    $export.output_canvas = @($scaledFrameSize, $scaledFrameSize)
	$export.display_scale = $displayScale
    $export.filter = "nearest"
    $export.mipmaps = $false
}

$manifest = [ordered]@{
    source_canvas = @(32, 16)
    frame_size = @(16, 16)
    display_scale = $displayScale
    exports = $exports
}
[System.IO.File]::WriteAllText(
    (Join-Path $outputRoot "cursor_manifest.json"),
    ($manifest | ConvertTo-Json -Depth 6),
    [System.Text.UTF8Encoding]::new($false)
)

Write-Output "Exported $($exports.Count) cursor frames."
