# Pokémon — RPG Economy Overhaul

**Statut :** conception, RFC transactionnelle et bundle Lua source fusionnés (PRs #3 à #9)
**Identifiant de travail :** pokemon-rpg-economy  
**Dépôt :** G1R-Mods  
**Périmètre de cette documentation :** design, économie, contenu, faisabilité et plan de validation. Le code runtime est dans mods/pokemon-rpg-economy/ ; ses sources de bibliothèque restent modulaires et sont assemblées au packaging.

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

## Jeu cible retenu

**Décision validée : Emerald uniquement.**

Le premier périmètre cible exclusivement **Pokémon Emerald** et la région de Hoenn. FireRed, LeafGreen, Ruby et Sapphire sont hors périmètre pour cette première version. Aucune compatibilité avec ces jeux ne sera annoncée.

L'API 3 de Gen1Recomp constitue la base du mod. Le contenu, les cartes, les rencontres, les dresseurs, les boutiques, les personnages et les tests seront conçus pour Emerald. La matrice de capacités du moteur confirme des systèmes spécifiques à Emerald tels que les baies, les Pokéblocs, les concours, les bases secrètes et la Zone de Combat ; leur exposition au mod reste à distinguer de leur disponibilité native dans le jeu.

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

- [LIBRARY_DESIGN.md](LIBRARY_DESIGN.md) — architecture de la bibliothèque privée, isolation, performances, persistance et critères de test.
- [POKEMON_TRANSACTION_API.md](POKEMON_TRANSACTION_API.md) — RFC de références Pokémon stables et transactions atomiques côté moteur.
- [spec.md](spec.md) — plan directeur d'implémentation, phases, dépendances techniques et critères de sortie.
- [session_handoff.md](session_handoff.md) — état de reprise, décisions et première tâche de la prochaine session.

- [GAME_DESIGN.md](GAME_DESIGN.md) — progression, badges, règles de combat et structure de difficulté.
- [ECONOMY.md](ECONOMY.md) — Pokédollars, contrats de capture, entraînement, services, TM, œufs et matériaux.
- [ACTIVITIES_AND_CHARACTERS.md](ACTIVITIES_AND_CHARACTERS.md) — personnages, minibosses, boss et densité du contenu.
- [TECHNICAL_FEASIBILITY.md](TECHNICAL_FEASIBILITY.md) — état réel de l'API 3 et extensions moteur nécessaires.
- [ROADMAP_AND_TEST_PLAN.md](ROADMAP_AND_TEST_PLAN.md) — étapes de conception, prototypes et critères d'acceptation.
- [RECOMMENDED_FEATURES.md](RECOMMENDED_FEATURES.md) — ajouts recommandés autour des systèmes propres à Hoenn.
- [OPEN_DECISIONS.md](OPEN_DECISIONS.md) — arbitrages encore à valider avant le code.

## État d'avancement

La bibliothèque, le hook EXP/EV et le pipeline de bundle Lua source sont intégrés à main via les PRs #6, #7 et #9. Les sources restent séparées dans Git, tandis que le ZIP contient le seul lib/runtime.bundle.lua pour la bibliothèque runtime. La CI #41056713666 a validé lint, tests SDK headless, smoke-template et packaging. Ce bundle est compilé par le load() sandboxé du moteur ; aucun binaire natif ni bytecode n'est utilisé.

Le mod ne constitue pas encore une boucle économique jouable. La consommation sûre de Pokémon, les mutations de niveau/nature/IV/EV, les accès aux boîtes et le filtrage des objets en combat restent bloqués par des capacités publiques à prouver ou à faire ajouter au moteur. La RFC POKEMON_TRANSACTION_API.md a été fusionnée dans la PR #8, mais reste une proposition : elle ne correspond pas à une API moteur existante. Les systèmes Hoenn natifs constituent des opportunités de contenu, sans garantir que chaque opération est déjà accessible à un mod.
