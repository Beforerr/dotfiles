
default:
    -R --version

install:
    brew install --cask r

# Install posterdown
posterdown:
    #!/usr/bin/env Rscript
    options(repos = c(CRAN = "https://cloud.r-project.org"))
    install.packages("pak")
    pak::pkg_install("brentthorne/posterdown")
