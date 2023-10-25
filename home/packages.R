
options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages("pak")
pak::pkg_install("tidyverse")
pak::pkg_install("arrow")

list = c("ggplot2", "ggpubr", "patchwork")
pak::pkg_install(list)
