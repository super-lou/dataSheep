# Copyright 2022 Louis Héraut (louis.heraut@inrae.fr)*1,
#                Éric Sauquet (eric.sauquet@inrae.fr)*1
#
# *1   INRAE, France
#
# This file is part of dataSheep R package.
#
# dataSheep R package is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# dataSheep R package is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dataSheep R package.
# If not, see <https://www.gnu.org/licenses/>.


## 1. PERSONAL PLOT __________________________________________________
### 1.1. Void plot ___________________________________________________
# A plot completly blank
#' @title Void plot
#' @export
void = function () {
    plot = ggplot() + geom_blank(aes(1,1)) +
        theme(
            plot.background = element_blank(), 
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(), 
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_blank(), 
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            axis.line = element_blank()
        )
    return (plot)
}

### 1.2. Contour void plot ___________________________________________
# A plot completly blank with a contour
#' @title Contour plot
#' @export
contour = function () {
    plot = ggplot() + geom_blank(aes(1,1)) +
        theme(
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(), 
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_blank(), 
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            axis.line = element_blank(),
            plot.background=element_rect(fill=NA, color="#EC4899"),
            plot.margin=margin(t=0, r=0, b=0, l=0, unit="mm"))
    return (plot)
}

### 1.3. Circle ______________________________________________________
# Allow to draw circle in ggplot2 with a radius and a center position
#' @title Circle
#' @export
gg_circle = function(r, xc, yc, color="black", fill=NA, ...) {
    x = xc + r*cos(seq(0, pi, length.out=100))
    ymax = yc + r*sin(seq(0, pi, length.out=100))
    ymin = yc + r*sin(seq(0, -pi, length.out=100))
    annotate("ribbon", x=x, ymin=ymin, ymax=ymax, color=color,
             fill=fill, ...)
}

## 2. PLOT MANAGEMENT ________________________________________________
### 2.1. Merge _______________________________________________________
#' @title Merge
#' @export
merge_panel = function (add, to, widths=NULL, heights=NULL) {
    # Plot the graph as the layout
    plot = grid.arrange(grobs=list(add, to),
                        heights=heights, widths=widths)
    return (plot)
}

### 2.2. Add plot ____________________________________________________
add_plot = function (df_P, plot=NULL, name="", first=FALSE, last=FALSE,
                     overwrite_by_name=FALSE) {
    
    if (overwrite_by_name == FALSE | !any(which(df_P$name == name))) {
        if (nrow(df_P) == 0) {
            df_P = tibble(name=name, first=first,
                          last=last, plot=NULL)
        } else {
            df_P = bind_rows(df_P, tibble(name=name, first=first,
                                          last=last, plot=NULL))
        }
        df_P$plot[[nrow(df_P)]] = plot

    } else {
        id = which(df_P$name == name)
        df_P$first[id] = first
        df_P$last[id] = last
        df_P$plot[[id]] = plot
    }
    return (df_P)
}


## 3. NUMBER MANAGEMENT ______________________________________________
### 3.1. Number formatting ___________________________________________
# Returns the power of ten of the scientific expression of a value
#' @title Number formatting
#' @export
get_power = function (value) {

    if (length(value) > 1) {
        power = unlist(as.list(sapply(value, get_power),
                               recursive=TRUE,
                               use.names=FALSE))
    } else {
        if (!is.na(value)) {
            # Do not care about the sign
            value = abs(value)
            
            # If the value is greater than one
            if (value >= 1) {
                # The magnitude is the number of character of integer part
                # of the value minus one
                power = nchar(as.character(as.integer(value))) - 1
                # If value is zero
            } else if (value == 0) {
                # The power is zero
                power = 0
                # If the value is less than one
            } else {
                # Extract the decimal part
                dec = gsub('0.', '', as.character(value), fixed=TRUE)
                # Number of decimal with zero
                ndec = nchar(dec)
                # Number of decimal without zero
                nnum = nchar(as.character(as.numeric(dec)))
                # Compute the power of ten associated
                power = -(ndec - nnum + 1)
            }
        } else {
            power = NA
        }
    }
    return (power)
}

### 3.2. Pourcentage of variable _____________________________________
# Returns the value corresponding of a certain percentage of a
# data serie
#' @title Pourcentage of variable
#' @export
gpct = function (pct, L, min_lim=NULL, shift=FALSE) {

    # If no reference for the serie is given
    if (is.null(min_lim)) {
        # The minimum of the serie is computed
        minL = min(L, na.rm=TRUE)
    # If a reference is specified
    } else {
        # The reference is the minimum
        minL = min_lim
    }

    # Gets the max
    maxL = max(L, na.rm=TRUE)
    # And the span
    spanL = maxL - minL
    # Computes the value corresponding to the percentage
    xL = pct/100 * as.numeric(spanL)

    # If the value needs to be shift by its reference
    if (shift) {
        xL = xL + minL
    }
    return (xL)
}


