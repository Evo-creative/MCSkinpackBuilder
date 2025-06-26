$tempDir = "skinpack_temp"
$packName = Read-Host "输入皮肤包显示名称"
$outputFile = "$($packName -replace ' ','_').mcpack"

New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
New-Item -Path "$tempDir/texts" -ItemType Directory -Force | Out-Null

$skinFiles = @(Get-ChildItem -Path *.png, *.tga, *.jpg -Exclude $MyInvocation.MyCommand.Name)
if ($skinFiles.Count -eq 0) {
    Write-Host "错误：未找到皮肤文件（支持 .png/.tga/.jpg）" -ForegroundColor Red
    Remove-Item -Path $tempDir -Recurse -Force
    exit
}

$skinConfig = @{
    serialize_name = "pack_$(New-Guid | Select-Object -ExpandProperty Guid -First 8)"
    localization_name = "pack_$($packName -replace ' ','_')"
    skins = @()
}

foreach ($file in $skinFiles) {
    $skinName = Read-Host "输入 [$($file.Name)] 的显示名称"
    $modelType = Read-Host "选择模型类型 (1=纤细 2=粗壮)"
    
    $skinConfig.skins += @{
        localization_name = $file.BaseName.PadLeft(2,'0')
        geometry = if ($modelType -eq '2') {'geometry.humanoid.custom'} else {'geometry.humanoid.customSlim'}
        texture = $file.Name
        type = "free"
    }

    "skin.pack_$($packName -replace ' ','_').$($file.BaseName.PadLeft(2,'0'))=$skinName" | Out-File "$tempDir/texts/zh_CN.lang" -Append -Encoding UTF8
    Copy-Item $file.FullName $tempDir\
}

@"
{
    "format_version": 1,
    "header": {
        "name": "$packName",
        "version": [1, 0, 0],
        "uuid": "$(New-Guid)"
    },
    "modules": [
        {
            "version": [1, 0, 0],
            "type": "skin_pack",
            "uuid": "$(New-Guid)"
        }
    ]
}
"@ | Out-File "$tempDir/manifest.json" -Encoding UTF8


$skinConfig | ConvertTo-Json -Depth 3 | Out-File "$tempDir/skins.json" -Encoding UTF8

Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $outputFile)
} catch {
    Write-Host "打包失败: $_" -ForegroundColor Red
    exit 1
}
Remove-Item -Path $tempDir -Recurse -Force
Write-Host "`n 完成!" -ForegroundColor Green