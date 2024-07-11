# Retroplanning Sabrina - Objectifs

## Semaine du 15-19 juillet

Objectifs de la semaine :

- Affichage du résumé des questions converties
- Remodelage de l'onglet d'aide
- Banque de fichiers à convertir avec tous types d'erreurs / répertorier les erreurs
- Plan du rapport de stage

## Semaine du 22-26 juillet

Objectifs de la semaine :

- Remodelage de l'onglet d'aide
- Banque de fichiers à convertir
- Première ébauche du rapport de stage

## Semaine du 29 juillet - 2 août

Objectifs de la semaine :

- Remodelage de l'onglet d'aide
- Banque de fichiers à convertir
- **Vendredi 2 août : Rapport de stage à m'envoyer à relire**

## Semaine du 5-9 août

Objectifs de la semaine :

- Remodelage de l'onglet d'aide
- Banque de fichiers à convertir
- Rapport fini le vendredi 9 août

## Remodelage de l'onglet d'aide

Onglet avec des tutos et gabarit(s) à télécharger pour expliquer comment formater le fichier d'entrée

- Expliquer comment est structuré le fichier de questions
- Fournir des gabarits à télécharger / à préremplir en fonction des types de questions dont l'utilisateur a besoin
- Expliquer comment intégrer le xml sur moodle
- Faire une vidéo tuto ?

> [Voir conseils de Virginie](https://github.com/Marie-Verbanck-Lab/Sabrina/tree/main/Aide_SARP.moodle)

## Banque de fichiers à convertir

Créer une banque de fichiers à convertir

- Tester toutes les extensions systématiquement
- Tester tous les types de questions 
- Tester plusieurs types d'erreurs / répertorier les erreurs (au niveau de shiny, SARP.moodle, et imprime_Moodle) dans un tableau

<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->
# Interface graphique

## Charte graphique

Presenter toujours de la même façon : 

1. Texte introductif d'abord 
2. Bouton d'action ensuite 

Charte couleur : 

- **Couleur d'information** : actuellement designée par "purple" et pointant vers "#8A1538" = couleur UPC 
- **Couleur action de l’utilisateur** : actuellement designée par "blue" / status "primary" 
- **Couleur retour de l’application** : actuellement designée par "green"  


## Fonctionnement de l'interface

### Fichier de questions

---

**TO-DO**

- Ajouter un petit apercu du fichier gabarit importé
- Faire apparaître le bouton convertir uniquement lorsqu'un fichier est importé
- Verification entre extension du fichier et la nature du fichier --> Voir df_moodle : pr vérifier les extensions.

---

### Images

---

**TO-DO**

- Verifications
  - Si on supprime une image on peut de nouveau l'importer ?
  - Gestion des doublons
  - Bien vérifier qu'une fois les images importées, elles sont correctement utilisées dans la conversion
- "Images validées": doit aparaitre uniquement quand il y a des images d'importer
- Bouton "Valider les images" à remplacer par "Vérifier les images importées" ?

---

### Onglet d'aide

Il faut ajouter un onglet avec des tutos et gabarit à télécharger pour expliquer comment formater le fichier d'entrée.

---

**TO-DO**

- Expliquer comment est structuré le fichier de questions 
- Fournir des gabarits à télécharger / à préremplir en fonction des types de questions dont l'utilisateur a besoin
- Expliquer comment intégrer le xml sur moodle
- Faire une vidéo tuto


---

### Validation finale

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

# Code

---

**TO-DO**

- Revoir l'indentation des fichiers de codes
- Structurer et commenter TOUS les blocs de codes

---

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
