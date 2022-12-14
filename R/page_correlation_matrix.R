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


page_correlation_matrix = function (dataEx2D, metaVAR,
                                    ModelGroup=NULL,
                                    icon_path="", logo_path="",
                                    df_page=NULL,
                                    figdir='') {

    if (is.null(ModelGroup)) {
        Model = levels(factor(dataEx2D$Model))
        ModelGroup = append(as.list(Model), list(Model))
        names(ModelGroup) = c(Model, "Multi-model")
    }
    nModelGroup = length(ModelGroup)

    page_margin = c(t=0.5, r=0.5, b=0.5, l=0.5)

    leg_width = 11
    tl_width = 21 - leg_width - page_margin["l"] - page_margin["r"]

    info_height = 1
    cm_height = 22
    cm_width = 21 - page_margin["l"] - page_margin["r"]
    
    cb_height = 1.25
    ssg_height = 1.25
    si_height = 1
    tl_height = cb_height + si_height + ssg_height
    
    foot_height = 1.25

    cm_margin = margin(t=1.2, r=0, b=2, l=0.5, "cm")
    tl_shift = c(x=3, y=0)
    cb_shift = c(x=2.5, y=0)
    ssg_shift = c(x=2.5, y=0)
    si_shift = c(x=2.5, y=0.2)

    NAME = matrix(c("info", "cm", "cb", "ssg", "si", "foot",
                    "info", "cm", "tl", "tl", "tl", "foot"),
                  ncol=2)

    WIP = FALSE

    for (i in 1:nModelGroup) {
        model = ModelGroup[[i]]
        model_names = names(ModelGroup)[i]
        
        if (is.null(model_names)) {
            model_names = ""
        }
        if (nchar(model_names) == 0) {
            model2Disp = paste0(model, collapse=" ")
            model4Save = paste0(model, collapse="_")
        } else {
            model2Disp = model_names
            model4Save = gsub(" ", "_", model_names)
        }
        
        print(model2Disp)

        STOCK = tibble()
        var_plotted = c()
        
        dataEx2D_model = dataEx2D[dataEx2D$Model %in% model,]

        text = paste0(
            "<b>Matrice de corrélation des critères d'évaluation</b><br>",
            model2Disp)
        info = richtext_grob(text,
                             x=0, y=1,
                             margin=unit(c(t=0, r=0, b=0, l=0), "mm"),
                             hjust=0, vjust=1,
                             gp=gpar(col="#00A3A8", fontsize=16))
        STOCK = add_plot(STOCK,
                         plot=info,
                         name="info",
                         height=info_height)
        
        res = panel_correlation_matrix(dataEx2D_model,
                                       metaVAR,
                                       icon_path=icon_path,
                                       margin=cm_margin)
        cm = res$cm
        subTopic_path = res$info
        STOCK = add_plot(STOCK,
                         plot=cm,
                         name="cm",
                         height=cm_height)

        tl = leg_shape_info(Shape=subTopic_path,
                            Size=0.5,
                            Label=names(subTopic_path),
                            dy_icon=0.55,
                            dx_label=0.25,
                            height=tl_height,
                            width=tl_width,
                            shift=tl_shift,
                            WIP=WIP)
        STOCK = add_plot(STOCK,
                         plot=tl,
                         name="tl",
                         width=tl_width)

        cb = leg_colorbar(-1, 1, Palette=Palette_rainbow(),
                          colorStep=6, include=TRUE,
                          asFrac=TRUE,
                          reverse=TRUE,
                          size_color=0.3,
                          dx_color=0.4,
                          dy_color=0.45,
                          height=cb_height,
                          width=leg_width,
                          shift=cb_shift,
                          WIP=WIP)
        STOCK = add_plot(STOCK,
                         plot=cb,
                         name="cb",
                         height=cb_height,
                         width=leg_width)

        ssg = leg_shape_size_gradient(shape="rect",
                                      Size=c(0.1, 0.15, 0.2, 0.25),
                                      color=IPCCgrey50,
                                      labelArrow="Plus corrélé",
                                      dx_shape=0.2,
                                      dy_shape=0.1,
                                      dy_arrow=0.3,
                                      size_arrow=0.25,
                                      dz_arrow=1,
                                      dl_arrow=0,
                                      dr_arrow=0,
                                      dx_text=0.3, 
                                      height=ssg_height,
                                      width=leg_width,
                                      shift=ssg_shift,
                                      WIP=WIP)
        STOCK = add_plot(STOCK,
                         plot=ssg,
                         name="ssg",
                         height=ssg_height,
                         width=leg_width)

        si = leg_shape_info(Shape="rect",
                            Size=0.2,
                            Color=IPCCgrey50,
                            Label=c(
                                "Significatif à un risque de 10 %",
                                "Non significatif à un risque de 10 %"),
                            Cross=c(FALSE, TRUE),
                            dy_icon=0.35,
                            dx_label=0.2,
                            height=si_height,
                            width=leg_width,
                            shift=si_shift,
                            WIP=WIP)
        STOCK = add_plot(STOCK,
                         plot=si,
                         name="si",
                         height=si_height,
                         width=leg_width)

        footName = paste0('matrice de corrélation : ', model2Disp)
        if (is.null(df_page)) {
            n_page = i
        } else {
            if (nrow(df_page) == 0) {
                n_page = 1
            } else {
                n_page = df_page$n[nrow(df_page)] + page
            }
        }
        foot = panel_foot(footName, n_page,
                          foot_height, logo_path)
        STOCK = add_plot(STOCK,
                         plot=foot,
                         name="foot",
                         height=foot_height)

        # STOCK = add_plot(STOCK,
        #                  plot=void(),
        #                  name="void",
        #                  width=void_width)

        res = merge_panel(STOCK, NAME=NAME,
                          page_margin=page_margin,
                          paper_size="A4",
                          hjust=0, vjust=1)

        plot = res$plot
        paper_size = res$paper_size

        print(paper_size)

        filename = paste0("correlation_", model4Save, ".pdf")

        if (!(file.exists(figdir))) {
            dir.create(figdir, recursive=TRUE)
        }
        ggplot2::ggsave(plot=plot,
                        path=figdir,
                        filename=filename,
                        width=paper_size[1],
                        height=paper_size[2], units='cm',
                        dpi=300,
                        device=cairo_pdf)
    }
}
