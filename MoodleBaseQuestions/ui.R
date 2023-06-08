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
		          img(src = 'Logo-BioSTM.png', height = "60px", width = "60px"),
		          style = "padding-top:10px; padding-bottom:10px;"),
		        class = "dropdown"),
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
			),
			menuItem("Aide",
			         tabName = "Aide", 
			         icon = icon("circle-info")
			)
			
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
					valueBox("SARP moodle", "Bienvenue dans l'assistant SARP moodle. Cet assistant vous permet à partir d'un simple fichier Excel, Ods, ou Csv de récupérer un fichier XML que vous pourrez importer sur moodle pour en faire une base de questions.", 
						icon = icon("info"),
						color = "purple", 
						width = 12
  				)
  			),
  			fluidRow(	
  				infoBox("En entrée : un fichier excel", "Préparez votre fichier (xlsx, ods, csv) comportant toutes les questions de votre future base selon le modèle.", 
						icon = icon("file-excel"),
						color = "purple", 
						width = 12
  				),
					infoBox("En entrée : des fichiers d'images", "Préparez tous vos fichiers images (jpeg, jpg, png) utilisées dans votre base de question.", 
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
			          infoBox("Structurer le fichier de questions", "......",
			                  icon = icon("stapler"),
			                  color = "purple", 
			                  width = 12
			          ),
			          infoBox("intégrer le xml sur moodle",
			            HTML("
			              1.Connectez-vous à votre site Moodle en tant qu'administrateur ou enseignant disposant des droits nécessaires pour créer un cours ou une activité.<br/><br/>
                    2.Accédez à la section du cours où vous souhaitez intégrer le fichier XML. Si vous créez un nouveau cours, créez d'abord le cours lui-même.<br/><br/>
                    3.Cliquez sur le bouton 'Ajouter une activité ou une ressource' dans la section où vous souhaitez intégrer le fichier XML. Cela ouvrira la page 'Ajouter une activité ou une ressource'.<br/><br/>
                    4.Sur la page 'Ajouter une activité ou une ressource', sélectionnez l'option 'URL' ou 'Page externe', selon la version de Moodle que vous utilisez.<br/><br/>
                    5.Dans la section 'Contenu de la page', recherchez l'option permettant d'insérer du code HTML ou XML. Elle peut être appelée 'Éditeur HTML' ou 'Contenu HTML', ou vous pouvez voir une icône ressemblant à '</>'. Cliquez sur cette option pour ouvrir l'éditeur.<br/><br/>
                    6.Dans l'éditeur HTML, collez le contenu de votre fichier XML. Vous pouvez également utiliser l'option d'importation de fichier si elle est disponible pour importer directement le fichier XML.<br/><br/>
			              7.Enregistrez les modifications et prévisualisez la page pour vous assurer que le fichier XML est correctement intégré."
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



