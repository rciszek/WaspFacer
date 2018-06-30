# WaspFacer

WaspFacer is a toolbox for measuring WaspFacial markings. User draws a rough estimate of the markings location and the software automatically segments the markings from the area.

WaspFacer calculates for each segmented marking:
- Continuous Asymmetry Measure
- Procustes distance
- Difference in the log of area between left and right side of the marking.
- Total marking area.

The measurements can be exported from WaspFacer as .csv files for further analysis. The coordinates of the landmarks placed on the marking contour are exportable in a format compatible with [MorphoJ](http://www.flywings.org.uk/morphoj_page.htm). Black and white images of the segmented markings can be exported as bitmap images (BMP). 

All exported results include a metadata file that contains image coordinates of the symmetry axis, marking and automatically placed landmarks, and the settings (e.g. threshold) used to produce the exported results. The metadata is stored in MAT format.

## Download
[WaspFacer 1.07 installer](https://studentuef-my.sharepoint.com/:u:/g/personal/ciszek_uef_fi/EbaO-mbP5LFEv2ycxx8bctYBo0Z2ygoN0JV4XEUt2-n0kg?e=TcVMbj) for Windows.



