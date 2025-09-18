# prep data before
library(dplyr)
library(stringr)
library(sf)
library(rmapshaper)

sf_swe <- read_sf("data-raw/SWE 1st Apr anomaly 2024.geojson")

tbl_name_id <- sf_swe |> 
  st_drop_geometry() |> 
  select(MapName, GMBA_V2_ID)

sf_swe <- read_sf("data-raw/SWE 1st Apr anomaly 2025.gpkg")

# sf_swe2 <- st_simplify(sf_swe, preserveTopology = T, dTolerance = 2000)
# sf_swe3 <- st_cast(sf_swe2, "MULTIPOLYGON")

sf_swe2 <- ms_simplify(sf_swe, keep = 0.2, keep_shapes = FALSE)

sf_plot <- sf_swe2 %>%
  left_join(tbl_name_id) |> 
  filter(!is.na(relAno2025)) %>%
  filter(abs(relAno2025) < 1e3) %>%
  mutate(xx_col = if_else(relAno2025 > 150, 150, relAno2025) %>% as.integer) %>%
  mutate(zz_peak = as.numeric(`peakSweCurrent20252025_asof05-May-2025_mean`),
         peak_SWE_2025 = if_else(zz_peak < -9000, NA_real_, zz_peak),
         peak_SWE_2025_anomaly = as.integer(relAno2025)) %>%
  rename(
    Name = MapName,
    peak_SWE_clim_1991_2020 = peakSwe19912020_mean
  ) %>%
  mutate(
    labels = str_c(
      "<table>",
      "<tr><th style='text-align: left'>",
      Name,
      "</th></tr>",
      "<tr>",
      "<td>",
      "01 April SWE 2025 anomaly:",
      "</td>",
      "<td style='text-align: right; padding-left: 15px;'>",
      sprintf("%i %%", peak_SWE_2025_anomaly),
      "</td>",
      "</tr>",
      "<tr>",
      "<td>",
      "01 April SWE 2025:",
      "</td>",
      "<td style='text-align: right; padding-left: 15px;'>",
      sprintf("%0.1f mm", 1000 * peak_SWE_2025),
      "</td>",
      "</tr>",
      "<tr>",
      "<td>",
      "01 April SWE average 1991-2020:",
      "</td>",
      "<td style='text-align: right; padding-left: 15px;'>",
      sprintf("%0.1f mm", 1000 * peak_SWE_clim_1991_2020),
      "</td>",
      "</tr>",
      "</table>"
    )
  )

saveRDS(sf_plot, "data/sf_plot_2025.rds")
