#Librairies

library(shiny)
library(shinydashboard)
#library(xlsx)
library(base64enc)
library(openxlsx)
library(SARP.moodle)
library(data.table)
library(readxl)
library(readODS)
library(spsComps)
library(base64enc)
library(shinyalert)
# library(SARP.moodle, lib.loc = "/usr/lib64/R/library")
library(SARP.moodle) #, lib.loc = "/home/sabrina/R/x86_64-mageia-linux-gnu-library/4.0/")

#input=list(file = list(datapath = "/Users/travail/ResilioSync/Desktop/Sabrina-main/ErreurBaseQuestionsMoodle_2021-11-19 2.csv"))

############################################################################################################

FichierErreurs <- read.table("www/codes_erreur.2023-05-18_EC.txt", header = TRUE, sep = "\t", fill = TRUE)

shinyServer(function(input, output, session){
  
  values <- reactiveValues()

  FilePath <- reactive({
		input$file$datapath
	})


  output$email <- renderUI({
    tagList(a(
      h5("Contacter Emmanuel Curis pour vos demandes au sujet de SARP.moodle."), 
      href = "mailto:emmanuel.curis@u-paris.fr")
    )
  })
  
  
  # Ce code utilise la fonction `observeEvent()` pour détecter le déclenchement de l'événement "Start" et mettre à jour l'onglet "Conversion" en utilisant la fonction `updateTabItems()`.
  observeEvent(input$convertButton, {
    if (!is.null(FilePath())) {
      updateTabItems(session, "tabs", "Base")
    }
  })

	# observeEvent(values[["xml"]], {
	#   cat(! is.null(values[["xml"]]))
	#   if (! is.null(values[["xml"]])) {
	#     enable("downloadSolution")
	#   } else {
	#     disable("downloadSolution")
	#   }
	# })
	
	output$downloadSolution <- downloadHandler(
		filename = function() {
			as.character(paste0("BaseQuestionsMoodle_", Sys.Date(), ".xml"))
		},
		content = function(file) {
			# return(getXML(file))
		  values[["log"]] <- capture.output(xml <- getXML(file))
		  # values[["xml"]] <- xml
		  if(! is.null(xml))
  		  return(xml)
		  else
		    return(NULL)
		}
	)
	
	
#Cette fonction "getXML" prend un nom de fichier en entrée et effectue des opérations en fonction de la valeur des options "ImagesQuestion" et "conversion" de l'entrée utilisateur, avant de renvoyer le nom du fichier en sortie. La fonction convertit les fichiers CSV, XLSX et ODS en fichier XML en utilisant les fonctions csv.moodle(), xlsx.moodle() et ods.moodle() respectivement. Si l'option "ImagesQuestion" est activée, la fonction copie les fichiers d'images spécifiés dans le répertoire de destination avant de convertir le fichier en XML.

	
	getXML <- function(){
	  
	  extension <- tools::file_ext(input$file$datapath)
	  file <- "temp.xml"
	  
	  if(input$ImagesQuestion == TRUE){
	    FileRep <- gsub("0\\.[a-zA-Z]+$", "", input$file$datapath)
	    system(paste0("cp ", input$Images[, 4], " ", FileRep, input$Images[, 1], collapse = ";"))
	    
	    if(extension == "csv"){
	      msgErr <- try(conv <-
	        csv.moodle(
	          fichier.csv = input$file$datapath, 
	          fichier.xml = file,
	          sep.images = if ("Image" %in% input$conversion) c('@@', '@@') else NULL,
	          dossier.images = FileRep
	        )
        )
	    } else if(extension == "xlsx"){
	      msgErr <- try(conv <-
	        xlsx.moodle(
  	        fichier.xlsx = input$file$datapath, 
  	        fichier.xml = file,
  	        sep.images = if ("Image" %in% input$conversion) c('@@', '@@') else NULL,
  	        dossier.images = FileRep
  	      )
        )
	    } else if(extension == "ods"){
	      msgErr <- try(conv <-
  	      ods.moodle(
  	        fichier.csv = input$file$datapath, 
  	        fichier.xml = file,
  	        sep.images = if ("Image" %in% input$conversion) c('@@', '@@') else NULL,
  	        dossier.images = FileRep
  	      )
	      )
	    }
	  } else {
	    cat(paste("########################", extension, "######################\n\n\n"))
	    
	    if(extension == "csv"){
	    msgErr <- try(conv <-
	      csv.moodle(
	        fichier.csv = input$file$datapath, 
	        fichier.xml = file
	        )
	      )
	    } else if(extension == "xlsx"){
	      msgErr <- try(conv <-
	        xlsx.moodle(
	          fichier.xlsx = input$file$datapath, 
	          fichier.xml = file
	        )
	      )
	    } else if(extension == "ods"){
	      msgErr <- try(conv <-
	      ods.moodle(
	        fichier.ods = input$file$datapath, 
	        fichier.xml = file
	        )
	      )
	    }
	  }
	  if (class(msgErr) %in% "try-error") {
	    shinyCatch({ stop(msgErr) }, prefix = '')
	    return(msgErr)
	  } else {
	    return(conv)
	  }
	}
	
	output$WARNINGS <- renderPrint({
	  textOutput("text")
		# getXML(as.character(paste0("BaseQuestionsMoodle_", Sys.Date(), ".xml")))
	})
	
#Ce code crée une boîte d'informations "infoBox" contenant un élément d'entrée de fichier "fileInput" avec un bouton de parcours permettant aux utilisateurs de sélectionner un fichier CSV, XLSX ou ODS. La boîte d'informations n'est rendue que si l'option "ImagesQuestion" est activée et si l'utilisateur a déjà téléchargé les images requises. La boîte d'informations est stylisée avec une icône Excel, une couleur de fond bleue et une largeur de 12.

	output$FileBox <- renderUI({

		infoBox(title = "",
			fileInput("file", 
			label = "Importez votre fichier de questions preparé en suivant le gabarit (xlsx, csv, ods). Vous pouvez trouver des exemples de gabarits pour créer vos questions dans l’aide", 
			buttonLabel = HTML(paste(icon("upload"), "Parcourir")),
							placeholder = "Aucun fichier importé pour l'instant ..."
			, width = "100%",
			accept = c(".csv", ".ods", ".xlsx")
			),
			icon = icon("file-excel"), 
			fill = TRUE, 
			color = "blue", 
			width = 12
  		)
	})
	
	#################  Code pour afficher un apercu du gabarit mais ne fonctionne pas  ############################
	output$preview <- DT::renderDataTable({
	  req(input$file)  # S'assurer qu'un fichier est sélectionné
	  
	  # Chemin vers le fichier téléchargé
	  filepath <- input$file$datapath
	  
	  # Vérification du type de fichier
	  if (grepl("\\.csv$", input$file$name, ignore.case = TRUE)) {
	    data <- read.csv(filepath)
	  } else if (grepl("\\.xlsx$|\\.xls$", input$file$name, ignore.case = TRUE)) {
	    data <- readxl::read_excel(filepath)
	  } else if (grepl("\\.ods$", input$file$name, ignore.case = TRUE)) {
	    data <- readxl::read_ods(filepath)
	  } else {
	    return(NULL)  # Fichier non pris en charge
	  }
	  
	  # Afficher l'aperçu des données
	  DT::datatable(head(data, 10))
	})
	
	######################################################################################################################
	
#Ce code crée une boîte contenant un élément d'entrée de fichier "fileInput" permettant aux utilisateurs de sélectionner des images en format PNG, JPEG ou JPG, qui seront utilisées pour créer une base de questions. La boîte n'est rendue que si l'option "ImagesQuestion" est activée et elle est stylisée avec un titre, un fond solide de couleur primaire et une largeur de 12.

#### NV images
	output$ImageBox <- renderUI({
	  		if(input$ImagesQuestion == FALSE)
	  			return(NULL)
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
	  if(input$ImagesQuestion == "FALSE")
	     return(NULL)
	  
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
	        paste("Vous avez importer l'image suivante :", selected())
	      } else {
	        paste("Vous avez importer les", selected_count, "images suivantes :", paste(selected(), collapse = ", "))
	      }
	    }),
	    footer = tagList(modalButton("Fermer")),
	    easyClose = TRUE
	  ))
	})
	
	
	output$validate_button_ui <- renderUI({
	  if(input$ImagesQuestion == "FALSE")
	    return(NULL)
	  
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

	})
	
	
	
