## —————————————————————————————————————————————————————————————————
## Création de XML Moodle avec R
## Emmanuel Curis — mars 2015, avril 2020
##
## Fonctions facilitant les affichages : messages prédéfinis
## ——————————————————————————————————————————————————————————————————————
## HISTORIQUE
##   31 mai  2020 : création du fichier
##
##    8 juil 2020 : si temps = NULL, on renvoie une chaîne vide
##
##   24 avr. 2022 : unité du temps définissable dans le texte
##
##   14 juin 2022 : corrigé erreur de temps lorsque indiqué en texte sans unité
##
##    3 juil 2022 : si temps NULL, manquant : on utilisse le temps de catégorie
##                  si NA, en revanche, on ignore ce temps de catégorie
##
##    9 avr. 2023 : corrigé la détection du temps sous la forme « xx m yy »
##                  prise en compte de l'apostrophe UTF-8, utilisée dans Libre Office
##
##   24 juin 2023 : texte pour le temps conseillé modifiable (#T remplacé par le temps)
##                  valeurs des textes et couleurs récupérées des options
##                    (évite de les passer en paramètre à chaque fonction !)
##                  texte pour la consigne d'arrondi
## 
## ——————————————————————————————————————————————————————————————————————

## ——————————————————————————————————————————————————————————————————————
##
##              Temps conseillé pour répondre à une question
##
## temps    : le temps conseillé (en min)
## couleur  : la couleur du message
## nv.ligne : si TRUE, on commence par un retour à la ligne
## masque   : le texte à utiliser (#T sera remplacé par le temps)

temps_necessaire.moodle <- function( temps, 
                                     couleur = getOption( "Sm.temps_couleur" ),
                                     nv.ligne = TRUE,
                                     masque = getOption( "Sm.temps_masque" ) )
{
    ## Tous les cas où aucun temps n'est demandé
    if ( missing( temps ) ) temps <- NULL
    if ( any( is.null( temps ), length( temps ) == 0 ) ) {
        ## Si pas de temps fourni, on vérifie si un de catégorie existe
        if ( exists( "temps.categorie", envir = SARP.Moodle.env ) ) {
            temps <- get( "temps.categorie", envir = SARP.Moodle.env )
        } else temps <- NA
    }
    if ( length( temps ) > 1 ) {
        avertissement( 6, "temps_necessaire.moodle",
                       "Plusieurs temps - seul le premier sera",
                       " utilis\u00e9." )
        temps <- temps[ 1 ]
    }
    if ( is.na( temps ) ) {
        return( "" )
    }

    ## Codes pour ne pas mettre de temps
    if ( temps %in% c( "-", "/", "0" ) ) {
        return( "" )
    }
    
    masque <- paste0( if ( nv.ligne ) "<br />",
                      "<span style=\"color: ", couleur, ";\">",
                      masque,
                      "</span>" )
    
    if ( is.character( temps ) ) {
        ## Harmonisation : minuscules
        temps <- tolower( temps )
        
        ## Suppression des espaces
        temps <- gsub( "[[:space:]]", "", fixed = FALSE, temps )
        
        ## Harmonisation des unités...
        temps <- gsub( "min", "m", fixed = TRUE, temps )
        temps <- gsub( "mn" , "m", fixed = TRUE, temps )
        temps <- gsub( "'"  , "m", fixed = TRUE, temps )
        temps <- gsub( "\u2019", "m", fixed = TRUE, temps )

        temps <- gsub( "sec", "s", fixed = TRUE, temps )
        temps <- gsub( "\"" , "s", fixed = TRUE, temps )

        ## Cas de la virgule, si valeur décimale...
        temps <- gsub( ",", ".", fixed = TRUE, temps )

        if ( grepl( ":", fixed = TRUE, temps ) ) {
            tps <- strsplit( temps, ":", fixed = TRUE )[[ 1 ]]
            tps <- as.numeric( tps )
            if ( length( tps ) == 3 ) {
                ## hh:mm:ss"
                temps <- tps[ 1 ] * 60 + tps[ 2 ] + tps[ 3 ] / 60
            } else if ( length( tps ) == 2 ) {
                ## postulé mm:ss
                temps <- tps[ 1 ] + tps[ 2 ] / 60
            } else {
                avertissement( 700, "temps_necessaire.moodle",
                               "Format de temps inconnu : ",
                               temps, "." )
            }
        } else {
            l <- nchar( temps )
            dc <- substr( temps, l, l )
            if ( !( dc %in% c( "s", "m", "h", 0:9 ) ) ) {
                avertissement( 701, "temps_necessaire.moodle",
                               "Unit\u00e9 de temps inconnue : ",
                               dc, " [", temps, "]" )
                return( gsub( "#T", temps, fixed = TRUE, masque ) )
            }

            if ( !( dc %in% 0:9 ) ) {
                temps <- substr( temps, 1, l - 1 )
            }
            x <- suppressWarnings( as.numeric( temps ) )
            if ( is.na( x ) ) {
                ## Il reste donc des caractères...
                if ( grepl( "h", fixed = TRUE, temps ) ) {
                    tps <- strsplit( temps, split = "h", fixed = TRUE )[[ 1 ]]
                    tps.h <- tps[ 1 ]
                    if ( length( tps ) > 1 ) {
                        tps <- strsplit( tps[ 2 ], split = "m", fixed = TRUE )[[ 1 ]]
                        tps.m <- tps[ 1 ]
                        if ( length( tps ) > 1 ) {
                            tps.s <- tps[ 2 ]
                        } else {
                            tps.s <- 0
                        }
                    } else {
                        tps.m <- 0
                        tps.s <- 0
                    }
                } else {
                    tps <- strsplit( temps, split = "m", fixed = TRUE )[[ 1 ]]
                    tps.h <- 0
                    tps.m <- tps[ 1 ]
                    if ( length( tps ) > 1 ) {
                        tps.s <- tps[ 2 ]
                        } else {
                            tps.s <- 0
                    }
                }

                tps.h <- if ( nchar( tps.h ) ) as.numeric( tps.h ) else 0
                tps.m <- if ( nchar( tps.m ) ) as.numeric( tps.m ) else 0
                tps.s <- if ( nchar( tps.s ) ) as.numeric( tps.s ) else 0

                temps <- tps.h * 60 + tps.m + tps.s / 60
            } else {
                temps <- x
                if ( dc == "h" ) temps <- temps * 60
                if ( dc == "s" ) temps <- temps / 60
            }
        }
    }
    if ( !is.finite( temps ) ) return( "" )

    ## On affiche le temps conseillé pour répondre
    txt <- ""
    temps.min <- as.integer( temps )
    if ( temps.min > 60 ) {
        temps.h <- as.integer( temps / 60 )
        txt <- paste0( txt, temps.h, "&nbsp;h" )
        temps.min <- temps.min - temps.h * 60
    }
    if ( temps.min > 0 ) {
        txt <- paste0( txt, temps.min, "&nbsp;min" )
    }
    if ( temps > temps.min ) {
        temps.s <- temps - temps.min
        temps.s <- 60 * temps.s
        temps.s <- as.integer( round( temps.s, 0 ) )

        txt <- paste0( txt, if ( temps.min > 0 ) "&nbsp;",
                       temps.s, "&nbsp;s" )
    }

    texte.temps <- gsub( "#T", 
                         paste0( "<span style=\"white-space: nowrap;\">",
                                 txt, "</span>" ),
                         masque, fixed = TRUE )
    texte.temps
}

