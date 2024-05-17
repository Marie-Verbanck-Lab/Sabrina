library(shiny)

ui <- fluidPage(
  titlePanel("Sélection multiple d'images"),
  sidebarLayout(
    sidebarPanel(
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
  image_count <- reactiveVal(0)
  selected_images <- reactiveVal(list())
  
  observeEvent(input$add_image, {
    image_count(image_count() + 1)
  })
  
  output$image_selectors <- renderUI({
    fileInput("images", label = "", multiple = TRUE, accept = c('image/png', 'image/jpeg', 'image/jpg'))
  })
  
  observe({
    observeEvent(input$images, {
      images <- selected_images()
      images[[input$images$name]] <- input$images
      selected_images(images)
    })
  })
  
  output$selected_images <- renderUI({
    img_list <- selected_images()
    tagList(
      lapply(names(img_list), function(name) {
        imgs <- img_list[[name]]
        if (!is.null(imgs)) {
          tags$div(
            h5(name),
            tags$ul(
              lapply(imgs$name, function(fname) {
                tags$li(fname)
              })
            )
          )
        }
      })
    )
  })
}

shinyApp(ui = ui, server = server)
