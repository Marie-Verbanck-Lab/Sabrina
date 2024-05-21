library(shiny)

ui <- fluidPage(
  titlePanel("Sélection multiple d'images"),
  sidebarLayout(
    sidebarPanel(
      fileInput("images", label = "Sélectionnez des images", multiple = TRUE, accept = c('image/png', 'image/jpeg', 'image/jpg')),
      hr(),
      uiOutput("image_selectors")
    ),
    mainPanel(
      h4("Images sélectionnées :"),
      uiOutput("selected_images")
    )
  )
)

server <- function(input, output, session) {
  selected_images <- reactiveVal(list())
  
  observeEvent(input$images, {
    images <- selected_images()
    new_images <- lapply(seq_along(input$images$name), function(i) {
      list(name = input$images$name[i], datapath = input$images$datapath[i])
    })
    names(new_images) <- input$images$name
    images <- c(images, new_images)
    selected_images(images)
  })
  
  output$selected_images <- renderUI({
    img_list <- selected_images()
    tagList(
      lapply(names(img_list), function(name) {
        tags$div(
          h5(name),
          tags$button(
            "Supprimer",
            id = paste0("delete_", name),
            onclick = sprintf('Shiny.onInputChange("%s", "%s")', paste0("delete_", name, "_btn"), name)
          ),
          tags$hr()
        )
      })
    )
  })
  
  observe({
    lapply(names(selected_images()), function(name) {
      observeEvent(input[[paste0("delete_", name, "_btn")]], {
        images <- selected_images()
        images[[name]] <- NULL
        selected_images(images)
      })
    })
  })
}

shinyApp(ui = ui, server = server)
