library(shiny)
library(ggplot2)
library(glue)
library(dplyr)
library(DT)
library(shinyjs)
library(shinylive)
library(bslib)
library(thematic)

thematic_shiny(font = "auto")

data(diamonds)

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
      
      selectInput("color_filter", "Choisir une couleur à filtrer :", 
                  choices = c("D", "E", "F", "G", "H", "I", "J")),
      
      sliderInput("range_price", "Prix maximum :", 
                  min = 300, max = 20000, value = c(300, 5000)),
      actionButton("show_notif", "Afficher une notification")
    ),
    
    mainPanel(
      plotOutput("plot"),
      DTOutput("table")
    )
  )
)

server <- function(input, output, session) {
  
  filtered_data <- reactive({
    diamonds %>%
      filter(color == input$color_filter,
             price >= input$range_price[1], price <= input$range_price[2])
  })
  
  observeEvent(input$show_notif, {
    showNotification(glue("Prix: {input$range_price[2]} & Couleur: {input$color_filter}"),
                     type = "message", duration = 3)
  })
  
  output$plot <- renderPlot({
    data <- filtered_data()
    
    ggplot(data, aes(x = carat, y = price)) +
      geom_point(color = ifelse(input$pink_points == "Oui", "pink", "blue"), alpha = 0.5) +
      labs(title = glue("Prix des diamants ({input$color_filter})"),
           x = "Carat", y = "Prix") +
      theme_minimal()
  })
  
  output$table <- renderDT({
    filtered_data() %>%
      select(carat, cut, color, clarity, depth, table, price) %>%
      datatable(options = list(pageLength = 10))
  })
}


shinyApp(ui = ui, server = server)