library(shiny)

ui <- fluidPage(
  uiOutput("FileBox"),
  uiOutput("convertButtonUI")
)

server <- function(input, output, session) {
  # UI pour le champ d'importation de fichier
  output$FileBox <- renderUI({
    infoBox(
      title = "",
      fileInput(
        "file",
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
  
  # Réactif pour suivre l'importation de fichier
  fileUploaded <- reactive({
    !is.null(input$file)
  })
  
  # UI pour le bouton, affiché uniquement si un fichier est importé
  output$convertButtonUI <- renderUI({
    
    #if(is.null(input$file))
    #  retrun(NULL)
    
    req(fileUploaded()) # Affiche le bouton seulement si un fichier est importé
    linebreaks(3)
    fluidRow(
      column(12, align = "center", 
             div(
               style = "margin-top: 20px;",
               actionButton("convertButton", "Convertir", icon = icon("refresh"), style = "color: white;", class = "btn-lg btn-primary")
             )
      )
    )
  })
}

shinyApp(ui = ui, server = server)
