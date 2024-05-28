<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->

# Interface et charte graphique - A respecter partout!

Presenter toujours de la même façon : 

1. Texte introductif d'abord 
2. Bouton d'action ensuite 

Charte couleur : 

- **Couleur d'information** : actuellement designée par "purple" et pointant vers "#8A1538" = couleur UPC 
- **Couleur action de l’utilisateur** : actuellement designée par "blue" / status "primary" 
- **Couleur retour de l’application** : actuellement designée par "green"  

Ajouter une boite bordeau sur l'onglet numero 1 de conversion pour expliquer la charte de couleur, voici le texte :

> Voici la charte Graphique des couleurs pour vous guider 

>   - bordeau : fournit une information 
>   - bleu : nécessite une action de votre part 
>   - vert : fournit un retour de l’application 
>   - rouge : prévient d’une erreur 


*NB: Voir si on introduit une couleur supplementaire pour les pb, actuellement "red"*


## Onglet numero 1 : "Convertir son fichier de questions"

Box bleue 1 

- Question : "Importez votre fichier de questions preparé en suivant le gabarit (xlsx, csv, ods). Vous pouvez trouver des exemples de gabarits pour créer vos questions dans l’aide *(bouton qui va vers l'onglet 3 d'aide)*"

Box bleue 2 

- Question : "Utilisez-vous des images ?"
- Reponse : "oui" "non"

Box bleu 3 qui s'ouvre si oui aux images

- Question : "Selectionnez les images utilisées dans votre fichier de questions."

Box vert 4 qui s'ouvre pour synthetiser l'importation

- Texte : "Vous avez importer les X images suivantes: ..."

*NB: A ajouter une box de verification qui compare les images selectionnees et les noms de fichiers utilisés dans le fichier de questions (images non importer, images importees et pas dans le fichier de questions)*


Box bleu 5 qui propose d'afficher les parametres avancées avec des cases cochées par défault (peut-etre juste un collapse = TRUE).

- Titre : "Paramètres avancés"
- Texte : "Sélectionnez les paramètres pour la conversion de votre fichier de questions"
- Cases a cocher/remplir
    - [ ] Afficher le temps conseillé.
    - [bleu] Couleur des messages de temps conseillé sur moodle.
    - [chiffre] Tolérance des arrondis.
    - [fichier_date] Catégorie par défaut des questions sur moodle si la catégorie n'est pas renseignée dans le fichier de questions. 
    - [X] Conversion automatique des images.
    - [X] Conversion automatique des formules mathématiques (LaTeX).
    - [X] Conversion automatique des codes SMILES.
 
Bouton bleu de conversion

- Titre: "Convertir"

Appuyer sur convertir fait basculer l'application sur l'onglet 2 "Récupérer son fichier de questions".

## Onglet numero 2 : "Récupérer son fichier de questions"

Box verte 1 pour telecharger le fichier

- Texte : "Vous pouvez télécharger votre fichier de questions prêt à l’importation sous Moodle."
- Bouton pour telecharger
- Lien aide "Plus d’informations sur l’importation sous Moodle" qui renvoit vers l'onglet d'aide

Box verte 2 pour faire le bilan de la conversion.


---


<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->

---

# Images

- Faire Tableau de sortie avec 2 colonnes
    - Colonne de gauche case à cocher pour selectionner l'image
    - Colonne de droite Nom de l'image
    - Objectif recuperer les cases cochees
- Bouton pour valider les images
  

Problemes
- Si on supprime une image on peut plus reimporter
- Attention doublons


<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->


# Liste de fonctionnalités à ajouter (voir Virginie)

- Page d'acceuil + conversion
- Bouton soumettre une fois pour tout importer
- Images
  - Bouton image reclickable 
  - Afficher le nom des images importees
  - cases à ticker pour valider
- en entree un fichier excel 
  (Voir texte modifie de Virginie)
- Bien utiliser charte partout 

<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->

# Création d'une base de fichiers de questions avec différents niveaux de difficultés

Il serait pratique avoir une base de fichiers de questions "test" pour pouvoir faire des essais sur des fichiers simples avec différents types de questions.

---

**TO-DO**

- Créer une base de fichiers 
  - avec des extensions .xlsx, .ods et csv
  - et des niveaux de complexité croissants (ex : 4 niveaux) selon le nombre et la structure des questions
- Ecrire un script R (indépendant de Shiny) qui
  - lit indépendemment de l'extension
  - convertit tous ces fichiers pour s'assurer que la conversion aboutit bien

