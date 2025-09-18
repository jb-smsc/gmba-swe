# prep data before
library(dplyr)
library(stringr)
library(sf)
library(rmapshaper)

sf_swe <- read_sf("data-raw/SWE 1st Apr anomaly 2024.geojson")

# sf_swe2 <- st_simplify(sf_swe, preserveTopology = T, dTolerance = 2000)
# sf_swe3 <- st_cast(sf_swe2, "MULTIPOLYGON")

sf_swe2 <- ms_simplify(sf_swe, keep = 0.2, keep_shapes = FALSE)

sf_plot <- sf_swe2 %>%
  filter(!is.na(relAno2024)) %>%
  mutate(xx_col = if_else(relAno2024 > 150, 150, relAno2024) %>% as.integer) %>%
  rename(
    Name = MapName,
    peak_SWE_2024_anomaly = relAno2024,
    peak_SWE_2024 = peakSweCurrent20242024_mean,
    peak_SWE_clim_1992_2020 = peakSwe19912020_mean
  ) %>%
  mutate(
    labels = str_c(
      "<table>",
      "<tr><th style='text-align: left'>",
      Name,
      "</th></tr>",
      "<tr>",
      "<td>",
      "01 April SWE 2024 anomaly:",
      "</td>",
      "<td style='text-align: right; padding-left: 15px;'>",
      sprintf("%i %%", peak_SWE_2024_anomaly),
      "</td>",
      "</tr>",
      "<tr>",
      "<td>",
      "01 April SWE 2024:",
      "</td>",
      "<td style='text-align: right; padding-left: 15px;'>",
      sprintf("%0.1f mm", 1000 * peak_SWE_2024),
      "</td>",
      "</tr>",
      "<tr>",
      "<td>",
      "01 April SWE average 1991-2020:",
      "</td>",
      "<td style='text-align: right; padding-left: 15px;'>",
      sprintf("%0.1f mm", 1000 * peak_SWE_clim_1992_2020),
      "</td>",
      "</tr>",
      "</table>"
    )
  )

saveRDS(sf_plot, "data/sf_plot_2024.rds")
