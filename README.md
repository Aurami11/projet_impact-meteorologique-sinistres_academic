# Analyse de l’Impact Météorologique sur les Sinistres Automobiles

## Description

Ce projet se concentre sur la modélisation des effets des conditions météorologiques sur la fréquence et la sévérité des sinistres automobiles. En utilisant des techniques statistiques et de simulation, nous cherchons à quantifier l'impact climatique sur les sinistres.

## Objectifs

- **Modélisation des Effets Météorologiques** : Évaluer comment les conditions météorologiques influencent la survenance et la gravité des sinistres automobiles.
- **Simulation de Scénarios** : Créer des simulations avec des populations exposées à des conditions homogènes et hétérogènes pour mesurer l'impact climatique.
- **Aide à la Décision** : Fournir des insights pour aider les assureurs à ajuster leurs politiques de couverture et leurs stratégies de tarification face aux aléas climatiques.

## Pourquoi ce Projet ?

Avec l'augmentation des événements météorologiques extrêmes, il est crucial pour les assureurs de comprendre comment ces conditions peuvent affecter leurs opérations. Ce projet vise à fournir des outils analytiques pour mieux anticiper et gérer les risques associés.

## Technologies Utilisées

- **Langages** : Python, R
- **Bibliothèques** :
  - Analyse Statistique : Pandas, NumPy, StatsModels
  - Visualisation : Matplotlib, Seaborn
  - Simulation : SimPy, Monte Carlo
- **Données Météorologiques** : API météo, bases de données climatiques

# Test Statistique des Hypothèses Météorologiques et du Nombre d'Accidents

## Contexte

Le script **hypothese_accident_test.R** effectue des tests statistiques sur deux méthodes différentes pour simuler le nombre d'accidents de moto en fonction des conditions météorologiques. Ces méthodes se basent sur deux hypothèses de modélisation des états météorologiques :

- **Hypothèse A (météo homogène)** : La transition météorologique est modélisée de manière uniforme pour tous les jours.
- **Hypothèse B (météo hétérogène)** : La transition météorologique varie en fonction des différents jours et des conditions précédentes.

L'objectif de ce test est de déterminer si le nombre d'accidents est significativement influencé par ces deux modèles de météo. Les tests utilisés pour cette analyse sont :

- **Test t de Student** (Welch Two Sample t-test) : Permet de comparer les moyennes des accidents simulés sous les deux hypothèses.
- **Test de Wilcoxon** (Wilcoxon Rank Sum Test) : Test non paramétrique pour comparer les distributions des deux méthodes de simulation.

## Résultats des Tests

### 1. Test t de Student (Welch Two Sample t-test)

Le test t a été appliqué pour comparer les moyennes des nombres d'accidents simulés sous les deux hypothèses. Voici les résultats obtenus :


t = 0.76062, df = 100.83, p-value = 0.4487
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval: [-239.3343, 536.9943]
sample estimates:
mean of x  mean of y
76810.20   76661.37


**Interprétation** :  
La p-value de 0.4487 est bien supérieure à 0.05, ce qui suggère que nous ne rejetons pas l'hypothèse nulle. Autrement dit, il n'y a pas de différence significative entre les moyennes des deux simulations d'accidents. Cela indique que le nombre d'accidents n'est pas sensible à la distinction entre les hypothèses de météo homogène et hétérogène.

### 2. Test de Wilcoxon (Wilcoxon Rank Sum Test)

Le test de Wilcoxon a été effectué pour comparer les distributions des accidents simulés sous les deux hypothèses :

W = 4927, p-value = 0.8594
alternative hypothesis: true location shift is not equal to 0

**Interprétation** :  
La p-value de 0.8594 est également bien supérieure à 0.05, ce qui nous permet de conclure qu'il n'y a pas de différence significative entre les distributions des deux approches de simulation. Cela confirme les résultats du test t et soutient l'idée que le nombre d'accidents ne dépend pas du modèle météorologique choisi.

## Conclusion

Les tests statistiques (test t de Student et test de Wilcoxon) montrent qu'il n'y a **pas de différence significative** entre les deux méthodes de simulation des accidents, que ce soit sous l'hypothèse de météo homogène ou hétérogène.

### Implication pour l'entreprise

Puisque le nombre d'accidents ne dépend pas du modèle météorologique, cela implique que le montant que l'entreprise d'assurance devra provisionner pour ses assurés est **indépendant des conditions météorologiques**. 

Ainsi, un portefeuille composé d'assurés ayant des comportements très mobiles ou statiques ne sera pas sujet à un risque accru en raison des variations météorologiques. Cette conclusion est basée sur les hypothèses simplifiées de notre modèle, et il serait intéressant d'étendre cette analyse avec un plus grand nombre de simulations pour obtenir des résultats encore plus robustes.

## Limitations

- Le nombre de simulations a été limité à **100** en raison de contraintes matérielles. Un plus grand nombre de simulations pourrait donner des résultats plus fiables.
- Les hypothèses météorologiques (homogène vs hétérogène) sont simplifiées et ne tiennent pas compte de toute la complexité des conditions météorologiques réelles.

## Installation

Pour exécuter ce projet, vous devez avoir Python et les bibliothèques nécessaires installées. Voici comment procéder :

1. Clonez le dépôt :
   ```bash
   git clone https://github.com/votre-utilisateur/analyse-impact-sinistres.git
   cd analyse-impact-sinistres
   ```

2. Installez les dépendances :
   ```bash
   pip install -r requirements.txt
   ```

## Utilisation

1. Préparez vos données météorologiques et de sinistres selon les spécifications du projet.
2. Exécutez le script principal pour lancer l'analyse :
   ```bash
   python main.py
   ```

3. Consultez les résultats et les visualisations générées.

## Contribuer

Les contributions sont les bienvenues ! Si vous souhaitez contribuer à ce projet, veuillez suivre ces étapes :

1. Forkez le projet.
2. Créez une nouvelle branche (`git checkout -b feature/nouvelle-fonctionnalité`).
3. Effectuez vos modifications et validez-les (`git commit -m 'Ajout d&apos;une nouvelle fonctionnalité'`).
4. Poussez vos modifications (`git push origin feature/nouvelle-fonctionnalité`).
5. Ouvrez une Pull Request.

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
