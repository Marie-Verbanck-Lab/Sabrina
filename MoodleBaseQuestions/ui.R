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
#####################################################################################

# library(rsconnect) ; rsconnect::setAccountInfo(name='verbam01', token='06416503D2F55082582397B5BDE79501', secret='bYpuEPHs35y+ChC6ajQoui2XV9rxJTpSowPFmDan')
# deployApp(account = "verbam01", appName = "MoodleBaseQuestions", appDir = "MoodleBaseQuestions")

#####################################
linebreaks <- function(n){HTML(strrep(br(), n))}
#Permet de changer les couleurs 
mytheme <- create_theme(
  adminlte_color(
    purple = "#8A1538"
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


shinyUI(


  #####################################################################################
  
  dashboardPage(skin = "purple",
	dashboardHeader(
		title = "SARP moodle",
		tags$li(a(href = 'https://biostm.u-paris.fr/',
		          img(src = "UniversiteParisCite_Pharmacie.jpeg", height = "50px", width = "150px"),
		          img(src = 'Logo-BioSTM.png', height = "60px", width = "60px"),
		          style = "padding-top:10px; padding-bottom:10px;"),
		        class = "dropdown"),
		dropdownMenuOutput("messageMenu")
	),
####################################################################
############################# Sidebar ##############################
 
# Créer les onglets
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
			),
			menuItem("Aide",
			         tabName = "Aide", 
			         icon = icon("circle-info")
			)
# Insérer les logos
		),
		linebreaks(25),
		tags$div(
		  style = "padding: 100px;",
		  tags$img(src = "UniversiteParisCite_idex.jpeg", height = "90px", width = "90px"),
		  tags$img(src = "Logo_investir_lavenir.png", height = "90px", width = "90px")
		)
		
		
	),

################################################################
############################# Body ##############################

	dashboardBody(
	  use_theme(mytheme),
		tabItems(
			tabItem(tabName = "Base",

				################ Premiere partie introductive
				
				fluidRow(
				  img(src = "UniversiteParisCite_Pharmacie.jpeg", height = "157px", width = "500px"),
				),
				linebreaks(1),
				fluidRow(
					valueBox("SARP moodle", "Bienvenue dans l'assistant SARP.Moodle qui, à partir d’un gabarit au format csv, xlsx ou ods, convertit votre base de questions en fichier XML que vous pourrez ensuite importer sur Moodle. Si vous utilisez des images, vous pourrez aussi les intégrer.", 
						icon = icon("info"),
						color = "purple", 
						width = 12
  				)
  			),
  			fluidRow(	
  				infoBox("En entrée : un fichier excel", "Préparez votre fichier (csv, xlsx, ods) comportant toutes les questions de votre future base selon le modèle.", 
						icon = icon("file-excel"),
						color = "purple", 
						width = 12
  				),
					infoBox("En entrée : des fichiers d'images", "Préparez tous vos fichiers images utilisées dans votre base de question.", 
						icon = icon("images"),
						color = "purple", 
						width = 12
					),
  			  infoBox("En sortie", "Vous pourrez ensuite télécharger un fichier XML qui peut être directement importé dans Moodle.", 
  				  icon = icon("graduation-cap"),
  				  color = "purple", 
  				  width = 12
  			  ),
  			  align = "center"
  			),
				fluidRow(
				  column(3),
				  column(6, align = "center",
  				valueBox("",
						actionButton("Start", "Commencer"),
						color = "black",
						width = 12
  				),
  				column(3),
				  )
				),
				fluidRow(
				  infoBox(title = "Information",
				          uiOutput("email"),
				          icon = icon("envelope"),
				          fill = TRUE,
				          color = "purple",
				          width = 12
				  )
				), 
			),
  			tabItem(tabName = "Conversion",
				################ Importation des Images
  				fluidRow(
  					infoBox("", "Votre base de questions utilise-t-elle des images ?", 
  						radioButtons("ImagesQuestion", label = "", choices = list("Non" = FALSE, "Oui" = TRUE), inline = TRUE, selected = FALSE),
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
			),
			tabItem(tabName = "Aide",
			        
			        
			        fluidRow(	
			          infoBox("Structurer le fichier de questions", "Vous pouvez télécharger le fichier ci-joint, qui est un fichier de base. Je vous demande de le compléter avec vos propres questions, et de l'utiliser pour la conversion en XML.",
			                  icon = icon("stapler"),
			                  color = "purple", 
			                  width = 12
			          ),
			          #Pas tt à fait fonctionnel
			          #mainPanel(
			            # Votre contenu principal ici
			          infoBox("Gabarit", 
			             downloadButton("downloadTemplate", "Télécharger le fichier CSV"),
			             icon = icon("stapler"),
			             color = "purple", 
			             width = 12
			          ),
			          #),
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
			        )
			     
			)
#################################################################################################################################			
		)
	)
))



