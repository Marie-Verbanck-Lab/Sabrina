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
      uiOutput("selected_images"),
      actionButton("validate_images", "Valider les images")
    )
  )
)

server <- function(input, output, session) {
  
  selected_images <- reactiveVal(list())
  
  observeEvent(input$images, {
    # Si on observe un nouvel usage de "fileInput"
    images <- selected_images() # Recuperation des images importees jusque la
    new_images <- lapply(seq_along(input$images$name), function(i) { # lapply: permet de faire une boucle for
      list(name = input$images$name[i], datapath = input$images$datapath[i]) # input$images$datapath: chemin de l'image dans l'application
    })
    # for (i in seq_along(input$images$name)){ # seq_along(input$images$name) un vecteur avec les indices des images selectionnees 1:nbImages. Autre facon de le faire 1:length(input$images$name)
    #    list( # on cree une liste avec 2 elements 
    #        name = input$images$name[i], # 1er element nom de l'image i
    #        datapath = input$images$datapath[i] # 2eme element chemin de l'image i
    #   )
    # }
    names(new_images) <- input$images$name  # renommer les elements de la liste avec les noms des images
    # Vérification des doublons
    duplicate_names <- names(selected_images())[names(selected_images()) %in% input$images$name]
    if (length(duplicate_names) > 0) {
      showModal(modalDialog(
        title = "Attention",
        paste("Les images suivantes ont été sélectionnées plusieurs fois :", paste(duplicate_names, collapse = ", ")),
        footer = NULL
      ))
    } else {
    images <- c(images, new_images) # concatene anciennes images et nouvelles. images est une liste de taille egale aux nombres d'images importees depuis le debut (anciennes + nouvelles) et avec chaque element qui est une liste de 2 elements name et datapath.
    selected_images(images) # Mise a jour de la liste d'images
    }
  })
  
  output$selected_images <- renderUI({ # Renvoit un element du UI (user interface)
    img_list <- selected_images() # Recuperation des images importees jusque la
    tagList(
      lapply(names(img_list), function(name) {# Une boucle for pour chaque element de names(img_list), donc pour chaque nom d'image
        tags$div(
          checkboxInput(inputId = paste0("select_", name), label = "", value = TRUE),
          h5(name),
          tags$hr()
        )
      })
    )
  })
  
  observeEvent(input$validate_images, {
    selected <- reactiveVal(NULL) # Crée une reactiveVal pour stocker les images sélectionnées
    observe({
      # Liste des valeurs de toutes les cases à cocher correspondant à chaque image sélectionnée
      input_list <- lapply(names(selected_images()), function(name) input[[paste0("select_", name)]])
      # Sélectionne les noms des images pour lesquelles les cases à cocher sont cochées
      selected(names(selected_images())[unlist(input_list)])
    })
    # Affiche une boîte de dialogue modale contenant les images sélectionnées
    showModal(modalDialog(
      title = "Images validées",
      renderText({
        # Affiche les noms des images sélectionnées dans un texte
        paste("Voici les images que vous avez sélectionnées :", paste(selected(), collapse = ", "))
      }),
      footer = NULL,
      easyClose = T
    ))
  })
  
  observe({
    img_list <- selected_images() # Recuperation des images importees jusque la 
    lapply(names(img_list), function(name) { # Boucle for pour chaque image
      observeEvent(input[[paste0("delete_", name, "_btn")]], {
        images <- selected_images()
        images[[name]] <- NULL
        # imagesUpdated <- images[names(images) != name]
        # Probleme pour reimporter une image deja supprimee ds input[[paste0("delete_", name, "_btn")]]
        selected_images(images)
      })
    })
  })
}

shinyApp(ui = ui, server = server)
