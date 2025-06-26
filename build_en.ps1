$tempDir = "skinpack_temp"
$packName = Read-Host "Enter skin pack display name"
$outputFile = "$($packName -replace ' ','_').mcpack"

New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
New-Item -Path "$tempDir/texts" -ItemType Directory -Force | Out-Null

$skinFiles = @(Get-ChildItem -Path *.png, *.tga, *.jpg -Exclude $MyInvocation.MyCommand.Name)
if ($skinFiles.Count -eq 0) {
    Write-Host "Error: No skin files found (.png/.tga/.jpg)" -ForegroundColor Red
    Remove-Item -Path $tempDir -Recurse -Force
    exit
}

$skinConfig = @{
    serialize_name = "pack_$(New-Guid | Select-Object -ExpandProperty Guid -First 8)"
    localization_name = "pack_$($packName -replace ' ','_')"
    skins = @()
}

foreach ($file in $skinFiles) {
    $skinName = Read-Host "Name for [$($file.Name)]"
    $modelType = Read-Host "Model type (1=slim 2=classic)"
    
    $skinConfig.skins += @{
        localization_name = $file.BaseName.PadLeft(2,'0')
        geometry = if ($modelType -eq '2') {'geometry.humanoid.custom'} else {'geometry.humanoid.customSlim'}
        texture = $file.Name
        type = "free"
    }

    "skin.pack_$($packName -replace ' ','_').$($file.BaseName.PadLeft(2,'0'))=$skinName" | Out-File "$tempDir/texts/zh_CN.lang" -Append
    Copy-Item $file.FullName $tempDir\
}

$manifest = @"
{
  "format_version": 1,
  "header": {
    "name": "$packName",
    "uuid": "$(New-Guid)",
    "version": [1, 0, 0]
  },
  "modules": [
    {
      "type": "skin_pack",
      "uuid": "$(New-Guid)",
      "version": [1, 0, 0]
    }
  ]
}
"@
[System.IO.File]::WriteAllText("$tempDir/manifest.json", $manifest, [System.Text.Encoding]::UTF8)


$skinConfig | ConvertTo-Json -Depth 3 | Out-File "$tempDir/skins.json"

Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $outputFile)
} catch {
    Write-Host "打包失败: $_" -ForegroundColor Red
    exit 1
}
Remove-Item -Path $tempDir -Recurse -Force
Write-Host "`n Done!" -ForegroundColor Green