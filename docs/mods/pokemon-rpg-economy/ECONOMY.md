# Economy — Pokédollars, captures et services

## 1. Principes économiques

Les Pokédollars deviennent la ressource centrale. Le joueur doit choisir entre augmenter le niveau de son équipe, acheter des outils de capture, acquérir des TM ou payer une amélioration spécialisée.

L'économie doit éviter deux extrêmes :
- une économie trop généreuse qui rend les choix insignifiants ;
- une économie trop pauvre qui bloque la progression si le joueur ne souhaite pas répéter un contenu.

La base de référence est désormais Pokémon Emerald. Les prix, niveaux, revenus et rencontres seront relevés dans Emerald uniquement, puis simulés palier par palier.

## 2. Sources et usages de l'argent

| Source | Fonction |
|---|---|
| Contrats de capture | Source principale de revenus réguliers |
| Dresseurs renouvelables des routes | Petit revenu de secours, répétable après repos |
| Minibosses | Paiement supérieur et matériau de palier |
| Boss cachés et boss dresseurs | Récompense majeure, principalement unique |
| Récompenses de progression | Prime ponctuelle liée à un badge ou une découverte |

| Dépense | Fonction |
|---|---|
| Entraînement de niveau | Dépense principale et récurrente |
| Poké Balls | Dépense fréquente qui alimente les contrats |
| Super Balls, Hyper Balls et autres outils | Dépense de capture qui augmente avec la progression |
| TM | Gros investissement dans la construction d'équipe |
| Services d'arène | Dépense élevée pour améliorer une équipe précise |
| Day Care | Prix et sacrifice d'un donneur pour un egg-move |
| Crafting d'objets tenus | Dépense de matériaux de boss et éventuellement d'argent |

Les soins au Centre Pokémon ne doivent pas devenir une dépense obligatoire si le joueur doit déjà investir dans la progression de son équipe. Le Centre est avant tout un point de repos et de renouvellement des dresseurs.

## 3. Rang de guilde et progression de réputation

En complément des badges, le joueur progresse dans une **réputation de guilde**. Les badges restent l'unique référence du plafond de niveau ; la réputation sert à débloquer des contrats spécialisés, des services, des remises limitées et des recettes.

Sources de réputation proposées :
- contrats de capture et contrats d'expédition complétés ;
- miniboss et boss vaincus pour la première fois ;
- découvertes de lieux et relevés d'espèces ;
- résultats remarquables dans les concours.

La réputation ne doit pas pouvoir être farmée à l'infini par un seul contrat ou un même dresseur renouvelable. Chaque activité possède un plafond, un premier succès récompensé ou une rotation contrôlée. Elle ne remplace jamais les badges et ne permet pas de dépasser le plafond de niveau.

## 4. Baies et Pokéblocs : deuxième boucle économique

Emerald possède des arbres à baies, un mélangeur et des Pokéblocs. Le mod devrait s'appuyer sur cette activité plutôt que d'inventer un système de récolte entièrement séparé.

Boucle proposée :
1. récolter et cultiver des baies au fil de l'exploration ;
2. répondre à des contrats de livraison de baies précises ou de lots ;
3. transformer certaines baies en Pokéblocs ;
4. remettre des Pokéblocs ou les utiliser pour préparer un Pokémon aux concours ;
5. obtenir des Pokédollars, des points de réputation, des rubans ou des recettes de collection.

Les Pokéblocs doivent rester utiles sans devenir des consommables de combat. La règle d'interdiction des objets en combat de dresseur et de boss ne doit pas être contournée par des bonus activés avant le combat.

Les baies peuvent aussi servir à des contrats d'approvisionnement, ce qui donne une source de revenu qui ne nécessite pas de sacrifier un Pokémon. Les taux de récompense doivent prendre en compte le temps de culture, la rareté de la baie et le rendement réel.

## 5. Tableau de contrats de capture

Un tableau de contrats est installé dans chaque Centre Pokémon, à la place de l'affichage mural/cartographique retenu pour ce système. Un personnage placé à côté du tableau gère les contrats et le rachat.

### Génération des contrats

Les contrats proviennent des espèces réellement rencontrables dans les zones proches du Centre. Le tableau doit proposer plusieurs niveaux de rareté et indiquer clairement :
- l'espèce recherchée ;
- la zone de référence ;
- la rareté ou la difficulté d'obtention ;
- la somme payée ;
- les conditions de remise.

Proposition initiale : trois contrats actifs à la fois, renouvelés lors d'un changement de palier ou d'une rotation contrôlée. Un simple soin ou une ouverture du PC ne doit pas permettre de reroller gratuitement les contrats.

