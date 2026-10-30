# Open Decisions — Décisions à confirmer

Ce document rassemble les points qui restent à décider avant l'implémentation. Les propositions marquées « recommandation » constituent un point de départ, pas une décision prise à la place du joueur.

## 1. Jeu cible — décision validée

**Pokémon Emerald uniquement.** Cette décision est confirmée. FireRed, LeafGreen, Ruby et Sapphire ne sont pas des cibles de la première version et ne doivent pas apparaître dans le manifeste du mod.

L'analyse des systèmes, la carte du contenu, les équipes de dresseurs, les contrats de capture, les PNJ et les tests seront construits pour Hoenn/Emerald.

## 2. Plafond de niveau

Le barème de départ proposé est 12, 18, 24, 30, 36, 42, 48, 54 et 60 pour zéro à huit badges, puis 70 en post-game.

**Questions :**
- Valider ce barème ou préférer un autre rythme ?
- Le plafond s'applique-t-il strictement à tous les Pokémon, y compris ceux capturés dans une zone avancée ?
- Un Pokémon capturé au-dessus du plafond doit-il être ramené au plafond, rester en boîte jusqu'au badge requis, ou devenir utilisable seulement après déblocage ?

**Recommandation :** aucun Pokémon ne doit permettre de contourner le système. Le plafond effectif doit donc couvrir les captures, dons, œufs et retraits de boîte, pas seulement le service payant.

## 3. Dresseurs renouvelables

**Question :** quels dresseurs sont réinitialisés par le soin au Centre ou l'accès au PC ?

- Uniquement les nouveaux dresseurs de guilde/entraînement créés par le mod (recommandation).
- Tous les dresseurs ordinaires d'une route, y compris les dresseurs originaux.
- Un mélange, avec une liste explicitement définie.

**Recommandation :** ne pas réinitialiser les flags des dresseurs narratifs originaux. Ajouter des dresseurs renouvelables appartenant au mod.

**À préciser :**
- Le PC déclenche-t-il le reset dès l'ouverture de l'écran ou seulement lors d'une consultation effective d'une boîte ?
- Le soin doit-il réinitialiser le cycle même si les Pokémon étaient déjà en pleine santé ?
- Le reset peut-il se produire plusieurs fois lors d'une même visite au Centre ?

## 4. Interdiction des objets en combat

**Question :** confirme-t-on que les objets tenus restent autorisés ?

Proposition :
- objets de sac interdits dans les combats contre dresseurs, miniboss et boss ;
- objets tenus autorisés ;
- Poké Balls autorisées uniquement dans les combats sauvages ordinaires ;
- boss sauvages non capturables, sauf règle particulière.

## 5. Boss et progression

**Questions :**
- Le boss sauvage caché est-il définitivement vaincu après une victoire ?
- Les boss dresseurs donnent-ils une récompense unique ou peuvent-ils être rejoués sans matériaux ?
- Les deux miniboss de route doivent-ils être chacun obligatoires pour ouvrir un détour, ou entièrement facultatifs ?
- Un personnage-barrage peut-il empêcher un accès à une zone optionnelle tant qu'il n'est pas battu ?

**Recommandation :** un boss unique ne doit pas réapparaître après un soin/PC. Les barrages ne doivent bloquer que du contenu secondaire, jamais la progression principale vers les badges.

## 6. Contrats de capture

**Questions :**
- Combien de contrats sont disponibles à la fois ? Trois sont proposés dans cette conception.
- Les contrats sont-ils locaux au Centre Pokémon où ils sont acceptés ?
- Un Pokémon capturé avant l'acceptation peut-il être remis ?
- Les Pokémon des boîtes peuvent-ils être vendus ?
- Les espèces très rares, fossiles ou évoluées peuvent-elles être demandées ?

**Recommandation :** un contrat est accepté avant la capture, est associé à une espèce locale et ne peut être validé qu'une fois.

## 7. Consommation des Pokémon

C'est une décision importante car le service peut détruire définitivement un membre de l'équipe ou de la boîte.

**Questions :**
- La consommation peut-elle utiliser les Pokémon présents dans l'équipe, les boîtes ou les deux ?
- Le joueur doit-il toujours conserver au moins un Pokémon utilisable ?
- Les Pokémon reçus par échange, événements ou cadeaux sont-ils éligibles ?
- Les Pokémon rares, shiny ou marqués favoris sont-ils protégés par défaut ?

**Recommandation :** afficher un écran de confirmation explicite, protéger le dernier Pokémon utilisable et permettre au joueur de marquer certains Pokémon comme non consommables.

## 8. Règles précises des services

**Entraînement de niveau :** le modèle actuel propose un paiement en Pokédollars sans Pokémon donneur, car l'argent est censé être le principal coût de montée en niveau. Confirmer que cette exception est voulue, ou préciser si le joueur doit aussi fournir un donneur.

### IV

