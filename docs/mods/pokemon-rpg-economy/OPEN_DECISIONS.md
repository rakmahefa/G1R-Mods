# Open Decisions — Décisions à confirmer

Ce document rassemble les points qui restent à décider avant l'implémentation. Les propositions marquées « recommandation » constituent un point de départ, pas une décision prise à la place du joueur.

## 1. Jeu de départ

**Question :** quel jeu doit recevoir la première version jouable ?

- FireRed (recommandation pour le premier prototype Kanto).
- FireRed et LeafGreen en même temps.
- Emerald.

La recommandation actuelle est FireRed en premier, puis LeafGreen après une vérification de parité. Emerald doit être traité comme une adaptation de contenu distincte.

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

**Questions :**
- Les cinq œufs sont-ils consommés en une seule transaction ?
- La liste de dix espèces est-elle fixe, ou change-t-elle par palier ?
- Le Pokémon niveau 1 est-il obligatoire, même si le moteur suit normalement la règle d'éclosion niveau 5 de la génération III ?
- Les Pokémon reçus par échange d'œufs peuvent-ils être utilisés comme donneurs ?

**Recommandation :** une liste de dix espèces non légendaires et de premier stade, contrôlée par palier, afin d'éviter une récompense aléatoire disproportionnée.

## 10. Matériaux de boss

- Les matériaux sont-ils des objets visibles dans le sac ou un inventaire privé de guilde ?
- Le crafting d'un objet tenu demande-t-il seulement les matériaux, ou aussi des Pokédollars et un Pokémon donneur ?
- Les boss donnent-ils un matériau garanti à chaque victoire ou un tirage aléatoire ?

**Recommandation technique :** commencer avec un inventaire privé du mod et une liste de recettes claire ; décider plus tard si les matériaux doivent apparaître dans le sac natif.

## 11. Volume de contenu

La densité demandée représente un miniboss par ville et quatre rencontres par segment de route. Elle peut produire un grand nombre de combats sur toute la région.

**Question :** cette densité est-elle un objectif ferme pour toutes les routes, y compris les petites routes et les embranchements, ou un objectif prioritaire à adapter selon la géographie ?

**Recommandation :** conserver la densité comme cible, mais autoriser une adaptation locale lorsque la carte ne peut accueillir quatre rencontres distinctes sans répétition.

## 12. Identité du mod

Le nom définitif, le style visuel, le nom de la guilde et les noms des personnages ne sont pas encore définis. Le dossier utilise uniquement un identifiant technique de travail.

## 13. Décisions bloquantes avant le code

Les décisions prioritaires sont :
1. le jeu exact ;
2. le caractère strict ou non du plafond sur les Pokémon capturés ;
3. la portée des dresseurs renouvelables et du reset PC/Centre ;
4. la règle de consommation des donneurs et l'accès aux boîtes ;
5. la règle EV « un donneur par point » ;
6. le blocage des objets et le statut des objets tenus ;
7. le rôle exact des boss et de leurs récompenses.
