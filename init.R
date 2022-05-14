my_packages = c("tidyverse", "ggthemes", "shiny", "shinythemes", "leaflet", "rgdal", "sp", "sf", "htmlwidgets", "raster")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))