$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

function New-IconBitmap {
  param(
    [int]$Size
  )

  $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.Clear([System.Drawing.Color]::Black)

  $centerX = $Size / 2.0
  $centerY = $Size / 2.0
  $scale = $Size * 0.018

  $points = New-Object System.Collections.Generic.List[System.Drawing.PointF]
  for ($i = 0; $i -le 360; $i += 3) {
    $t = [Math]::PI * 2.0 * $i / 360.0
    $x = 16 * [Math]::Pow([Math]::Sin($t), 3)
    $y = 13 * [Math]::Cos($t) - 5 * [Math]::Cos(2 * $t) - 2 * [Math]::Cos(3 * $t) - [Math]::Cos(4 * $t)
    $points.Add([System.Drawing.PointF]::new(
        [float]($centerX + ($x * $scale)),
        [float]($centerY - ($y * $scale) + ($Size * 0.02))
      ))
  }

  $wirePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(175, 210, 210, 210), [Math]::Max(2, $Size * 0.008))
  $wirePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  for ($layer = 0; $layer -lt 3; $layer++) {
    $offsetX = ($layer - 1) * ($Size * 0.004)
    $offsetY = ($layer - 1) * ($Size * 0.004)
    $layerPoints = $points | ForEach-Object {
      [System.Drawing.PointF]::new([float]($_.X + $offsetX), [float]($_.Y + $offsetY))
    }
    $graphics.DrawCurve($wirePen, [System.Drawing.PointF[]]$layerPoints)
  }

  $linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(85, 220, 220, 220), [Math]::Max(1, $Size * 0.0024))
  $linePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $random = [System.Random]::new(1406)
  for ($i = 0; $i -lt 120; $i++) {
    $start = $points[$random.Next(0, $points.Count)]
    $finish = $points[$random.Next(0, $points.Count)]
    $graphics.DrawLine($linePen, $start, $finish)
  }

  $glowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 255, 255, 255))
  foreach ($point in $points) {
    $radius = [Math]::Max(1.4, $Size * 0.006)
    $graphics.FillEllipse(
      $glowBrush,
      [float]($point.X - $radius / 2),
      [float]($point.Y - $radius / 2),
      [float]$radius,
      [float]$radius
    )
  }

  $graphics.Dispose()
  $wirePen.Dispose()
  $linePen.Dispose()
  $glowBrush.Dispose()
  return $bitmap
}

function Save-ScaledPng {
  param(
    [System.Drawing.Bitmap]$Source,
    [string]$Path,
    [int]$Size
  )

  $dir = Split-Path -Parent $Path
  if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
  }

  $canvas = New-Object System.Drawing.Bitmap($Size, $Size)
  $graphics = [System.Drawing.Graphics]::FromImage($canvas)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.Clear([System.Drawing.Color]::Black)
  $graphics.DrawImage($Source, 0, 0, $Size, $Size)
  $canvas.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  $graphics.Dispose()
  $canvas.Dispose()
}

function Save-Ico {
  param(
    [System.Drawing.Bitmap]$Source,
    [string]$Path,
    [int]$Size = 256
  )

  $tmp = New-Object System.Drawing.Bitmap($Source, $Size, $Size)
  $icon = [System.Drawing.Icon]::FromHandle($tmp.GetHicon())
  $stream = [System.IO.File]::Create($Path)
  $icon.Save($stream)
  $stream.Dispose()
  $icon.Dispose()
  $tmp.Dispose()
}

$root = Split-Path -Parent $PSScriptRoot
$mobileRoot = Join-Path $root 'mobile'
$master = New-IconBitmap -Size 1024

$androidIcons = @{
  'android/app/src/main/res/mipmap-mdpi/ic_launcher.png' = 48
  'android/app/src/main/res/mipmap-hdpi/ic_launcher.png' = 72
  'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png' = 96
  'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png' = 144
  'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png' = 192
  'web/favicon.png' = 32
  'web/icons/Icon-192.png' = 192
  'web/icons/Icon-512.png' = 512
  'web/icons/Icon-maskable-192.png' = 192
  'web/icons/Icon-maskable-512.png' = 512
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png' = 20
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png' = 40
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png' = 60
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png' = 29
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png' = 58
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png' = 87
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png' = 40
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png' = 80
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png' = 120
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png' = 120
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png' = 180
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png' = 76
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png' = 152
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png' = 167
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png' = 1024
  'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png' = 16
  'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png' = 32
  'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png' = 64
  'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png' = 128
  'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png' = 256
  'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png' = 512
  'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png' = 1024
}

foreach ($entry in $androidIcons.GetEnumerator()) {
  Save-ScaledPng -Source $master -Path (Join-Path $mobileRoot $entry.Key) -Size $entry.Value
}

Save-Ico -Source $master -Path (Join-Path $mobileRoot 'windows/runner/resources/app_icon.ico')

$master.Dispose()
Write-Output 'App icons generated.'
