Creating buffers of Landuse
================
Derek Corcoran
2022-01-01

# 1 Methods

In this repository, the goal is to generate rasters with the proportion
of cells of different landuse within a certain distance of each point,
for the polygon showed in figure <a href="#fig:MapSite">1.1</a>:

<div class="figure">

<img src="Study_site.png" alt="Study site with the sampled points and the polygon corresponding to a 5050 meter buffer of all the points" width="515" />
<p class="caption">
Figure 1.1: Study site with the sampled points and the polygon
corresponding to a 5050 meter buffer of all the points
</p>

</div>

For that we used the databased generated in (Zhao et al. 2016), and used
both the raster and terra packages to create the layers (Hijmans 2021a,
2021b)

# 2 References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-HijmansRaster" class="csl-entry">

Hijmans, Robert J. 2021a. *Raster: Geographic Data Analysis and
Modeling*. <https://CRAN.R-project.org/package=raster>.

</div>

<div id="ref-HijmansTerra" class="csl-entry">

———. 2021b. *Terra: Spatial Data Analysis*.
<https://CRAN.R-project.org/package=terra>.

</div>

<div id="ref-zhao2016detailed" class="csl-entry">

Zhao, Yuanyuan, Duole Feng, Le Yu, Xiaoyi Wang, Yanlei Chen, Yuqi Bai, H
Jaime Hernández, et al. 2016. “Detailed Dynamic Land Cover Mapping of
Chile: Accuracy Improvement by Integrating Multi-Temporal Data.” *Remote
Sensing of Environment* 183: 170–85.

</div>

</div>
