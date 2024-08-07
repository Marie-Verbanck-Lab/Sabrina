#Librairies
library(shiny)
library(shinydashboard)
library(base64enc)
library(openxlsx)
library(SARP.moodle)
library(data.table)
library(readxl)
library(readODS)
library(SARP.moodle)
library(fresh)
library(base64enc)
library(DT)
library(shinyalert)
library(colourpicker)

#####################################################################################

# devtools::install_github("Marie-Verbanck-Lab/Sabrina/SARP.moodle") 
# setwd("/home/sabrina/Documents/ShinyMoodle")
# rsconnect::setAccountInfo(name="verbam01", token="83EE1187C6F7C3597C9DCB26703A8516", secret="3rN95pQ5s3/24ELui7eEeV/yM1zqP2k4X6kLZ9Dc") ; rsconnect::deployApp(account = "verbam01", appDir = "MoodleBaseQuestions")

#####################################################################################

linebreaks <- function(n){HTML(strrep(br(), n))}
#Permet de changer les couleurs 
mytheme <- create_theme(
	adminlte_color(
		purple = "#8A1538",
		aqua = "#8A1538",
		light_blue = "#005c93",
		blue= "#005c93"
	),
	adminlte_sidebar(
		width = "400px",
		dark_bg = "#8A1538",
		dark_hover_bg = "#CC3333",
		dark_color = "#FFFFFF"
	),
	adminlte_global(
		content_bg = "#FFF",
		box_bg = "#FFFFFF", 
		info_box_bg = "#F3F1F1"
	)
)

# Couleurs shiny https://rstudio.github.io/shinydashboard/appearance.html#statuses-and-colors

