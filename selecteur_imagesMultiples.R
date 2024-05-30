library(shiny)
library(base64enc)

ui <- fluidPage(
  titlePanel("Sélection multiple d'images"),
  tags$head(tags$style(HTML("
    .image-preview {
      width: 50px;
      height: 50px;
      object-fit: cover;
      margin-right: 10px;
    }
  "))),
  sidebarLayout(
    sidebarPanel(
      fileInput("images", label = "Sélectionnez des images", multiple = TRUE, accept = c('image/png', 'image/jpeg', 'image/jpg')),
      hr(),
      uiOutput("image_selectors")
    ),
    mainPanel(
      h4("Images sélectionnées :"),
      uiOutput("selected_images_bilan"),
      uiOutput("validate_button_ui")
    )
  )
)

server <- function(input, output, session) {
  
  selected_images <- reactiveVal(list())
  is_validated <- reactiveVal(FALSE)
  
  observeEvent(input$images, {
    # if (is_validated()) return()
    # Si on observe un nouvel usage de "fileInput"
    
    images <- selected_images()# Recuperation des images importees jusque la
    new_images <- lapply(seq_along(input$images$name), function(i) {# lapply: permet de faire une boucle for
      list(
        name = input$images$name[i], 
        datapath = input$images$datapath[i], 
        data = base64enc::dataURI(file = input$images$datapath[i], mime = input$images$type[i])
      )
    })
    # for (i in seq_along(input$images$name)){ # seq_along(input$images$name) un vecteur avec les indices des images selectionnees 1:nbImages. Autre facon de le faire 1:length(input$images$name)
    #    list( # on cree une liste avec 2 elements 
    #        name = input$images$name[i], # 1er element nom de l'image i
    #        datapath = input$images$datapath[i] # 2eme element chemin de l'image i
    #   )
    # }
    names(new_images) <- input$images$name # renommer les elements de la liste avec les noms des images
    # Vérification des doublons
    duplicate_names <- names(selected_images())[names(selected_images()) %in% input$images$name]
    if (length(duplicate_names) > 0) {
      showModal(modalDialog(
        title = "Attention",
        paste("Les images suivantes ont été sélectionnées plusieurs fois :", paste(duplicate_names, collapse = ", ")),
        footer = tagList(modalButton("Fermer"))
      ))
    } else {
      images <- c(images, new_images)# concatene anciennes images et nouvelles. images est une liste de taille egale aux nombres d'images importees depuis le debut (anciennes + nouvelles) et avec chaque element qui est une liste de 2 elements name et datapath.
      selected_images(images)# Mise a jour de la liste d'images
    }
  })
  
  output$selected_images_bilan <- renderUI({# Renvoit un element du UI (user interface)
    img_list <- selected_images()# Recuperation des images importees jusque la

      # tagList(
      #   lapply(names(img_list), function(name) {# Une boucle for pour chaque element de names(img_list), donc pour chaque nom d'image
      #     tags$div(
      #       style = "display: flex; align-items: center;",
      #       tags$img(src = img_list[[name]]$data, class = "image-preview"),
      #       tags$span(h5(name), style = "margin-left: 10px;")
      #     )
      #   })
      # )
    tagList(
      lapply(names(img_list), function(name) {
        tags$div(
          style = "display: flex; align-items: center;",
          checkboxInput(inputId = paste0("select_", name), label = NULL, value = TRUE),
          tags$img(src = img_list[[name]]$data, class = "image-preview"),
          tags$span(h5(name), style = "margin-left: 10px;")
        )
      })
    )
      # if (is_validated()) { # si jamais on veut arreter de pouvoir cocher les boites des images on peut utiliser cette condition
      #   
      # }
  })
  
  observeEvent(input$validate_images, { # si on observe un click sur bouton valider les images
    # Bloc suivant permet de mettre a jour la liste d'images quand on decoche cases
    selected <- reactiveVal(NULL)# Crée une reactiveVal pour stocker les images sélectionnées
    observe({
      # Liste des valeurs de toutes les cases à cocher correspondant à chaque image sélectionnée
      input_list <- lapply(names(selected_images()), function(name) input[[paste0("select_", name)]])
      # Sélectionne les noms des images pour lesquelles les cases à cocher sont cochées
      selected(names(selected_images())[unlist(input_list)])
    })
    
    is_validated(TRUE)
    # Affiche une boîte de dialogue modale contenant les images sélectionnées
    showModal(modalDialog(
      title = "Images validées",
      renderText({
        selected_count <- length(selected())
        if (selected_count == 1) {
          paste("Voici l'image que vous avez sélectionnée :", selected())
        } else {
          paste("Voici les images que vous avez sélectionnées :", paste(selected(), collapse = ", "))
        }
      }),
      footer = tagList(modalButton("Fermer")),
      easyClose = TRUE
    ))
  })
  
  
  output$validate_button_ui <- renderUI({
    #if (!is_validated()) { # utiliser ça si on veut enlever le bouton une fois que c'est validé
      actionButton("validate_images", "Valider les images")
    #}
  })
  
  observe({
    img_list <- selected_images()# Recuperation des images importees jusque la 
    lapply(names(img_list), function(name) {# Boucle for pour chaque image
      observeEvent(input[[paste0("delete_", name, "_btn")]], {
        images <- selected_images()
        images[[name]] <- NULL
        # imagesUpdated <- images[names(images) != name]
        # Probleme pour reimporter une image deja supprimee ds input[[paste0("delete_", name, "_btn")]]
        selected_images(images)
      })
    })
  })
  # Fonction pour vérifier s'il y a des images sélectionnées
  output$has_images <- reactive({
    length(selected_images()) > 0
  })
  outputOptions(output, "has_images", suspendWhenHidden = FALSE)
}

shinyApp(ui = ui, server = server)