library(tidyverse)
library(rgdal)
library(sp)
library(sf)
library(leaflet)
library(htmlwidgets)
library(shiny)
library(shinythemes)

avg_rating <- read.csv("R/avg_rating.csv") %>% transmute(shop = name, avg_rat)

shinyUI(
    fluidPage(theme = shinytheme("cosmo"), 
        navbarPage(
            "Навигация",
            tabPanel(
                "Графики",
                sidebarPanel(
                    h3("Ввод:"),
                    textInput("txt1", "Ваше имя:", "Иван Иванов"),
                    selectInput("shop", label = "Какие магазины вас интересуют?", 
                                choices = as.character(avg_rating[,1]), 
                                multiple = T),
                ),
                mainPanel(
                    verbatimTextOutput("txtout"),
                    plotOutput(outputId = "avg")
                )
            ),
            tabPanel(
                "Карта",
                sidebarPanel(
                    selectInput("shop_map", label = "Какие магазины вас интересуют?", 
                                choices = as.character(avg_rating[,1]), 
                                multiple = T),
                ),
                mainPanel(
                    "Ну вот карта смотрите", 
                    leafletOutput(outputId = "map", width = 800, height = 600)
                )
            )
        )
    )
)