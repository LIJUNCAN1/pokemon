Add-Type -AssemblyName System.Drawing

$sourceDirectory = Join-Path $PSScriptRoot '..\素材\图鉴'

function Export-CompactNinePatch {
    param(
        [string]$SourceName,
        [string]$OutputName,
        [int]$Margin,
        [int]$TileSize,
        [int]$HorizontalSampleX,
        [int]$VerticalSampleY
    )

    $sourcePath = Join-Path $sourceDirectory $SourceName
    $outputPath = Join-Path $sourceDirectory $OutputName
    $source = [System.Drawing.Bitmap]::FromFile($sourcePath)
    $outputSize = $Margin * 2 + $TileSize
    $result = New-Object System.Drawing.Bitmap $outputSize, $outputSize, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($result)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $rightSource = $source.Width - $Margin
    $bottomSource = $source.Height - $Margin
    $rightDestination = $Margin + $TileSize
    $bottomDestination = $Margin + $TileSize

    # Four corners.
    $graphics.DrawImage($source, [System.Drawing.Rectangle]::new(0, 0, $Margin, $Margin), [System.Drawing.Rectangle]::new(0, 0, $Margin, $Margin), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.DrawImage($source, [System.Drawing.Rectangle]::new($rightDestination, 0, $Margin, $Margin), [System.Drawing.Rectangle]::new($rightSource, 0, $Margin, $Margin), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.DrawImage($source, [System.Drawing.Rectangle]::new(0, $bottomDestination, $Margin, $Margin), [System.Drawing.Rectangle]::new(0, $bottomSource, $Margin, $Margin), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.DrawImage($source, [System.Drawing.Rectangle]::new($rightDestination, $bottomDestination, $Margin, $Margin), [System.Drawing.Rectangle]::new($rightSource, $bottomSource, $Margin, $Margin), [System.Drawing.GraphicsUnit]::Pixel)

    # One clean repeatable sample for each edge.
    $graphics.DrawImage($source, [System.Drawing.Rectangle]::new($Margin, 0, $TileSize, $Margin), [System.Drawing.Rectangle]::new($HorizontalSampleX, 0, $TileSize, $Margin), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.DrawImage($source, [System.Drawing.Rectangle]::new($Margin, $bottomDestination, $TileSize, $Margin), [System.Drawing.Rectangle]::new($HorizontalSampleX, $bottomSource, $TileSize, $Margin), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.DrawImage($source, [System.Drawing.Rectangle]::new(0, $Margin, $Margin, $TileSize), [System.Drawing.Rectangle]::new(0, $VerticalSampleY, $Margin, $TileSize), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.DrawImage($source, [System.Drawing.Rectangle]::new($rightDestination, $Margin, $Margin, $TileSize), [System.Drawing.Rectangle]::new($rightSource, $VerticalSampleY, $Margin, $TileSize), [System.Drawing.GraphicsUnit]::Pixel)

    $graphics.Dispose()
    $source.Dispose()
    $result.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $result.Dispose()
}

# Keep only the orange outer edge. Everything inside is supplied by live UI controls.
Export-CompactNinePatch '图层 1.png' '图鉴左栏_外框_九宫格.png' 8 8 210 700

# Keep only the gray/white frame. The same slice is reused for every information panel.
Export-CompactNinePatch '图层 3.png' '图鉴左栏_信息框_九宫格.png' 14 8 280 100

# The collection frame must render above the scrolling cards, so its opaque center is removed.
Export-CompactNinePatch '33.png' '图鉴右栏_外框_前景.png' 14 8 700 370
