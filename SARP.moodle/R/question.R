## ─────────────────────────────────────────────────────────────────
## Création de XML Moodle avec R
## © Emmanuel Curis — mars 2015
##
## Fonctions permettant la création de questions génériques [dont « cloze »]
## ─────────────────────────────────────────────────────────────────
## Historique
##   22 juillet 2016 : mise en page adaptée
##                     avertissement en cas de notes automatiques
##
##   20 octobre 2016 : commentaire global (après réponse) géré
##
##   31 mars    2017 : sortie des notes avec 7 décimales pour garder les fractions…
##
##   29 janvier 2020 : codage des textes (énoncés, commentaires)
##                      => l'inclusion d'images est possible...
##
##   28 avril   2020 : fonctions de création de questions partielles
##                       pour types de questions plus exotiques
##
##   29 avril   2020 : bloc générique « q. à réponses multiple » [début]
##
##    1 janvier 2021 : tag « idnumber » pris en compte (entier)
##
##    3 juillet 2022 : corrigé la balise pour indiquer le nombre de réponses correctes
##
##   18 mai     2023 : conversion stop → erreur et warning → avertissement
##
##   24 juin    2023 : début de prise en charge des tags
##                     correction de coquilles dans les avertissements
##
##   12 janvier 2024 : avertissement si réponse avec une note > 100 % ou < -100 %
##
##   15 avril   2024 : à → \u00e0 dans quelques messages…
##
##   23 avril   2024 : écriture des tags
##                     note → note.question pour harmoniser (et simplifier la doc)
## ─────────────────────────────────────────────────────────────────

question.moodle <- function( type = "cloze",
                             titre = "Question...", texte, reponses = NULL,
                             penalite = NA, note.question = NA, commentaire.global = NA, idnum = NA,
                             autres.codes = NULL, tags = NULL,
                             fichier.xml = get( "fichier.xml", envir = SARP.Moodle.env ) ) {
    ## On démarre la question
    debut_question.moodle( type = type, titre = titre, texte = texte,
                           penalite = penalite, note.question = note.question,
                           commentaire.global = commentaire.global,
                           idnum = idnum,
                           fichier.xml = fichier.xml )

    ## On a indiqué des réponses...
    n.reponses <- length( reponses )
    if ( n.reponses > 0 ) {
        ## A-t-on précisé la fraction des points pour chaque réponse ?
        fractions <- attr( reponses, "fractions" )
        n.fractions <- length( fractions )
        
        if ( n.fractions != n.reponses ) {
            ## Longueurs discordantes...
            if ( 0 == n.fractions ) {
                ## Aucune fraction indiquée : la première réponse est à 100 %, les autres à 0
                avertissement( 450, "question.moodle",
                               "Aucune note n'est indiqu\u00e9e pour les r\u00e9ponses.",
                               " La premi\u00e8re r\u00e9ponse est, arbitrairement,",
                               " suppos\u00e9e la seule correcte.",
                               " Toutes les autres ont une note nulle." )
                fractions <- c( 100, rep( 0, n.reponses - 1 ) )
                n.fractions <- n.reponses
            } else {
                ## Pas d'automatisation, erreur...
                erreur( 22, "question.moodle",
                        "Discordance entre nombre de r\u00e9ponses et nombre de fractions..." )
            }
        }

        ## Contrôles de cohérence sur les fractions
        if ( any( fractions > 100 ) ) {
            avertissement( 356, "question.moodle",
                           "Certaines notes sont sup\u00e9rieures \u00e0 100%.",
                           " On les bloque \u00e0 100%." )
            fractions[ which( fractions > 100 ) ] <- 100
        }
        if ( any( fractions < -100 ) ) {
            avertissement( 357, "question.moodle",
                           "Certaines notes sont inf\u00e9rieures \u00e0 -100%.",
                           " On les bloque \u00e0 -100%." )
            fractions[ which( fractions < -100 ) ] <- -100
        }
        
        ## On convertit les fractions en textes, en garantissant les chiffres corrects
        fractions <- format( fractions, decimal.mark = ".", digits = 10, nsmall = 8,
                             drop0trailing = TRUE, trim = TRUE )

        ## A-t-on précisé des commentaires pour chaque réponse ?
        commentaires <- attr( reponses, "commentaire" )
        n.commentaires <- length( commentaires )
        if ( n.commentaires != n.reponses ) {
            if ( 0 == n.commentaires ) {
                commentaires <- rep( NA, n.reponses )
            } else {
                ## Pas d'automatisation, erreur...
                erreur( 23, "question.moodle",
                        "Discordance entre nombre de r\u00e9ponses et nombre de commentaires..." )
            }
        }

        ## On ajoute chaque réponse (bonne, partielle ou fausse) au fichier
        ##   Attention, pas forcément de balise CDATA !
        ##    => s'il en faut, la fonction appelante doit les mettre
        ##       on fait le recodage sans en ajouter
        for ( i in 1:n.reponses ) {
            cat( file = fichier.xml, sep = "", "\n",
                 " <answer fraction=\"", fractions[ i ], "\">\n" )
            coder.texte( reponses[ i ], fichier.xml = fichier.xml,
                         balise.CDATA = FALSE ) 
#                 "  <text>", reponses[ i ], "</text>\n" )
            if ( all( ( FALSE == is.na( commentaires[ i ] ) ),
                      nchar( commentaires[ i ] ) > 0 ) ) {
              cat( file = fichier.xml, sep = "", "\n",
                   "  <feedback>\n" )
                   coder.texte( commentaires[ i ], fichier.xml = fichier.xml,
                                indentation = 3 )
              cat( file = fichier.xml, sep = "", "\n",
                   "  </feedback>\n" )
            }
            cat( file = fichier.xml, sep = "\n",
                 " </answer>" )
        }
    }

    if ( length( autres.codes ) > 0 ) {
        nom.codes <- names( autres.codes )
        if ( is.null( nom.codes ) ) {
            erreur( 24, "question.moodle",
                    "Vous devez pr\u00e9ciser le nom des codes",
                    " comme nom de la liste de leur valeur..." )
        }
        for ( i in 1:length( autres.codes ) ) {
            cat( file = fichier.xml, sep = "",
                 " <", nom.codes[ i ], ">", autres.codes[ i ], "</", nom.codes[ i ], ">\n" )
        }
    }

    ## Question finie...
    fin_question.moodle( fichier.xml = fichier.xml, tags = tags )
}

