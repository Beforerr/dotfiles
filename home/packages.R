
options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages("pak")
pak::pkg_install("tidyverse")
pak::pkg_install("arrow")