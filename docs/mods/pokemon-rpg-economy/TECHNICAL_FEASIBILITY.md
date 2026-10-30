# Technical Feasibility — Gen1Recomp API 3

## 1. Référence et périmètre de l'étude

Cette étude est basée sur le submodule du dépôt G1R-Mods, épinglé à :

- Dépôt moteur : https://github.com/bryanthaboi/gen1recomp
- Commit audité : 0be34bc76cecf996e91d2f905d1b4bb5f14d43ae
- Documentation API Gen 3 : https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/docs/mod-api-gen3-compat.md
- Documentation API modding : https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/docs/modding.md

Le dépôt de mods utilise déjà le template API 3 et un SDK headless. La conception doit respecter l'API publique : pas d'import de modules internes du moteur et pas de modification directe de l'état interne du jeu depuis le Lua du mod.

## 2. Choix du jeu : Emerald uniquement

Le périmètre validé est **Pokémon Emerald uniquement**. Les autres versions Gen 3 ne font pas partie du premier mod. Les données et scripts propres à Hoenn doivent être la référence pour toutes les analyses de cartes, dresseurs, rencontres, boutiques, récompenses et tests.

La matrice du moteur identifie dans Emerald des capacités natives spécifiques : Match Call/PokéNav, arbres à baies, Pokéblocs, mélangeur, concours, bases secrètes, décorations, Battle Frontier, Battle Tents et Battle Pyramid. Les sources principales auditées sont [capabilities.lua](https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/core/game3/capabilities.lua), [berry_trees.lua](https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/core/game3/rse/berry_trees.lua) et [pokeblock.lua](https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/core/game3/rse/pokeblock.lua). Ces entrées et modules confirment la présence de systèmes natifs côté moteur ; ils ne garantissent pas à eux seuls qu'un mod peut appeler ou modifier chacune de leurs fonctions via l'API publique.

La base du mod reste Portable API 3. Les extensions moteur doivent être proposées lorsque les opérations requises ne sont pas exposées, plutôt que d'importer des modules internes depuis le mod.

## 3. Matrice de faisabilité

| Système | Support existant identifié | Évaluation |
|---|---|---|
| Supprimer l'EXP des combats | Hook battle.exp_award avec une répartition contrôlée | Faisable côté API publique |
| Supprimer les EV des combats | Les EV sont attribués dans le chemin d'attribution, avant l'application de l'EXP ; supprimer entièrement la récompense empêche aussi cet appel | Faisable via le même point, à tester |
| Modifier les équipes des dresseurs | Hook trainer.party qui reçoit la classe, l'identifiant du dresseur et son équipe ; il accepte une équipe transformée en retour | Faisable côté API publique |
| Réduire les paiements des dresseurs | Les données des dresseurs supportent baseMoney | Faisable pour le montant de base |
| Détecter les combats et les résultats | Événements battle.started, battle.ended et world.trainer_engaged | Faisable côté API publique |
| Ajouter des PNJ dynamiques | mod.world:spawnNpc, npc et removeNpc ; interaction via world.talk | Faisable, avec respawn contrôlé par le mod |
| Afficher des écrans propres au mod | Registre content.screens et mod.ui.push ; screen.pushed/screen.popped | Faisable, prototype d'interface requis |
| Sauvegarder les contrats et boss vaincus | mod.save pour les petits états liés à la sauvegarde ; mod.storage pour des données plus indépendantes | Faisable côté API publique |
| Déclencher un boss sauvage | mod.world:startWildBattle est documenté | Faisable pour un boss sauvage |
| Déclencher un boss dresseur entièrement personnalisé | Scripts/équipes de dresseur disponibles, mais la composition et le démarrage précis doivent être validés avec le jeu cible | Prototype requis |
| Réinitialiser les dresseurs après un soin ou le PC | Événements génériques screen.pushed, screen.popped, world.interacted et script.command ; pas d'événement public dédié « soin terminé » identifié | Prototype requis |
| Vendre et consommer un Pokémon du joueur | mod.world:party retourne des données détachées ; il n'existe pas d'opération publique générale pour consommer un membre de l'équipe ou un Pokémon de boîte | Extension moteur requise |
| Entraîner un Pokémon en niveau | Les scripts peuvent manipuler certaines données globales, mais pas offrir une opération publique transactionnelle de modification de niveau sur un Pokémon choisi | Extension moteur requise |
| Modifier nature, IV, EV | Le moteur possède ces données et des fonctions internes, mais le mod ne dispose pas d'une API publique générique de mutation sûre | Extension moteur requise |
| Enseigner un move et consommer un donneur | Données de learnset et d'egg-moves disponibles, mais pas d'opération publique de mutation/consommation de deux Pokémon | Extension moteur requise |
| Faire évoluer un Pokémon choisi via le service | Les évolutions natives existent ; le service ne dispose pas d'une API publique pour choisir et muter la cible contre un donneur | Extension moteur requise |
| Utiliser les Pokémon du PC comme monnaie | Pas d'API publique de lecture/consommation des boîtes identifiée | Extension moteur requise |
| Interdire les objets dans les combats de dresseurs et de boss | item.use couvre le chemin d'utilisation hors combat ; le chemin de combat passe par BattleItems.use et aucun hook battle-specific d'interdiction n'est documenté dans l'API Gen 3 étudiée | Extension moteur requise pour un blocage complet |
| Contrats de capture avec remise d'un Pokémon | pokemon.caught donne l'événement de capture ; catch.party_full permet une prise en charge dans le seul cas de l'équipe pleine ; cela ne fournit pas un système générique de vente depuis l'équipe/PC | Extension moteur requise |
| Modifier les prix d'objets | Registre items et prix des enregistrements disponibles ; le flux des boutiques Gen 3 utilise cependant des données/scripts natifs | Faisable en partie, prototype de boutique requis |
| Remplacer le panneau du Centre par un tableau | PNJ, interaction et écran custom sont disponibles ; intégration précise dans chaque Centre Emerald à cartographier | Prototype requis |
| Baies et Pokéblocs | Les systèmes natifs Emerald d'arbres à baies, Pokéblocs et mélangeur sont présents dans le moteur | Base native disponible ; interface de contrat mod à prototyper |
| Concours Pokémon | Le moteur répertorie les concours Emerald et leurs interfaces natives | Base native disponible ; récompenses et intégration guilde à prototyper |
| Base secrète et décorations | Les systèmes secret base et decorations sont identifiés comme propres à RSE/Emerald | Base native disponible ; usage comme quartier général à prototyper |
| Match Call / PokéNav | La capacité Match Call est présente pour Emerald | Base native disponible ; contrôle des rematchs et de leurs récompenses à prototyper |
| Battle Frontier | Battle Frontier, Battle Tents et Battle Pyramid sont identifiés pour Emerald | Base native disponible ; intégration comme contenu post-game à prototyper |

