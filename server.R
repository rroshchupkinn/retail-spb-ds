library(tidyverse)
library(ggthemes)
library(rgdal)
library(sp)
library(sf)
library(raster)
library(leaflet)
library(htmlwidgets)
library(shiny)
library(shinythemes)

avg_rating <- read.csv("avg_rating.csv") %>% transmute(shop = name, avg_rat)
data = read.csv("data.csv")

shinyServer(function(input, output) {
    
    output$txtout <- renderText({
        paste(input$txt1, "привет", sep = " ")
    })
    
    react = reactive({
        
        df_map = data.frame(
            name = as.character(c(input$shop_map)),
            stringsAsFactors = F
        )
        data_map = inner_join(data, df_map)
        
    })

    output$avg <- renderPlot({
        df = data.frame(
            shop = as.character(c(input$shop)),
            stringsAsFactors = F
        )
        avg_rating = inner_join(avg_rating, df)
        ggplot(avg_rating) + 
            geom_col(aes(avg_rat, shop, fill = avg_rat)) + 
            labs(title = "Главные торговые сети СПб", x = "Рейтинг", y = "Название сети") + 
            scale_fill_gradient() +
            labs(fill="Средний рейтинг") + 
            theme_classic() + 
            theme(
                plot.background = element_rect(fill = "transparent"),
                title = element_text(size = 12, face = "bold", color = "black"),
                panel.background = element_rect(fill = "transparent"),
                legend.text = element_text(colour="black", size=10, face="bold"),
                axis.text = element_text(colour = "black", size = 10, face = "bold")
            )
    })
    
    output$map = renderLeaflet({
        data_map = react()
        if (nrow(data_map) == 0) {
            coordinates(data)<-~lon+lat
            proj4string(data) = CRS("+init=epsg:4326")
            poly = readOGR("lvl8_spb_lo.shp")
            proj4string(poly) = CRS("+init=epsg:4326")
            poly$area_sqkm <- area(poly) / 1000000
            icon <- makeIcon(
                iconUrl = "https://img.icons8.com/office/344/place-marker--v1.png",
                iconWidth = 40, iconHeight = 40
            )
            bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
            pal <- colorBin("YlOrRd", domain = poly$area_sqkm, bins = bins)
            map = leaflet(data) %>% 
                addProviderTiles(provider = "CartoDB.Positron") %>% 
                addTiles() %>% 
                addMarkers(
                    popup = paste("Адрес:", data$address, "<br>", "Рейтинг (YM):", data$rating, "<br>"), 
                    label = ~ name, 
                    icon = icon, 
                    clusterOptions = markerClusterOptions()
                ) %>%
                addPolygons(data = poly, 
                            popup = poly$name, 
                            # fillColor = ~ pal(area_sqkm),
                            weight = 1,
                            opacity = 0.2,
                            color = "black",
                            dashArray = "3",
                            fillOpacity = 0.2,
                            highlightOptions = highlightOptions(
                                weight = 3,
                                color = "gray",
                                dashArray = "",
                                fillOpacity = 0.4,
                                bringToFront = TRUE))
            # addLegend(pal = pal, values = ~ poly$area_sqkm, opacity = 0.7, title = NULL,
            #           position = "bottomright")
        } else {
            coordinates(data_map)<-~lon+lat
            proj4string(data_map) = CRS("+init=epsg:4326")
            poly = readOGR("R/8/lvl8_spb_lo.shp")
            proj4string(poly) = CRS("+init=epsg:4326")
            poly$area_sqkm <- area(poly) / 1000000
            icon <- makeIcon(
                iconUrl = "https://img.icons8.com/office/344/place-marker--v1.png",
                iconWidth = 40, iconHeight = 40
            )
            bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
            pal <- colorBin("YlOrRd", domain = poly$area_sqkm, bins = bins)
            map = leaflet(data_map) %>% 
                addProviderTiles(provider = "CartoDB.Positron") %>% 
                addTiles() %>% 
                addMarkers(
                    popup = paste("Адрес:", data_map$address, "<br>", "Рейтинг (YM):", data_map$rating, "<br>"), 
                    label = ~ name, 
                    icon = icon, 
                    clusterOptions = markerClusterOptions()
                ) %>%
                addPolygons(data = poly, 
                            popup = poly$name, 
                            # fillColor = ~ pal(area_sqkm),
                            weight = 1,
                            opacity = 0.2,
                            color = "black",
                            dashArray = "3",
                            fillOpacity = 0.2,
                            highlightOptions = highlightOptions(
                                weight = 3,
                                color = "gray",
                                dashArray = "",
                                fillOpacity = 0.4,
                                bringToFront = TRUE))
                # addLegend(pal = pal, values = ~ poly$area_sqkm, opacity = 0.7, title = NULL,
                #           position = "bottomright")
            }
    })
    
})