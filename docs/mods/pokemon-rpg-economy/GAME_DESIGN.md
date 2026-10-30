# Game Design — RPG Economy Overhaul

## 1. Nature du mod

Le mod transforme les systèmes de progression et d'économie d'un jeu Pokémon de troisième génération. Il conserve la structure d'aventure et les badges du jeu cible, mais change la manière de développer une équipe et la valeur des activités.

Le niveau n'est plus la conséquence automatique d'une succession de combats. Il devient un investissement. Les combats servent à relever des défis, acquérir des captures, obtenir des récompenses ou gagner un revenu limité.

Le mod ne doit pas donner l'impression d'un jeu de survie ou d'un Nuzlocke. Le joueur peut perdre un combat, soigner ses Pokémon, changer son équipe et recommencer. La difficulté vient de la préparation, du coût des décisions et de la puissance des adversaires, pas de la perte définitive de Pokémon.

## 2. Boucle de progression

1. Le joueur arrive dans une zone correspondant à son palier actuel.
2. Il rencontre les dresseurs ordinaires, les contrats de capture et les personnages de la guilde.
3. Il peut explorer les zones suivantes, mais leurs dresseurs et leurs Pokémon sont calibrés pour un palier supérieur.
4. Il gagne des Pokédollars avec les contrats et un petit revenu renouvelable avec les dresseurs de route.
5. Il dépense son argent pour entraîner son équipe, acheter des TM, des Poké Balls ou payer des services.
6. Il peut chercher les minibosses et boss de la zone afin d'obtenir des matériaux et des récompenses supérieures.
7. Le badge de l'arène valide le palier et débloque le niveau, les services et le contenu associés.

Les combats ne doivent pas devenir une activité inutile : ils restent le moyen de gagner les petites récompenses des dresseurs, de terminer certains contrats et d'affronter les défis optionnels.

## 3. Badges et paliers de niveau

Le nombre de badges obtenus détermine le palier de campagne. Le niveau maximal autorisé doit progresser avec les badges, et les zones doivent avoir un niveau de référence lié au badge qu'elles précèdent ou suivent.

### Barème de départ à tester

| Badges obtenus | Niveau maximal proposé |
|---:|---:|
| 0 | 12 |
| 1 | 18 |
| 2 | 24 |
| 3 | 30 |
| 4 | 36 |
| 5 | 42 |
| 6 | 48 |
| 7 | 54 |
| 8 | 60 |
| Ligue / post-game | 70 |

Ce tableau est un point de départ pour le balancing, pas une valeur définitive. Il devra être confronté aux niveaux réels des Champions d'arène, des dresseurs de route, des boss et de la Ligue dans le jeu retenu.

### Deux règles distinctes

- **Palier d'entraînement :** le service d'entraînement ne peut jamais dépasser le plafond autorisé par les badges.
- **Plafond effectif de l'équipe :** les Pokémon capturés, reçus, éclos ou retirés d'une boîte ne doivent pas permettre de contourner le plafond. Le design demande donc un contrôle à l'acquisition ou à la réintégration dans l'équipe. Sans ce contrôle, le plafond ne serait qu'une limite de boutique et ne remplirait pas son rôle.

Les valeurs de niveau des zones ne sont pas identiques au plafond du joueur. Une zone avancée peut présenter un danger supérieur au palier actuel. La possibilité d'y entrer tôt est conservée, mais elle expose le joueur à des combats très difficiles.

### Modèle de difficulté des zones

Chaque ville et chaque route reçoit un identifiant de palier. Les dresseurs ordinaires sont réévalués en fonction de ce palier, et non uniquement de leur équipe d'origine. Une route associée au prochain badge doit représenter un défi sérieux pour une équipe encore limitée au palier précédent.

Les combats d'arène et les boss utilisent un niveau cible propre à leur rôle. Les boss doivent être nettement plus exigeants que les dresseurs ordinaires du même palier, sans devenir obligatoires pour continuer l'histoire principale.

## 4. EXP et EV

- Tous les gains d'EXP de combat sont supprimés : dresseurs, Pokémon sauvages ordinaires, miniboss et boss.
- Tous les gains d'EV issus des K.O. sont supprimés.
- Aucun système de partage d'EXP ne doit contourner cette règle.
- Le joueur obtient des niveaux uniquement au service d'entraînement.
- Le joueur obtient des EV uniquement auprès du service spécialisé de l'arène.

La suppression de l'EXP et celle des EV doivent être testées ensemble : dans le moteur actuel, l'attribution native des EV est exécutée séparément de l'application de l'EXP. Un simple gain d'EXP ramené à zéro ne suffit donc pas à supprimer les EV.

## 5. Règles de combat

### Combats de dresseurs et combats de boss