shinyUI(
	dashboardPage(skin = "purple",
		############################# Header ##############################
		dashboardHeader(
			title = "SARP.moodle",
			tags$li(a(href = 'https://biostm.u-paris.fr/',
				img(src = "UniversiteParisCite_Pharmacie.jpg", height = "79px", width = "250px"),
				img(src = 'logo-BioSTM.png', height = "80px", width = "80px"),
				style = "padding-top:10px; padding-bottom:10px;"),
				class = "dropdown",
				# Code pour fixer le header
				tags$style(HTML("
					.main-header {
						position: fixed;
						width: 100%;
						z-index: 1000;
					}
					.content-wrapper, .right-side {
						margin-top: 100px; 
					}
				"))
			),
			dropdownMenuOutput("messageMenu")
		),
		############################# Sidebar ##############################
		#Créer les onglets
		dashboardSidebar(
			collapsed = FALSE,
			tags$style(HTML("
				.main-sidebar {
					position: fixed;
					overflow: visible;
				}
				.content-wrapper, .right-side {
					margin-left: 400px;
				}
			")),
			linebreaks(3),
			sidebarMenu(
				id = "tabs",
				menuItem("Convertir son fichier de questions",
					tabName = "Convertir",
					icon = icon("gears")
				),
				menuItem("Récupérer son fichier de questions",
					tabName = "Base",
					icon = icon("graduation-cap")
				),
				menuItem("Aide et ressources",
					tabName = "Aide",
					icon = icon("info")
				)
			),
			# Insérer les logos
			linebreaks(18),
			tags$div(
				style = "padding: 100px;",
				tags$img(src = "UniversiteParisCite_idex.jpeg", height = "90px", width = "90px"),
				tags$img(src = "Logo_investir_lavenir.png", height = "90px", width = "90px")
			)
		),
		############################# Body ##############################

		dashboardBody(
			use_theme(mytheme),
			useShinyalert(),
			tabItems(
				######################################################################################################################
				##########################################  Onglet 2: Récupérer son fichier de qst  ###################################
				tabItem(tabName = "Base",
					fluidRow(
						column(
							width = 12,
							align = "center",
							actionButton("retourButton", "Retour vers l'onglet de conversion", icon = icon("refresh"), style = "color: white;", class = "btn-lg btn-primary")
						)
					),
					linebreaks(3),
					fluidRow(
						uiOutput("downloadButton")
					),
					fluidRow(
						uiOutput("WARNINGSbox")
					)
				),
				#######################################################################################################################
				##########################################  Onglet 1: Convertir son fichier de qst  ################################### 					
				tabItem(tabName = "Convertir",
					fluidRow(
						box(
							title = "Charte graphique des couleurs",
							solidHeader = TRUE,
							status = "info",
							width = 12,
							HTML("
								<p>Voici la charte graphique des couleurs pour vous guider :</p>
					  			<ul>
					  			<li><span style='color: #8A1538;'><b>Bordeaux :</b></span> fournit une information</li>
								<li><span style='color: #005c93;'><b>Bleu :</b></span> nécessite une action de votre part</li>
								<li><span style='color: green;'><b>Vert :</b></span> fournit un retour de l’application</li>
								<li><span style='color: red;'><b>Rouge :</b></span> prévient d’une erreur</li>
								</ul>
							")
						)
					),
					fluidRow(
						uiOutput("FileBox"),
						column(12, DTOutput("filePreview"))
					),
					################ Importation des images
					#### NV images
					linebreaks(2),
					fluidRow(
						tags$head(tags$style(HTML("
							.image-preview {
								width: 50px;
								height: 50px;
								object-fit: cover;
								margin-right: 10px;
							}
							.image-container {
								display: flex;
								align-items: center;
								margin-bottom: 10px;
							}
							.image-label {
								margin-left: 10px;
							}
							.image-selector-container {
								width: 100%; /* Définissez la largeur souhaitée */
								max-width: 400px; /* Ajustez la largeur en fonction des autres boîtes */
								margin: 0 auto; /* Centrez la boîte horizontalement */
							}
						"))),
						infoBox(
							"", 
							"Utilisez-vous des images ?",
							radioButtons(
								"ImagesQuestion", 
								label = "", 
								choices = list("Non" = FALSE, "Oui" = TRUE), 
								inline = TRUE, 
								selected = FALSE
							),
							icon = icon("images"),
							fill = TRUE,
							color = "blue",
							width = 12
						)
					),
					# fluidRow( ca ne sert pas
					#div(class = "image-selector-container", uiOutput("image_selector_ui")) ca ne sert pas
					uiOutput("image_selector_ui"),
					#),
						
					fluidRow(
						uiOutput("ImageBox"),
						uiOutput("ImageInfo")
					),
						
					#### Boutton convertir Tout l'ensemble de ce qu'on a importer							
					linebreaks(3),
					uiOutput("convertButtonUI")
					# fluidRow(
					# 	column(12, align = "center", 
					# 		div(
					# 			style = "margin-top: 20px;",
					# 			actionButton("convertButton", "Convertir", icon = icon("refresh"), style = "color: white;", class = "btn-lg btn-primary")
					# 		)
					# 	)
					# )
				),
				
				
				################################################
				###############################################
				
				
				
				#######################################################################################################################
				##########################################  Onglet 3: Aide et ressources  #############################################
				tabItem(tabName = "Aide",
				  # Ajout du contenu du fichier HTML onglet aide ressources
				  fluidRow(
				    column(
				      width = 12,
				      tags$div(
				        style = "max-width: 1200px; margin: auto;",
				        includeHTML("www/ideesFilConducteurAide.html")
				      )
				    )
				  ),
					fluidRow(
			  			infoBox("Structurer le fichier de questions", "Vous pouvez télécharger l'un des fichiers ci-joint, qui sont des fichiers de base selon le type de questions que vous souhaîtez créer. Complétez le fichier que vous avez télécharger pour vos propres questions, et utilisez le pour la conversion en XML.",
						icon = icon("stapler"),
						color = "purple",
						width = 12
				  		),
				  		#Pas tt à fait fonctionnel
				  		#mainPanel(
				  		# Votre contenu principal ici
				  		box("",
							downloadButton("downloadTemplate", "Télécharger le fichier xlsx de votre choix"),
							downloadButton("downloadTemplate2", "Télécharger le fichier QCU contenant un exemple"), #pas fonctionnel pour le moment
							downloadButton("downloadTemplate3", "Télécharger le fichier QCM contenant un exemple"), #pas fonctionnel pour le moment
							downloadButton("downloadTemplate4", "Télécharger le fichier image contenant un exemple"), #pas fonctionnel pour le moment
							downloadButton("downloadTemplate5", "Télécharger le fichier SMILES contenant un exemple"), #pas fonctionnel pour le moment
							icon = icon("stapler"),
							color = "purple",
							width = 12
				  		),
						infoBox("intégrer le xml sur moodle",
							HTML("
								1.Connectez-vous à votre site Moodle en tant qu'administrateur ou enseignant disposant des droits nécessaires pour créer un cours ou une activité.<br/><br/>
								2.Accédez à la section du cours où vous souhaitez intégrer le fichier XML. Si vous créez un nouveau cours, créez d'abord le cours lui-même.<br/><br/>
								3.Cliquez sur le bouton 'ajouter une bande de questions' dans la section où vous souhaitez intégrer le fichier XML. Cela ouvrira la page 'importer le fichier sur moodle'."
							),
							icon = icon("m"),
							color = "purple",
							width = 12
						),
						align = "center"
					),
					########### Boite mail
					fluidRow(
						infoBox(title = "Information",
							uiOutput("email"),
							icon = icon("envelope"),
					  		fill = TRUE,
					  		color = "purple",
					  		width = 12
			  			),
					),   
				)
			)
		)
	)
)