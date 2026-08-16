$ErrorActionPreference = 'Stop'

$aseprite = 'D:\asseprite\aseprite.exe'
$python = 'C:\Users\lijc\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$source = 'D:\pokemon\素材\主菜单\信息框.aseprite'
$output = 'D:\pokemon\_aseprite_inspect\character_info'
$runtime = 'D:\pokemon\assets\ui\character_info'

New-Item -ItemType Directory -Force -Path $output | Out-Null
New-Item -ItemType Directory -Force -Path $runtime | Out-Null
$generated = @(
    (Join-Path $output 'composite.png'),
    (Join-Path $output 'layers.png'),
    (Join-Path $output 'layout.json')
)
foreach ($file in $generated) {
    if (Test-Path -LiteralPath $file) {
        Remove-Item -LiteralPath $file -Force
    }
}
& $aseprite -b --list-layer-hierarchy --list-tags $source
& $aseprite -b $source --save-as (Join-Path $output 'composite.png') | Out-Null
Start-Sleep -Milliseconds 250
& $python (Join-Path $PSScriptRoot 'clean_character_info_frame.py') (Join-Path $output 'composite.png') (Join-Path $runtime 'frame.png') (Join-Path $runtime 'frame_foreground.png')
& $aseprite -b $source --split-layers --trim --sheet (Join-Path $output 'layers.png') --data (Join-Path $output 'layout.json') --format json-array | Out-Null
