# WaspFacer

MATLAB Toolset for assessing facial markings in wasps (Vespula sp.). User simply draws a rough estimate of marking's location on an image and WaspFacer will segment the marking from the indicated area. 


![alt text](https://github.com/rciszek/WaspFacer/blob/gh-pages/img/gui.jpg "WaspFacer GUI")

WaspFacer calculates for each segmented marking:
- Continuous Asymmetry Measure
- Procustes distance
- Difference in the log areas of the left and right side of the marking.
- Total marking area.

WaspFacer also includes a tool for measuring distances on imported images, which can be used e.g. to measure wasp head width.

The measurements can be exported as .csv files for further analysis. The coordinates of the landmarks placed on the marking contour are also exportable in a format compatible with [MorphoJ](http://www.flywings.org.uk/morphoj_page.htm). Black and white images of the segmented markings can be exported as bitmap images (.bmp). 

All exported results include a metadata file that contains image coordinates of the symmetry axis, marking and automatically placed landmarks, and the settings (e.g. threshold) used to produce the exported results. The metadata is stored as .mat file.

## Installation
### Automatic (Windows)
Download and execute [WaspFacer 1.07 installer](https://github.com/rciszek/WaspFacer/releases/download/v0.96/WaspFacerInstaller.exe).

### Manual (Windows, Linux, Mac)
- Download [source](https://github.com/rciszek/WaspFacer/releases) from the releases page, and extract the source to a folder of choice.  

   **Or**  
   
   Clone the repository with:`git clone https://github.com/rciszek/WaspFacer.git`

- Download [MATLAB GUI Layout Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox). Extract the folder inside the WaspFacer folder.
- The program can be started by running WaspFacer.m using MATLAB




