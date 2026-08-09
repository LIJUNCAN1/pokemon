param([string]$ProjectRoot = "D:\pokemon")

Add-Type -AssemblyName System.Drawing

function Export-Crop([string]$Source, [string]$Output, [System.Drawing.Rectangle]$Rect) {
    $sourceImage = [System.Drawing.Bitmap]::new($Source)
    try {
        $crop = $sourceImage.Clone($Rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $directory = [System.IO.Path]::GetDirectoryName($Output)
            [System.IO.Directory]::CreateDirectory($directory) | Out-Null
            $crop.Save($Output, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $crop.Dispose()
        }
    } finally {
        $sourceImage.Dispose()
    }
}

$shopRoot = Join-Path $ProjectRoot "素材\事件\aseprite_export\shop_table"
$shopRuntime = Join-Path $shopRoot "runtime"
$panelSource = Join-Path $shopRoot "per_layer\panel.png"
$frameSource = Join-Path $shopRoot "per_layer\frame.png"
$attributeSource = Join-Path $shopRoot "per_layer\attributes.png"
$compositeSource = Join-Path $shopRoot "source_composite_updated.png"
Export-Crop $panelSource (Join-Path $shopRuntime "shop_panel.png") ([System.Drawing.Rectangle]::new(16, 8, 1152, 275))
Export-Crop $frameSource (Join-Path $shopRuntime "shop_card_frame.png") ([System.Drawing.Rectangle]::new(939, 78, 210, 188))
Export-Crop $attributeSource (Join-Path $shopRuntime "attribute_swatch.png") ([System.Drawing.Rectangle]::new(951, 190, 30, 30))
Export-Crop $compositeSource (Join-Path $shopRuntime "shop_card_template.png") ([System.Drawing.Rectangle]::new(939, 78, 210, 188))

$healthRoot = Join-Path $ProjectRoot "素材\主菜单\aseprite_export\health"
$healthRuntime = Join-Path $healthRoot "runtime"
$healthSource = Join-Path $healthRoot "composite.png"
for ($index = 0; $index -lt 5; $index++) {
    $x = 16 + $index * 64
    Export-Crop $healthSource (Join-Path $healthRuntime ("heart_{0}.png" -f $index)) ([System.Drawing.Rectangle]::new($x, 10, 21, 18))
}

$manifest = [ordered]@{
    shop = [ordered]@{
        source = "res://素材/事件/商店表格.aseprite"
        canvas = @(1323, 295)
        panel_source_bounds = @(16, 8, 1152, 275)
        card_source_bounds = @(939, 78, 210, 188)
        attribute_source_bounds = @(951, 190, 30, 30)
        runtime_width = 796
        columns = 4
    }
    health = [ordered]@{
        source = "res://素材/主菜单/Spritesheet.aseprite"
        canvas = @(303, 35)
        frame_rects = @(
            @(16, 10, 21, 18), @(80, 10, 21, 18), @(144, 10, 21, 18),
            @(208, 10, 21, 18), @(272, 10, 21, 18)
        )
        max_lives = 3
        filter = "nearest"
        mipmaps = $false
    }
}
[System.IO.File]::WriteAllText(
    (Join-Path $shopRoot "runtime_manifest.json"),
    ($manifest | ConvertTo-Json -Depth 8),
    [System.Text.UTF8Encoding]::new($false)
)

Write-Output "Exported shop panel/card assets and 5 health frames."