## 4. LOADING ________________________________________________________
### 4.1. Shapefile loading ___________________________________________
#' @title Shapefiles loading
#' @description  Generates a list of shapefiles to draw a hydrological
#' map of the France
#' @param resources_path Path to the resources directory.
#' @param fr_shpdir Directory you want to use in ash\\resources_path\\
#' to get the France shapefile.
#' @param fr_shpname Name of the France shapefile.
#' @param bs_shpdir Directory you want to use in ash\\resources_path\\
#' to get the hydrological basin shapefile.
#' @param bs_shpname Name of the hydrological basin shapefile.
#' @param sbs_shpdir Directory you want to use in
#' ash\\resources_path\\ to get the hydrological sub-basin shapefile.
#' @param sbs_shpname Name of the hydrological sub-basin shapefile.
#' @param rv_shpdir Directory you want to use in ash\\resources_path\\
#' to get the hydrological network shapefile.
#' @param rv_shpname  Name of the hydrological network shapefile.
#' @param show_river Boolean to indicate if the shapefile of the
#' hydrological network will be charge because it is a heavy one and
#' that it slows down the entire process (default : TRUE)
#' @return A list of shapefiles converted as tibbles that can be plot
#' with 'geom_polygon' or 'geom_path'.
#' @export
load_shapefile = function (resources_path, data,
                           fr_shpdir, fr_shpname,
                           bs_shpdir, bs_shpname,
                           sbs_shpdir, sbs_shpname,
                           cbs_shpdir, cbs_shpname, cbs_coord,
                           rv_shpdir, rv_shpname,
                           river_selection=c('all'),
                           toleranceRel=10000) {

    Code = rle(data$Code)$value
    
    # Path for shapefile
    fr_shppath = file.path(resources_path, fr_shpdir, fr_shpname)
    bs_shppath = file.path(resources_path, bs_shpdir, bs_shpname)
    sbs_shppath = file.path(resources_path, sbs_shpdir, sbs_shpname)
    cbs_shppath = file.path(resources_path, cbs_shpdir, cbs_shpname)
    rv_shppath = file.path(resources_path, rv_shpdir, rv_shpname)

    
    # France
    france = st_read(fr_shppath)
    france = st_union(france)
    france = st_simplify(france,
                         preserveTopology=TRUE,
                         dTolerance=toleranceRel)
    france = st_transform(france, 2154)
    
    # Hydrological basin
    basin = st_read(bs_shppath)
    basin = st_simplify(basin,
                        preserveTopology=TRUE,
                        dTolerance=toleranceRel/2)
    basin = st_transform(basin, 2154)
    
    # Hydrological sub-basin
    subBasin = st_read(sbs_shppath)
    subBasin = st_simplify(subBasin,
                           preserveTopology=TRUE,
                           dTolerance=toleranceRel/2)
    subBasin = st_transform(subBasin, 2154)

    # Hydrological code bassin
    codeBasin_list = lapply(cbs_shppath, read_sf)
    codeBasin_list = lapply(codeBasin_list, st_transform, 2154)
    codeBasin = do.call(rbind, codeBasin_list)
    codeBasin = codeBasin[codeBasin$Code %in% Code,]
    codeBasin = st_simplify(codeBasin,
                            preserveTopology=TRUE,
                            dTolerance=toleranceRel/10)

    # If the river shapefile needs to be load
    if (!("none" %in% river_selection)) {
        # Hydrographic network
        river = st_read(rv_shppath)

        if ('all' %in% river_selection) {
            river = river[river$Classe == 1,]
        } else {
            river = river[grepl(paste(river_selection, collapse='|'),
                                river$NomEntiteH),]
        }
        river = st_simplify(river,
                            preserveTopology=TRUE,
                            dTolerance=toleranceRel/10)
        river = st_transform(river, 2154) 
    } else {
        river = NULL
    }

    return (list(france=france,
                 basin=basin,
                 subBasin=subBasin,
                 codeBasin=codeBasin,
                 river=river))
}

### 4.2. Logo loading ________________________________________________
#' @title Logo loading
#' @export
load_logo = function (resources_path, logo_dir, PRlogo_file, AEAGlogo_file,
                      INRAElogo_file, FRlogo_file, logo_to_show) {

    logo_path = c()
    if ('PR' %in% logo_to_show) {
        path = file.path(resources_path, logo_dir, PRlogo_file)
        logo_path = c(logo_path, path)
        names(logo_path)[length(logo_path)] = 'PR'
    }
    if ('FR' %in% logo_to_show) {
        path = file.path(resources_path, logo_dir, FRlogo_file)
        logo_path = c(logo_path, path)
        names(logo_path)[length(logo_path)] = 'FR'
    }
    if ('INRAE' %in% logo_to_show) {
        path = file.path(resources_path, logo_dir, INRAElogo_file)
        logo_path = c(logo_path, path)
        names(logo_path)[length(logo_path)] = 'INRAE'
    }
    if ('AEAG' %in% logo_to_show) {
        path = file.path(resources_path, logo_dir, AEAGlogo_file)
        logo_path = c(logo_path, path)
        names(logo_path)[length(logo_path)] = 'AEAG'
    }
    
    return (logo_path)
}

### 4.3. Other _______________________________________________________    
#' @title Split filename
#' @export
splitext = function(file) { # tools::file_ext
    ex = strsplit(basename(file), split="\\.")[[1]]
    res = list(name=ex[1], extension=ex[2])
    return (res)
}

#' @title Split path
#' @export
split_path = function (path) {
  if (dirname(path) %in% c(".", path)) return(basename(path))
  return(c(basename(path), split_path(dirname(path))))
}