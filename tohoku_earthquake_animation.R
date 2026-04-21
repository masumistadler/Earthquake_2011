## -------------------------------------------------------------------------
##
## Script name: tohoku_earthquake_animation.R
##
## Purpose of script: Making an animation of 3 years of earthquake data.
##                    Before and after Tohoku earthquake on 2011.3.11
##
## Author: Masumi Stadler
##
## Date Finalized: 
##
## Copyright (c) Masumi Stadler, 2025
## Email: m.stadler.jp.at@gmail.com
##
## -------------------------------------------------------------------------
##
## Notes:
##
##
## -------------------------------------------------------------------------

## Use R project with regular scripts, all paths are relative 

# Server set-up -----------------------------------------------------------
## Working directory is set from where the job is submitted
## Load library path, if on a server
# .libPaths( c( .libPaths(), "/home/mstadler/projects/def-pauldel/R/x86_64-pc-linux-gnu-library/4.2") )

# R-setup -----------------------------------------------------------------
## Load Packages -----------------------------------------------------------
pckgs <- list('data.table', 'tidyverse', # wrangling & programming
              'ggplot2', 'gganimate', 'patchwork', # plotting
              'sf','rnaturalearth',
              'gifski') # change as needed

## Check if packages are installed, output packages not installed:
(miss.pckgs <- unlist(pckgs)[!(unlist(pckgs) %in% installed.packages()[,"Package"])])
#if(length(miss.pckgs) > 0) install.packages(miss.pckgs)

## Load
invisible(lapply(pckgs, library, character.only = T))
rm(pckgs, miss.pckgs)

## Load custom functions --------------------------------------------------
funs <- list.files("./Functions", full.names = T)
invisible(lapply(funs, source))

## Other set-up -----------------------------------------------------------
options(scipen = 6, digits = 4) # view outputs in non-scientific notation
 
## Parallel environment ---------------------------------------------------
## Server version
# cores <- as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK"))
# registerDoMC(cores = cores)

## Personal version
# detectCores(); registerDoMC(); getDoParWorkers()
# numCores <- detectCores()
# cl <- makeCluster(numCores, type = "FORK")
 
# Read in data -----------------------------------------------------------
files <- list.files("./Data/JMA")
data <- lapply(paste0("./Data/JMA/",files), read.csv, stringsAsFactors = F)

# need to do some cleaning
# make column M a character (NA is 不明)
data <- lapply(data, function(x){
  x$Ｍ <- as.character(x$Ｍ)
  return(x)})

# make into one data frame
data <- bind_rows(data)

# Format data ------------------------------------------------------------
# change Japanese column names
colnames(data) <- c("date", "time", "EQ_region", 
                    "lat", "long", "EQ_depth","EQ_M", "EQ_JPSI")
# Japanese "Shindo" refers to Japanese Seismic Intensity scale

setDT(data)
# replace 不明 with NA
data[EQ_M == "不明",EQ_M := NA]
# remove 震度 and km from strings
data[, EQ_depth := str_remove(EQ_depth, " km")]
data[, EQ_JPSI := str_remove(EQ_JPSI, "震度")]

dmm2dec <- function(x){
  deg <- as.numeric(sapply(strsplit(x, "°|′"),"[[",1)) # degrees
  min <- as.numeric(sapply(strsplit(x, "°|′"),"[[",2)) # minutes
  hemis <- sapply(strsplit(x, "°|′"),"[[",3) # hemisphere
  
  dec_deg <- deg + (min / 60)
  
  if(hemis %in% c("S","W")){
    dec_deg <- -dec_deg
  }
  return(dec_deg)
}

data[, lat_dec := sapply(lat, dmm2dec)]
data[, long_dec := sapply(long, dmm2dec)]

# date time format
data[, date.time := as.POSIXct(paste(date, time, sep = " "),
                               format = "%Y/%m/%d %H:%M:%OS")]

# convert M into metric scale
data[, EQ_M := as.numeric(EQ_M)]
#
data[, scaled_size := 10^(1.5 * EQ_M)]
data[, scaled_size := sqrt(10^(5.24 + 1.44 * EQ_M))]
data[, date := as.Date(date, format = "%Y/%m/%d")]

data <- data %>% distinct() %>% arrange(date.time) %>% setDT()

# Get map ----------------------------------------------------------------------

