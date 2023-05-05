#Chargement de SARP.moodle
library("SARP.moodle", lib.loc = "/usr/lib64/R/library")

#Choisir mon fichier CSV
gabarit <-file.choose()

#A ajouter pour les images à positionner au meme endroit que le CSV
setwd(dirname(gabarit))
ods.moodle(gabarit) # Échoue avec iris.jpg

# Version  CSV
gabarit.csv <- file.choose()
definir_dossier.image.moodle( URL, local = FALSE )
csv.moodle( gabarit.csv )


# Renvoyer un tableau synthétique avec une synthèse des questions converties (nombre de questions par type de question et nombre de choix)
test <- csv.moodle( gabarit.csv )
paste("Vous avez importé", nrow(test[[1]]), "questions")


# Version Excel

gabarit.xlsx <- file.choose()
xlsx.moodle( gabarit.xlsx)