#### ANCIEN images	
	
# 	output$ImageBox <- renderUI({
# 		if(input$ImagesQuestion == FALSE)
# 			return(NULL)
# 		box(title = "Selectionnez les images utilisées dans votre fichier de questions.",
# 			fileInput("Images",
# 				label = "",
# 				buttonLabel = HTML(paste(icon("upload"), "Cliquez ici pour sélectionner toutes les images")),
# 							placeholder = "Aucune image importée pour l'instant ...",
# 				multiple = TRUE,
# 				accept = c("png", "jpeg", "jpg", "pdf") # les formats d'images favoris !
# 			),
# 			solidHeader = TRUE,
#   			status = "primary",
#   			width = 12
#   		)
# 	})

	
	
	
# Ce code génère une boîte de dialogue qui permet à l'utilisateur de sélectionner les conversions automatiques qu'il souhaite activer pour les images, les formules mathématiques et les codes SMILES, si l'option "ImagesQuestion" est activée dans l'application R Shiny.
	
	output$ImageInfo <- renderUI({
	  
	  box(
	    title = "Paramètres avancés. Sélectionnez les paramètres pour la conversion de votre fichier de questions",
	    checkboxGroupInput(
	      inputId = "conversion",
	      label = "",
	      selected = c('Image', 'Latex', 'Smiles', 'Time'),
	      choiceNames = list(
	        "Images", 
	        "Formules mathématiques",
	        "Codes SMILES",
	        "Afficher le temps conseillé"
	      ),
	      choiceValues = list(
	        "Image",
	        "Latex",
	        "Smiles",
	        "Time"
	      ), 
	      inline = TRUE
	    ),
	    textInput("color_time_advice", "Couleur des messages de temps conseillé sur Moodle", value = ""),
	    numericInput("rounding_tolerance", "Tolérance des arrondis", value = 0, min = 0),
	    textInput("default_category", "Catégorie par défaut des questions sur Moodle si la catégorie n'est pas renseignée dans le fichier de questions", value = ""),
	    solidHeader = TRUE,
	    status = "primary",
	    width = 12,
	    collapsible = T,
	    collapsed = T
	  )
	})
	observeEvent(input$questionFile, {
	  req(input$questionFile)
	  file_name <- tools::file_path_sans_ext(input$questionFile$name) # Extraire le nom du fichier sans l'extension
	  updateTextInput(session, "default_category", value = file_name)
	})

