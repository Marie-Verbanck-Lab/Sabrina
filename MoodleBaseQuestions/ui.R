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

# library(rsconnect) ; setwd("~/Documents/ShinyMoodle/") ; rsconnect::setAccountInfo(name='verbam01', token='83EE1187C6F7C3597C9DCB26703A8516', secret='3rN95pQ5s3/24ELui7eEeV/yM1zqP2k4X6kLZ9Dc') ; deployApp(account = "verbam01", appName = "MoodleBaseQuestions", appDir = "MoodleBaseQuestions")


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
		          img(src = "UniversiteParisCite_Pharmacie.jpeg", height = "70px", width = "200px"),
		          img(src = 'Logo-BioSTM.png', height = "80px", width = "80px"),
		          style = "padding-top:10px; padding-bottom:10px;"),
		        class = "dropdown"),
		dropdownMenuOutput("messageMenu")
	),
####################################################################
############################# Sidebar ##############################
 
# Créer les onglets
	dashboardSidebar(
		collapsed = FALSE,
		linebreaks(3),
		sidebarMenu(
			id = "tabs",
			menuItem("Convertir",
			         tabName = "Convertir", 
			         icon = icon("gears")
			),
			menuItem("Récupérer son fichier de questions",
				tabName = "Base", 
				icon = icon("graduation-cap")
				
			),
			menuItem("Aide",
			         tabName = "Aide", 
			         icon = icon("info")
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
				  infoBox(title = "Information",
				          uiOutput("email"),
				          icon = icon("envelope"),
				          fill = TRUE,
				          color = "purple",
				          width = 12
				  )
				  ################ Telechargement du fichier resultat
				), 
				fluidRow(
				  uiOutput("downloadButton")
				),
				fluidRow(
				  uiOutput("WARNINGSbox")
				)
			),
  			tabItem(tabName = "Convertir",
				################ Importation des Images
				fluidRow(
				  box(
				    title = "Charte Graphique des Couleurs",
				    status = "info", 
				    solidHeader = TRUE,
				    width = 10,
				    HTML("
      <p>Voici la charte Graphique des couleurs pour vous guider :</p>
      <ul>
        <li><span style='color: #8A1538;'><b>Bordeaux :</b></span> fournit une information</li>
        <li><span style='color: blue;'><b>Bleu :</b></span> nécessite une action de votre part</li>
        <li><span style='color: green;'><b>Vert :</b></span> fournit un retour de l’application</li>
        <li><span style='color: red;'><b>Rouge :</b></span> prévient d’une erreur</li>
      </ul>
    ")
				  )
				),
				
				################ Importation des fichiers
				fluidRow(
				  uiOutput("FileBox"),
				),
				linebreaks(2),
  				fluidRow(
  					infoBox("", "Votre base de questions utilise-t-elle des images ?", 
  						radioButtons("ImagesQuestion", label = "", choices = list("Non" = FALSE, "Oui" = TRUE), inline = TRUE, selected = FALSE),
  						icon = icon("images"), 
  						fill = TRUE, 
  						color = "blue", 
  						width = 12
    					)
			  	),
				  fluidRow(
					  uiOutput("ImageBox"),
					  uiOutput("ImageInfo")
				  ),
  				
				
				  linebreaks(3),
				fluidRow(
				  column(12, align = "center", 
				         div(
				           style = "margin-top: 20px;",
				           actionButton("convertButton", "Convertir", icon = icon("refresh"), style = "color: white;", class = "btn-lg btn-primary")
				         )
				  )
				  
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



