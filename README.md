# panorama.ps1
From partial equirectangular panorama to cube face panorama with web viewer and mobile fallback. 
I'am using cube face over equirectangular because of quality. 
Not all browser/devices can handle one large equirectangular panoram file.

This example is made on windows but the most parts should also apply to other OS's.

Example is based on a full horizontal (360°) and partial (-90° to 30°) vertical panorama. 
Stitched file has a width of 20480px and height of 7671px.

## Requirements
  * [ImageMagick](http://www.imagemagick.org/script/download.php#windows) (convert)
  * [Hugin](http://hugin.sourceforge.net/) (nona)
  * powershell

## Panorama workflow steps
  - Stitching photos with Microsoft "[Image Composite Editor](https://www.microsoft.com/en-us/research/product/computational-photography-applications/image-composite-editor/)" (ICE) as equirectangular (sphere) projection.
  - generate 600x300 preview
  - expand panorama to 2:1 aspect ratio
  - create mobile browser fallback version
  - create tif cube faces from equirectangular pano using nona
  - convert cube faces to jpg and remove tif files

### generate 600x300 preview
This preview is used later, in the webviewer.
``` powershell
convert "pano.jpg" -resize x300 "pano_preview.jpg"
convert "pano_preview.jpg" -gravity center -crop 600x300+0+0 "pano_preview.jpg"
```
Resizing the stitched panorama to 300px height, crop 600px width from center.


### expand panorama to 2:1 aspect ratio
To generate cube faces a 2:1 image is required, so adding black background to the top.
``` powershell
convert "pano.jpg" -background black -gravity south -extent "20480x10240" "pano.jpg"
```
In my example the sky was missing fromt he panorama, so i needed to expand the height from 7671px to 10240px.

### create mobile fallback version
Limited RAM on mobile device can't handle a 20480px wide equirectangular file nor a 4096px cube faced panorama. 
So generating a 4096px wide equirectangular panorama.
``` powershell
convert "pano.jpg" -resize 4096x "pano_mobile.jpg"
```
This file is used if the web viewer detects a mobile device.

### create tif cube faces from equirectangular pano using nona
Converting an equirectangular panorama to cube faces with nona, which comes with Hugin.
``` powershell
"C:\Program Files\Hugin\bin\nona.exe" -o pano "pano.pto"
```
Simply replace filename (pano.jpg) or pixel sizes (4096, 10240, 20480) to your needs in the "pano.pto".


### convert cube faces to jpg and remove tif files in powershell
Since nona's output are TIF files, i convert them to jpg.
``` powershell
Get-ChildItem "*.tif" | %{ write-host "converting $($_.Name)"; & $imagemagick_convert "$($_)" "$($_.Basename).jpg"; Remove-Item "$_" }
```

### Webviewer
Now we are ready to use the genereated files with eg. [pannellum](https://pannellum.org)