## ——————————————————————————————————————————————————————————————————————
##
##           Éléments servant à la construction d'une question
##
## ——————————————————————————————————————————————————————————————————————

## ——————————————————————————————————————————————————————————————————————
##
## Créer le code d'un début de question, avec les champs obligatoires
##
## type  = le type de question
## titre = le titre de la question [facultatif]
## texte = l'énoncé de la question
## penalite = la pénalité en cas de 2e tentative (% de la note)
## note.question = note par défaut
## commentaire.global = le commentaire fait à la fin de question, quoi qu'il arrive
## idnum = identifiant numérique Moodle
## 
debut_question.moodle <- function( type,
                                   titre, texte, 
                                   penalite = NA, note.question = NA, 
                                   commentaire.global = NA,
                                   idnum = NA,
                                   fichier.xml = get( "fichier.xml", envir = SARP.Moodle.env ) )
{
    ## On démarre la question
    cat( file = fichier.xml, sep = "",
         "\n<question type=\"", type, "\">\n" )

    ## A-t-on indiqué un titre pour la question ?
    if ( length( titre ) > 0 ) {
        cat( file = fichier.xml, sep = "",
             " <name format=\"html\">\n",
             "  <text><![CDATA[", titre, "]]></text>\n",
             " </name>\n" )
    }

    ## OBLIGATOIRE : le texte de la question
    cat( file = fichier.xml, sep = "",
         " <questiontext format=\"html\">\n" )
    coder.texte( texte, fichier.xml = fichier.xml )
    cat( file = fichier.xml, sep = "",
         " </questiontext>\n" )

    ## On indique le commentaire général fait à la question
    if ( all( is.na( commentaire.global ) == FALSE,
              nchar( commentaire.global ) > 0 ) ) {
        cat( file = fichier.xml, sep = "",
             " <generalfeedback>\n" )
        coder.texte( commentaire.global, fichier.xml = fichier.xml )
        cat( file = fichier.xml, sep = "",
             " </generalfeedback>\n" )
    }

    ## On indique une note par défaut
    if ( is.finite( note.question ) ) {
        cat( file = fichier.xml, sep = "",
             " <defaultgrade>", note.question, "</defaultgrade>\n" )
    }
    
    ## On indique une pénalité
    if ( is.finite( penalite ) ) {
        cat( file = fichier.xml, sep = "",
             " <penalty>", penalite, "</penalty>\n" )
    }
    
    ## On indique un identifiant unique [par catégorie]
    if ( is.finite( idnum ) ) {
        idnum <- as.integer( idnum )

        ## On vérifie qu'il n'existe pas déjà dans la catégorie...
        lst <- get( "liste.ids", envir = SARP.Moodle.env )
        if( idnum %in% lst ) {
            erreur( 450, "question.moodle",
                    "Identifiant num\u00e9rique [", idnum,
                    "] d\u00e9j\u00e0 attribu\u00e9",
                    " dans la cat\u00e9gorie en cours." )
        }
        lst <- c( lst, idnum )
        assign( "liste.ids", lst, envir = SARP.Moodle.env )

        cat( file = fichier.xml, sep = "",
             " <idnumber>", idnum, "</idnumber>\n" )
    }
}

