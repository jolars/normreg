library(here)

url <- "https://github.com/IowaBiostat/data-sets/raw/main/Rhee2006/Rhee2006.rds"

tmp <- tempfile(fileext = ".rds")

download.file(url, tmp)

data <- readRDS(tmp)

xy <- cbind(data$y, data$X)

write.csv(xy, here("data", "rhee2006.csv"), row.names = FALSE)
