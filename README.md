# panorama.ps1
Not all browsers/devices can handle one large (20480px or wider) [equirectangular](https://wiki.panotools.org/Equirectangular_Projection) panorama file.
So i'm converting the (partial) equirectangular panorama to a [cube face](https://wiki.panotools.org/Cubic_Projection) panorama.
In addition, a lower resolution (4096px wide) equirectangular mobile fallback version is created.

This is tested on windows but the most parts should also apply to other OS's.

The script assumes a full (360° by 180°) panorama with an aspect ratio of 2:1. 
If it isn't, the top is filled with black to accomplish the 2:1 ratio.

## Requirements
  * [ImageMagick](http://www.imagemagick.org/script/download.php#windows) (convert)
  * [Hugin](http://hugin.sourceforge.net/) (nona)
  * powershell

## Usage
  - First stitch photos, for example with Microsoft "[Image Composite Editor](https://www.microsoft.com/en-us/research/product/computational-photography-applications/image-composite-editor/)" (ICE), as equirectangular (sphere) projection
  - Export the partial panorama or if your panoram is missing the sky, try the following steps in ICE to autocomplete the sky:
    - In step 2 (STITCH), change "Pitch" under "Orientation" section to 90 degrees. 
    - In step 3 "CROP", click "Auto complete".
  - Open Powershell an change to a workdir.
  - run ```panorama.ps1 -panoOriginal <path_to_exported_panorama>```
    - if you previously changed the pitch append the ```-fixPitch``` parameter 

## What does Panorama.ps1 do?
  - copys the panorama in to the workdir
  - if specified, fixes the pitch of equirectangular pano using nona
  - generates 1000px wide preview
  - if needed, expands panorama to 2:1 aspect ratio with black
  - creates mobile browser fallback version
  - creates cube faces from equirectangular pano using nona

### Webviewer
Now we are ready to use the genereated files with eg. [pannellum](https://pannellum.org)
