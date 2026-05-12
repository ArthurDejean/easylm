# all mandatory packages in order for this package to work.

packages = c("tidyverse", "knitr", "stats", "car", "lmtest", "tseries", "rsq", "broom", "gt", "patchwork")

for (element in packages) {
  if (require(element, character.only=T) == FALSE) {
    install.packages(element)
    require(element, character.only=T)
  } else {
    require(element, character.only=T)
  }
}

rm(packages,element)
