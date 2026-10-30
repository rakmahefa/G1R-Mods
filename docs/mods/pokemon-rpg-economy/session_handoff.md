# Session Handoff — Pokémon RPG Economy

**Dernière mise à jour :** 2026-10-30  
**Dépôt :** [rakmahefa/G1R-Mods](https://github.com/rakmahefa/G1R-Mods)  
**Mod :** `pokemon-rpg-economy`  
**Jeu cible :** Pokémon Emerald uniquement  
**État :** PRs documentaires #3/#4/#5 fusionnées ; socle de bibliothèque dans la PR #6 (brouillon, CI verte) ; hook de suppression EXP/EV dans la PR #7 (brouillon, CI verte 85/85) ; aucun autre gameplay implémenté.

---

## 1. Résumé de la session précédente

La PR [#3 — docs: define first Pokémon RPG economy mod](https://github.com/rakmahefa/G1R-Mods/pull/3) a été fusionnée dans `main`.

- Merge commit : `8326759ab9316907ca453e5d0d095e6221805201`
- PR #3 : fermée et fusionnée.
- Contenu : 9 fichiers documentaires, 1 339 ajouts, aucune suppression.
- Aucune implémentation Lua, aucun manifeste de mod et aucun code de gameplay n'ont été ajoutés.

Cette session a ajouté le plan d'exécution `spec.md` et ce document de passation. Les fichiers de plan sont documentaires uniquement.

### PRs documentaires

- PR [#3 — design initial](https://github.com/rakmahefa/G1R-Mods/pull/3) : fusionnée.
- PR [#4 — specification et handoff](https://github.com/rakmahefa/G1R-Mods/pull/4) : fusionnée.
- PR [#5 — bibliothèque et garde-fous](https://github.com/rakmahefa/G1R-Mods/pull/5) : fusionnée le 30 octobre 2026.
- Baseline de `main` après PR #5 : `0b52dee3619aa57bba817f63437e47f1e2051cb4`.

La documentation de conception et de planification est donc intégrée à `main`.

## 2. État du produit à reprendre

### Décisions confirmées

- Pokémon Emerald uniquement (Hoenn).
- API 3 de Gen1Recomp.
- Pas de Nuzlocke, pas de permadeath.
- Aucun EXP ni EV donné par les combats.
- Niveaux achetés auprès d'un service, plafond indexé sur les badges.
- Objets du sac interdits dans les combats de dresseurs et de boss ; objets tenus proposés comme autorisés (confirmation finale encore à faire).
- Boss et miniboss facultatifs, déclenchés volontairement.
- Les recommandations Emerald ont été acceptées comme direction de roadmap et seront intégrées progressivement.
- Les cinq œufs du Day Care suivent la règle détaillée ci-dessous.

### Échange Day Care — décision importante à ne pas perdre

- Le joueur lance l'échange au Day Care en remettant cinq œufs.
- Avant confirmation, un avertissement annonce la consommation définitive des cinq œufs et le risque de 10 % de ne rien recevoir.
- Une fois l'échange lancé, les cinq œufs sont consommés.
- Le système tire dix espèces distinctes admissibles et génère dix vrais Pokémon de niveau 5, un par espèce.
- Le joueur voit les dix Pokémon déjà générés et en choisit un.
- Après son choix, le résultat est tiré une seule fois : 90 % de recevoir exactement le Pokémon sélectionné, 10 % de ne rien recevoir.
- Une annulation après le lancement ou le résultat de non-réception ne rend pas les œufs.
- Aucun reroll après rechargement, fermeture ou répétition d'interaction.
- Aucune espèce légendaire ni espèce déjà évoluée ; uniquement le premier stade.
- Une erreur technique de remise ne doit pas être confondue avec le résultat de non-réception à 10 %. Elle doit suivre un état persistant et ne pas reroll le hasard.

## 3. Références du dépôt

- Dossier design : `docs/mods/pokemon-rpg-economy/`
- Plan principal : `docs/mods/pokemon-rpg-economy/spec.md`
- Passation : `docs/mods/pokemon-rpg-economy/session_handoff.md`
- Décisions ouvertes : `docs/mods/pokemon-rpg-economy/OPEN_DECISIONS.md`
- Faisabilité moteur/API : `docs/mods/pokemon-rpg-economy/TECHNICAL_FEASIBILITY.md`
- Roadmap et matrice de tests : `docs/mods/pokemon-rpg-economy/ROADMAP_AND_TEST_PLAN.md`
- Recommandations Emerald acceptées : `docs/mods/pokemon-rpg-economy/RECOMMENDED_FEATURES.md`
- Guide repo : `docs/development.md`, `docs/architecture.md`
- Template de mod : `templates/mod-template/`
- Architecture de la bibliothèque : `docs/mods/pokemon-rpg-economy/LIBRARY_DESIGN.md`
- Sous-module moteur : `third_party/gen1recomp/`

Révision moteur épinglée dans le dossier de faisabilité et le sous-module au moment de la conception : `0be34bc76cecf996e91d2f905d1b4bb5f14d43ae`. Vérifier la révision réelle avant toute conclusion ou mise à jour.

## 4. Ce qui n'est pas encore décidé

Consulter `OPEN_DECISIONS.md` avant de coder. Les décisions les plus structurantes :

1. Barème final des plafonds et sort d'un Pokémon capturé au-dessus du plafond.
2. Dresseurs renouvelables : lesquels, et quel événement précis valide le repos au Centre ou l'accès au PC.
3. Vente/consommation : équipe seule ou équipe + boîtes ; protections des shiny, favoris, cadeaux/événements ; protection du dernier Pokémon utilisable.
4. Entraînement de niveau avec ou sans Pokémon donneur.
5. IV PV, progression d'IV et coût.
6. EV : un donneur par point ou un lot proportionnel au niveau du donneur.
7. Règles précises d'évolution, techniques tutorées, TM et HM.
8. Confirmation objets tenus et objets de sac.
9. Capture des boss sauvages, unicité des récompenses et réapparition.
10. Contrats de capture : nombre actif, portée locale, capturé avant acceptation, boîtes, espèces évoluées/fossiles/rares.
11. Matériaux : inventaire privé ou objets visibles, règles de drop et coûts de recettes.
12. Densité finale des boss selon la carte de Hoenn.
13. Pool du Day Care : espèces exactes, filtre par badge/palier, rotation ou nouveau pool à chaque échange.

Ne pas choisir en silence à la place du joueur les règles qui détruisent des Pokémon ou changent fortement le rythme économique.

## 5. Risques techniques connus

D'après `TECHNICAL_FEASIBILITY.md`, à revalider directement dans le code moteur épinglé :

- L'audit du moteur confirme que `battle.exp_award` enveloppe `Experience.awardFoe` et peut supprimer le pipeline complet ; `exp.gain` seul ne bloque pas les EV car `Pokemon.gainEVs` est appelé avant `Experience.apply`. La comparaison baseline/mod est maintenant testée par la PR #7 et sa CI est verte.
- `trainer.party` peut modifier l'équipe, mais ne reçoit pas directement le mapId ; le mod doit suivre le contexte de carte.
- `mod.world:party()` retourne une copie détachée ; elle ne permet pas de muter la sauvegarde en modifiant simplement le résultat.
- Le moteur possède des primitives internes `Party.giveMon` et `Storage.*`, mais aucune façade API 3 documentée et transactionnelle n'a été identifiée pour consommer/muter un Pokémon précis. Ne pas utiliser `mod.game.session` ni les modules `src.*` directement.
- Le hook `item.use` recensé n'intercepte pas à lui seul les objets de combat.
- Les signaux génériques d'écran ne prouvent pas un soin effectif ou une consultation effective du PC.
- PNJ, écrans custom et données sauvegardées du mod sont documentés, mais doivent être validés avec de petits prototypes.
- Baies, Pokéblocs, concours, bases secrètes, Match Call et Battle Frontier sont identifiés côté Emerald ; cela ne garantit pas que toutes leurs fonctions soient accessibles par l'API mod publique.

La dépendance la plus risquée est l'API transactionnelle de mutation/consommation des Pokémon. La traiter avant de construire les services, contrats et Day Care.

### Garde-fou d'architecture ajouté

La première tranche de cette bibliothèque est maintenant dans la PR [#6](https://github.com/rakmahefa/G1R-Mods/pull/6) : chargeur local allowlisté via `mod:read` + `load`, validation, résultats, cache FIFO borné, persistance versionnée sur `mod.save` et diagnostics opt-in. Aucun gameplay n'est activé. Les tests headless s'exécutent via le SDK officiel et la CI du commit initial de la PR est verte. La bibliothèque ne remplace pas l'API transactionnelle du moteur et ne sécurise pas une mutation directe de Pokémon.


## 5 bis. Résultats consignés le 30 octobre 2026

### Baseline du dépôt

La CI du commit de fusion `3e2f187cbb1112fa8d39b833b51e035a997133fc` a réussi : [run #41021024747](https://github.com/rakmahefa/G1R-Mods/actions/runs/41021024747).

- `make check` : réussi, aucun mod présent à contrôler.
- `make test` : commande réussie, mais **0 suite de test** ; ce résultat ne valide aucun gameplay.
- `make smoke-template` : réussi, 3/3 contrôles du template.
- `make package` : réussi, aucun mod à empaqueter.

Il s'agit du résultat CI historique, pas d'une exécution locale. Depuis, le premier mod et sa suite de tests sont présents dans la branche de la PR #6 ; leur résultat CI est consigné ci-dessous.

### Constats du code moteur épinglé

- `battle.exp_award` enveloppe le chemin d'attribution. Un wrapper qui ne poursuit pas `next` évite le chemin qui appelle `Pokemon.gainEVs` puis `Experience.apply`. `exp.gain` seul est insuffisant, car les EV sont gagnés avant l'application de l'EXP. La preuve headless correspondante est maintenant consignée dans PR #7 (run #41045753060).
- Le moteur possède des fonctions internes pour générer et déplacer des Pokémon (notamment `Party.giveMon` et `Storage.*`). Ce ne sont pas des opérations transactionnelles publiques pour les mods.
- `mod.game.session` ne doit pas être muté directement : cela couple le mod aux structures privées du moteur.
- Le chargement de fichiers locaux est possible dans le sandbox avec `mod:read` + `load`, dans le même environnement que le module principal.

### Implémentation de la bibliothèque — PR #6

- PR [#6 — isolated API 3 library foundation](https://github.com/rakmahefa/G1R-Mods/pull/6).
- Branche : `feat/pokemon-rpg-economy-library-foundation`.
- Commit testé : `91daf575531cdc21b9e36f0272d7d2dd6ff7565a`.
- Statut : ouverte, en brouillon, fusionnable au dernier contrôle.
- 13 fichiers ajoutés ; aucun changement au sous-module moteur.

La CI [#41044501372](https://github.com/rakmahefa/G1R-Mods/actions/runs/41044501372) est **réussie** : syntaxe shell/Python, `make check`, `make test`, `make smoke-template` et `make package`. Le test du mod charge réellement le manifeste/API 3 dans le SDK Gen 3 headless, puis teste les modules et leurs chemins d'échec.

Le code ne change encore aucun comportement de jeu. Cette CI ne valide ni les interactions en jeu ni les prototypes EXP/EV ou les transactions Pokémon.

### Prototype EXP/EV — PR #7

- PR [#7 — disable battle EXP and EV rewards](https://github.com/rakmahefa/G1R-Mods/pull/7).
- Branche : `feat/pokemon-rpg-economy-disable-battle-exp-ev`.
- Commit code : `832c5f52785de01f839fa8bb37090d5e65cbefa9`.
- PR ouverte en brouillon ; base `main` pour déclencher le workflow CI du dépôt.
- La branche descend du head de PR #6 (`c2c97187db0cf079d74dd2e090e0f668cf40850f`) ; le diff inclut temporairement la fondation jusqu'à fusion de PR #6.
- Aucun changement au sous-module moteur.

Le test headless commence par une baseline sans mod : le participant et le détenteur d'Exp. Share reçoivent les récompenses natives. Il charge ensuite le vrai mod avec le SDK et vérifie qu'en combat sauvage et de dresseur ni l'EXP ni les EV ne changent pour aucun des deux Pokémon. L'observateur de hook confirme que le wrapper `battle.exp_award` a été appelé.

La CI [#41045753060](https://github.com/rakmahefa/G1R-Mods/actions/runs/41045753060) est **réussie** sur le commit `f62f5160aab992950233fe9221c7d1381ff401de` : **85/85 checks passed**, `make check`, `make test`, `make smoke-template` et `make package`.

La baseline sans mod accorde bien EXP et EV au participant et au porteur d'Exp. Share. Avec le mod chargé, les cas sauvages et dresseurs ne modifient ni EXP ni EV sur aucun des deux Pokémon. Les cas boss/miniboss, Pokérus/objets multiplicateurs, les événements/messages de montée de niveau et le comportement en jeu restent à valider.

## 6. Suite recommandée

1. Relire puis fusionner la PR #6 avant la PR #7, car la PR #7 est basée sur son head.
2. Compléter les cas boss/miniboss, Pokérus/objets multiplicateurs et événements/messages de montée de niveau ; faire la validation en jeu avant de déclarer la règle complètement terminée.
3. Définir puis documenter le contrat moteur transactionnel requis pour muter/consommer un Pokémon (identité stable, préconditions, commit/rollback, persistance et reprise).
4. Prototyper séparément les niveaux de dresseurs, les objets de combat et les signaux de soin/PC, selon les blocages recensés.
5. Ne commencer les services économiques qu'après preuve technique des opérations dont ils dépendent.

Ne pas modifier `third_party/gen1recomp/` silencieusement et ne jamais accéder à `mod.game.session` ou à des modules `src.*` depuis le mod.

## 7. Commandes de reprise

Dans un clone local :

```bash
git clone --recurse-submodules https://github.com/rakmahefa/G1R-Mods.git
cd G1R-Mods
git status --short --branch
git log -1 --oneline
git submodule status
make bootstrap
make check
make test
make smoke-template
```

Si le dépôt est déjà cloné :

```bash
git switch main
git pull --ff-only
git submodule update --init --recursive
git status --short --branch
git submodule status
```

Ne pas supposer que les commandes passent : rapporter leurs sorties réelles.

## 8. Instructions pour la prochaine session

- Répondre en français.
- Utiliser le dépôt GitHub comme source de vérité ; vérifier les états live avant toute écriture GitHub.
- Ne pas répéter les décisions déjà validées.
- Ne pas commencer l'écriture du gameplay complet avant le retour des prototypes et les décisions destructives.
- Séparer les changements par PR petites et testées.
- Mettre à jour ce handoff à la fin de la session.
- Si un détail n'est pas prouvé dans la révision moteur, le noter comme inconnu plutôt que le déduire.

**Objectif de reprise :** poursuivre les preuves headless de faisabilité moteur, en commençant par EXP/EV, puis formaliser l'API publique transactionnelle Pokémon avant les fonctionnalités économiques.
