
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

- Convertir les scripts ui.R et serveur.R en app.R si c'est plus commode
- Pour chaque bloc de code, ajouter un commentaire pour expliquer ce que fait le bloc de code

---



<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->

# Script de conversion




<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->


# Validation à la fin

Travailler sur la validation par l'utilisateur des questions converties et créées par SARP.moodle. 
SARP.moodle renvoie beaucoup d'informations dans la console (via la fonction cat), reste à trouver un moyen de les récupérer.

---

**TO-DO**

- Explorer les possibilités du package shinyjs
https://deanattali.com/shinyjs/overview
- Exemples d'options qui peuvent être utiles lors du développement

```r
options(shiny.trace=TRUE)
options(shiny.fullstacktrace=TRUE)
```
---


<!-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -->


# Mise en forme des questions

Si l'utilisateur met en forme ses questions dans Excel, y-a-t-il un moyen de récupérer cette mise en forme pour les convertir des balises html ?

---

**TO-DO**

- Etudier si une solution est envisageable avec le package openxlsx


```r
library(openxlsx)
wb <- loadWorkbook("Questions.xlsx")
```

---



