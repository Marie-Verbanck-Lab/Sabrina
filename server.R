#Librairies

library(shiny)
library(shinydashboard)
#library(xlsx)
library(openxlsx)
library(SARP.moodle)
library(data.table)
library(readxl)
library(readODS)
# library(SARP.moodle, lib.loc = "/usr/lib64/R/library")
library(SARP.moodle) #, lib.loc = "/home/sabrina/R/x86_64-mageia-linux-gnu-library/4.0/")

############################################################################################################

FichierErreurs <- read.table("www/codes_erreur.2023-05-18_EC.txt", header = TRUE, sep = "\t")

shinyServer(function(input, output, session){
  
# !!!!!!!!!!!!!!!!!!!!!!   Insérer Logos mais fonctionne pas pour le moment
  
  output$picture <- renderImage({
    image_list <- c("www/UniversiteParisCite_Pharmacie.jpeg",contentType = "image/jpeg",
                    "www/UniversiteParisCite_idex.jpeg",contentType = "image/jpeg",
                    "www/logo-BioSTM.png",contentType = "image/png",
                    "www/Logo_investir_lavenir.png",contentType = "image/png")
    images <- lapply(image_list, function(image_path) {
      renderImage({
        list(src = image_path, contentType = "image/jpeg", "image/png")
      }, deleteFile = FALSE)
    })
    
    tagList(images)
  })
  
  values <- reactiveValues()
  
  
	# getCSV <- function(){
	# 	#res <- read.xlsx(FilePath(), 1) 
	#   #fwrite(res, paste0("BaseQuestionsMoodle_", Sys.Date(), ".csv"), sep = ";")
	#   res <- 
	#   return(paste0("BaseQuestionsMoodle_", Sys.Date(), ".csv"))
	# }

  FilePath <- reactive({
		input$file$datapath
	})

	# Ce code utilise la fonction `observeEvent()` pour détecter le déclenchement de l'événement "Start" et mettre à jour l'onglet "Conversion" en utilisant la fonction `updateTabItems()`.
	observeEvent(input$Start, {
		updateTabItems(session, "tabs", "Conversion")
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

	
	getXML <- function(file){
	  
	  extension <- tools::file_ext(input$file$datapath)
	  
	  if(input$ImagesQuestion == TRUE){
	    FileRep <- gsub("0\\.[a-zA-Z]+$", "", input$file$datapath)
	    system(paste0("cp ", input$Images[, 4], " ", FileRep, input$Images[, 1], collapse = ";"))
	    
	    if(extension == "csv"){
	       csv.moodle(
	        fichier.csv = input$file$datapath, 
	        fichier.xml = file,
	        sep.images = if ("Image" %in% input$conversion) c('@@', '@@') else NULL,
	        dossier.images = FileRep
	      )
	    } else if(extension == "xlsx"){
	      xlsx.moodle(
	        fichier.xlsx = input$file$datapath, 
	        fichier.xml = file,
	        sep.images = if ("Image" %in% input$conversion) c('@@', '@@') else NULL,
	        dossier.images = FileRep
	      )
	    } else if(extension == "ods"){
	      ods.moodle(
	        fichier.csv = input$file$datapath, 
	        fichier.xml = file,
	        sep.images = if ("Image" %in% input$conversion) c('@@', '@@') else NULL,
	        dossier.images = FileRep
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
	    return(NULL)
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
		if(input$ImagesQuestion == TRUE & is.null(input$Images))
			return(NULL)

		infoBox(title = "",
			fileInput("file", 
			label = "Sélectionnez le fichier contenant les questions.", 
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
	
#Ce code crée une boîte contenant un élément d'entrée de fichier "fileInput" permettant aux utilisateurs de sélectionner des images en format PNG, JPEG ou JPG, qui seront utilisées pour créer une base de questions. La boîte n'est rendue que si l'option "ImagesQuestion" est activée et elle est stylisée avec un titre, un fond solide de couleur primaire et une largeur de 12.
	
	
	output$ImageBox <- renderUI({
		if(input$ImagesQuestion == FALSE)
			return(NULL)
		box(title = "Choisissez les images utilisées dans la base de questions (png ou jpeg).",
			fileInput("Images", 
				label = "", 
				buttonLabel = HTML(paste(icon("upload"), "Cliquez ici pour sélectionner toutes les images")),
							placeholder = "Aucune image importée pour l'instant ...",
				multiple = TRUE,
				accept = c("png", "jpeg", "jpg", "pdf") # les formats d'images favoris !
			),
			solidHeader = TRUE,
  			status = "primary",
  			width = 12
  		)
	})
	
# Ce code génère une boîte de dialogue qui permet à l'utilisateur de sélectionner les conversions automatiques qu'il souhaite activer pour les images, les formules mathématiques et les codes SMILES, si l'option "ImagesQuestion" est activée dans l'application R Shiny.
	
	output$ImageInfo <- renderUI({
		if(input$ImagesQuestion == FALSE)
			return(NULL)
		box(title = "Autorisez-vous les conversions automatiques ?",
			checkboxGroupInput(inputId = "conversion",
				label = "",
				selected = c( 'Image', 'Latex', 'Smiles' ),
				choiceNames = list( "Images", 
					"Formules mathématiques",
					"Codes SMILES" ),
				choiceValues = list("Image",
					"Latex",
					"Smiles"
				), inline = TRUE
			),
			solidHeader = TRUE,
  			status = "primary",
  			width = 12
  		)
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
  				status = "warning",
  				width = 12
  			)
	})

### Ce code utilise une fonction observeEvent pour détecter le changement de l'élément d'entrée input$FileBox. Lorsque cela se produit, il utilise une fonction tryCatch pour capturer les avertissements éventuels générés par le code qui traite le fichier téléchargé. Si un avertissement est capturé, la variable mess contient le message d'avertissement, qui est ensuite affiché à l'utilisateur à l'aide de la fonction showNotification. En résumé, ce code affiche une notification à l'utilisateur en cas d'avertissement lors du traitement du fichier téléchargé.
	
 observeEvent(input$FileBox, {
 	a <- tryCatch(warning(Sys.time()), warning=function(w) { w })
    mess <- a$message
    showNotification(mess)
  })

### Ce code crée un bouton de téléchargement qui permet à l'utilisateur de télécharger un fichier résultat si un chemin de fichier est fourni. Le bouton est affiché dans une boîte d'information avec une icône de téléchargement et une couleur maroon. Si aucun chemin de fichier n'est fourni, rien ne sera affiché.
 
	output$downloadButton <- renderUI({
		if(is.null(FilePath()))
	   	return(NULL)
		else
			infoBox("", "Vous pouvez télécharger le fichier résultat.", 
				downloadButton("downloadSolution", "Cliquez ici pour télécharger le fichier résultat"),
  			icon = icon("download"), 
			fill = TRUE, 
			color = "maroon", 
			width = 12
  			)
	})

	output$console <- renderPrint({
	  return(print(values[["log"]]))
	  # You could also use grep("Warning", values[["log"]]) to get warning messages and use shinyBS package
	  # to create alert message
	})
})