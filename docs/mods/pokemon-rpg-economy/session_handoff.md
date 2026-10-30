# Session Handoff — Pokémon RPG Economy

**Dernière mise à jour :** 2026-10-30  
**Dépôt :** https://github.com/rakmahefa/G1R-Mods  
**Mod :** pokemon-rpg-economy  
**Jeu cible :** Pokémon Emerald uniquement  
**Baseline main vérifiée :** e68febd862a9e92de2959457f92c55b6877d6e1d  
**Travail courant :** PR #9 en brouillon, branche feature/pokemon-economy-lua-bundle, head f163c3f5e1e9348d66f02f10c50e243caf749943.

## 1. État Git et PR fusionnées

- PRs #3 à #8 sont fusionnées.
- PR #6 : socle de bibliothèque API 3 Emerald.
- PR #7 : suppression des récompenses EXP/EV via le hook public battle.exp_award.
- PR #8 : RFC d'API transactionnelle Pokémon ; fusionnée le 30 octobre 2026.
- Commit de merge PR #8 : e68febd862a9e92de2959457f92c55b6877d6e1d.
- PR #8 est documentaire : elle ne fournit aucune API de transaction Pokémon implémentée.
- Sous-module Gen1Recomp toujours épinglé à 0be34bc76cecf996e91d2f905d1b4bb5f14d43ae au dernier contrôle. Aucun fichier moteur ou gitlink n'a été modifié.

## 2. PR #9 — bundle Lua source

- URL : https://github.com/rakmahefa/G1R-Mods/pull/9
- Statut : ouverte, en brouillon, pas fusionnée.
- CI #41056713666 : success ; syntaxe Python/shell, lint, tests SDK headless, smoke-template et vérification du ZIP sont tous réussis.
- La PR garde les sources séparées dans Git, génère un unique bundle Lua source et le fait lire/compiler par le sandbox.
- Le ZIP contient lib/runtime.bundle.lua, sans les modules source séparés, .lua-bundle.json ou tests.
- make test crée une copie staging avec le bundle généré puis charge cette copie par le vrai SDK.
- Le script de packaging valide la présence du bundle et l'absence des sources groupées.
- Aucun changement dans third_party/gen1recomp, son gitlink ou le moteur.
- Le bundle est du texte Lua : pas de binaire natif, de bytecode LuaJIT, ffi ou permission engine_internals.

## 3. Code gameplay déjà présent sur main

### Bibliothèque privée

Le mod contient les modules sources :
- validation.lua : validation de nombres, identifiants, enums et tableaux ;
- result.lua : résultats typés ;
- cache.lua : cache FIFO borné ;
- persistence.lua : enveloppe versionnée mod.save data-only ;
- diagnostics.lua : diagnostics opt-in et déduplication bornée.

Le chargeur bootstrap.lua est supprimé dans la PR #9 et remplacé par la factory générée dans runtime.bundle.lua. Tant que la PR n'est pas fusionnée, main conserve l'ancien chargeur et la PR est à traiter comme la nouvelle implémentation candidate.

### Suppression EXP/EV en combat

Le hook battle.exp_award interrompt volontairement le pipeline complet, car le moteur attribue les EV avant l'EXP. Les tests déjà fusionnés établissent une baseline native et vérifient les combats sauvages/dresseurs, Pokémon participant et Exp. Share. CI PR #7 : run #41045978256, succès, 85/85 assertions.

Couverture restante : miniboss/boss, Pokérus et autres multiplicateurs d'EV, événements/messages de montée de niveau et validation réelle en jeu.

## 4. RFC transactionnelle (PR #8)

docs/mods/pokemon-rpg-economy/POKEMON_TRANSACTION_API.md définit :
- des références Pokémon opaques et stables ;
- des snapshots détachés ;
- des transactions couvrant Pokémon, argent, sac et modData ;
- staging, validation globale, commit durable, reçus idempotents, erreurs typées et reprise ;
- le Day Care en deux commits afin d'éviter double consommation et reroll.

**Limite inchangée :** cette RFC est une proposition. Aucune façade publique API 3 de mutation/consommation générique ou transaction Pokémon n'a été confirmée dans le moteur épinglé. Ne pas contourner : pas de mod.game.session, src.*, Party.* ou Storage.* depuis le mod.

## 5. Architecture bundle retenue

- Configuration cachée versionnée : .lua-bundle.json.
- Générateur : scripts/build_lua_bundle.py.
- Bundle runtime : lib/runtime.bundle.lua, généré uniquement dans les artefacts.
- Les sources lib/*.lua restent séparées dans le dépôt.
- Le ZIP final inclut le bundle et exclut les sources modulaires, les tests et la configuration de build.
- main.lua utilise mod:read + load ; le moteur compile le code source dans le sandbox.
- make test charge une copie staging du mod avec ce même bundle via le SDK headless.
- make package vérifie la présence du bundle et l'absence des modules séparés.
- make bundle MOD=pokemon-rpg-economy génère une copie de l'artefact dans build/.

## 6. Étapes de reprise

1. Relire PR #9 et la fusionner uniquement après revue explicite.
2. Après fusion, vérifier que main reflète le head testé et que le gitlink moteur est inchangé.
3. Poursuivre ensuite les prototypes qui utilisent uniquement l'API publique, tout en gardant les mutations Pokémon bloquées.
4. Compléter la couverture EXP/EV, les tests d'objets en combat et les preuves en jeu.

## 7. Commandes locales

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

## 8. Garde-fous

- Répondre en français.
- Vérifier l'état live de GitHub avant chaque écriture.
- Petites PR séparées ; ne pas fusionner sans demande explicite.
- Aucun binaire natif, bytecode LuaJIT, ffi ou permission engine_internals.
- Le bundle ne crée aucune capacité moteur supplémentaire et ne justifie aucun accès interne.
- Ne jamais présenter une preuve headless partielle comme une validation en jeu.