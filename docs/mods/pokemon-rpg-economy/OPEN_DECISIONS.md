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

**Décision validée — échange risqué de cinq œufs :** le joueur remet cinq œufs ; le système génère dix Pokémon de niveau 5 appartenant à dix espèces admissibles et distinctes ; le joueur choisit l'un de ces dix Pokémon. Le joueur choisit parmi les Pokémon déjà générés, pas uniquement parmi des noms d'espèces.

Règles confirmées :
- avant le lancement, le Day Care affiche un avertissement : cinq œufs seront consommés, une annulation après lancement ne les rendra pas et le joueur a 10 % de risque de ne recevoir aucun Pokémon ;
- le joueur doit confirmer explicitement ces conditions ;
- à la confirmation du lancement, les cinq œufs sont consommés définitivement ;
- le système tire dix espèces distinctes et génère un Pokémon réel pour chacune, directement au niveau 5 ;
- aucune espèce légendaire n'est admissible ;
- chaque choix correspond à une espèce au premier stade (forme de base, sans évolution préalable) ;
- le joueur sélectionne exactement un des dix Pokémon générés ;
- après le choix, le tirage de réception donne 90 % de chance de recevoir exactement le Pokémon choisi et 10 % de chance de ne rien recevoir ;
- une annulation après lancement ou un échec de réception ne rend pas les cinq œufs et ne donne aucun Pokémon ;
- aucun nouvel essai gratuit n'est possible avec les mêmes œufs.

Restent à définir :
- la liste complète des espèces admissibles et les règles précises du pool selon le palier ;
- si le pool de dix options est fixe, renouvelé par rotation ou recalculé à chaque échange ;
- le traitement des Pokémon obtenus par cet échange lorsqu'ils sont proposés comme donneurs ;
- si des protections supplémentaires s'appliquent aux espèces déjà possédées.

La génération doit conserver les caractéristiques légales d'un Pokémon de génération III. L'interface doit distinguer clairement l'annulation avant confirmation (aucun échange n'a commencé) d'une annulation après lancement (œufs déjà consommés).

## 10. Systèmes propres à Emerald — direction acceptée

**Décision validée :** les recommandations Emerald sont acceptées comme direction de conception et de roadmap. Elles seront intégrées par étapes, sans retarder la première boucle économique jouable.

- **Rang de guilde distinct des badges :** accepté. Les badges contrôlent les plafonds de niveau et les jalons de campagne ; la réputation débloque les contrats spécialisés, services secondaires et recettes.
- **Baies et contrats d'approvisionnement :** acceptés comme voie de revenus alternative ne nécessitant pas de sacrifier un Pokémon.
- **Pokéblocs et concours :** acceptés comme boucle secondaire non combattante et source de réputation, rubans, décorations et récompenses économiques contrôlées.
- **Base secrète comme quartier général :** acceptée comme objectif de conception, sous réserve d'un prototype pour choisir entre réutilisation du système natif et carte dédiée, sans dégrader la base personnelle du joueur.
- **Match Call / PokéNav :** accepté pour des rematchs de guilde et défis contrôlés, sans réinitialiser les flags des dresseurs de l'histoire originale ni créer de farm illimité.
- **Boss conçus autour de la météo, des doubles combats et de l'environnement :** acceptés comme principes de conception des rencontres optionnelles.
- **Contrats d'expédition :** acceptés pour valoriser la découverte, l'observation et les zones facultatives, sans imposer systématiquement la capture ou la consommation d'un Pokémon.
- **Zone de Combat :** acceptée comme contenu de post-game, avec ses récompenses de maîtrise distinctes.

L'ordre d'intégration reste celui décrit dans les documents de fonctionnalités et de roadmap : boucle économique initiale et contrat simple de baies d'abord ; réputation, Pokéblocs/concours, expéditions, Match Call et quartier général ensuite ; Zone de Combat et défis d'élite après la Ligue.

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
