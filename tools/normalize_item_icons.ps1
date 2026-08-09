param(
    [string]$ProjectRoot = "D:\pokemon"
)

Add-Type -AssemblyName System.Drawing

$consumableIds = @(
    1, 3, 7, 13, 14, 26, 49, 53, 57, 61, 67, 81,
    82, 83, 84, 87, 88, 93, 94, 96, 105, 109, 110, 111,
    112, 113, 114, 130, 167, 185, 204, 240, 259, 277, 296, 351,
    388, 406, 443, 480, 498, 535, 553, 572, 609, 682, 756, 811
)
$accessoryIds = @(
    2, 4, 5, 6, 9, 10, 11, 12, 15, 25, 27, 28,
    33, 34, 35, 36, 37, 38, 62, 63, 64, 65, 66, 68,
    69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
    85, 86, 91, 92, 95, 97, 98, 99, 100, 101, 102, 103
)

$sourceDirectory = Join-Path $ProjectRoot "assets\items\64x64"
$outputRoot = Join-Path $ProjectRoot "assets\items\generated"
$records = [System.Collections.Generic.List[object]]::new()

function Export-NormalizedIcon {
    param(
        [int]$Id,
        [string]$Kind
    )

    $sourcePath = Join-Path $sourceDirectory ("fc{0}.png" -f $Id)
    if (-not [System.IO.File]::Exists($sourcePath)) {
        throw "Missing source icon: $sourcePath"
    }
    $kindDirectory = Join-Path $outputRoot $Kind
    [System.IO.Directory]::CreateDirectory($kindDirectory) | Out-Null
    $outputPath = Join-Path $kindDirectory ("{0}_{1:D4}.png" -f $Kind, $Id)

    $source = [System.Drawing.Bitmap]::new($sourcePath)
    try {
        $minX = $source.Width
        $minY = $source.Height
        $maxX = -1
        $maxY = -1
        for ($y = 0; $y -lt $source.Height; $y++) {
            for ($x = 0; $x -lt $source.Width; $x++) {
                if ($source.GetPixel($x, $y).A -eq 0) { continue }
                $minX = [Math]::Min($minX, $x)
                $minY = [Math]::Min($minY, $y)
                $maxX = [Math]::Max($maxX, $x)
                $maxY = [Math]::Max($maxY, $y)
            }
        }
        if ($maxX -lt 0) { throw "Empty source icon: $sourcePath" }

        $sourceWidth = $maxX - $minX + 1
        $sourceHeight = $maxY - $minY + 1
        $scale = [Math]::Min(1.0, [Math]::Min(52.0 / $sourceWidth, 52.0 / $sourceHeight))
        $targetWidth = [Math]::Max(1, [Math]::Round($sourceWidth * $scale))
        $targetHeight = [Math]::Max(1, [Math]::Round($sourceHeight * $scale))
        $targetX = [Math]::Floor((64 - $targetWidth) / 2.0)
        $targetY = [Math]::Floor((64 - $targetHeight) / 2.0)

        $output = [System.Drawing.Bitmap]::new(64, 64, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($output)
            try {
                $graphics.Clear([System.Drawing.Color]::Transparent)
                $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
                $graphics.DrawImage(
                    $source,
                    [System.Drawing.Rectangle]::new($targetX, $targetY, $targetWidth, $targetHeight),
                    [System.Drawing.Rectangle]::new($minX, $minY, $sourceWidth, $sourceHeight),
                    [System.Drawing.GraphicsUnit]::Pixel
                )
            } finally {
                $graphics.Dispose()
            }
            $output.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $output.Dispose()
        }

        $records.Add([ordered]@{
            id = $Id
            kind = $Kind
            source = $sourcePath.Substring($ProjectRoot.Length + 1).Replace("\", "/")
            output = $outputPath.Substring($ProjectRoot.Length + 1).Replace("\", "/")
            source_canvas = @(64, 64)
            alpha_bounds = @($minX, $minY, $sourceWidth, $sourceHeight)
            target_bounds = @($targetX, $targetY, $targetWidth, $targetHeight)
            scale = [Math]::Round($scale, 6)
        })
    } finally {
        $source.Dispose()
    }
}

foreach ($id in $consumableIds) { Export-NormalizedIcon -Id $id -Kind "item" }
foreach ($id in $accessoryIds) { Export-NormalizedIcon -Id $id -Kind "accessory" }

$manifest = [ordered]@{
    source_directory = "assets/items/64x64"
    output_canvas = @(64, 64)
    safe_content_size = @(52, 52)
    filter = "nearest"
    mipmaps = $false
    records = $records
}
$manifestPath = Join-Path $outputRoot "normalization_manifest.json"
[System.IO.File]::WriteAllText(
    $manifestPath,
    ($manifest | ConvertTo-Json -Depth 8),
    [System.Text.UTF8Encoding]::new($false)
)

Write-Output "Generated $($records.Count) normalized icons."

