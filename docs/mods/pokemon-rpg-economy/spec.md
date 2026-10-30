# Spec — Plan d'implémentation du mod Pokémon RPG Economy

**Statut :** plan d'exécution v1 — après fusion du dossier de conception  
**Mod :** `pokemon-rpg-economy`  
**Jeu cible :** Pokémon Emerald uniquement  
**Dépôt :** [rakmahefa/G1R-Mods](https://github.com/rakmahefa/G1R-Mods)  
**Dossier de conception :** [README](README.md)  
**Point de départ :** PR [#3](https://github.com/rakmahefa/G1R-Mods/pull/3), fusionnée dans `main` par le commit `8326759ab9316907ca453e5d0d095e6221805201`.

---

## 1. Objectif

Ce document transforme le dossier de conception accepté en un plan de réalisation ordonné, testable et découpé en livrables. Il définit les dépendances techniques, les étapes de développement, les tests de sortie et les limites à respecter.

Le but n'est pas de coder toutes les fonctionnalités d'un seul coup. La priorité est de prouver les points où l'API publique Gen1Recomp ne suffit pas encore, puis de construire une première boucle de jeu jouable sans corruption de sauvegarde, perte involontaire de Pokémon, duplication de récompenses ou blocage économique.

**État actuel :** le design est documenté et fusionné. Aucun code de gameplay du mod n'a encore été implémenté. Ce plan ne constitue pas une autorisation de contourner les limites de l'API publique ou de modifier directement les données internes du moteur.

## 2. Périmètre et règles de conception verrouillées

### 2.1 Jeu et plateforme

- Cible exclusive : **Pokémon Emerald** (région de Hoenn).
- API de modding : API 3 de Gen1Recomp.
- Ruby, Sapphire, FireRed et LeafGreen ne font pas partie de la première cible.
- Le sous-module moteur reste épinglé à la révision upstream définie par le dépôt. Ne pas le mettre à jour dans le cadre de ce travail sans tâche distincte, justification et tests.
- Aucun ROM, octet dérivé d'une ROM, cache de jeu ou fichier de sauvegarde privé ne doit être commité.

### 2.2 Progression et combats

- Aucun gain d'EXP ni d'EV à la suite d'un combat, qu'il soit sauvage, de dresseur ou de boss.
- La montée de niveau est achetée auprès d'un service, contre Pokédollars.
- Les plafonds de niveau progressent avec les badges. Le barème actuel (12, 18, 24, 30, 36, 42, 48, 54, 60, puis 70 en post-game) reste une **proposition à équilibrer**, pas un chiffre final verrouillé.
- Le contrôle du plafond doit couvrir les Pokémon capturés, reçus, générés, retirés des boîtes et réintégrés dans l'équipe.
- Les objets du sac sont interdits pendant les combats de dresseurs et de boss. Les objets tenus restent proposés comme autorisés ; cette règle doit être confirmée avec les autres décisions de combat.
- Les Poké Balls restent utilisables dans les combats sauvages ordinaires.
- Aucun boss ne déclenche un combat par proximité. Le joueur initie ou confirme le défi.
- Pas de Nuzlocke et pas de permadeath.

### 2.3 Économie

- Les Pokédollars sont la monnaie principale.
- Les contrats de capture forment la principale source de revenus réguliers.
- Les contrats de baies et d'expédition sont une voie de revenu complémentaire, sans sacrifice obligatoire de Pokémon.
- Les dresseurs de guilde renouvelables paient peu et ne sont disponibles qu'une fois par cycle contrôlé.
- Les matériaux de boss financent le crafting spécialisé.
- La réputation de guilde débloque du contenu ; elle n'est pas une monnaie dépensable.
- Les systèmes Emerald acceptés (baies, Pokéblocs, concours, base secrète/quartier général, Match Call/PokéNav, défis météo/doubles, expéditions) sont intégrés par étapes. La Zone de Combat est réservée au post-game.

### 2.4 Échange Day Care de cinq œufs — règle verrouillée

Le processus doit respecter exactement le déroulement suivant :

1. Le joueur lance l'échange de cinq œufs au Day Care.
2. Avant le lancement, l'interface annonce explicitement :
   - les cinq œufs seront consommés ;
   - une fois l'échange lancé, une annulation ne rendra pas les œufs ;
   - le joueur a **10 % de risque de ne recevoir aucun Pokémon**.
3. Après confirmation du lancement, les cinq œufs sont consommés définitivement.
4. Le système tire dix espèces **distinctes** dans le pool admissible.
5. Il génère réellement dix Pokémon — un pour chaque espèce — directement au niveau 5. Ce ne sont pas dix noms ou aperçus abstraits : le joueur choisira parmi les dix Pokémon générés.
6. Le joueur examine les dix candidats et choisit exactement un Pokémon.
7. Le tirage de réception est effectué une seule fois après ce choix :
   - **90 %** : le joueur reçoit exactement le Pokémon choisi ;
   - **10 %** : le joueur ne reçoit aucun Pokémon.
8. Une annulation après le lancement, ou le résultat volontaire de non-réception à 10 %, ne restitue pas les cinq œufs. Le résultat est annoncé clairement.
9. Aucun re-tirage, rechargement ou nouvel essai ne doit permettre de récupérer les œufs, de changer les dix candidats après coup ou de relancer le tirage de 90/10.

Règles d'éligibilité des dix espèces :

- dix espèces différentes ;
- aucune espèce légendaire ;
- uniquement des espèces de premier stade / forme de base, qui ne sont pas déjà évoluées ;
- pool à définir, éventuellement filtré par palier ;
- génération au niveau 5 avec les caractéristiques normales d'un Pokémon Gen 3 (nature, IV, capacité, personnalité, attaques de départ).

**Important :** le résultat volontaire de non-réception à 10 % est une règle du jeu. Une erreur technique (sauvegarde pleine, exception moteur, échec d'insertion, fermeture pendant une transaction) n'est pas un tirage aléatoire. Elle doit être gérée par un état transactionnel persistant et ne doit ni déclencher un nouveau tirage opportuniste ni être présentée comme un échec aléatoire normal.

---

## 3. Principes d'architecture et de qualité

1. **API publique d'abord.** Utiliser les hooks et API documentés de Gen1Recomp. Ne pas importer ou appeler des modules internes du moteur depuis le mod.
2. **Extensions explicites.** Si une opération manque à l'API publique, documenter la fonction, ses invariants, ses tests et proposer une extension moteur dédiée. Ne pas simuler une mutation en modifiant une copie détachée.
3. **Transactions atomiques.** Vérifier toutes les préconditions avant le paiement ou la consommation. Chaque opération doit avoir un résultat unique et persistant.
4. **Idempotence.** Recharger, répéter une interaction ou recevoir deux callbacks ne doit pas dupliquer un paiement, un Pokémon, un matériau ou une récompense.
5. **État versionné.** Les contrats, cycles, boss vaincus, matériaux et opérations en cours doivent être stockés avec un schéma versionné et une stratégie de migration.
6. **Headless en premier.** La logique économique, les règles, les tirages et les transitions d'état doivent être testés sans ROM avec le SDK fourni.
7. **Validation en jeu ensuite.** Les scripts Emerald, menus natifs, Centres Pokémon, PC, combats, cartes et animations nécessitent des vérifications en jeu.
8. **Livrables petits et vérifiables.** Une étape ne passe pas à la suivante tant que ses critères de sortie ne sont pas satisfaits.

## 4. Dépendances techniques prioritaires

Les constats ci-dessous proviennent de `TECHNICAL_FEASIBILITY.md` et doivent être revalidés sur la révision moteur effectivement épinglée avant toute conclusion nouvelle.

| Capacité | État recensé | Conséquence pour le plan |
|---|---|---|
| Bloquer EXP et EV via `battle.exp_award` | API publique identifiée ; tests nécessaires | Prototype prioritaire |
| Modifier les équipes d'un dresseur via `trainer.party` | API publique identifiée ; le hook ne reçoit pas directement le mapId | Prototype de suivi de carte et de niveaux |
| Ajouter PNJ et écrans | API publique identifiée | Prototype UI / cycle de vie session |
| Sauvegarder des données du mod | `mod.save` / `mod.storage` documentés | Définir un schéma persistant versionné |
| Soins effectifs / PC effectif | Pas d'événement public explicite identifié | Prototype de détection Emerald ; aucun reset sur simple ouverture |
| Consommer un Pokémon d'équipe ou de boîte | Pas d'opération publique générale identifiée | Extension moteur sûre et transactionnelle |
| Modifier niveau, nature, IV, EV, moves ou évolution d'un Pokémon choisi | API publique générique non identifiée | Extension moteur / preuves par opération |
| Lire et consommer les Pokémon des boîtes | API publique non identifiée | Décider équipe seule ou boîte + équipe |
| Filtrer les objets de sac dans les combats | Hook public spécifique manquant dans l'audit | Extension moteur requise pour blocage complet |
| Remettre un Pokémon de contrat de capture | Capture détectable, mais remise/consommation générique manquante | Dépend de l'API de stockage/mutation |
| Baies, Pokéblocs, concours, bases, Match Call, Frontier | Capacités Emerald natives identifiées | Prototypes d'intégration, pas présumer une exposition mod complète |

### Ordre des risques techniques

1. Mutation/consommation transactionnelle des Pokémon (bloquant pour contrats et services).
2. Suppression conjointe EXP/EV et respect du plafond de niveau.
3. Filtrage des objets pendant les combats.
4. Détection exacte d'un soin effectif et d'une utilisation effective du PC.
5. Génération et stockage transactionnels de dix Pokémon pour le Day Care.
6. Intégration des interfaces Emerald et des activités secondaires.

---

## 5. Plan de réalisation par phases

### Phase 0 — Préparation du dépôt et gel des décisions

**Objectif :** établir une base de travail reproductible et fermer les règles qui affectent les données du joueur ou l'économie.

Tâches :
- synchroniser `main` après la PR #3 ;
- initialiser les sous-modules et dépendances selon le guide de développement ;
- exécuter les commandes existantes de validation, test et packaging du dépôt ;
- confirmer la révision exacte du sous-module Gen1Recomp ;
- définir le nom de travail final, sans bloquer la preuve technique ;
- décider les points listés dans `OPEN_DECISIONS.md` :
  - barème final des plafonds et comportement d'un Pokémon capturé au-dessus du plafond ;
  - dresseurs renouvelables et sémantique exacte du repos Centre/PC ;
  - accès aux Pokémon d'équipe et/ou de boîte ;
  - protection du dernier Pokémon utilisable, Pokémon favoris, shiny et cadeaux/événements ;
  - entraînement de niveau avec ou sans donneur ;
  - IV PV et coût de montée d'IV ;
  - EV par point ou par lot lié au niveau du donneur ;
  - méthodes d'évolution couvertes ;
  - moves tutorés, TM et HM ;
  - confirmation définitive des règles objets de sac / objets tenus ;
  - capture/réapparition/récompenses des boss ;
  - stock visible ou inventaire privé des matériaux ;
  - densité des boss selon la géographie réelle de Hoenn.
- préciser le pool des dix espèces du Day Care et son mode de sélection/rotation, sans changer la règle 10 candidats générés + choix + 90/10.

**Livrables :**
- état initial du dépôt consigné ;
- tableau des décisions (validé / à décider / bloqué) ;
- commandes de test initiales et résultats enregistrés.

**Critères de sortie :**
- `make check`, `make test` et `make smoke-template` donnent un état de référence exploitable (les échecs préexistants sont documentés) ;
- aucune règle destructive ou de progression n'est laissée implicite.

### Phase 1 — Prototypes techniques API 3 / moteur

**Objectif :** prouver les points bloquants dans des prototypes isolés, sans construire encore tout le gameplay.

#### 1A. EXP et EV

- créer un cas de test headless sur `battle.exp_award` ;
- vérifier combat sauvage, combat de dresseur, miniboss/boss ;
- vérifier séparément l'EXP, les EV, les messages de montée de niveau et Exp Share ;
- vérifier qu'aucun hook annexe ne réintroduit des EV.

**Sortie :** preuve automatisée que les deux récompenses sont supprimées ensemble, ou proposition d'extension moteur documentée.

#### 1B. Équipes de dresseurs / niveaux par zone

- tester `trainer.party` ;
- suivre le mapId via les événements d'entrée/sortie de carte ;
- tester les transitions de carte, combats démarrés par script et contextes périmés ;
- prouver que les dresseurs d'histoire gardent leurs flags et scripts ;
- tester les niveaux Emerald palier par palier.

**Sortie :** prototype de mise à l'échelle déterministe sans fuite de contexte de carte.

#### 1C. Transactions Pokémon (bloquant majeur)

Définir et prouver une API publique, ou préparer une proposition moteur, qui permette au minimum :
- identifier de façon stable un Pokémon dans l'équipe ou une boîte ;
- valider qu'il s'agit toujours du même Pokémon au moment de l'opération ;
- lire et écrire les données utiles ;
- consommer un donneur ou un Pokémon remis à un contrat ;
- ajouter un Pokémon généré à l'équipe ou à la boîte ;
- effectuer paiement, consommation et mutation en une opération atomique ;
- annuler proprement avant commit ;
- protéger shiny/favoris/cadeaux/dernier Pokémon selon les décisions prises ;
- gérer sauvegarde, crash et reprise sans duplication ni perte imprévue.

Tester au moins une opération de consommation et une opération de mutation sur cible avec rollback forcé.

**Sortie :** preuve de transaction atomique documentée et testée, ou liste explicite d'extensions nécessaires. Ne pas implémenter les services qui dépendent de cette capacité avant ce résultat.

#### 1D. Objets de sac en combat

- identifier le point de décision dans le chemin des objets de combat ;
- concevoir un hook public recevant le contexte du combat et l'objet ;
- retirer les objets interdits de l'interface avant validation ;
- conserver les Poké Balls en combat sauvage normal ;
- tester dresseurs, boss sauvages et boss dresseurs ;
- vérifier que les objets tenus ne sont pas touchés.

**Sortie :** preuve de filtrage complet ou extension moteur approuvée.

#### 1E. Repos Centre / PC

- tracer le script Emerald de soin jusqu'à la guérison effective ;
- tracer l'accès PC jusqu'à la consultation effective d'une boîte ;
- distinguer ouverture, navigation, annulation et opération effective ;
- empêcher plusieurs resets pour une même visite ;
- persister le numéro de cycle par sauvegarde.

**Sortie :** suite de tests sans faux reset ni double reset.

#### 1F. Day Care — transaction à risque

- obtenir/générer dix espèces distinctes et éligibles ;
- générer dix Pokémon complets au niveau 5 ;
- montrer les dix Pokémon, et non uniquement des espèces ;
- enregistrer les candidats avant le choix et conserver exactement ces candidats après rechargement ;
- enregistrer le choix du joueur ;
- exécuter une seule décision 90/10 après le choix ;
- garantir 90 % de remise exacte du candidat sélectionné et 10 % sans Pokémon ;
- consommer les cinq œufs au démarrage confirmé ;
- persister les états de l'opération pour éviter reroll, remboursement ou duplication après fermeture/rechargement ;
- traiter séparément une panne technique : reprendre le même résultat enregistré, jamais relancer silencieusement le hasard ;
- informer le joueur avant le démarrage et à l'issue de l'opération.

**Sortie :** tests reproductibles pour succès, échec à 10 %, annulation après lancement, fermeture/reprise et erreur de remise.

### Phase 2 — Squelette du mod et fondations de sauvegarde

**Objectif :** créer un mod Emerald propre, isolé, testable et désactivable.

Tâches :
- créer `mods/pokemon-rpg-economy/` depuis `templates/mod-template/` ;
- déclarer API 3 et Emerald uniquement dans le manifeste ;
- organiser les modules : bootstrap, config, progression, économie, contrats, PNJ/UI, données, persistance ;
- définir version de schéma save, migrations, valeurs par défaut et reset de debug ;
- établir des identifiants stables pour contrats, PNJ, trainers et boss ;
- ajouter les tests headless du chargement, du manifeste, des hooks et de la migration ;
- documenter les commandes exactes de lint, tests et packaging.

**Critères de sortie :**
- le mod est découvert et chargé par le SDK ;
- tests et lint passent ;
- désactivation du mod ne laisse pas de données ou comportements corrompus ;
- aucun système de progression n'est encore activé par défaut sans prototype requis.

### Phase 3 — Première boucle économique jouable

**Objectif :** produire un slice vertical limité à une ville de départ et une route.

Fonctionnalités :
- suppression EXP/EV de combat ;
- plafond de niveau par badges, contrôlé aux points d'entrée/sortie appropriés ;
- service d'entraînement payé ;
- tableau de contrats de capture local ;
- acceptation d'un contrat avant capture ;
- remise et paiement transactionnels ;
- quelques dresseurs de guilde renouvelables ;
- prix de Poké Balls ajustés ;
- contrat simple de livraison de baies comme alternative ;
- dialogues clairs, sauvegarde/reprise et journalisation debug désactivable.

**Critères de sortie :**
- le joueur peut commencer un contrat, capturer, remettre, recevoir le paiement et entraîner son équipe ;
- il peut progresser sans devoir farmer une source unique ;
- aucune capture ne paie deux fois ;
- aucun reset d'histoire vanilla ;
- le cycle de revenu est contrôlé ;
- pas de softlock économique sur le slice choisi.

### Phase 4 — Services d'optimisation et Day Care

Fonctionnalités à ajouter une par une, chacune avec tests :
- changement de nature ;
- IV, dont règle spécifique PV ;
- EV avec modèle de donneur validé ;
- apprentissage de techniques ;
- évolution par service ;
- boutique de TM ;
- egg-moves au Day Care ;
- échange risqué de cinq œufs conforme à la section 2.4.

**Critères de sortie :**
- limites Gen 3 respectées ;
- aucun Pokémon cible consommé à la place du donneur ;
- protection des Pokémon et confirmations respectées ;
- transaction et sauvegarde cohérentes ;
- échange de cinq œufs testé statistiquement et fonctionnellement, sans reroll exploitable.

### Phase 5 — Boss, matériaux et contenu optionnel

Fonctionnalités :
- un miniboss de ville ;
- deux minibosses sur un segment de route pilote ;
- un boss sauvage caché ;
- un boss dresseur ;
- interaction/confirmation explicite ;
- équipes météo, doubles combats et stratégies distinctes ;
- matériaux de boss et inventaire de guilde ;
- recettes d'objets tenus ;
- récompenses uniques et état persistant.

**Critères de sortie :**
- aucun boss ne déclenche un combat automatiquement ;
- défi refusé possible ;
- aucun boss unique réinitialisé au repos ;
- récompenses non duplicables ;
- contenu optionnel ne bloque jamais la progression principale.

### Phase 6 — Extension Hoenn et progression de guilde

Intégrer selon valeur et disponibilité API :
- rang/réputation de guilde ;
- contrats de baies avancés ;
- commandes de Pokéblocs et concours ;
- contrats d'expédition (Safari Zone, Plongée, grottes et lieux cachés) ;
- Match Call / rematchs gérés par la guilde ;
- base secrète comme quartier général ou carte dédiée, selon prototype ;
- personnage/activité et récompenses associés.

La densité cible de boss (un miniboss par ville, deux miniboss + un boss sauvage caché + un boss dresseur par segment de route) doit être adaptée à la géographie réelle de Hoenn. La qualité et l'identité des rencontres priment sur un remplissage mécanique.

### Phase 7 — Post-game, équilibrage et livraison

- Zone de Combat et défis d'élite ;
- matériaux/recettes haut niveau ;
- simulation complète des revenus et dépenses ;
- test de progression badge par badge ;
- test de compatibilité sur Emerald ;
- sauvegarde/reprise à tous les jalons ;
- build/package reproductible ;
- notes de version, limites connues et procédure d'installation ;
- tests de non-régression du monorepo.

**Critère de sortie :** version jouable cohérente sur le parcours convenu, sans duplication, softlock ou perte involontaire de progression.

---

## 6. Plan de test transversal

### 6.1 Tests headless obligatoires

- Chargement du mod, manifeste et compatibilité Emerald.
- Hooks de combat : aucune EXP et aucun EV, y compris cas Exp Share.
- Adaptation des équipes et caps par badge/carte.
- Contrats : états, paiement unique, espèce/zone/conditions et sauvegarde.
- Dresseurs renouvelables : une victoire par cycle, cycle incrémenté une fois.
- Transactions Pokémon : identité, protections, commit, rollback et reprise.
- Natures : shiny/sexe/forme/capacité et propriétés dépendantes du Personality Value.
- IV 0–31 ; EV 252 par statistique / 510 total.
- Moves et évolutions légales.
- Day Care : dix espèces et dix Pokémon générés distincts, niveau 5, choix, 90/10, œufs consommés, annulation, reprise et anti-reroll.
- Boss et matériaux : récompense unique, pas de reset abusif.
- Migrations de sauvegarde et désactivation.

### 6.2 Tests en jeu obligatoires

- Centres Pokémon Emerald, PNJ, tableau, guichet et dialogues.
- PC/boîtes : ouvertures, accès effectif, transferts et annulation.
- Soin : guérison effective, équipe déjà saine, double interaction.
- Combats sauvages, dresseurs, miniboss et boss.
- Objets de sac et Poké Balls selon contexte ; objets tenus.
- Génération et ajout d'un Pokémon à l'équipe ou au PC.
- Day Care complet, prévisualisation des dix candidats et choix.
- Baies, Pokéblocs, concours, base secrète, Match Call, Frontier quand activés.
- Save/load, fermeture/reprise pendant chaque étape transactionnelle.

### 6.3 Règles globales d'acceptation

- Aucun paiement, œuf, Pokémon, objet ou matériau dupliqué.
- Aucune mutation partielle.
- Aucun Pokémon perdu en dehors d'une consommation explicitement annoncée et confirmée.
- Aucun comportement narratif vanilla réinitialisé involontairement.
- Aucun système dépendant d'une API interne non documentée.
- Aucun softlock de progression ou d'économie.
- Toute opération destructive affiche le coût, le Pokémon concerné, l'effet et les risques avant confirmation.

## 7. Organisation du travail et règles Git

- Travailler sur des branches courtes, une phase ou un prototype par PR.
- Garder `main` stable et fusionner les prototypes isolément après revue.
- Ne pas mélanger refactor, contenu, modifications moteur et packaging dans une seule PR.
- Toute extension moteur doit être justifiée par une lacune de l'API publique, testée upstream et documentée ; le sous-module ne doit pas être modifié silencieusement.
- Ajouter les tests au même changement que la fonctionnalité.
- Actualiser `OPEN_DECISIONS.md`, `TECHNICAL_FEASIBILITY.md` et ce plan à mesure que les décisions et les résultats changent.
- Mettre à jour `session_handoff.md` à la fin de chaque session de travail significative.

## 8. Prochaine session — première séquence recommandée

1. Cloner/synchroniser le dépôt et sous-modules depuis `main), vérifier le commit courant et la révision moteur.
2. Lire `docs/development.md`, `docs/architecture.md`, le template, le SDK headless et les trois documents techniques du mod.
3. Exécuter `make bootstrap`, `make check`, `make test`, `make smoke-template` et consigner le résultat réel.
4. Créer une branche de travail dédiée aux prototypes, pas au gameplay complet.
5. Commencer par une preuve headless minimale pour `battle.exp_award` (EXP et EV ensemble).
6. En parallèle, rédiger le contrat attendu de l'API de transaction Pokémon : identifiant stable, opérations supportées, invariants, rollback, sauvegarde et reprise.
7. Établir un tableau « API publique / prototype / extension requise / décision produit » avant de démarrer la Phase 2.

**Ne pas commencer la construction complète de l'overhaul avant d'avoir clarifié la dépendance majeure de mutation/consommation des Pokémon.**

## 9. Références internes

- [Vision et index](README.md)
- [Règles du jeu](GAME_DESIGN.md)
- [Économie et Day Care](ECONOMY.md)
- [Personnages et défis](ACTIVITIES_AND_CHARACTERS.md)
- [Faisabilité API 3](TECHNICAL_FEASIBILITY.md)
- [Roadmap et tests initiaux](ROADMAP_AND_TEST_PLAN.md)
- [Recommandations Emerald acceptées](RECOMMENDED_FEATURES.md)
- [Décisions à confirmer](OPEN_DECISIONS.md)
- [Guide de développement du dépôt](../../development.md)
- [Architecture du monorepo](../../architecture.md)
