library(shiny)
library(shinydashboard)
#library(xlsx)
library(openxlsx)
library(SARP.moodle)
library(fresh)
#####################################################################################

# library(rsconnect) ; rsconnect::setAccountInfo(name='verbam01', token='06416503D2F55082582397B5BDE79501', secret='bYpuEPHs35y+ChC6ajQoui2XV9rxJTpSowPFmDan')
# deployApp(account = "verbam01", appName = "MoodleBaseQuestions", appDir = "MoodleBaseQuestions")

#####################################
linebreaks <- function(n){HTML(strrep(br(), n))}

mytheme <- create_theme(
  adminlte_color(
    purple = "#8A1538"
  ),
  adminlte_sidebar(
    width = "400px",
    dark_bg = "#8A1538",
    dark_hover_bg = "#CC6666",
    dark_color = "#2E3440"
  ),
  adminlte_global(
    content_bg = "#FFF",
    box_bg = "#FFFFFF", 
    info_box_bg = "#F3F1F1"
  )
)


shinyUI(

  
  
  #####################################################################################
  

  dashboardPage(skin = "purple",
	dashboardHeader(
		title = "SARP moodle",
		tags$li(class = "dropdown",
		        tags$a(href = "#", class = "dropdown-toggle", `data-toggle` = "dropdown",
		               tags$img(src = "Logo BioSTM.png", height = "60px", width = "80px"))
		       
		),
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
			
		),
		tags$div(
		  style = "padding: 100px;",
		  tags$img(src = "UniversiteParisCite_idex.jpeg", height = "150px", width = "150px"),
		  tags$img(src = "Logo_investir_lavenir.png", height = "150px", width = "150px")
		)
		
		
	),

################################################################
############################# Body ##############################

	dashboardBody(
	  fluidRow(
	    column(width = 3,
	           img(src = "UniversiteParisCite_Pharmacie.jpeg", height = "157px", width = "500px")
	    )
	  ),
  
	  use_theme(mytheme),
		tabItems(
			tabItem(tabName = "Base",

				################ Premiere partie introductive
				linebreaks(3),
  				fluidRow(
  				  column(width = 6, align = "center",
  				         imageOutput("picture")
  				  ),
  			
					valueBox("SARP moodle", "Bienvenue dans l'assistant SARP moodle. Cet assistant vous permet à partir d'un simple fichier Excel, Ods, ou Csv de récupérer un fichier XML que vous pourrez importer sur moodle pour en faire une base de questions.", 
						icon = icon("info"),
						color = "purple", 
						width = 10
  					)
  				),
  				fluidRow(	
  					infoBox("En entrée : un fichier excel", "Préparez votre fichier (xlsx, ods, csv) comportant toutes les questions de votre future base selon le modèle.", 
						icon = icon("file-excel"),
						color = "purple", 
						width = 10
  					),
						infoBox("En entrée : des fichiers d'images", "Préparez tous vos fichiers images (jpeg, jpg, png) utilisées dans votre base de question.", 
						icon = icon("images"),
						color = "purple", 
						width = 10
						),
  					align = "center"
  				),
  				fluidRow(
  				  infoBox("En sortie", "Vous pourrez ensuite télécharger un fichier XML qui peut être directement importé dans Moodle.", 
  				  icon = icon("graduation-cap"),
  				  color = "purple", 
  				  width = 10
  				  ),
  					valueBox("",
						actionButton("Start", "Commencer"),
						color = "black",
						width = 3
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
						color = "purple", 
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



