library(shiny)
library(shinydashboard)
#library(xlsx)
library(openxlsx)
library(SARP.moodle)

#####################################################################################

# library(rsconnect) ; rsconnect::setAccountInfo(name='verbam01', token='06416503D2F55082582397B5BDE79501', secret='bYpuEPHs35y+ChC6ajQoui2XV9rxJTpSowPFmDan')
# deployApp(account = "verbam01", appName = "MoodleBaseQuestions", appDir = "MoodleBaseQuestions")

#####################################################################################

linebreaks <- function(n){HTML(strrep(br(), n))}

shinyUI(dashboardPage(skin = "black",
	
	dashboardHeader(
		title = "SARP moodle",
		dropdownMenuOutput("messageMenu")
	),

####################################################################
############################# Sidebar ##############################
 
	dashboardSidebar(
		collapsed = FALSE,
		sidebarMenu(
			id = "tabs",
			menuItem("Informations générales",
				tabName = "Base", 
				icon = icon("info")
			),
			menuItem("Conversion",
				tabName = "Conversion", 
				icon = icon("gears")
			)
		)
	),

################################################################
############################# Body ##############################

	dashboardBody(
		tabItems(
			tabItem(tabName = "Base",

				################ Premiere partie introductive
				linebreaks(3),
  				fluidRow(
					valueBox("SARP moodle", "Bienvenue dans l'assistant SARP moodle. Cet assistant vous permet à partir d'un simple fichier Excel de récupérer un fichier XML que vous pourrez importer sur moodle pour en faire une base de questions.", 
						icon = icon("info"),
						color = "red", 
						width = 12
  					)
  				),
  				fluidRow(	
  					infoBox("En entrée : un fichier excel", "Préparez votre fichier excel comportant toutes les questions de votre future base selon le modèle.", 
						icon = icon("file-excel"), 
						fill = TRUE, 
						color = "red", 
						width = 6
  					),
  					infoBox("En sortie", "Vous pourrez ensuite télécharger un fichier XML qui peut être directement importé dans Moodle.", 
						icon = icon("graduation-cap"), 
						fill = TRUE, 
						color = "red", 
						width = 6
  					),
  					align = "center"
  				),
  				fluidRow(
  					infoBox("En entrée : des fichiers d'images", "Préparez tous vos fichiers images (jpeg, jpg, png) utilisées dans votre base de question.", 
						icon = icon("images"), 
						fill = TRUE, 
						color = "red", 
						width = 6
  					),
  					valueBox("",
						actionButton("Start", "Commencer"),
						color = "red",
						width = 6
  					),
  					align = "center"
				)
			),
  			tabItem(tabName = "Conversion",
				################ Importation des Images
  				fluidRow(
					infoBox("", "Votre base de questions utilise-t-elle des images ?", 
						radioButtons("ImagesQuestion", label = "", choices = list("Non" = FALSE, "Oui" = TRUE), inline = TRUE, selected = TRUE),
						icon = icon("images"), 
						fill = TRUE, 
						color = "red", 
						width = 12
  					)
				),
				fluidRow(
					uiOutput("ImageBox"),
					uiOutput("ImageInfo")
				),
  				################ Importation des fichiers
  				fluidRow(
					uiOutput("FileBox"),
				),
				linebreaks(3),
  				################ Telechargement du fichier resultat
  				fluidRow(
  					uiOutput("downloadButton")
  				),
  				fluidRow(
  					uiOutput("WARNINGSbox")
  				)
			)
#################################################################################################################################			
		)
	)
))