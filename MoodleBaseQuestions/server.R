library(shiny)
library(shinydashboard)
#library(xlsx)
library(openxlsx)
library(SARP.moodle)
library(data.table)
library(readxl)
library(readODS)

# ;dld

############################################################################################################

shinyServer(function(input, output, session){
	
	# getCSV <- function(){
	# 	#res <- read.xlsx(FilePath(), 1) 
	#   #fwrite(res, paste0("BaseQuestionsMoodle_", Sys.Date(), ".csv"), sep = ";")
	#   res <- 
	#   return(paste0("BaseQuestionsMoodle_", Sys.Date(), ".csv"))
	# }

	FilePath <- reactive({
		input$file$datapath
	})

	# reaction au bouton commencer, changement de tab
	observeEvent(input$Start, {
		updateTabItems(session, "tabs", "Conversion")
	})

	output$downloadSolution <- downloadHandler(
		filename = function() {
			as.character(paste0("BaseQuestionsMoodle_", Sys.Date(), ".xml"))
		},
		content = function(file) {
			cat(input$file$datapath)
			cat("##################################\n")
			getXML(file)
		}
	)

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
	      csv.moodle(
	        fichier.csv = input$file$datapath, 
	        fichier.xml = file
	      )
	    } else if(extension == "xlsx"){
	      xlsx.moodle(
	        fichier.xlsx = input$file$datapath, 
	        fichier.xml = file
	      )
	      
	     
	    } else if(extension == "ods"){
	      ods.moodle(
	        fichier.ods = input$file$datapath, 
	        fichier.xml = file
	      )
	      
	    }
	  }
	  
	  return(file)
	}

	output$WARNINGS <- renderPrint({
		# getXML(as.character(paste0("BaseQuestionsMoodle_", Sys.Date(), ".xml")))
	})

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
  
	output$WARNINGSbox <- renderUI({
		if(is.null(FilePath()))
			return(NULL)
		else
			box(title = "Détail du traitement de votre fichier de base de questions.", 
				verbatimTextOutput("WARNINGS"),
				solidHeader = TRUE,
  				status = "warning",
  				width = 12
  			)
	})

 observeEvent(input$FileBox, {
 	a <- tryCatch(warning(Sys.time()), warning=function(w) { w })
    mess <- a$message
    showNotification(mess)
  })


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


})

