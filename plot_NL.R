
library(ggplot2)
library(rgdal)
library(rgeos)
library(maptools)

plot_NL <- function (dsn,         # map data set to use 
  data_df,                        # data to use
  plot_var,                       # name variable to plot
  plot_varc     = plot_var,       # caption variable to plot
  data_linkvar  = 'RegioS_coded', # name variable to link to map
  labels        = F,              # labels to plot?
  label_var     = NULL,           # name variable that contains labels
  co            = F)              # check overlap labels?
{
  mylayers            = ogrListLayers(dsn)
  gp                  = readOGR(dsn, mylayers[1], disambiguateFIDs = T)
  gp                  = spTransform(gp, CRS("+init=epsg:4238"))
  gp.f                = fortify(gp)
  gp@data$id          = rownames(gp@data)
  gp@data$gp_code     = as.character(gp@data$statcode)
  data_df$plot_var    = data_df[,plot_var]
  if (!is.null(label_var)) {
    data_df$label_var = data_df[,label_var]
  }
  gp@data             =  gp@data %>%
    inner_join(data_df, by = c('gp_code' = data_linkvar))
  gp.f                = merge(gp.f, gp@data, by.x = "id", by.y = "id") %>%
    arrange(group,piece,order)
  
  if (labels==T) { 
    # create label information only for provinces
    gp.n = gp.f %>%
      group_by(statnaam) %>%
      summarize(
        minlat  = min(lat),
        maxlat  = max(lat),
        minlong = min(long),
        maxlong = max(long),
        label_var  = first(label_var)
      ) %>%
      mutate(cenlat  = (minlat + maxlat) / 2,
        cenlong = (minlong + maxlong) / 2) %>%
      select(statnaam, lat = cenlat, long = cenlong,label_var)
  }
  
  p = ggplot(gp.f,
    aes(long, lat, color = plot_var)) +
    geom_polygon(aes(group = group, fill = plot_var), color = 'black' )  +
    labs(x = "longitude", y = "latitude") +
    scale_fill_distiller(plot_varc,palette = "Spectral") +
    scale_x_continuous(labels=format_WE) +
    scale_y_continuous(labels=format_NS) 
  if  (labels==T) { 
    p = p +   geom_text(data = gp.n, aes(label = label_var), 
      color = 'black', check_overlap = co)
  }
  return(p)
}


dsn_map <- function(gem_prov) {
  if (gem_prov == 'P') {
    dsn        = "D:/data/maps/cbs_provincies.gml"
  } else if (gem_prov == 'C') {
    dsn        = "D:/data/maps/cbs_coropplusgebied.gml"
  } else {
    dsn        = "D:/data/maps/cbs_gemeenten.gml"
  }
}

format_WE <- function(x,dig=3) {
  format_WENS(x,'WE',dig)
}

format_NS <- function(x,dig=3) {
  format_WENS(x,'NS',dig)
}

format_WENS <- function(x,WENS,dig=3) {
  if (WENS=='WE') {
    Z1 = 'W' ; Z2 = 'E'
  } else {
    Z1 = 'S' ; Z2 = 'N'
  }
  f  = sprintf('%%.%.0ff',dig)
  xf = sprintf(f,abs(x))
  Z  = ifelse(x < 0, Z1, ifelse(x > 0, Z2,'')) 
  # e= bquote(.(xf)*degree*~.(quote(Z)))
  # e=as.expression(e) # fails in plot why ?
  f = parse(text = paste(xf, "*degree~", Z),keep.source = F)
}
