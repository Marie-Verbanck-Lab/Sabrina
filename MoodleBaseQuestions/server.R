#Librairies
library(shiny)
library(shinydashboard)
library(base64enc)
library(openxlsx)
library(SARP.moodle)
library(data.table)
library(readxl)
library(readODS)
library(spsComps)
library(base64enc)
library(shinyalert)
library(colourpicker)
# library(SARP.moodle, lib.loc = "/usr/lib64/R/library")
library(SARP.moodle) #, lib.loc = "/home/sabrina/R/x86_64-mageia-linux-gnu-library/4.0/")

#input=list(file = list(datapath = "/Users/travail/ResilioSync/Desktop/Sabrina-main/ErreurBaseQuestionsMoodle_2021-11-19 2.csv"))

#####################################
HTMLconvert <- FALSE # Booleen pour verifier si on peut faire la conversion avec le programme d'Emmanuel 
#####################################

############################################################################################################

FichierErreurs <- read.table("www/codes_erreur.2023-05-18_EC.txt", header = TRUE, sep = "\t", fill = TRUE)

shinyServer(function(input, output, session){

    values <- reactiveValues()
	
		FilePath <- reactive({
			input$file$datapath
		})
	
	
		output$email <- renderUI({
			tagList(a(
				h5("Contacter les développeurs pour vos demandes au sujet de SARP.moodle."), 
				href = "mailto:sarp.moodle@listes.u-paris.fr")
			)
		})
	
	
# Ce code utilise la fonction `observeEvent()` pour détecter le déclenchement de l'événement "Start" et mettre à jour l'onglet "Conversion" en utilisant la fonction `updateTabItems()`.
		observeEvent(input$convertButton, {
			if (!is.null(FilePath())) {
				updateTabItems(session, "tabs", "Base")
			}
		})
	
	# observeEvent(values[["xml"]], {
	#	 cat(! is.null(values[["xml"]]))
	#	 if (! is.null(values[["xml"]])) {
	#		 enable("downloadSolution")
	#	 } else {
	#		 disable("downloadSolution")
	#	 }
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
		
		observe({
		    options("Sm.temps_couleur" = as.character(input$temps_couleur), "Sm.temps_masque" = paste(input$temps_masque), "Sm.arrondi_couleur" = input$numerique_color)
		})
	
		getXML <- function(){
		
			extension <- tools::file_ext(input$file$datapath)
				file <- "temp.xml"
				if(input$ImagesQuestion == TRUE){
					FileRep <- gsub("0\\.[a-zA-Z]+$", "", input$file$datapath) # recupere le dossier du fichier de question
					img_list <- selected_images()
					if(length(img_list) != 0)
						sapply(img_list, function(x) system(paste0("cp ", x$datapath, " ", FileRep, x$name)))
				        # petit exemple de copie d'une image ds les dossiers temporaires de shiny cp /tmp/Rtmp/93748hjkf/0.jpeg /tmp/Rtmp/98e3jfku6/iris.jpeg
							if(extension == "csv"){
								msgErr <- try(conv <-
																csv.moodle(
																	fichier.csv = input$file$datapath, 
																	fichier.xml = file,
																	sep.images = if ("Image" %in% input$conversion) c('@@', '@@') else NULL,
																	dossier.images = FileRep,
																	n.decimales = input$decimales,
																	tolerance = input$tolerance_arrondis
																)
								)
							} else if(extension == "xlsx"){
								msgErr <- try(conv <-
																xlsx.moodle(
																	fichier.xlsx = input$file$datapath, 
																	fichier.xml = file,
																	sep.images = if ("Image" %in% input$conversion) c('@@', '@@') else NULL,
																	dossier.images = FileRep,
																	n.decimales = input$decimales,
																	tolerance = input$tolerance_arrondis
																)
								)
							} else if(extension == "ods"){
								msgErr <- try(conv <-
																ods.moodle(
																	fichier.csv = input$file$datapath, 
																	fichier.xml = file,
																	sep.images = if ("Image" %in% input$conversion) c('@@', '@@') else NULL,
																	dossier.images = FileRep,
																	n.decimales = input$decimales,
																	tolerance = input$tolerance_arrondis
																)
								)
							}
					} else {
						cat(paste("########################", extension, "######################\n\n\n"))
						
						if(extension == "csv"){
							msgErr <- try(conv <-
															csv.moodle(
																fichier.csv = input$file$datapath, 
																fichier.xml = file,
																n.decimales = input$decimales,
																tolerance = input$tolerance_arrondis
															)
							)
						} else if(extension == "xlsx"){
							msgErr <- try(conv <-
															xlsx.moodle(
																fichier.xlsx = input$file$datapath, 
																fichier.xml = file,
																n.decimales = input$decimales,
																tolerance = input$tolerance_arrondis
															)
							)
						} else if(extension == "ods"){
							msgErr <- try(conv <-
															ods.moodle(
																fichier.ods = input$file$datapath, 
																fichier.xml = file,
																n.decimales = input$decimales,
																tolerance = input$tolerance_arrondis
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
												label = HTML('Importez votre fichier de questions préparé en suivant le gabarit (xlsx, csv, ods).<br><br><i>Vous pouvez trouver des exemples de gabarits pour créer vos questions dans la rubrique "aide et ressources".</i>'), 
												buttonLabel = HTML(paste(icon("upload"), "Parcourir")),
												placeholder = "Aucun fichier importé pour l'instant ...",
												width = "100%",
												accept = c(".csv", ".ods", ".xlsx")
												
							),
							icon = icon("file-excel"),
							fill = TRUE, 
							color = "blue", 
							width = 12
			)
		})
		
		
		output$convertButtonUI <- renderUI({
			req(input$file)	# Cette ligne assure que le fichier est importé
			fluidRow(
				column(12, align = "center",
							 div(
								 style = "margin-top: 20px;",
								 actionButton("convertButton", "Convertir", icon = icon("refresh"), style = "color: white;", class = "btn-lg btn-primary")
							 )
				)
			)
		})
	 
		output$filePreview <- renderDataTable({
			req(input$file)
			file <- input$file
			ext <- tools::file_ext(file$datapath)

			df <- switch(ext,
									 csv = fread(file$datapath, data.table = FALSE),
									 xlsx = read_excel(file$datapath),
									 ods = read_ods(file$datapath),
									 validate("Fichier invalide; Veuillez télécharger un fichier .csv, .xlsx, or .ods")
			)

			# Vérifier si la colonne "temps" existe
			if(!"Temps" %in% colnames(df)) {
			# Message alerte pour dire qu'il n'y a pas de colonne "temps" dans le fichier importé
				shinyalert(
					title = "Conseil pédagogique",
					text = 'Le fichier de questions importé ne comporte pas de colonne "temps" pour associer un temps conseillé aux questions.',
					type = "warning"
				)
			} else {
				shinyalert(
					text = 'Votre fichier de questions a bien été importé.',
					type = "success"
				)
			}
			datatable(
				df,
				options = list(
					pageLength = 5,
					language = list(
						url = '//cdn.datatables.net/plug-ins/1.10.21/i18n/French.json'
					)
				)
			)

		})
		
		####################################

		# getPreview <- function(){
		#	 if {
		#		 return(df)
		#	 } else {
		#		 return(NULL)
		#	 }
		# }
		# 
		# output$CheckTemps <- render ({
		#	 df <- getPreview()
		#	 colmnames(df)
		# })
		# #################	Code pour afficher un apercu du gabarit mais ne fonctionne pas	############################
		# output$preview <- DT::renderDataTable({
		#	 req(input$file)	# S'assurer qu'un fichier est sélectionné
		#	 
		#	 # Chemin vers le fichier téléchargé
		#	 filepath <- input$file$datapath
		#	 
		#	 # Vérification du type de fichier
		#	 if (grepl("\\.csv$", input$file$name, ignore.case = TRUE)) {
		#		 data <- read.csv(filepath)
		#	 } else if (grepl("\\.xlsx$|\\.xls$", input$file$name, ignore.case = TRUE)) {
		#		 data <- readxl::read_excel(filepath)
		#	 } else if (grepl("\\.ods$", input$file$name, ignore.case = TRUE)) {
		#		 data <- readxl::read_ods(filepath)
		#	 } else {
		#		 return(NULL)	# Fichier non pris en charge
		#	 }
		#	 
		#	 # Afficher l'aperçu des données
		#	 DT::datatable(head(data, 10))
		# })
		
		######################################################################################################################
		
		#Ce code crée une boîte contenant un élément d'entrée de fichier "fileInput" permettant aux utilisateurs de sélectionner des images en format PNG, JPEG ou JPG, qui seront utilisées pour créer une base de questions. La boîte n'est rendue que si l'option "ImagesQuestion" est activée et elle est stylisée avec un titre, un fond solide de couleur primaire et une largeur de 12.
		
		#######" test images
		
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
										placeholder = "Aucune image importée pour l'instant ...",
					),
					hr(),
					h4("Images sélectionnées :"),
					uiOutput("selected_images_bilan"),
					uiOutput("validate_button_ui")
				)
			)
		})
		
	selected_images <- reactiveVal(list()) # Initialisation de la liste d'images
	is_validated <- reactiveVal(FALSE)
	
	# Importation de nouvelles images
	observeEvent(input$images, {
	    images <- selected_images() # On recupere la liste d'images importées
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
	
	# Affichage des vignettes + cases à cocher d'images
	output$selected_images_bilan <- renderUI({
		if(input$ImagesQuestion == FALSE)
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
	
	# Afficher les images selectionnées
	observeEvent(input$validate_images, { # Si input$validate_images est cliqué, ça execute le code entre accolades
		selected <- reactiveVal(NULL)
		img_list <- selected_images()
	 	observe({
	 		input_list <- lapply(names(img_list), function(name) input[[paste0("select_", name)]]) # input_list ne contient que les images selectionnees.
	 		selected(names(img_list)[unlist(input_list)])
	 		img_list_updated <- img_list[unlist(input_list)]
	 		if(length(img_list_updated) != length(img_list))
	 		    selected_images(img_list_updated)
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
	 	if(input$ImagesQuestion == FALSE)
			return(NULL)
	
		actionButton("validate_images", "Vérifier les images sélectionnées",style = "color: white;", class = "btn-primary")
	})
	
	
	# observe({
	# 	img_list <- selected_images()
	# 	lapply(names(img_list), function(name) {
	# 		observeEvent(input[[paste0("delete_", name, "_btn")]], {
	# 			images <- selected_images()
	# 			images[[name]] <- NULL
	# 			# images <- images[-which(names(images) == name)]
	# 			selected_images(images)
	# 		})
	# 	})
	# })
	
	output$has_images <- reactive({
		length(selected_images()) > 0
	})
	outputOptions(output, "has_images", suspendWhenHidden = FALSE)
	
	
	
	
	# #### NV images
	# 	output$ImageBox <- renderUI({
	# 				if(input$ImagesQuestion == FALSE)
	# 					return(NULL)
	# 	selected_images <- reactiveVal(list())
	# 	is_validated <- reactiveVal(FALSE)
	# 
	# 	observeEvent(input$images, {
	# 		# if (is_validated()) return()
	# 		# Si on observe un nouvel usage de "fileInput"
	# 
	# 		images <- selected_images()# Recuperation des images importees jusque la
	# 		new_images <- lapply(seq_along(input$images$name), function(i) {# lapply: permet de faire une boucle for
	# 			list(
	# 				name = input$images$name[i],
	# 				datapath = input$images$datapath[i],
	# 				data = base64enc::dataURI(file = input$images$datapath[i], mime = input$images$type[i])
	# 			)
	# 		})
	# 		# for (i in seq_along(input$images$name)){ # seq_along(input$images$name) un vecteur avec les indices des images selectionnees 1:nbImages. Autre facon de le faire 1:length(input$images$name)
	# 		#		list( # on cree une liste avec 2 elements
	# 		#				name = input$images$name[i], # 1er element nom de l'image i
	# 		#				datapath = input$images$datapath[i] # 2eme element chemin de l'image i
	# 		#	 )
	# 		# }
	# 		names(new_images) <- input$images$name # renommer les elements de la liste avec les noms des images
	# 		# Vérification des doublons
	# 		duplicate_names <- names(selected_images())[names(selected_images()) %in% input$images$name]
	# 		if (length(duplicate_names) > 0) {
	# 			showModal(modalDialog(
	# 				title = "Attention",
	# 				paste("Les images suivantes ont été sélectionnées plusieurs fois :", paste(duplicate_names, collapse = ", ")),
	# 				footer = tagList(modalButton("Fermer"))
	# 			))
	# 		} else {
	# 			images <- c(images, new_images)# concatene anciennes images et nouvelles. images est une liste de taille egale aux nombres d'images importees depuis le debut (anciennes + nouvelles) et avec chaque element qui est une liste de 2 elements name et datapath.
	# 			selected_images(images)# Mise a jour de la liste d'images
	# 		}
	# 	})
	# 
	# 	output$selected_images_bilan <- renderUI({# Renvoit un element du UI (user interface)
	# 		if(input$ImagesQuestion == "FALSE")
	# 			 return(NULL)
	# 
	# 		img_list <- selected_images()# Recuperation des images importees jusque la
	# 
	# 		# tagList(
	# 		#	 lapply(names(img_list), function(name) {# Une boucle for pour chaque element de names(img_list), donc pour chaque nom d'image
	# 		#		 tags$div(
	# 		#			 style = "display: flex; align-items: center;",
	# 		#			 tags$img(src = img_list[[name]]$data, class = "image-preview"),
	# 		#			 tags$span(h5(name), style = "margin-left: 10px;")
	# 		#		 )
	# 		#	 })
	# 		# )
	# 		tagList(
	# 			lapply(names(img_list), function(name) {
	# 				tags$div(
	# 					style = "display: flex; align-items: center;",
	# 					checkboxInput(inputId = paste0("select_", name), label = NULL, value = TRUE),
	# 					tags$img(src = img_list[[name]]$data, class = "image-preview"),
	# 					tags$span(h5(name), style = "margin-left: 10px;")
	# 				)
	# 			})
	# 		)
	# 		# if (is_validated()) { # si jamais on veut arreter de pouvoir cocher les boites des images on peut utiliser cette condition
	# 		#
	# 		# }
	# 	})
	# 
	# 	observeEvent(input$validate_images, { # si on observe un click sur bouton valider les images
	# 		# Bloc suivant permet de mettre a jour la liste d'images quand on decoche cases
	# 		selected <- reactiveVal(NULL)# Crée une reactiveVal pour stocker les images sélectionnées
	# 		observe({
	# 			# Liste des valeurs de toutes les cases à cocher correspondant à chaque image sélectionnée
	# 			input_list <- lapply(names(selected_images()), function(name) input[[paste0("select_", name)]])
	# 			# Sélectionne les noms des images pour lesquelles les cases à cocher sont cochées
	# 			selected(names(selected_images())[unlist(input_list)])
	# 		})
	# 
	# 		is_validated(TRUE)
	# 		# Affiche une boîte de dialogue modale contenant les images sélectionnées
	# 		showModal(modalDialog(
	# 			title = "Images validées",
	# 			renderText({
	# 				selected_count <- length(selected())
	# 				if (selected_count == 1) {
	# 					paste("Vous avez importer l'image suivante :", selected())
	# 				} else {
	# 					paste("Vous avez importer les", selected_count, "images suivantes :", paste(selected(), collapse = ", "))
	# 				}
	# 			}),
	# 			footer = tagList(modalButton("Fermer")),
	# 			easyClose = TRUE
	# 		))
	# 	})
	# 
	# 
	# 	output$validate_button_ui <- renderUI({
	# 		if(input$ImagesQuestion == "FALSE")
	# 			return(NULL)
	# 
	# 		#if (!is_validated()) { # utiliser ça si on veut enlever le bouton une fois que c'est validé
	# 		actionButton("validate_images", "Valider les images")
	# 		#}
	# 	})
	# 
	# 
	# 	observe({
	# 		img_list <- selected_images()# Recuperation des images importees jusque la
	# 		lapply(names(img_list), function(name) {# Boucle for pour chaque image
	# 			observeEvent(input[[paste0("delete_", name, "_btn")]], {
	# 				images <- selected_images()
	# 				images[[name]] <- NULL
	# 				# imagesUpdated <- images[names(images) != name]
	# 				# Probleme pour reimporter une image deja supprimee ds input[[paste0("delete_", name, "_btn")]]
	# 				selected_images(images)
	# 			})
	# 		})
	# 	})
	# 	# Fonction pour vérifier s'il y a des images sélectionnées
	# 	output$has_images <- reactive({
	# 		length(selected_images()) > 0
	# 	})
	# 	outputOptions(output, "has_images", suspendWhenHidden = FALSE)
	# 
	# 	})
	
	
	
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
	#	 			status = "primary",
	#	 			width = 12
	#	 		)
	# 	})
	
	
	
	# Ce code génère une boîte de dialogue qui permet à l'utilisateur de sélectionner les conversions automatiques qu'il souhaite activer pour les images, les formules mathématiques et les codes SMILES, si l'option "ImagesQuestion" est activée dans l'application R Shiny.
	
	output$ImageInfo <- renderUI({
		box(
			title = "Paramètres avancés",
				div(
					HTML("<i>Sélectionnez les paramètres pour la conversion de votre fichier de questions.</i>"),
					style = "margin-bottom: 10px;"
				),
				# checkboxGroupInput(
				#	 inputId = "conversion",
				#	 label = "",
				#	 selected = c('Latex', 'Smiles'),
				#	 choiceNames = list(
				#		 "Formules mathématiques",
				#		 "Codes SMILES"
				#	 ),
				#	 choiceValues = list(
				#		 "Image",
				#		 "Latex",
				#		 "Smiles"
				#	 ), 
					# inline = TRUE
				# ),
			#(%T sera remplacé par le temps indiqué dans la colonne temps de votre fichier de questions) -> pour le moment on ne sait pas changer de place le temps
			textInput("temps_masque", 'Si la colonne "temps" de votre fichier de questions est renseignée, le texte du message sur le temps conseillé pour répondre à la question est par défaut (où #T est le temps renseigné dans votre fichier) :', value = "Temps conseillé pour répondre : <b>#T</b>"),
			colourInput("temps_couleur", 'Si la colonne "temps" de votre fichier de questions est renseignée, la couleur du message sur le temps conseillé pour chaque question est par défaut en bleu. Cliquez sur la zone bleue pour choisir une autre couleur.', value = "#0000FF"), 
			colourInput("numerique_color", "Si votre fichier de questions contient des questions de type numérique, la couleur du message sur la précision est par défaut en orange. Cliquez sur la zone orange pour choisir une autre couleur.", value = "orange"),
			# Ajout du sélecteur de couleurs
				# numericInput("decimales", "Tolérance des decimales", value = 0, min = 0),
				# numericInput("tolerance_arrondis", "Tolérance des arrondis", value = 0, min = 0, step = 0.1),
			textInput("default_category", "Catégorie par défaut des questions sur Moodle si la catégorie n'est pas renseignée dans le fichier de questions", value = ""),
				solidHeader = TRUE,
				status = "primary",
				color = "blue",
				width = 12,
				collapsible = TRUE,
				collapsed = TRUE
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
				# https://daattali.com/shiny/shinyalert-demo/	
			} else {
				# creation d'un html à partir du xml
				if(HTMLconvert){
					system("imprime_Moodle temp.xml") # creation de temp.html
					system("mkdir .TMP/; mv temp.html .TMP/.") # creation de temp.html
					if(file.exists("img_*"))
						system("mv img_* .TMP/.") # creation de temp.html
				}
			}
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
				    ifelse(HTMLconvert, shiny::includeCSS("www/impression.css"), "Programme de conversion XML -> HTML pas installé"),
					ifelse(HTMLconvert, shiny::includeHTML(".TMP/temp.html"), ""),
					solidHeader = TRUE,
					status = "success",
					width = 12,
					collapsible = TRUE,
					collapsed = FALSE,
				)
			)
		} 
	})
	
	output$downloadSolution <- downloadHandler(
		filename = function() {
			as.character(paste0("BaseQuestionsMoodle_", format(Sys.Date(), "%d-%m-%Y", locale = "French_France"), ".xml"))
		},
		content = function(file) {
			if(file.exists("temp.xml")){
				file.copy("temp.xml", file)
				if(file.exists(".TMP")) system("rm -r .TMP")
			}
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