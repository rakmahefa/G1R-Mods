# Pokémon — RPG Economy Overhaul

**Statut :** conception initiale v0.1 — à valider avant développement  
**Identifiant de travail :** pokemon-rpg-economy  
**Dépôt :** G1R-Mods  
**Périmètre de cette documentation :** design, économie, contenu, faisabilité et plan de validation. Aucun code de mod n'est défini ici.

## Vision

Transformer l'aventure Pokémon en un RPG où l'équipe se construit par des décisions économiques et des services spécialisés. Les combats restent importants, mais ne sont plus le moyen automatique de faire monter les niveaux et les statistiques. Le joueur finance sa progression en explorant, capturant, remplissant des contrats, affrontant des adversaires optionnels et récupérant des matériaux.

Le mod est un **overhaul de systèmes** : il touche à la progression, l'économie, les récompenses, les services, les personnages et les activités optionnelles. Il ne cherche pas à imposer un Nuzlocke.

## Piliers de conception

1. **L'argent a une vraie valeur.** Les Pokédollars sont le moteur principal de la progression et doivent être gagnés, arbitrés puis dépensés.
2. **L'effort est récompensé.** Un combat difficile, une capture rare, un boss découvert ou une bonne préparation doit avoir une récompense proportionnée.
3. **Les badges structurent la progression.** Ils définissent les paliers de niveau, les services disponibles, les zones de référence et les récompenses.
4. **Les Pokémon sont des ressources de progression, pas des vies à protéger à tout prix.** Certains services les consomment volontairement, mais le mod n'ajoute aucune mort permanente.
5. **Les défis majeurs sont proposés, jamais imposés par surprise.** Les boss et miniboss ne poursuivent pas le joueur et ne lancent pas eux-mêmes le combat.
6. **Chaque activité a une raison d'exister.** Les combats rapportent peu d'argent mais sont renouvelables ; les contrats de capture financent l'économie ; les boss apportent les matériaux rares ; les services convertissent les ressources en puissance.

## Jeu cible proposé

Les mécaniques demandées nécessitent un jeu de **troisième génération** : natures, IV, EV, reproduction, œufs et egg-moves. L'API 3 de Gen1Recomp est donc le socle pertinent.

Proposition de périmètre initial :
- **Première cible : Pokémon FireRed.**
- **Compatibilité suivante : LeafGreen**, après vérification de la parité des cartes, scripts et événements.
- **Emerald : hors du premier périmètre**, car la structure de Hoenn et les données de contenu nécessitent un travail d'adaptation spécifique.

Ce choix est une recommandation de travail, pas une décision définitive. La liste des jeux du manifeste sera fixée après validation.

## Boucle principale

**Explorer → combattre/capturer → remplir des contrats → gagner de l'argent et des matériaux → investir dans l'équipe → relever un défi optionnel → obtenir un badge → débloquer le palier suivant.**

Les combats ordinaires ne donnent ni EXP ni EV. Ils restent néanmoins utiles pour gagner les petits paiements des dresseurs renouvelables, obtenir des captures destinées aux contrats et progresser dans les défis. Le joueur entraîne son équipe en dépensant son argent auprès de services dédiés.

## Règles non négociables

- Pas de Nuzlocke, pas de mort permanente, pas de suppression automatique d'un Pokémon après un K.O.
- Aucun EXP et aucun EV attribués par les combats une fois le mode activé.
- Les niveaux sont obtenus via un service de progression payé.
- La limite de niveau suit le nombre de badges ; son application aux Pokémon capturés dans les zones avancées doit être garantie pour éviter les contournements.
- Les combats contre les dresseurs et les boss interdisent les objets utilisables depuis le sac. Les objets tenus sont considérés séparément et restent autorisés dans la proposition actuelle.
- Les boss sont facultatifs et déclenchés volontairement par le joueur.
- Toute consommation volontaire d'un Pokémon par un service doit afficher clairement le Pokémon concerné et demander une confirmation.
- Les contrats de capture doivent consommer le Pokémon remis au guichet, sans permettre les doubles paiements.

## Documents

- [GAME_DESIGN.md](GAME_DESIGN.md) — progression, badges, règles de combat et structure de difficulté.
- [ECONOMY.md](ECONOMY.md) — Pokédollars, contrats de capture, entraînement, services, TM, œufs et matériaux.
- [ACTIVITIES_AND_CHARACTERS.md](ACTIVITIES_AND_CHARACTERS.md) — personnages, minibosses, boss et densité du contenu.
- [TECHNICAL_FEASIBILITY.md](TECHNICAL_FEASIBILITY.md) — état réel de l'API 3 et extensions moteur nécessaires.
- [ROADMAP_AND_TEST_PLAN.md](ROADMAP_AND_TEST_PLAN.md) — étapes de conception, prototypes et critères d'acceptation.
- [OPEN_DECISIONS.md](OPEN_DECISIONS.md) — arbitrages à valider avant de commencer à coder.

## État d'avancement

La vision générale est cohérente. En revanche, la consommation sûre de Pokémon appartenant au joueur, les changements de nature/IV/EV/niveau, la gestion des Pokémon stockés dans les boîtes et le filtrage complet des objets en combat nécessitent encore une preuve de faisabilité ou une extension publique du moteur. Ces points sont des dépendances bloquantes, pas des détails à repousser après le premier prototype.
