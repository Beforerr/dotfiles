options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages("pak")

pak::pkg_install("languageserver")

pak::pkg_install("tidyverse")
pak::pkg_install("arrow")

list <- c("ggplot2", "ggpubr", "patchwork")
pak::pkg_install(list)

pak::repo_add(rhub = "https://easystats.r-universe.dev")
pak::pkg_install("easystats/easystats")

pak::pkg_install("brentthorne/posterdown")