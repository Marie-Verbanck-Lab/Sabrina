## —————————————————————————————————————————————————————————————————
## Création de XML Moodle avec R
## Emmanuel Curis — juin 2015
##
## Fonctions permettant la préparation des textes
## —————————————————————————————————————————————————————————————————
## HISTORIQUE
##   24 juin 2020 : création du fichier
##
##    1 jan. 2021 : question de pur texte (« description »)
##
##    3 jui. 2022 : corrigé le titre pour les questions description
##
##   15 avr. 2024 : option pour transformer les insécables en espace
##                   dans preparer_textes [pour les notes…]
## —————————————————————————————————————————————————————————————————

## —————————————————————————————————————————————————————————————————
##
## Question de type « description »
##
## —————————————————————————————————————————————————————————————————
description.moodle <- function( texte,
                                titre = "Description",
                                commentaire.global = NA, 
                                idnum = NA, tags = NULL,
                                fichier.xml = get( "fichier.xml", envir = SARP.Moodle.env ) )
{
    ## On crée la question
    debut_question.moodle( type = "description",
                           titre = titre, texte = texte,
                           commentaire.global = commentaire.global,
                           penalite = 0, note.question = 0, idnum = idnum,
                           fichier.xml = fichier.xml )

    ## Et on a fini en fait…
    fin_question.moodle( fichier.xml = fichier.xml, tags = tags )
}

## —————————————————————————————————————————————————————————————————
##
## Préparation des textes pour meilleur rendu etc.
## 
## —————————————————————————————————————————————————————————————————

preparer_texte <- function( textes, oter.insecables = FALSE )
{
    if ( oter.insecables ) {
        textes <- gsub( "\u00a0", "", fixed = TRUE, textes )
    }
    
    ## On supprime les doubles-espaces
    textes <- gsub( " {2,}", " ", textes )

    ## On supprime les espaces en début de ligne
    textes <- gsub( "^[[:space:]]+", "", textes )

    ## On supprime les espaces en fin de ligne
    textes <- gsub( "[[:space:]]+$", "", textes )

    ## On convertit les < qui trainent en &lt;
    textes <- gsub( "<([[:space:]]+)", "&lt;\\1", textes )

    ## On convertit les > qui trainent en &gt;
    textes <- gsub( "([[:space:]]+)>", "\\1&gt;", textes )
    
    ## On renvoie les textes modifiés
    textes
}
