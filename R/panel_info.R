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


#' @title Info panel
#' @export
panel_info = function(list_df2plot, meta, trend_period=NULL,
                      mean_period=NULL, period=NULL,
                      shapefile_list=NULL, codeLight=NULL,
                      data_code=NULL, to_do='all',
                      zone_to_show='France') {

    # If there is a data serie for the given code
    if (!is.null(data_code)) {
        # Computes the hydrograph
        hyd = panel_hydrograph(data_code, period=period,
                               margin=margin(t=0, r=0, b=0, l=5,
                                             unit="mm"))
    # Otherwise
    } else {
        # Puts it blank
        hyd = void()
    }

    if (!is.null(shapefile_list)) {
        # Computes the map associated to the station
        map =  page_map(list_df2plot,
                         meta,
                         trend_period=trend_period,
                         mean_period=mean_period,
                         shapefile_list=shapefile_list,
                         codeLight=codeLight,
                         mapType='mini',
                         margin=margin(t=0, r=-12, b=0, l=0,
                                       unit="mm"),
                         showSea=FALSE,
                         zone_to_show=zone_to_show,
                         verbose=FALSE)
    # Otherwise
    } else {
        # Puts it blank
        map = void()
    }

    # Gets the metadata about the station
    meta_code = meta[meta$Code == codeLight,]

    if ('name' %in% to_do | 'all' %in% to_do) {
        # Extracts the name
        nom = meta_code$nom
        # Corrects some errors about the formatting of title with dash
        nom = gsub("-", "-&nbsp;", nom)
        # Name of the datasheet
        text1 = paste(
            "<b>", codeLight, '</b>  -  ', nom,
            sep='')
        # Converts all texts to graphical object in the right position
        gtext1 = richtext_grob(text1,
                               x=0, y=1,
                               margin=unit(c(t=0, r=5, b=0, l=0),
                                           "mm"),
                               hjust=0, vjust=1,
                               gp=gpar(col="#00A3A8", fontsize=14))
    } else if ('code' %in% to_do) {
        # Name of the datasheet
        text1 = paste(
            "<b>", codeLight, '</b>',
            sep='')
        # Converts all texts to graphical object in the right position
        gtext1 = richtext_grob(text1,
                               x=0, y=1,
                               margin=unit(c(t=0, r=5, b=0, l=0),
                                           "mm"),
                               hjust=0, vjust=1,
                               gp=gpar(col="#00A3A8", fontsize=14))
    } else {
        gtext1 = void()
    }

    # Subitle info
    if ('loc' %in% to_do | 'all' %in% to_do) {
        text2 = paste(
            "<b>",
            "Gestionnaire : ", meta_code$gestionnaire, "<br>",
            "Bassin hydrographique : ", meta_code$region_hydro,
            "</b>",
            sep='')
        gtext2 = richtext_grob(text2,
                               x=0, y=1.25,
                               margin=unit(c(t=0, r=0, b=0, l=0),
                                           "mm"),
                               hjust=0, vjust=1,
                               gp=gpar(col="grey20", fontsize=8))
    } else {
        gtext2 = void()
    }

    # Spatial info about station
    if ('spatial' %in% to_do | 'all' %in% to_do) {
        text3 = paste(
            "<b>",
            "Superficie : ", meta_code$surface_km2_BH,
            "  [km<sup>2</sup>] <br>",
            "Altitude : ", meta_code$altitude_m_BH, "  [m]<br>",
            "X = ", meta_code$L93X_m_BH, "  [m ; Lambert93]<br>",
            "Y = ", meta_code$L93Y_m_BH, "  [m ; Lambert93]",
            "</b>",
            sep='')
        gtext3 = richtext_grob(text3,
                               x=0, y=1,
                               margin=unit(c(t=0, r=0, b=0, l=0),
                                           "mm"),
                               hjust=0, vjust=1,
                               gp=gpar(col="grey20", fontsize=9))
    } else {
        gtext3 = void()
    }

    # Time info about station
    if ('temporal' %in% to_do | 'all' %in% to_do) {
        # Computes the time span of data, the start and the end
        duration = as.numeric(format(as.Date(meta_code$fin),
                                     "%Y")) -
            as.numeric(format(as.Date(meta_code$debut), "%Y"))
        debut = format(as.Date(meta_code$debut), "%d/%m/%Y")
        fin = format(as.Date(meta_code$fin), "%d/%m/%Y")

        text4 = paste(
            "<b>",
            "Date de début : ", debut, "<br>",
            "Date de fin : ", fin, "<br>",
            "Nombre d'années : ", duration, "  [ans]", "<br>",
            "Taux de lacunes : ", signif(meta_code$tLac100, 2),
            "  [%]",
            "</b>",
            sep='')
        gtext4 = richtext_grob(text4,
                               x=0, y=1,
                               margin=unit(c(t=0, r=0, b=0, l=0),
                                           "mm"),
                               hjust=0, vjust=1,
                               gp=gpar(col="grey20", fontsize=9))
    } else {
        gtext4 = void()
    }


    # Makes a list of all plots
    P = list(gtext1, gtext2, gtext3, gtext4, hyd, map)
    # P = list(void(), void(), void(), void(), void(), void(), void())
    
    # Creates the matrix layout
    LM = matrix(c(1, 1, 1, 6,
                  2, 2, 5, 6,
                  3, 4, 5, 6,
                  3, 4, 5, 6),
                nrow=4, 
                byrow=TRUE)
    # And sets the relative height of each plot
    heights = rep(1, times=nrow(LM))
    # heights[2] = 0.1
    heights[2] = 0.8

    # Arranges all the graphical objetcs
    plot = grid.arrange(grobs=P,
                        layout_matrix=LM,
                        heights=heights)
    # Return the plot object
    return(plot)
}  
