library(shiny)
library(base64enc)

ui <- fluidPage(
  checkboxInput("ImagesQuestion", "Souhaitez-vous importer des images ?", value = FALSE),
  uiOutput("image_selector_ui")
)

server <- function(input, output, session) {
  output$image_selector_ui <- renderUI({
    if (input$ImagesQuestion == FALSE)
      return(NULL)
    
    fluidRow(
      box(
        title = "Sélecteur d'image(s)",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        fileInput("images", label = 'Sélectionnez les images utilisées dans votre fichier de questions. Vous pouvez utiliser la touche "Ctrl" pour sélectionner plusieurs images, ou appuyer sur plusieurs fois sur "Parcourir".', multiple = TRUE, accept = c('image/png', 'image/jpeg', 'image/jpg'), buttonLabel = HTML(paste(icon("upload"), "Parcourir")),
                  placeholder = "Aucune image importée pour l'instant ..."),
        hr(),
        h4("Images sélectionnées :"),
        uiOutput("selected_images_bilan"),
        uiOutput("validate_button_ui"),
        h4("Chemins temporaires des images importées :"),
        verbatimTextOutput("image_paths")
      )
    )
  })
  
  selected_images <- reactiveVal(list())
  is_validated <- reactiveVal(FALSE)
  
  observeEvent(input$images, {
    images <- selected_images()
    new_images <- lapply(seq_along(input$images$name), function(i) {
      list(
        name = input$images$name[i],
        datapath = input$images$datapath[i],
        data = base64enc::dataURI(file = input$images$datapath[i], mime = input$images$type[i])
      )
    })
    names(new_images) <- input$images$name
    duplicate_names <- names(selected_images())[names(selected_images()) %in% input$images$name]
    if (length(duplicate_names) > 0) {
      showModal(modalDialog(
        title = "Attention",
        paste("Les images suivantes ont été sélectionnées plusieurs fois :", paste(duplicate_names, collapse = ", ")),
        footer = tagList(modalButton("Fermer"))
      ))
    } else {
      images <- c(images, new_images)
      selected_images(images)
    }
  })
  
  output$selected_images_bilan <- renderUI({
    if (input$ImagesQuestion == FALSE)
      return(NULL)
    img_list <- selected_images()
    
    tagList(
      lapply(names(img_list), function(name) {
        tags$div(
          class = "image-container",
          checkboxInput(inputId = paste0("select_", name), label = NULL, value = TRUE),
          tags$img(src = img_list[[name]]$data, class = "image-preview"),
          tags$span(name, class = "image-label")
        )
      })
    )
  })
  
  observeEvent(input$validate_images, {
    selected <- reactiveVal(NULL)
    observe({
      input_list <- lapply(names(selected_images()), function(name) input[[paste0("select_", name)]])
      selected(names(selected_images())[unlist(input_list)])
    })
    
    is_validated(TRUE)
    showModal(modalDialog(
      title = "Images validées",
      renderText({
        selected_count <- length(selected())
        if (selected_count == 1) {
          paste("Vous avez importé l'image suivante :", selected())
        } else {
          paste("Vous avez importé les", selected_count, "images suivantes :", paste(selected(), collapse = ", "))
        }
      }),
      footer = tagList(modalButton("Fermer")),
      easyClose = TRUE
    ))
  })
  
  output$validate_button_ui <- renderUI({
    if (input$ImagesQuestion == FALSE)
      return(NULL)
    
    actionButton("validate_images", "Vérifier les images sélectionnées", style = "color: white;", class = "btn-primary")
  })
  
  # Affichez les chemins des fichiers temporaires
  output$image_paths <- renderPrint({
    img_list <- selected_images()
    if (length(img_list) == 0) {
      return("Aucune image importée")
    } else {
      sapply(img_list, function(x) x$datapath)
    }
  })
}

shinyApp(ui = ui, server = server)
