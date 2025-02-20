library(shiny)
library(ggplot2)
library(glue)
library(dplyr)
library(DT)
library(shinyjs)
library(shinylive)
library(bslib)
library(thematic)
library(shinyjs)

thematic_shiny(font = "auto")

data(diamonds)

ui <- fluidPage(
  useShinyjs(),
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
                  min = 300, max = 20000, value = c(300, 5000), step = 100),
      actionButton("show_notif", "Afficher une notification")
    ),
    
    mainPanel(
      plotOutput("plot"),
      DTOutput("table")
    )
  )
)

server <- function(input, output, session) {
  
  observe({
    updateSliderInput(session, "range_price", min = 300, value = c(300, input$range_price[2]))
  })
  
  runjs("
      $('.shiny-notification').css({
        'background-color': 'white',
        'color': 'black'
      });
    ")
  
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
      labs(title = glue("prix: {input$range_price[2]} & color: {input$color_filter}"),
           x = "carat", y = "price") +
      theme_minimal(base_family = "Nanum Gothic Coding") +
      theme(
        plot.title = element_text(color = "darkgray"),
        axis.text = element_text(color = "darkgray"),
        axis.title = element_text(color = "darkgray")
      )
  })
  
  output$table <- renderDT({
    filtered_data() %>%
      select(carat, cut, color, clarity, depth, table, price) %>%
      datatable(options = list(pageLength = 10))
  })
}


shinyApp(ui = ui, server = server)