## ——————————————————————————————————————————————————————————————————————
##
##              Temps conseillé pour répondre à une question
##
## temps    : le temps conseillé (en min)

ajouter_temps <- function( texte, temps )
{
    if ( missing( temps ) ) {
    }

    txt.temps <- temps_necessaire.moodle( temps )
    if ( nchar( txt.temps ) > 0 ) {
        texte <- paste0( texte, txt.temps )
    }

    texte
}

## ——————————————————————————————————————————————————————————————————————
##
##              Arrondi demandé, pour une réponse numérique
##
## arrondi      : le nombre de chiffres auquel arrondir (0 = entier)
## significatif : si TRUE, nombre de chiffres significatifs
##                si FALSE, nombre de décimales
## couleur      : la couleur du message
## nv.ligne     : si TRUE, on commence par un retour à la ligne

arrondi.moodle <- function( arrondi, significatif = FALSE,
                            couleur = getOption( "Sm.arrondi_couleur" ),
                            nv.ligne = TRUE,
                            masques = getOption( "Sm.arrondi_masques" ) )
{
    ## Tous les cas où aucun arrondi n'est demandé
    if ( missing( arrondi ) ) arrondi <- NULL
    if ( any( is.null( arrondi ), length( arrondi ) == 0 ) ) {
        ## Si pas de temps fourni, on vérifie si un de catégorie existe
        if ( exists( "arrondi.categorie", envir = SARP.Moodle.env ) ) {
            arrondi <- get( "arrondi.categorie", envir = SARP.Moodle.env )
        } else arrondi <- NA
    }
    if ( length( arrondi ) > 1 ) {
        avertissement( 7, "arrondi.moodle", 
                       "Plusieurs arrondis - seul le premier sera",
                       " utilis\u00e9" )
        arrondi <- arrondi[ 1 ]
    }
    if ( is.na( arrondi ) ) {
        return( "" )
    }

    ## Codes pour ne pas mettre d'arrondi
    if ( arrondi %in% c( "-", "/" ) ) {
        return( "" )
    }

    ## On sélectionne le bon masque
    if ( significatif ) {
        if( length( masques ) > 2 ) masques <- masques[ 4:5 ]
        masque <- if ( arrondi == 1 ) {
                      masques[ 1 ]
                  } else {
                      masques[ 2 ]
                  }
    } else {
        masque <- if ( arrondi == 1 ) {
                      masques[ 1 ]
                  } else if ( arrondi == 0 ) {
                      masques[ 3 ]
                  } else {
                      masques[ 2 ]
                  }
    }
    
    masque <- paste0( if ( nv.ligne ) "<br />",
                      "<span style=\"color: ", couleur, ";\">",
                      "<i>",
                      masque,
                      "</i>",
                      "</span>" )

    masque <- gsub( "#N", arrondi, masque, fixed = TRUE )
    masque
}