## ——————————————————————————————————————————————————————————————————————
##
## Créer le code d'un début de question, avec les champs obligatoires
##
## ordre.aleatoire : faut-il mélanger l'ordre des réponses ?

bloc.reponse_multiple <- function( ordre.aleatoire,
                                   commentaire.correct,
                                   commentaire.partiel,
                                   commentaire.incorrect,
                                   montrer.nombre.correct,
                                   numerotation,
                                   fichier.xml
                                  )
{
    ## Faut-il tirer au sort l'ordre des réponses ?
    if ( !missing( ordre.aleatoire ) ) {
        if ( length( ordre.aleatoire ) > 1 ) {
            avertissement( 3, "bloc.reponse_multiple",
                           "ordre.aleatoire de longueur > 1 - seule la premi\u00e8re valeur servira" )
            ordre.aleatoire <- ordre.aleatoire[ 1 ]
        }
        if ( is.null( ordre.aleatoire ) ) ordre.aleatoire <- TRUE
        if ( is.na( ordre.aleatoire ) ) ordre.aleatoire <- TRUE
        
        cat( file = fichier.xml, sep = "",
             "  <shuffleanswers>",
            if ( ordre.aleatoire ) "true" else "false",
             "</shuffleanswers>\n" ) 
    }

    ## Faut-il numéroter ?
    if ( !missing( numerotation ) ) {
        if ( length( numerotation ) > 1 ) {
            avertissement( 4, "bloc.reponse_multiple",
                           "numerotation de longueur > 1 - seule la premi\u00e8re valeur servira" )
            numerotation <- numerotation[ 1 ]
        }
        if ( is.null( numerotation ) ) numerotation <- "none"
        if ( is.na( numerotation ) ) numerotation <- "none"
        
        if ( !( numerotation %in% c( 'ABC', '123', 'abc', 'iii', 'III', 'none' ) ) ) {
            avertissement( 451, "bloc.reponse_multiple",
                           "Code de num\u00e9rotation inconnu - ", numerotation,
                           " - ignor\u00e9." )
            numerotation <- "none"
        }

        cat( file = fichier.xml, sep = "",
             "  <answernumbering>",
             numerotation,
             "</answernumbering>\n" )        
    }
    
    ## Faut-il indiquer le nombre de réponses correctes ?
    if ( !missing( montrer.nombre.correct ) ) {
        if ( length( montrer.nombre.correct ) > 1 ) {
            avertissement( 5, "bloc.reponse_multiple",
                           "montrer.nombre.correct de longueur > 1 - seule la premi\u00e8re valeur servira" )
            montrer.nombre.correct <- montrer.nombre.correct[ 1 ]
        }
        if ( is.null( montrer.nombre.correct ) ) montrer.nombre.correct <- TRUE
        if ( is.na( montrer.nombre.correct ) ) montrer.nombre.correct <- TRUE

        if ( montrer.nombre.correct ) {
            cat( file = fichier.xml, sep = "",
                 "  <shownumcorrect>",
                 if ( montrer.nombre.correct ) "true" else "false",
                 "  <shownumcorrect/>\n" )
        }
    }
}

## ——————————————————————————————————————————————————————————————————————
##
## Finir le code d'une question
##
fin_question.moodle <- function( fichier.xml = get( "fichier.xml", envir = SARP.Moodle.env ),
                                 tags = NULL )
{
    ## On place les tags, au besoin
    if ( length( tags ) > 0 ) {
        cat( file = fichier.xml, sep = "\n",
             "  <tags>" )

        for ( tag in tags ) {
            cat( file = fichier.xml, sep = "\n",
                 "    <tag>" )
            coder.texte( tag, fichier.xml = fichier.xml,
                         indentation = 6,
                         balise.CDATA = FALSE, ajouter.images = FALSE )
            cat( file = fichier.xml, sep = "\n",
                 "    </tag>" )
        }
        
        cat( file = fichier.xml, sep = "\n",
             "  </tags>" )
    }

    
    ## Question finie...
    cat( file = fichier.xml, sep = "\n",
         "</question>" )
}