---


<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->


# Interface Shiny

Il serait nécessaire de prendre en main l'interface Shiny déjà réalisée et bien identifier chaque portion de code pour pouvoir la modifier par la suite.

---

**TO-DO**

- Convertir les scripts ui.R et serveur.R en app.R si c'est plus commode pour vous
- Pour chaque bloc de code, ajouter un commentaire pour expliquer ce que fait le bloc de code

---

<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->


# Mise en forme des questions

Si l'utilisateur met en forme ses questions dans Excel, y-a-t-il un moyen de récupérer cette mise en forme pour les convertir des balises html ?

---

**TO-DO**

- Ajouter une boîte de dialogue pour demander à l'utilisateur quelle feuille de calcul il veut importer (si ods ou xlsx)
- Etudier si une solution est envisageable avec le package openxlsx
```{r, echo=TRUE, eval = FALSE}
library(openxlsx)
wb <- loadWorkbook("Questions.xlsx")
```


---


<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->

# Renvoyer les erreurs/warnings

Pour que l'utilisateur puisse modifier de façon autonome son fichier s'il est mal formaté.

---
**TO-DO**

- Exemples d'options qui peuvent être utiles lors du développement
```{r, echo=TRUE, eval = FALSE}
options(shiny.trace=TRUE)
options(shiny.fullstacktrace=TRUE)
```
- Idée à partir d'un excel/ods, convertir en xml à partir du tableau et à partir du csv obtenu à partir du tableau pour faire apparaitre des différences/erreurs potentielles.
- Créer une table de conversion des erreurs/warnings SARP.moodle et faire des phrases à renvoyer à l'utilisateur. Il faut au préalable récupérer les stop() et warnings() dans le code de SARP.moodle.
- Pour Emmanuel : numéroter les erreurs pour les parser dans le fichier de conversion.
 
---

<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->


# Validation à la fin

Travailler sur la validation par l'utilisateur des questions converties et créées par SARP.moodle. 
SARP.moodle renvoie beaucoup d'informations dans la console (via la fonction cat), reste à trouver un moyen de les récupérer.

---

**TO-DO**

- Explorer les possibilités du package shinyjs
https://deanattali.com/shinyjs/overview
- Récupérer suite à la conversion, les sorties consoles dans lesquelles SARP.moodle donne des indications
- Renvoyer un tableau synthétique avec une synthèse des questions converties (nombre de questions par type de question et nombre de choix)
- Visualiser les questions en convertissant le xml en html
- Voir si la fonction sink() permet de récupérer les sorties affichage console
---


<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->


# Mise en forme de l'interface

Il faut compléter l'interface pour qu'elle rendre l'utilisateur le plus autonome possible.

---

**TO-DO**

- Modifier la page d'accueil de l'interface pour ajouter des informations.
  - Fenêtre avec les informations de contact
  - Fenêtre avec des explications du principe etc
- https://github.com/dreamRs/fresh
- Couleurs en Hexadécimal: 
  - Rouge/Bordeau : 138/21/56 = #8A1538
  - Corail : 255/92/57 = #FF5C39
  - Bleu-Gris : 221/229/237 = #DDE5ED
  - Bleu : 91/194/231 = #5BC2E7
  - Beige : 241/241/222 = #F1DEDE
  - Gris : 85/72/72 = #554848
                           

---

<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->


# Onglet d'expllications

Il faut ajouter un onglet avec des tutos et gabarit à télécharger pour expliquer comment formater le fichier d'entrée.

---

**TO-DO**

- Expliquer comment est structuré le fichier de questions 
- Fournir des gabarits à télécharger / à préremplir en fonction des types de questions dont l'utilisateur a besoin
- Expliquer comment intégrer le xml sur moodle
- Faire une vidéo tuto


---

<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->


# Shiny Serveur

Pour pouvoir diffuser l'interface, il faut la déployer sur shiny serveur

---

**TO-DO**
- Installation de shiny serveur
https://shiny.rstudio.com/articles/shiny-server.html
- Fichier de log incrémental pour stocker les bilans de toutes les conversions effectuées
- Identité de l'utilisateur au préalable + discipline (pour les stats)
- Dossier utilisateur pour stocker et protéger les fichiers propres à l'utilisateur 
- Suppression des fichiers pour garantir a confidentialité de l'utilisateur ou conservation pour faire des statistiques
- Emmanuel : écrire résumé & Viginie : Contacter Luc Tamisier pour identification moodle -> shiny et dossier personnel utilisateur 
---
