Param (
  [string]$panoOriginal = "pano.jpg"
)

$imagemagick_convert = "$PSScriptRoot\convert.exe"
$panoFileName = $panoOriginal

Try {
  $panoFile = (get-item $panoFileName -ErrorAction Stop)
  $panoPath = $panoFile.fullname
  $panoBaseName = $panoFile.Basename
}
Catch {
  write-error "File pano.jpg not Found"
  break;
}

# get image dimensions
add-type -AssemblyName System.Drawing
#$img = [System.Drawing.Image]::FromFile("$($panoBaseName).jpg"); # creates file lock
$fs = New-Object System.IO.FileStream ("$($panoPath)", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
$img = [System.Drawing.Image]::FromStream($fs)
$fs.Dispose()

$width = $img.Size.Width;
$height = $img.Size.Height;

# print informations
write-host "Path: $($panoPath)"
write-host "Image Dimensions: $($width)x$($height)"

if($width -gt 20480) {
  $width = 20480
}
$newHeight = $width / 2

write-host "New Image Dimensions: $($width)x$($newHeight)"

Try {
  $test = 1/$width
  $test = 1/$height
}
Catch {
  write-error "size error"
  break;
}

# Generate ptos from template with filename
$ptoTPL = (Get-Content "$($PSScriptRoot)/pano_tpl.pto").replace("{{panofilename}}", "$($panoPath)") 
$ptoTPL = $ptoTPL.replace("{{panowidth}}", "$($width)") 
$ptoTPL = $ptoTPL.replace("{{panoheight}}", "$($newHeight)") 

$previewTPL = $ptoTPL.replace("{{preview}}", "`n") 
$previewTPL | Set-Content "$($PSScriptRoot)/preview.pto"

$cubeTPL = $ptoTPL.replace("{{cube}}", "`n") 
$cubeTPL | Set-Content "$($PSScriptRoot)/pano.pto"

# fix the pitch of equirectangular pano for previews using nona
write-host "creating tif preview with nona.exe"
& "C:\Program Files\Hugin\bin\nona.exe" -o pano "$($PSScriptRoot)/preview.pto"

write-host "convert preview to jpg and remove tif files"
Get-ChildItem "*.tif" | %{& $imagemagick_convert "$($_)" "$($panoBaseName)_preview_original.jpg"; Remove-Item "$_" }

# generate 600x300 preview
write-host "generating preview 600x300 ($($panoBaseName)_preview.jpg)"
& $imagemagick_convert "$($panoBaseName)_preview_original.jpg" -resize x300 "$($panoBaseName)_preview.jpg"
& $imagemagick_convert "$($panoBaseName)_preview.jpg" -gravity center -crop 600x300+0+0 "$($panoBaseName)_preview.jpg"

# create mobile fallback version
write-host "create mobile browser fallback version ($($panoBaseName)_mobile.jpg)"
& $imagemagick_convert "$($panoBaseName)_preview_original.jpg" -resize 4096x "$($panoBaseName)_mobile.jpg"

# create tif cube faces from equirectangular pano using nona
write-host "creating tif cube faces with nona.exe"
& "C:\Program Files\Hugin\bin\nona.exe" -o pano "$($PSScriptRoot)/pano.pto"

# convert cube faces to jpg and remove tif files
write-host "convert cube faces to jpg and remove tif files"
Get-ChildItem "*.tif" | %{ write-host "converting $($_.Name)"; & $imagemagick_convert "$($_)" "$($_.Basename).jpg"; Remove-Item "$_" }

# remove created temporary files
Remove-Item "$($panoBaseName)_preview_original.jpg"
Remove-Item "preview.pto"
Remove-Item "pano.pto"