###Ce code génère une boîte d'information qui contient les avertissements éventuels liés au traitement d'un fichier de base de questions.
	
###La fonction renderUI() est utilisée pour créer un objet HTML dynamique basé sur les valeurs des entrées de l'utilisateur. Dans ce cas, le contenu de la boîte d'information dépend de la valeur renvoyée par la fonction FilePath().
	
###Si la fonction renvoie une valeur nulle (c'est-à-dire que l'utilisateur n'a pas encore sélectionné de fichier), la fonction return(NULL) est appelée pour ne rien afficher. Si une valeur non nulle est renvoyée, une boîte d'information est créée à l'aide de la fonction box().

###Le titre de la boîte d'information est "Détail du traitement de votre fichier de base de questions." et le contenu de la boîte est défini par verbatimTextOutput("WARNINGS"). Cela signifie que la sortie de la fonction renderPrint() qui est associée à l'ID "WARNINGS" sera affichée dans la boîte.

###La boîte d'information est ensuite personnalisée avec les paramètres solidHeader = TRUE pour avoir une en-tête pleine et status = "warning" pour avoir une couleur de fond jaune qui attire l'attention de l'utilisateur. Le paramètre width = 12 spécifie la largeur de la boîte en nombre de colonnes sur la page.
	
	output$WARNINGSbox <- renderUI({
		if(is.null(FilePath()))
			return(NULL)
		else
			box(title = "Détail du traitement de votre fichier de base de questions.", 
				# verbatimTextOutput("WARNINGS"),
				#verbatimTextOutput(getXML()),
				verbatimTextOutput("console"),
				solidHeader = TRUE,
  			status = "success",
  			width = 12,
				collapsible = TRUE,
				collapsed = T,
  		)
	})

