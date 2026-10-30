# Session Handoff — Pokémon RPG Economy

**Dernière mise à jour :** 2026-10-30  
**Dépôt :** [rakmahefa/G1R-Mods](https://github.com/rakmahefa/G1R-Mods)  
**Mod :** `pokemon-rpg-economy`  
**Jeu cible :** Pokémon Emerald uniquement  
**État :** dossier de conception fusionné ; plan d'implémentation rédigé ; gameplay non commencé.

---

## 1. Résumé de la session précédente

La PR [#3 — docs: define first Pokémon RPG economy mod](https://github.com/rakmahefa/G1R-Mods/pull/3) a été fusionnée dans `main`.

- Merge commit : `8326759ab9316907ca453e5d0d095e6221805201`
- PR #3 : fermée et fusionnée.
- Contenu : 9 fichiers documentaires, 1 339 ajouts, aucune suppression.
- Aucune implémentation Lua, aucun manifeste de mod et aucun code de gameplay n'ont été ajoutés.

Cette session a ajouté le plan d'exécution `spec.md` et ce document de passation. Les fichiers de plan sont documentaires uniquement.

### PR documentaire de ce plan

- PR [#4 — docs: add implementation plan and session handoff](https://github.com/rakmahefa/G1R-Mods/pull/4).
- Branche : `docs/pokemon-rpg-economy-execution-plan`.
- État au dernier contrôle : ouverte, en brouillon, fusionnable.
- Fichiers concernés : `spec.md`, `session_handoff.md` et le README du dossier.
- Cette PR est distincte de la PR #3 déjà fusionnée. Ne pas considérer les deux nouveaux documents comme intégrés à `main` avant la fusion de la PR #4.

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

- L'audit statique du moteur confirme que `battle.exp_award` peut court-circuiter le chemin complet de distribution ; `exp.gain` seul ne bloque pas les EV. Le test headless reste à écrire et exécuter avant de déclarer le comportement validé.
- `trainer.party` peut modifier l'équipe, mais ne reçoit pas directement le mapId ; le mod doit suivre le contexte de carte.
- `mod.world:party()` retourne une copie détachée ; elle ne permet pas de muter la sauvegarde en modifiant simplement le résultat.
- Le moteur possède des primitives internes `Party.giveMon` et `Storage.*`, mais aucune façade API 3 documentée et transactionnelle n'a été identifiée pour consommer/muter un Pokémon précis. Ne pas utiliser `mod.game.session` ni les modules `src.*` directement.
- Le hook `item.use` recensé n'intercepte pas à lui seul les objets de combat.
- Les signaux génériques d'écran ne prouvent pas un soin effectif ou une consultation effective du PC.
- PNJ, écrans custom et données sauvegardées du mod sont documentés, mais doivent être validés avec de petits prototypes.
- Baies, Pokéblocs, concours, bases secrètes, Match Call et Battle Frontier sont identifiés côté Emerald ; cela ne garantit pas que toutes leurs fonctions soient accessibles par l'API mod publique.

La dépendance la plus risquée est l'API transactionnelle de mutation/consommation des Pokémon. La traiter avant de construire les services, contrats et Day Care.

### Garde-fou d'architecture ajouté

Le mod aura une petite bibliothèque locale isolée. Le sandbox supporte `mod:read` + `load` dans le même environnement ; un chargeur allowlisté évitera les imports moteur privés. Lire `LIBRARY_DESIGN.md` avant de créer le code. La bibliothèque ne remplacera pas l'API transactionnelle du moteur et ne prétendra pas sécuriser une mutation directe de Pokémon.


## 5 bis. Résultats consignés le 30 octobre 2026

### Baseline du dépôt

La CI du commit de fusion `3e2f187cbb1112fa8d39b833b51e035a997133fc` a réussi : [run #41021024747](https://github.com/rakmahefa/G1R-Mods/actions/runs/41021024747).

- `make check` : réussi, aucun mod présent à contrôler.
- `make test` : commande réussie, mais **0 suite de test** ; ce résultat ne valide aucun gameplay.
- `make smoke-template` : réussi, 3/3 contrôles du template.
- `make package` : réussi, aucun mod à empaqueter.

Il s'agit du résultat CI, pas d'une exécution locale dans cette session. La baseline est propre pour le dépôt documentaire/template, mais le premier mod et ses tests restent à créer.

### Constats du code moteur épinglé

- `battle.exp_award` enveloppe le chemin d'attribution. Un wrapper qui ne poursuit pas `next` évite le chemin qui appelle `Pokemon.gainEVs` puis `Experience.apply`. `exp.gain` seul est insuffisant, car les EV sont gagnés avant l'application de l'EXP. **Test headless encore à écrire.**
- Le moteur possède des fonctions internes pour générer et déplacer des Pokémon (notamment `Party.giveMon` et `Storage.*`). Ce ne sont pas des opérations transactionnelles publiques pour les mods.
- `mod.game.session` ne doit pas être muté directement : cela couple le mod aux structures privées du moteur.
- Le chargement de fichiers locaux est possible dans le sandbox avec `mod:read` + `load`, dans le même environnement que le module principal.

### Changement documentaire en cours

La PR [#5](https://github.com/rakmahefa/G1R-Mods/pull/5) ajoute la conception de la bibliothèque interne et les garde-fous. Elle est en brouillon ; son code n'est pas implémenté et son CI doit être vérifiée avant fusion.

## 6. Première tâche recommandée à la prochaine session

**Commencer par une session d'audit technique et de prototypes, pas par l'implémentation complète du jeu.**

Séquence :
1. Synchroniser `main` et les sous-modules ; vérifier le merge commit et la révision de Gen1Recomp.
2. Lire `docs/development.md`, `docs/architecture.md`, le template et les tests headless du repo.
3. Exécuter et consigner `make bootstrap`, `make check`, `make test`, `make smoke-template`.
4. Créer une branche dédiée au socle de bibliothèque et aux preuves de faisabilité.
5. Écrire un test headless minimal de `battle.exp_award` et vérifier l'absence d'EXP **et** d'EV.
6. Auditer le code du moteur et proposer le contrat de l'API transactionnelle Pokémon (identité stable, mutations couvertes, consommation, rollback, sauvegarde, reprise).
7. Classer chaque besoin en : API publique existante, prototype requis, extension moteur requise ou décision produit.
8. Implémenter ensuite le chargeur local et les primitives minimales de `LIBRARY_DESIGN.md`, sans gameplay, puis les tester par le SDK headless.

Ne pas encore commencer la boucle économique complète. Ne pas modifier `third_party/gen1recomp/` silencieusement et ne pas dépendre de fonctions internes.

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

**Objectif de la prochaine session :** établir la baseline reproductible du repo et valider les deux premiers risques techniques — suppression EXP/EV et contrat de transaction Pokémon — pour transformer les points bloquants du design en tâches moteur/API précises.
