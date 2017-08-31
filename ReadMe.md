This code reads data into Matlab (extractMouse_xlsx.m) from [Med-Associates wireless activity wheels](http://www.med-associates.com/product/low-profile-wireless-running-wheel-for-mouse/), and plots actograms (plotActogram.m).  The data should be exported from [Wheel Manager](http://www.med-associates.com/product/wheel-manager/) as an .xls file, and then manually converted to .xlxs in Excel.

Data should be exported in 1 minute time bins.

Behavioral data can be spread across multiple files, but they should not overlap.  All files need to be in the same directory.

Tested on a Mac with Excel 2013, Matlab R2017a.
