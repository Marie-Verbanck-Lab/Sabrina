library(shiny)
library(spsComps)
library(shinydashboard)

ui <- fluidPage(
  actionButton("msg", "msg"),
  actionButton("warn", "warn"),
  actionButton("err", "err"),
  renderPrint(reactiveB())
)

values <- reactiveValues(TEST = NULL)

server <- function(input, output, session) {
  
   observeEvent(input$msg, {
    x <- 1:3
    y <- c(2, 0, 4, NA)
    z <- x/y
    msg <- warnings()
    msg <- paste(names(msg), msg)
    shinyCatch({warning(msg)}, prefix = '')
    #shinyCatch({message("a message")}, prefix = '')
  })
  observeEvent(input$warn, {
    shinyCatch({warning("a warning")}, prefix = 'ATTENTION')
  })
  observeEvent(input$err, {
    msgErr <- try(log(10))
    #shinyCatch({stop("an error")}, prefix = '')
    
    if(class(msgErr) %in% "try-error") # si oui il trouvé une erreur
      shinyCatch({stop(msgErr)}, prefix = '')
    else
      reactiveB <- reactive({
        values$TEST = msgErr
      })
  })
  
  
  
}

shinyApp(ui, server)