### Ce code utilise une fonction observeEvent pour détecter le changement de l'élément d'entrée input$FileBox. Lorsque cela se produit, il utilise une fonction tryCatch pour capturer les avertissements éventuels générés par le code qui traite le fichier téléchargé. Si un avertissement est capturé, la variable mess contient le message d'avertissement, qui est ensuite affiché à l'utilisateur à l'aide de la fonction showNotification. En résumé, ce code affiche une notification à l'utilisateur en cas d'avertissement lors du traitement du fichier téléchargé.
	
 observeEvent(input$FileBox, {
 	a <- tryCatch(warning(Sys.time()), warning=function(w) { w })
    mess <- a$message
    showNotification(mess)
  })
 
 #bouton retour
 observeEvent(input$retourButton, {
   updateTabItems(session, "tabs", "Convertir")
 })

#### Ce code crée un bouton de téléchargement qui permet à l'utilisateur de télécharger un fichier résultat si un chemin de fichier est fourni. Le bouton est affiché dans une boîte d'information avec une icône de téléchargement et une couleur maroon. Si aucun chemin de fichier n'est fourni, rien ne sera affiché.
 
 output$downloadButton <- renderUI({
   if(is.null(FilePath())){
     return(NULL)
   } else {
     values[["log"]] <- capture.output(xml <- getXML())
     if(class(xml) %in% "try-error"){
       
       ## Erreurs avec les jolis messages
       CodeError <- gsub("(Error in erreur\\()([0-9]+)(.*)", "\\2", as.character(xml)) # recuperation du numero d'erreur
       ErrorMessage <- FichierErreurs$MessageUtilisateur[FichierErreurs$Code == CodeError] # Recuperation du message utilisateur
       ## Recuperation des erreurs brutes POUR L'INSTANT
       #ErrorMessage <- gsub("(.*)(ERREUR : )(.*)(\\\n)", "\\3", as.character(xml)) # recuperation du numero d'erreur
       
       infoBox("ATTENTION La conversion n'a pas abouti car il y a une erreur dans votre fichier d'entrée.",
        ErrorMessage,
        icon = icon("triangle-exclamation"),
        fill = TRUE,
        color = "red",
        width = 12
       )
       ##### renvoyer le detail de l'erreur qui est ds xml
       
       #https://daattali.com/shiny/shinyalert-demo/
       
     } else {
        # creation d'un html à partir du xml
        system("imprime_Moodle temp.xml") # creation de temp.html
        # visualise temp.html
        list(
         infoBox("", "Vous pouvez télécharger votre fichier de questions prêt à l’importation sous Moodle.",
                 downloadButton("downloadSolution", "Télécharger", style = "color: white;", class = "btn-lg btn-primary"),
                 icon = icon("download"),
                 fill = TRUE,
                 color = "green",
                 width = 12
         ),
         box(title = "Aperçu des questions importées.",
             includeHTML("temp.html"),
             solidHeader = TRUE,
             status = "success",
             width = 12,
             collapsible = TRUE,
             collapsed = FALSE,
             
         )
       )
       ####### VISUALISATION
       
       # creation d'un html à partir du xml
       # system("imprime_Moodle temp.xml") # creation de temp.html
       # visualise temp.html
       
       
       
       
     }
   } 
 })
   
 output$downloadSolution <- downloadHandler(
   filename = function() {
     as.character(paste0("BaseQuestionsMoodle_", format(Sys.Date(), "%d-%m-%Y", locale = "French_France"), ".xml"))
   },
   content = function(file) {
     if(file.exists("temp.xml"))
       file.copy("temp.xml", file)
   }
 )

	output$console <- renderPrint({
	  return(print(values[["log"]]))
	  # You could also use grep("Warning", values[["log"]]) to get warning messages and use shinyBS package
	  # to create alert message
	})
	

	    output$downloadTemplate <- downloadHandler(
	      filename = function() {
	        "types_questions_Moodle.csv"
	      },
	      content = function(file) {
	        file.copy("www/types_questions_Moodle.csv", file)
	      }
	    )

})