Les objets utilisables depuis le sac sont interdits pendant ces combats. Cela concerne les potions, objets de soin, objets de rappel, objets de boost et autres objets consommables utilisés comme action de combat.

Les objets tenus (par exemple Choice Band ou Leftovers) sont traités séparément. La proposition initiale est de les autoriser : ils sont des récompenses de crafting et une partie de la préparation stratégique de l'équipe.

### Combats sauvages ordinaires

Les objets restent utilisables dans les combats sauvages ordinaires, notamment les Poké Balls. Les combats contre les boss sauvages sont traités comme des combats de boss et suivent donc l'interdiction des objets.

### Absence de permadeath

Un K.O. ne détruit pas le Pokémon. Une défaite suit le comportement normal de défaite/retour du jeu, éventuellement avec une perte de Pokédollars calibrée. Aucune mécanique ne doit supprimer un membre de l'équipe à la suite d'une défaite.

## 6. Dresseurs renouvelables des routes

Des dresseurs de guilde ou d'entraînement sont ajoutés sur les routes en amont du prochain palier. Ils ne remplacent pas tous les dresseurs de l'histoire originale.

Leur règle de renouvellement proposée :

- chaque dresseur renouvelable peut être affronté une fois par cycle de repos ;
- un cycle est réinitialisé après une guérison effective au Centre Pokémon ou une utilisation effective du PC Pokémon ;
- le paiement de chaque dresseur reste faible et fixe par victoire ;
- l'obtention du badge du palier retire définitivement les dresseurs concernés du cycle de renouvellement ;
- les miniboss et boss ne sont jamais renouvelés par cette règle.

Le rôle de ces dresseurs est de fournir un revenu de secours, pas de devenir la source principale de richesse. Leur récompense doit rester nettement inférieure à celle d'un contrat de capture de valeur équivalente.

Les dresseurs d'histoire originaux doivent conserver leurs flags et leurs scripts de progression. Le système de rematch doit d'abord utiliser des personnages contrôlés par le mod, afin de ne pas casser les événements narratifs.

## 7. Exploration anticipée et personnages-barrages

Certains personnages peuvent bloquer l'accès à un passage, une grotte secondaire, une récompense ou un raccourci. Ils servent de miniboss ou de gardien de zone.

Règle de conception : ces barrages ne doivent pas bloquer la route principale nécessaire à l'obtention des badges. Ils peuvent protéger du contenu optionnel, une ressource rare ou une voie rapide. Le joueur doit comprendre pourquoi l'accès est bloqué et ce que le défi lui apportera.

## 8. Boss et liberté du joueur

- Aucun boss ne déclenche spontanément un combat en voyant le joueur.
- Le boss est visible, caché à découvrir ou annoncé par un indice.
- Le joueur doit interagir ou confirmer explicitement le défi.
- Le défi peut être ignoré sans bloquer la progression principale.
- La difficulté et les récompenses dépendent du palier de la zone.
- Une victoire donne des matériaux, de l'argent et/ou une récompense unique.
- Une défaite ne détruit aucun Pokémon.

Les boss sauvages ne doivent pas être capturables par accident si la récompense est conçue autour du combat et des matériaux. La règle exacte de capture reste à décider.

## 9. Densité de contenu proposée

La densité initiale demandée est la suivante :

| Emplacement | Contenu optionnel cible |
|---|---|
| Chaque ville | 1 miniboss de ville |
| Entre deux villes reliées par une route | 2 miniboss de route |
| Entre deux villes reliées par une route | 1 boss sauvage caché |
| Entre deux villes reliées par une route | 1 boss dresseur |

Ainsi, chaque segment de route contient quatre rencontres optionnelles majeures en plus des dresseurs ordinaires, et chaque ville possède son miniboss.

Cette densité constitue un objectif de contenu ambitieux. Elle devra être cartographiée sur le jeu choisi avant production : nombre de villes, routes, grottes, embranchements, zones secondaires et lieux intérieurs. Les boss ne doivent pas être simplement des combats identiques avec un niveau supérieur ; chaque rencontre doit avoir une identité, une mécanique ou une récompense propre.

## 10. Récompenses et sentiment de progression

Le joueur doit ressentir une différence claire entre :
- une victoire ordinaire : petite somme, progression de contrat ou accès à une route ;
- un miniboss : somme moyenne et matériau de palier ;
- un boss de route : matériau plus rare et récompense propre au combat ;
- un boss caché : découverte, matériau rare ou récompense spéciale ;
- un boss dresseur : équipe construite, objet rare, recette ou service débloqué ;
- un badge : plafond de niveau supérieur et nouvelle étape de progression.

Les récompenses sont conçues pour être complémentaires, pas interchangeables. L'argent finance les services ; les matériaux financent l'équipement spécial ; les Pokémon capturés peuvent financer les contrats ou servir de donneurs pour les services.
