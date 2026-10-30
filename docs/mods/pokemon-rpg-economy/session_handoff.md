# Session Handoff — Pokémon RPG Economy

**Dernière mise à jour :** 2026-10-30  
**Dépôt :** https://github.com/rakmahefa/G1R-Mods  
**Mod :** pokemon-rpg-economy  
**Jeu cible :** Pokémon Emerald uniquement  
**Baseline main vérifiée :** e68febd862a9e92de2959457f92c55b6877d6e1d

## 1. État Git et PR fusionnées

- PRs #3 à #8 sont fusionnées.
- PR #6 : socle de bibliothèque API 3 Emerald.
- PR #7 : suppression des récompenses EXP/EV via le hook public battle.exp_award.
- PR #8 : RFC d'API transactionnelle Pokémon ; fusionnée le 30 octobre 2026.
- Commit de merge PR #8 : e68febd862a9e92de2959457f92c55b6877d6e1d.
- PR #8 est documentaire : elle ne fournit aucune API de transaction Pokémon implémentée.
- Sous-module Gen1Recomp toujours épinglé à 0be34bc76cecf996e91d2f905d1b4bb5f14d43ae au dernier contrôle. Aucun fichier moteur ou gitlink n'a été modifié.

## 2. Code gameplay déjà présent

### Bibliothèque privée

Le mod contient les modules sources :
- validation.lua : validation de nombres, identifiants, enums et tableaux ;
- result.lua : résultats typés ;
- cache.lua : cache FIFO borné ;
- persistence.lua : enveloppe versionnée mod.save data-only ;
- diagnostics.lua : diagnostics opt-in et déduplication bornée.

La branche de travail adopte Option A : sources modulaires dans Git, bundle source Lua généré lors du build, un seul mod:read et un seul load sandboxé au runtime. Le bundle n'est ni un binaire natif ni du bytecode LuaJIT.

### Suppression EXP/EV en combat

Le hook battle.exp_award interrompt volontairement le pipeline complet, car le moteur attribue les EV avant l'EXP. Les tests déjà fusionnés établissent une baseline native et vérifient les combats sauvages/dresseurs, Pokémon participant et Exp. Share. CI PR #7 : run #41045978256, succès, 85/85 assertions.

Couverture restante : miniboss/boss, Pokérus et autres multiplicateurs d'EV, événements/messages de montée de niveau et validation réelle en jeu.

## 3. RFC transactionnelle (PR #8)

docs/mods/pokemon-rpg-economy/POKEMON_TRANSACTION_API.md définit :
- des références Pokémon opaques et stables ;
- des snapshots détachés ;
- des transactions couvrant Pokémon, argent, sac et modData ;
- staging, validation globale, commit durable, reçus idempotents, erreurs typées et reprise ;
- le Day Care en deux commits afin d'éviter double consommation et reroll.

**Limite inchangée :** cette RFC est une proposition. Aucune façade publique API 3 de mutation/consommation générique ou transaction Pokémon n'a été confirmée dans le moteur épinglé. Ne pas contourner : pas de mod.game.session, src.*, Party.* ou Storage.* depuis le mod.

## 4. Architecture de bundle retenue

- Configuration cachée versionnée : .lua-bundle.json.
- Générateur : scripts/build_lua_bundle.py.
- Bundle runtime : lib/runtime.bundle.lua, généré uniquement dans les artefacts.
- Les sources lib/*.lua restent séparées dans le dépôt.
- Le ZIP final inclut le bundle et exclut les sources modulaires, les tests et la configuration de build.
- main.lua utilise mod:read + load ; le moteur compile le code source dans le sandbox.
- make test charge une copie staging du mod avec ce même bundle via le SDK headless.
- make package vérifie la présence du bundle et l'absence des modules séparés.
- Le sous-module moteur reste inchangé.

## 5. Étapes de reprise

1. Finaliser le générateur et son intégration dans le packaging.
2. Vérifier par CI : syntaxe Python, lint du mod, tests headless sur la copie bundle, smoke-template et inspection du ZIP.
3. Garder toute PR de bundle séparée et ne pas la fusionner sans demande explicite.
4. Poursuivre ensuite les prototypes qui utilisent uniquement l'API publique, tout en gardant les mutations Pokémon bloquées.
5. Compléter la couverture EXP/EV, les tests d'objets en combat et les preuves en jeu.

## 6. Commandes locales

~~~bash
git switch main
git pull --ff-only
git submodule update --init --recursive
git status --short --branch
git submodule status
make check
make test
make bundle MOD=pokemon-rpg-economy
make smoke-template
make package
~~~

## 7. Garde-fous

- Répondre en français.
- Vérifier l'état live de GitHub avant chaque écriture.
- Petites PR séparées, sans fusionner sans demande explicite.
- Aucun binaire natif, bytecode LuaJIT, ffi ou permission engine_internals.
- Le bundle ne crée aucune capacité moteur supplémentaire et ne justifie aucun accès interne.
- Ne jamais présenter une preuve headless partielle comme une validation en jeu.
