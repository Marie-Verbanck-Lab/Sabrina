\name{glisser_deposer.moodle}
\alias{glisser_deposer}
\alias{glisser_deposer.moodle}
\title{
  Créer une question demandant de placer des éléments à des positions
  précises d'une image
}

\description{ Cette fonction permet de créer une question dans laquelle
  le but est de placer des éléments sur une image.
}

\usage{
glisser_deposer.moodle( texte, titre = "Glisser-d\u00e9poser...",
                        f.creer_figure,
                        fichier.image,
                        x.zones, y.zones, txt.zones,
                        indications = paste0( "Zone ", 1:n.zones ),
                        img.zones = NULL, zone.unique = TRUE,
                        grp.zones = rep( 1, n.zones ),
                        ordre.aleatoire = TRUE,
                        commentaire.global = NA,
                        penalite = NA, note.question = NA, idnum = NA,
                        temps, tags = NULL,
                        fichier.xml = get( "fichier.xml",
                                           envir = SARP.Moodle.env ),
                        \dots )
}
\arguments{
  \item{texte}{ L'énoncé de la question (une chaîne de caractères). Cet
  énoncé peut contenir n'importe quel caractère (codage en UTF-8) et
  n'importe quelles balises HTML.  }

  \item{titre}{ L'intitulé de la question, en HTML. }

  \item{f.creer_figure}{ La fonction qui va construire l'image et les
    zones sur lesquelles déposer les éléments (voyez les détails,
    ci-dessous). }

  \item{fichier.image}{ Le nom du fichier contenant l'image à
    légender. Ignoré si \code{f.creer_figure} est fournie.}

  \item{x.zones,y.zones}{ Les coordonnées des coins supérieurs, gauches
    des zones à définir sur l'image. Ignoré si \code{f.creer_figure} est
    fournie. }

  \item{txt.zones}{ Les textes à utiliser pour les marques à placer sur
    les zones (dans le même ordre que les coordonnées). Ignoré si
    \code{f.creer_figure} est fournie. }

  \item{indications}{ Les textes à afficher sur les zones de l'image
  pour les identifier. }

  \item{img.zones}{ Les noms des fichiers contenant les images à
    utiliser pour chaque marque.  Ignoré si \code{f.creer_figure} est
    fournie. }

  \item{zone.unique}{ Un vecteur aussi long que le nombre de zones,
    indiquant si l'étiquette associée peut être réutilisée après avoir
    été placée dans une zone (\code{FALSE}) ou non (\code{TRUE}). Ignoré
    si \code{f.creer_figure} est fournie.  }

  \item{grp.zones}{ Un vecteur d'entiers aussi long que le nombre de
    zones, indiquant à quel groupe d'étiquette appartient chacune des
    étiquettes. L'apparence de l'étiquette (forme, couleur) dépend de ce
    groupe.  Ignoré si \code{f.creer_figure} est fournie.  }
  
  \item{ordre.aleatoire}{Si \code{TRUE}, l'ordre des marques est permuté
    aléatoirement dans le fichier}
  
  \item{commentaire.global, penalite, note.question, idnum, tags}{Options
    communes à toutes les questions Moodle, voyez
    \code{\link{debut_question.moodle}}.}

  \item{temps}{ Le temps conseillé pour répondre à la question, en
    minutes. }

  \item{fichier.xml}{ Le fichier correspondant au questionnaire qui
    contiendra cette question (par défaut, le dernier créé).  }

  \item{\dots}{ Arguments additionnels qui seront passés à
    \code{f.creer_figure}.}
}

\details{ Ce type de question affiche une image et, en-dessous, des
  étiquettes textuelles ou formées d'une image à placer sur l'image. Les
  étiquettes ont toutes la même apparence (taille, forme, couleur). Les
  zones où les placer sont indiquées sur l'image en surimpression et
  font la même taille que les étiquettes.  Il est possible de créer des
  groupes d'étiquettes (mais ce n'est intéressant que s'il y a au moins
  deux étiquettes par groupe, sans quoi la taille de la zone affichée
  sur l'image donne la réponse...); la forme et la couleur des
  étiquettes varie d'un groupe à l'autre. Attention, les étiquettes d'un
  groupe donné ne peuvent pas être placées sur les zones des étiquettes
  des autres groupes.  Par défaut, toutes les étiquettes appartiennent
  au premier groupe (étiquettes rectangulaires, blanches). La taille des
  étiquettes est identique dans un même groupe, définie pour pouvoir
  contenir le texte ou l'image le plus grand du groupe.
  
  \bold{Utilisation de la fonction \code{f.creer_figure}}

  Avec cette méthode, la fonction se charge de créer le fichier d'image
  (au format PNG, dans le dossier temporaire de R) avant d'appeler
  \code{f.creer_figure}. La fonction \code{f.creer_figure} peut alors
  utiliser tous les outils graphiques basiques de R pour créer une
  figure et les zones à légender sur cette figure. Elle \emph{ne} doit
  \emph{pas} clore la figure (pas d'appel à \code{dev.off()} ou à
  \code{graphics.off}).

  La fonction \code{f.creer_figure} doit renvoyer une \code{data.frame}
  dont chaque ligne correspond à une zone, et contenant au moins trois
  colonnes:
  \itemize{
    \item \sQuote{\code{X}} et \sQuote{\code{Y}}, indiquant les
    coordonnées du coin supérieur, gauche de la zone, exprimées dans le
    système d'unité natif du graphe créé avec R (elles seront ensuite
    converties en pixels grâce aux fonctions \code{\link{grconvertX}} et
    \code{\link{grconvertY}}).;

    \item \sQuote{\code{Texte}}, indiquant le texte de l'étiquette
    associée à la zone.
  }

  La taille de la zone sera déterminée par Moodle en fonction de la
  taille de l'étiquette associée à la zone.

  De façon optionnelle, il peut y avoir une colonne \sQuote{Indications}
  qui contient une indication textuelle sur la zone, une colonne
  \sQuote{Images} qui contient le nom du fichier contenant l'image à
  associer à la zone, une colonne \sQuote{Groupes} qui précise à quelle
  groupe d'étiquette appartient l'étiquette associée à la zone et une
  colonne \sQuote{Unique} qui indique si l'étiquette disparaît des
  propositions après avoir été placée (\code{TRUE}) ou si elle reste,
  pouvant alors être placée sur plusieurs zones (\code{FALSE}).  Si ces
  colonnes sont absentes, l'indication est \dQuote{Zone n°} et le numéro
  de la zone (de sa ligne dans la \code{data.frame}), toutes les
  étiquettes ne contiennent que du texte, sont placées dans le même
  groupe et ne sont utilisables qu'une seule fois.

  Il est possible de créer des étiquettes ne correspondant à aucune zone
  (\dQuote{distracteurs}) en indiquant \code{NA} pour leurs coordonnées.

  \bold{Utilisation directe}

  Il est aussi possible de préciser une image quelconque, grâce à
  l'option \code{fichier.image}. Dans ce cas, les options
  \code{x.zones}, \code{y.zones}, \code{txt.zones}, \code{indications},
  \code{img.zones}, \code{grp.zones} et \code{zone.unique} permettent de
  préciser les caractéristiques de chaque zone à définir. Les
  coordonnées doivent être indiquées en pixels.  }

\value{
  Aucune valeur n'est renvoyée par cette fonction.
}
\author{
  Emmanuel Curis \email{emmanuel.curis@parisdescartes.fr}
}

\seealso{\code{\link{legender_image.moodle}} pour une autre façon de
  demander à placer des éléments sur une image;
  \code{\link{glisser_textes.moodle}} pour faire glisser des textes dans
  un texte à trou.  }
