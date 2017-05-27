$panoFileName = "pano.jpg"
$imagemagick_convert = "im_convert.exe"

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
$fs = New-Object System.IO.FileStream ("$($panoBaseName).jpg", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
$img = [System.Drawing.Image]::FromStream($fs)
$fs.Dispose()

$width = $img.Size.Width;
$height = $img.Size.Height;
$newHeight = $width / 2

# print informations
write-host "Path: $($panoPath)"
write-host "Image Dimensions: $($width)x$($height)"
write-host "New Image Dimensions: $($width)x$($newHeight)"

Try {
  $test = 1/$width
  $test = 1/$height
}
Catch {
  write-error "size error"
  break;
}

# Backup original pano equirectangular file
copy-Item $panoFile "$($panoBaseName)_ori.jpg"

# generate 600x300 preview
write-host "generating preview 600x300 ($($panoBaseName)_preview.jpg)"
& $imagemagick_convert $panoFile -resize x300 "$($panoBaseName)_preview.jpg"
& $imagemagick_convert "$($panoBaseName)_preview.jpg" -gravity center -crop 600x300+0+0 "$($panoBaseName)_preview.jpg"

# expand panorama to 2:1 aspect ratio
if($height -ne $newHeight) {
  write-host "making pano 2:1 ($($width)x$($newHeight))"
  & $imagemagick_convert "$($panoBaseName).jpg" -background black -gravity south -extent "$($width)x$($newHeight)" "$($panoBaseName).jpg"
}

# create mobile fallback version
write-host "create mobile browser fallback version ($($panoBaseName)_mobile.jpg)"
& $imagemagick_convert "$($panoBaseName).jpg" -resize 4096x "$($panoBaseName)_mobile.jpg"

# create tif cube faces from equirectangular pano using nona
write-host "creating tif cube faces with nona.exe"
& "C:\Program Files\Hugin\bin\nona.exe" -o pano "$($PSScriptRoot)/pano.pto"

# convert cube faces to jpg and remove tif files
write-host "convert cube faces to jpg and remove tif files"
Get-ChildItem "*.tif" | %{ write-host "converting $($_.Name)"; & $imagemagick_convert "$($_)" "$($_.Basename).jpg"; Remove-Item "$_" }