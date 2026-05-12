options(repos = c(CRAN = "https://cran.rstudio.com/"))

pkgs <- c(
  "tidyverse", "stringr", "boot", "caret", "cluster",
  "factoextra", "ggplot2", "knitr", "kableExtra",
  "GGally", "corrplot", "scales", "gridExtra"
)

new_pkgs <- pkgs[!pkgs %in% installed.packages()[, "Package"]]

if (length(new_pkgs) > 0) {
  cat("Menginstall:", paste(new_pkgs, collapse = ", "), "\n")
  install.packages(new_pkgs)
} else {
  cat("Semua paket sudah terinstall.\n")
}
