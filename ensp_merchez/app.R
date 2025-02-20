library(shiny)
library(ggplot2)
library(glue)
library(dplyr)
library(DT)
library(shinyjs)
library(shinylive)
library(bslib)
library(thematic)

ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bootswatch = "minty"
  ),
  
  titlePanel("Exploration des Diamants"),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("pink_points", "Colorier les points en rose ?",
                   choices = c("Oui", "Non")),
      
      selectInput("numeric_var", "Choisir une couleur à filtrer :", 
                  choices = c("D", "E", "F", "G", "H", "I", "J")),
      
      sliderInput("range_price", "Prix maximum :", 
                  min = 300, max = 20000, value = c(300, 5000))
    ),
    
    mainPanel(
      textOutput("dummy_output") 
    )
  )
)

server <- function(input, output) {
}


shinyApp(ui = ui, server = server)