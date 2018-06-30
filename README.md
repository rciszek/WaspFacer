# WaspFacer

WaspFacer is a toolbox for measuring facial markings in wasps. User simply draws a rough estimate of marking's location on an image and WaspFacer will segment the marking from the indicated area. 

WaspFacer calculates for each segmented marking:
- Continuous Asymmetry Measure
- Procustes distance
- Difference in the log areas of the left and right side of the marking.
- Total marking area.

WaspFacer also includes a tool for measuring distances on imported images, which can be used e.g. to measure wasp head width.

The measurements can be exported as .csv files for further analysis. The coordinates of the landmarks placed on the marking contour are also exportable in a format compatible with [MorphoJ](http://www.flywings.org.uk/morphoj_page.htm). Black and white images of the segmented markings can be exported as bitmap images (.bmp). 

All exported results include a metadata file that contains image coordinates of the symmetry axis, marking and automatically placed landmarks, and the settings (e.g. threshold) used to produce the exported results. The metadata is stored as .mat file.

## Download
[WaspFacer 1.07 installer](https://studentuef-my.sharepoint.com/:u:/g/personal/ciszek_uef_fi/EbaO-mbP5LFEv2ycxx8bctYBo0Z2ygoN0JV4XEUt2-n0kg?e=TcVMbj) for Windows.