## 4. EXP et EV : détail important

Dans le moteur étudié, le flux d'attribution d'une récompense de combat appelle Pokemon.gainEVs avant Experience.apply. Par conséquent :

- faire retourner zéro à exp.gain n'empêche pas les EV ;
- utiliser battle.exp_award pour ne pas distribuer la récompense (et ne pas appeler le chemin d'attribution) empêche le gain d'EXP et l'appel d'attribution des EV ;
- les tests doivent vérifier séparément l'EXP, les EV, les niveaux, les annonces de montée de niveau et le comportement des objets tenus comme Exp Share.

Références :
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/core/game3/battle/experience.lua
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/core/game3/pokemon.lua
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/tests/modkit/cases/unified_gen3_battle_hooks.lua

## 5. Équipes et niveaux de dresseurs

Le hook trainer.party est un bon point d'entrée pour adapter les équipes. Dans le chemin Gen 3 étudié, il reçoit :
- la classe du dresseur ;
- l'identifiant du dresseur ;
- une représentation de son équipe.

Il renvoie une équipe transformée, qui est ensuite convertie vers les données natives utilisées par le combat.

Cela autorise un système de niveaux par zone, mais le hook ne reçoit pas directement un mapId. Le mod devra suivre la carte active via les événements d'entrée/sortie de carte et vérifier que le contexte est toujours cohérent au lancement du combat.

Le registre trainers peut également modifier le baseMoney pour réduire le gain des dresseurs ordinaires.

Références :
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/core/game3/battle_bridge.lua
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/core/game3/battle/prize.lua
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/docs/mod-api-gen3-compat.md

## 6. PNJ, dialogues et écrans

Les PNJ dynamiques sont disponibles par mod.world:spawnNpc. Leurs interactions peuvent être traitées par world.talk. Les PNJ dynamiques sont de portée session : ils doivent être recréés lorsque le joueur charge une sauvegarde ou entre dans une carte, selon l'état persistant du mod.

Les écrans custom sont fournis par content.screens et mod.ui. Cela permet de construire les interfaces du tableau de contrats, du guichet, du service d'arène et du Day Care.

Les événements screen.pushed et screen.popped existent, mais ils ne constituent pas à eux seuls une preuve que le joueur vient d'utiliser réellement un PC Pokémon. Il faudra identifier les écrans et scripts propres à Emerald et vérifier les chemins de retour et d'annulation.

Références :
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/docs/modding.md
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/world/WorldAPI.lua

## 7. Consommation et mutation de Pokémon : dépendance bloquante

C'est le principal écart entre le design et l'API existante.

mod.world:party() renvoie une copie détachée des Pokémon. Elle est utile pour afficher la liste, vérifier les prérequis et construire une interface, mais modifier cette copie ne modifie pas la sauvegarde.

L'API catch.party_full permet au mod de prendre en charge un Pokémon capturé lorsque l'équipe est pleine. Ce n'est pas une alternative générale à une opération de vente, de sacrifice ou de mutation : elle ne couvre pas les Pokémon déjà présents dans l'équipe ou dans les boîtes.

Il faudra donc proposer au moteur une API publique, sûre et transactionnelle, au minimum pour :
- lire l'identité stable d'un Pokémon d'équipe ou de boîte ;
- consommer un Pokémon choisi, après validation de son identité ;
- modifier le niveau et recalculer les statistiques ;
- modifier IV et EV avec les bornes du jeu ;
- changer la nature sans altérer incorrectement le sexe, le shiny, la capacité ou la forme ;
- enseigner une technique et vérifier la compatibilité ;
- déclencher une évolution sur une cible ;
- accéder aux Pokémon des boîtes pour les contrats et les services, ou décider officiellement de limiter les échanges à l'équipe.

Ces opérations doivent être atomiques : si la vérification, le paiement ou la modification échoue, aucun Pokémon ni argent ne doit être perdu.

### Cas particulier de la nature

En génération III, la nature dérive du Personality Value. Un changement de nature ne doit pas se limiter à modifier une étiquette de nature. Le moteur doit recalculer ou préserver les propriétés qui dépendent de la personnalité, notamment le sexe, le shiny et certaines formes.

Référence : https://bulbapedia.bulbagarden.net/wiki/Personality_value

## 8. Interdiction des objets en combat

La documentation Gen 3 classe item.use parmi les hooks présents, mais le code du hook observé se trouve dans le chemin d'utilisation des objets hors combat. Les objets de combat sont traités par src/core/game3/battle/items.lua.

L'interdiction demandée doit agir avant qu'un objet soit consommé ou qu'un effet soit appliqué. Il faut proposer un hook de politique de combat, par exemple un hook public de validation/filtrage des objets joueur, recevant le type de combat et l'objet sélectionné. Il doit pouvoir refuser tout objet de sac dans un combat de dresseur ou de boss, tout en laissant les Poké Balls accessibles dans les combats sauvages ordinaires.

Un simple message d'erreur après sélection serait moins bon qu'un retrait des choix interdits de l'interface.

Références :
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/core/game3/item_use.lua
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/core/game3/battle/items.lua
- https://github.com/bryanthaboi/gen1recomp/blob/0be34bc76cecf996e91d2f905d1b4bb5f14d43ae/src/mods/UnifiedCallbacks.lua

## 9. Détection d'un repos au Centre ou au PC

Le moteur documente des événements génériques d'interaction et d'écran, mais aucun événement explicite « soin du Centre terminé » n'a été identifié dans le contrat Gen 3.

La preuve de faisabilité devra vérifier :
- l'interaction exacte avec l'infirmière du Centre ;
- le moment précis où l'équipe est effectivement soignée ;
- l'identifiant de l'écran PC et le moment où un accès effectif à une boîte a lieu ;
- le cas où le joueur ouvre puis annule un menu ;
- le cas où un écran est rouvert sans effectuer d'opération ;
- le cas où le jeu quitte le Centre, charge une carte ou restaure une sauvegarde.

Le reset d'un cycle de dresseurs ne doit pas se déclencher plusieurs fois pour un seul accès. Le compteur de cycle est stocké par sauvegarde.

## 10. Matériaux et stockage

Les contrats, boss vaincus, rotations et cycles de rematch doivent être stockés dans l'espace de sauvegarde du mod. Les matériaux de boss peuvent d'abord être conservés dans cet espace privé plutôt que sous forme d'objets natifs, afin d'éviter de détourner prématurément les inventaires du jeu.

Si un inventaire de matériaux visible est nécessaire, l'écran du mod doit afficher clairement les quantités et les coûts. Une conversion en objets natifs pourra être étudiée après la validation des registres d'objets et des boutiques.

## 11. Prototypes à exiger avant production

Les prototypes suivants sont des preuves techniques, pas des fonctionnalités finales :

1. Bloquer EXP et EV dans un combat sauvage, puis dans un combat de dresseur, sans casser les autres événements de combat.
2. Modifier les niveaux d'une équipe de dresseur selon le mapId suivi par le mod.
3. Créer un PNJ de guilde, ouvrir un écran custom et conserver son état après chargement.
4. Détecter une guérison effective et un accès effectif au PC, sans faux reset.
5. Lancer un boss sauvage sur interaction et lancer un boss dresseur scripté sans auto-déclenchement.
6. Prouver une transaction de mutation/consommation de Pokémon avec rollback en cas d'échec.
7. Retirer les objets interdits de la sélection de combat, sans empêcher les Poké Balls dans les combats sauvages ordinaires.
8. Prototyper un contrat de baies, une commande de Pokéblocs et une récompense de concours, sans toucher aux données internes du moteur.
9. Vérifier l'accès au système de décoration des bases secrètes et définir si le quartier général sera une base secrète décorée ou une carte dédiée.
10. Tester Match Call pour un rematch appartenant au mod, sans réactiver ou payer les dresseurs narratifs de façon incorrecte.
11. Évaluer un défi de Zone de Combat post-game séparé de la progression badge et des cycles de rematch.

Aucune fonctionnalité dépendant d'une opération privée du moteur ne doit être déclarée faisable simplement parce qu'un module interne du moteur sait déjà le faire.