### Paiement selon la rareté

Le montant dépend de trois facteurs :

1. le palier de la zone ;
2. la rareté de l'espèce dans les rencontres locales ;
3. la difficulté réelle de la capture.

La rareté doit être calculée à partir des tables de rencontres et des taux pondérés, et non à partir d'une classification subjective seule. Les espèces communes financent les dépenses de base ; les espèces rares constituent des contrats plus rentables mais demandent plus de Poké Balls et de temps.

### Acceptation et remise

Le contrat doit être accepté avant la capture. La remise est effectuée au guichet voisin du tableau. Le Pokémon est alors consommé et le paiement versé après confirmation du joueur.

Un contrat ne peut être payé qu'une fois. Un même Pokémon ne peut pas valider plusieurs contrats. Les captures antérieures à l'acceptation d'un contrat ne doivent pas être acceptées automatiquement, sauf décision contraire.

La remise de Pokémon provenant du PC/boîtes doit être couverte. Le moteur actuel n'expose pas encore une opération publique générique pour consommer proprement un Pokémon stocké ; ce point est bloquant pour une implémentation complète.

## 6. Prix des outils de capture

Les Poké Balls, Super Balls, Hyper Balls et autres outils de capture doivent être moins chers que dans le jeu d'origine, car les contrats de capture deviennent une source de revenus essentielle.

Cette réduction ne signifie pas qu'ils doivent être gratuits. Leur prix doit encore représenter une dépense réelle, en particulier lorsqu'un contrat demande une espèce rare ou nécessite de nombreux essais.

Le prix peut progresser avec les paliers, mais la disponibilité des outils doit rester cohérente avec le niveau de risque de la zone.

## 7. Entraînement : niveaux achetés

Le service d'entraînement remplace la progression par EXP. Le joueur paie pour faire monter un Pokémon d'un ou plusieurs niveaux, dans la limite du plafond de badges.

Proposition de tarification :
- le prix d'un niveau augmente avec le niveau demandé ;
- le prix augmente également avec le palier de campagne ;
- l'achat de plusieurs niveaux doit afficher le coût total avant confirmation ;
- le service refuse toute transaction qui dépasserait le plafond ou le niveau maximal du jeu.

Le coût doit être suffisamment élevé pour que le joueur ne puisse pas entraîner toute l'équipe au maximum immédiatement après un seul contrat. Les premiers niveaux doivent néanmoins rester accessibles afin d'éviter un blocage au début de partie.

Le service de niveau est conçu comme une dépense d'argent. Il ne consomme pas de Pokémon donneur dans la proposition initiale ; cette exception doit être validée dans les décisions ouvertes.

## 8. Services de l'arène

Un personnage de service est associé à chaque arène. Les services sont débloqués progressivement et leur prix dépend du palier. Les modifications sont transactionnelles : validation des conditions, confirmation du joueur, consommation du donneur et paiement doivent être effectués ensemble, sans perte partielle en cas d'erreur.

### Changement de nature

- Le Pokémon cible reçoit une nouvelle nature.
- Le joueur doit fournir un autre Pokémon possédant la nature désirée.
- Le donneur est consommé.
- Des Pokédollars sont également demandés.

La nature de génération III est liée au Personality Value du Pokémon. L'opération doit donc préserver correctement les autres propriétés dépendantes de cette valeur, notamment le statut shiny, le sexe et la forme lorsque cela s'applique. Une simple modification d'un champ affiché n'est pas suffisante.

### Augmentation d'IV

- Le service ajoute un point d'IV à une statistique donnée.
- Le maximum est 31 par statistique.
- Un donneur possédant une nature qui augmente la statistique ciblée est consommé.
- Le joueur paie un montant élevé, croissant avec la valeur de l'amélioration et le palier.

Exception à définir : les PV ne sont augmentés par aucune nature. Le type de donneur requis pour l'IV PV doit donc être différent ou faire l'objet d'une règle dédiée.

### Entraînement d'EV

Les combats ne donnent aucun EV. Le service d'arène est l'unique moyen d'en obtenir.

Contraintes de génération III à respecter :
- 252 EV efficaces maximum par statistique ;
- 510 EV au total ;
- les valeurs supérieures à 252 dans une statistique n'apportent pas de bénéfice utile équivalent.

Proposition utilisateur à conserver pour l'étude : chaque point d'EV demandé consomme un Pokémon donneur répondant à un seuil de niveau associé à l'investissement, plus un paiement en Pokédollars proportionnel à l'EV demandé.