- Quel donneur faut-il pour augmenter l'IV PV, puisqu'aucune nature n'augmente les PV ?
- L'IV est-il augmenté de 1 à chaque transaction ?
- Le coût doit-il accélérer lorsque l'IV se rapproche de 31 ?

### EV

La proposition initiale demande un donneur par point d'EV, avec un niveau correspondant et un coût élevé.

**Question :** confirme-t-on bien un Pokémon consommé par point d'EV, ou un Pokémon donneur dont le niveau détermine un lot d'EV ?

La première option est très exigeante : elle peut demander 252 Pokémon pour optimiser une seule statistique. Elle mérite une simulation avant d'être figée.

### Évolution

- Le donneur est-il un catalyseur générique, ou doit-il répondre à une condition de type/espèce ?
- Le service peut-il remplacer les méthodes pierre, échange et niveau ?
- Les évolutions à conditions spéciales restent-elles soumises à leurs prérequis ?

### Apprentissage de techniques

- Le donneur est-il toujours consommé même si la technique est déjà connue ?
- Les techniques de TM restent-elles séparées des techniques tutorées ?
- Les HM sont-elles exclues du service ?

## 9. Day Care

**Décision validée :** cinq œufs sont consommés en une transaction et donnent un Pokémon de niveau 5.

Restent à définir :
- la liste des dix espèces possibles ;
- une sélection fixe, par rotation ou dépendante du palier ;
- le traitement des Pokémon reçus par cet échange lorsqu'ils sont proposés comme donneurs ;
- si des protections supplémentaires s'appliquent aux espèces déjà possédées.

**Recommandation :** la sélection contient uniquement des espèces non légendaires et non évoluées de premier stade, avec une composition adaptée au palier de guilde. Le Pokémon récompense est créé directement au niveau 5, sans passer par un œuf à éclore.

## 10. Systèmes propres à Emerald — ajouts recommandés

Les systèmes ci-dessous sont des recommandations à inclure progressivement, pas des dépendances du premier prototype économique.

- Rang de guilde distinct des badges : recommandé. Les badges contrôlent les niveaux ; la réputation débloque contrats, services secondaires et recettes.
- Baies et Pokéblocs : fortement recommandé comme source de revenus non sacrificielle et activité d'exploration.
- Concours Pokémon : recommandé en contenu secondaire, avec des récompenses de réputation, rubans et Pokédollars plutôt que des améliorations de combat.
- Base secrète comme quartier général : recommandé, sous réserve de vérifier si le système natif peut être réutilisé proprement ou si une carte dédiée est préférable.
- Match Call / PokéNav : recommandé pour des rematchs d'élite contrôlés, sans transformer les dresseurs originaux en source infinie d'argent.
- Battle Frontier : recommandé pour le post-game, avec une économie de récompenses séparée.

**Question :** quels de ces systèmes doivent être inclus dans la première version jouable, et lesquels peuvent attendre après la boucle économique de base ?

## 11. Matériaux de boss

- Les matériaux sont-ils des objets visibles dans le sac ou un inventaire privé de guilde ?
- Le crafting d'un objet tenu demande-t-il seulement les matériaux, ou aussi des Pokédollars et un Pokémon donneur ?
- Les boss donnent-ils un matériau garanti à chaque victoire ou un tirage aléatoire ?

**Recommandation technique :** commencer avec un inventaire privé du mod et une liste de recettes claire ; décider plus tard si les matériaux doivent apparaître dans le sac natif.

## 12. Volume de contenu

La densité demandée représente un miniboss par ville et quatre rencontres par segment de route. Elle peut produire un grand nombre de combats sur toute la région.

**Question :** cette densité est-elle un objectif ferme pour toutes les routes, y compris les petites routes et les embranchements, ou un objectif prioritaire à adapter selon la géographie de Hoenn ?

**Recommandation :** conserver la densité comme cible, mais autoriser une adaptation locale lorsque la carte ne peut accueillir quatre rencontres distinctes sans répétition.

## 13. Identité du mod

Le nom définitif, le style visuel, le nom de la guilde et les noms des personnages ne sont pas encore définis. Le dossier utilise uniquement un identifiant technique de travail.

## 14. Décisions bloquantes avant le code

Les décisions prioritaires restantes sont :
1. valider le barème de plafonds de niveau et le traitement des Pokémon au-dessus du plafond ;
2. choisir précisément quels dresseurs sont renouvelables et quand le cycle PC/Centre est réinitialisé ;
3. fixer les règles de consommation des Pokémon, l'accès aux boîtes et les protections des Pokémon spéciaux ;
4. décider si un donneur est nécessaire pour l'entraînement de niveau ;
5. définir le modèle d'IV PV et confirmer si l'EV exige un donneur par point ou par lot ;
6. confirmer l'interdiction des objets de sac et le statut des objets tenus ;
7. définir les récompenses uniques et les conditions de réapparition des boss ;
8. choisir les ajouts Hoenn à intégrer au premier jalon jouable.
