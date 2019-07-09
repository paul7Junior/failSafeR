# failSafeR



A data driven approach of debugging.

Les genes donnent des caracteristiques.
Code genetic:
lepigenetic, les genes s'expriment non pas seulement parce qu'ils sont dans ton code, mais reagissent aussi a l'environnement/ s'exprime a cause de l'env.

Par exemple si tu vis dans un environenement tres pollue, certains gene s'active et certains gene se desactive. 
Le code est la, mais les programmes s'allument et s'eteignent.


Chaque code est specifique, pourtant les erreurs leve sont communes a tout les codes. Pourquoi ne pas avoir un debuggeur qui s'adapte a sont environement
L'ADN a une forme spaciale, et cette forme change la maniere dont le code est interprete dans le milieu.

Debuggeur qui s'adapte au milieu dans lequel il evolue.

Un debuggeur qui repond a l'environnement de la fonction.

TODO: - Creer une class, object pour recevoir et gerer une debug collection.
- add ML algo clustering Kmeans for categorical data
  - detect sign of numeric input
  - detect unusual value for factor input or character input
  - dim of data frames, could detect empty dataset
  - length of object
  - give a likelyhood confidence
  - track [[ functions : being warn if trying to access an element that doesnot exist. ## has_name
- mastering advanced topic for R
- Possibility to retrieve quickly the input values of the function to try the function and troubleshoot the issue.
- possibility to add a function to track through json file. so the actual code is never touched.
- Create a meaningfull example of a silent error
- Concept of silent errors,
- Concept de contextual debugging.



.onLoad package monitor functions in mc_register




Avoir un comportement different si japelle une fonction de class meta_collection, cad quon doit trigger la sauvegarde du current env.

## Debug collection class
A class got the attributes: 
-a function: the function that is monitored
-a data frame: where we sotre the data collected for that specific function

## Process

1. You add in a json file the function you want to monitor. What is happening in the background?
Your functon is slightly modified to be able to track its environment.

2. You run that function a couple of times: what is happening in th bg? 
It saves all the variables that lives in the function current environment.

3. Let say you run that function, and an error is raised. What is happening in th bg? 
We look at the stacktrace and filter the monitored functions.

4. It displays the unusual values that showed up among thoses monitored functions.


## PARTS

- enhance a function
  - add patch to the function to be able to track its environment
  - wrap the function in a tryCatchish function to be able to subscribe to error event
- Storage
- process the stored data to have it in proper way to be consumed in algo
- extract the information
 - extract meta data 
  - extract class (from the actual data.frame to class data.frame, or from 2 to numeric, or from 'Hello World' to character)
  
  - extract numeric sign (from -2 to negative, 4 to positive)
  - extract numeric length (from c(3,4) to 2, from 4 to 1)
  - extract numeric likely range value with variance, volatility
  - extract numeric type (integer, double)
  - extract numeric distinct values, if we detect that the number of different values is small
  
  - extract character distinct values
  - extract character length
  
 - aggregate meta data 
    - contingency table
 - get the actual best value 
  - beta 


La vrai intelligence elle reside dans la capacite a voir, quand tu creer tes fonctions meta, voir comment s'articule lensemble des possibilite
et etre capable de prendre la plus adapte, la moins couteuse. parce que ta une vue globale  de ce qu'il se passe

## WHAT IS A SILENT/IMPLICIT ERROR ?

It is an error up the stack that will not trigger any error/warning by the system because at the moment it was processed 
it was not an error, because you have to know the constraints down the stack.

how come?

I am implicitly creating a dependency between two objects.

Either I can explicitly tell the system what is the dependance by for example add an assertthat.
It is kind of a foolproof/ defensive design.

drawbacks: 1.The problem here is that it is really hard to be aware of all the dependency we are creating between the different pieces of the system.
drawback 2. it does add lines of codes 
drawback 3. when your code change, you have got to change your assertthat.

Because we are just human, that is where come the idee to p**p your mind! with failSafeR.


## THE PROBLEM WITH DEFENSIVE PROGRAMMING: THE IMBALANCE

if(myword == 'this') {
do whatever you want
}

 this bit of code works only for one specific string.
 It means that it wont work for all the other possibilities.
 In other words, there is millions of possibilities to mess up and only one way to have it working.
 
 Ther eis clearly an imbalanced. it is the same in internet securities. It is very hard to secure a system
  because there is thousands way to get in that we didnot though about.
  
  The system is not foolproof.
  
The idea behind fail safer is to grab the path we know already work and thus being able to pinpoint when the system
try a path that it has never seen or any unusual path.


## DATA FLOW AND CONTEXT



## SCENARIOS

### A script

### A simple function

### Complex function calls 
A function that call another function (and recursively)

### Shiny. being able to handle reactivity data flow



### A list 
Being able to trigger an event when trying to access a list item that doesnot exist.

function `[[` we have got you covered!


## SEQUENTIAL PATTERN MINING

Sequential pattern mining.

Example:

How is it possible to handle this?

Knowing within a function the space of acceptable values.

Knowing between functions the expected flow of values.


TO UNDERSTAND:
the callstack what are the different items, what does the numbers reffers to

## METADATA FEATURES DETECTED

### Class metadata

Fit a beta distribution. 

### Numerical metadata

### Dataframe, matrix, tibble metadata

### Factor, character with few different values metadata

## Length metaData




## BASICS OF THE SYSTEM

1. univariate variable to be tested (x, y, ...)
2. properties of variables (class, length, dim, )
  - common properties (class, mode)
  - inner/specific properties of variables (most often based on the class) (dim dataframes, sign numerical, distinct characters)
3. Be able to give a likelihood/probablity
4. Plot the success and failing space. There is a space where the function actually works. Cluster analysis.



## RESET A DC

- Quand une variable est reutilise dans la fonction, il faut pouvoir reinitialise la colonne.



Ce package peut s'appliquer a nimporte quel system qui genere un flux de donnee.
Poser une API dessus permet de le monetiser.
(du code, des logs machines, ...)

Peut s'appliquer a nimporte quel langage, puisque traite de la data, bak end is R.



On faisant touner ma function. je donne de linformation. et lapprentissage il se fait la.


having only NA in a column of integer make that bit of code crashing. because only NA in column make the column as character, 
where the system was expecting numeric

where m is a list of calls
$orders
sum(orders, na.rm = T)

$revenue
sum(revenue, na.rm = T)

data %>% 
  group_by_(.dots = dots) %>%
  summarise(!!!m[1:7]) 
  
  
injection de dependances 
le code nest pas responsable dinstancier les nouveau object



### Website

SSL certificate
https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04

Docker 
https://docker-curriculum.com/
https://docs.docker.com/storage/volumes/

S3 Classes 
https://www.cyclismo.org/tutorial/R/s3Classes.html

Logisitic regression
https://www.math.univ-toulouse.fr/~besse/Wikistat/pdf/st-m-app-rlogit.pdf

Fidel Castro
https://fr.wikipedia.org/wiki/Fidel_Castro

Platon le banquet.
https://papyrus.bib.umontreal.ca/xmlui/bitstream/handle/1866/3551/Fortin_Jerome_2009_memoire.pdf?sequence=4&isAllowed=y

New York
https://www.youtube.com/watch?v=igG6xDyCZFA

Deep learning with R
https://manning-content.s3.amazonaws.com/download/9/9a3b0d8-e651-4239-8c4f-94267be64fee/SampleCh03.pdf

Logique
https://www.editions-ellipses.fr/PDF/9782340014787_tdm.pdf



Une remise en question de quelaue chose qui parait evident au yeux de tout le monde.


## PYSPARK

https://medium.com/civis-analytics/experimenting-with-pyspark-to-match-large-data-sources-abf7ec44b8c2
https://medium.com/@suci/running-pyspark-on-jupyter-notebook-with-docker-602b18ac4494
https://spark.apache.org/docs/latest/quick-start.html


# SHINY
https://www.statworx.com/de/blog/master-r-shiny-one-trick-to-build-maintainable-and-scalable-event-chains/


# 
https://www.youtube.com/watch?v=DV44pB9fpf8&list=LLxCFwDyjOTXOfOIOTaVv1tw&index=2