Ce modèle peut devenir extrêmement coûteux : une seule statistique optimisée à 252 EV pourrait demander jusqu'à 252 donneurs. Il doit donc être simulé avant validation. Une alternative à évaluer serait qu'un donneur fournisse un lot d'EV déterminé par son niveau, tout en gardant un prix monétaire croissant.

### Apprentissage d'une technique

Le service permet d'enseigner une technique au Pokémon cible si celui-ci est compatible avec la technique. Le joueur fournit un donneur connaissant la technique ; ce donneur est consommé et le joueur paie le service.

Les techniques disponibles doivent être séparées en catégories :
- techniques compatibles par apprentissage naturel ou tutorat ;
- techniques accessibles via TM ;
- egg-moves, réservés au Day Care.

Le service doit vérifier la compatibilité avant de consommer le donneur.

### Évolution

Le service d'évolution permet de déclencher une évolution contre paiement et consommation d'un Pokémon catalyseur. Les méthodes acceptées (niveau, pierre, échange, condition spéciale) devront être définies espèce par espèce ou par catégorie.

Le Pokémon cible ne doit jamais être consommé par erreur : seul le donneur explicitement sélectionné sert de paiement.

## 9. Boutique de TM

Un commerçant spécialisé propose la collection de TM disponible pour le jeu cible.

- Les TM sont volontairement très chers.
- Leur disponibilité peut être débloquée par badges ou paliers.
- Les prix constituent un investissement concurrent de l'entraînement.
- Les HM et les techniques à restrictions particulières ne sont pas automatiquement incluses.
- Les prix et stocks doivent être audités par jeu, car les boutiques de troisième génération sont souvent pilotées par des données/scripts natifs.

L'objectif est de rendre l'accès à une technique puissant mais réfléchi, sans rendre les TM inutilisables.

## 10. Day Care : egg-moves et échange d'œufs

### Transmission d'un egg-move

Le Day Care propose un service distinct des services d'arène :
- le Pokémon cible doit pouvoir apprendre l'egg-move ;
- le donneur doit connaître la technique ;
- le donneur est consommé ;
- le joueur paie le service.

La compatibilité doit provenir des données d'egg-moves du jeu. Le service ne doit pas permettre d'enseigner une technique à une espèce incompatible.

### Échange de cinq œufs

Le joueur peut remettre cinq œufs pour recevoir un Pokémon non évolué de premier stade.

Règles proposées :
- les cinq œufs sont consommés ;
- le Pokémon reçu est tiré au sort dans une sélection contrôlée de dix espèces ;
- aucune espèce légendaire n'est éligible ;
- le Pokémon reçu est généré directement au niveau 5 ;
- la liste des dix espèces peut changer selon le palier, afin de préserver la valeur de l'échange.

Le niveau 5 correspond au niveau normal d'éclosion en génération III. Le service remet donc un Pokémon déjà généré au niveau 5, et non un œuf à faire éclore. Il faut préserver les règles de création normales du Pokémon (nature, IV, capacité, personnalité, moves de départ) et exclure explicitement les espèces légendaires et les formes qui ne sont pas de premier stade.

## 11. Matériaux et objets tenus

Les miniboss et boss fournissent des matériaux identifiés par palier. Ces matériaux ne remplacent pas les Pokédollars : ils constituent une seconde économie réservée aux récompenses rares.

Un personnage de crafting dans les arènes échange les matériaux de boss contre des objets tenus rares, par exemple :
- Leftovers ;
- Choice Band ;
- autres objets stratégiques propres au jeu cible.

Les recettes doivent être déterministes et lisibles : le joueur sait quel boss ou quel type de matériau lui manque. Les matériaux de haut palier ne doivent pas être remplaçables par une grande quantité d'argent seul.

## 12. Garde-fous contre les abus

- Une capture remise à un contrat est supprimée avant paiement, dans une transaction atomique.
- Un Pokémon vendu ne peut pas également être donneur d'un service.
- Un donneur consommé ne peut pas être réutilisé.
- Un contrat ne peut pas être validé plusieurs fois par le même Pokémon.
- Les contrats ne rerollent pas au soin ou à l'ouverture du PC.
- Un dresseur renouvelable ne paie qu'une fois par cycle.
- Les boss majeurs et leurs matériaux uniques ne se réinitialisent pas via le repos.
- Un service vérifie l'espace, les limites, la compatibilité, le solde et le donneur avant de faire la moindre mutation.
- Toute opération affiche clairement le coût en argent et les Pokémon qui seront consommés.