# two versions of detail
map1 <- ne_countries(type = "countries", country = "Japan",
                     scale = "medium", returnclass = "sf")
map2 <- rnaturalearth::ne_states("Japan", returnclass = "sf")
p1 <- ggplot(map1) + geom_sf()
p2 <- ggplot(map2) + geom_sf()
p1 + p2


(p <- ggplot() + 
  geom_sf(data = map2, fill = "grey50", colour = "grey50") +
  geom_point(data = data, #%>% filter(date >= "2011-03-01" & date <= "2011-03-31"),
             aes(x = long_dec, y = lat_dec, size = scaled_size,
                                      colour = EQ_M)) +
  theme_void() +
  theme(legend.margin = margin(0, 0, 0, 0),
        panel.background = element_rect(fill = "grey10", colour ="grey10"),
        plot.background = element_rect(fill = "grey10"),
        legend.text = element_text(colour = "white"),
        legend.title = element_text(colour = "white"),
        legend.frame = element_rect(colour = "grey10"),
        legend.ticks = element_line(colour = "grey10"),
        plot.title = element_text(colour = "white"),
        legend.justification.inside = c(0.95, 0.1),
       ) +
  guides(colour = guide_colorbar(order = 1, position = 'inside'),
         size = guide_legend(override.aes = list(colour = "white"), order = 2, position = 'inside')) +
  scale_colour_gradientn(colors = c('#CEFFFF', '#C6F7D6', '#A2F49B', '#BBE453', 
                                      '#D5CE04', '#E7B503', '#F19903', '#F6790B',
                                      '#F94902', '#E40515', '#A80003'),
                           name = "Magnitude") +
  scale_size_continuous(name = "Seismic\nEnergy (J)", range = c(0,10),
                        breaks = c(250000000,500000000,750000000,1000000000,1250000000),
                        labels = c("250 M", "500 M", "750 M", "1 B", "1.25 B")))
                           

anim <- p + transition_time(date) +
  shadow_mark(past = TRUE,alpha = 0.5) +
  ggtitle('Date: {frame_time}')
animate(anim, nframes = length(unique(data$date)), fps = 20,
        width = 4.5, height = 4.7, units = 'in',
        renderer = gifski_renderer(), res = 150, detail = )
anim_save("./Animation/gganimate-1.gif")




# 2011 only ---------------------------------------------------------------------------

(p <- ggplot() + 
    geom_sf(data = map2, fill = "grey50", colour = "grey50") +
    geom_point(data = data %>% filter(date >= "2011-02-01" & date <= "2011-07-31"), 
               aes(x = long_dec, y = lat_dec, size = scaled_size,
                                colour = EQ_M)) +
    theme_void() +
    theme(legend.margin = margin(0, 0, 0, 0),
          panel.background = element_rect(fill = "grey10", colour ="grey10"),
          plot.background = element_rect(fill = "grey10"),
          legend.text = element_text(colour = "white"),
          legend.title = element_text(colour = "white"),
          legend.frame = element_rect(colour = "grey10"),
          legend.ticks = element_line(colour = "grey10"),
          plot.title = element_text(colour = "white"),
          legend.justification.inside = c(0.95, 0.1),
    ) +
    guides(colour = guide_colorbar(order = 1, position = 'inside'),
           size = guide_legend(override.aes = list(colour = "white"), order = 2, position = 'inside')) +
    scale_colour_gradientn(colors = c('#CEFFFF', '#C6F7D6', '#A2F49B', '#BBE453', 
                                      '#D5CE04', '#E7B503', '#F19903', '#F6790B',
                                      '#F94902', '#E40515', '#A80003'),
                           name = "Magnitude") +
   scale_size_continuous(name = "Seismic\nEnergy (J)", range = c(0,10),
                         breaks = c(1000000, 100000000,500000000,1000000000),
                         labels = c("1 mm", "100 mm", "500 mm", "1 bn")))


anim <- p + transition_time(date) +
  shadow_mark(past = TRUE,alpha = 0.5) +
  ggtitle(' Earthquakes on: {frame_time}')
animate(anim, 
        nframes = nrow(unique(data %>% filter(date >= "2011-02-01" & date <= "2011-07-31") %>% 
                                select(date))), fps = 10,
        width = 4.5, height = 4.7, units = 'in',
        renderer = gifski_renderer(), res = 150)
anim_save("./Animation/earthquake_map_2011.gif")
