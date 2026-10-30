# Session Handoff — Pokémon RPG Economy

**Dernière mise à jour :** 2026-10-30  
**Dépôt :** https://github.com/rakmahefa/G1R-Mods  
**Mod :** pokemon-rpg-economy  
**Jeu cible :** Pokémon Emerald uniquement  
**Baseline main vérifiée :** baa81b25501da7dcd28eb75280830f845f0899ff  
**État :** PRs #3 à #9 fusionnées ; Option A (bundle Lua source généré au build) est intégrée.

## 1. État Git et PR fusionnées

- PRs #3 à #9 sont fusionnées.
- PR #6 : socle initial de bibliothèque API 3 Emerald.
- PR #7 : suppression des récompenses EXP/EV via le hook public battle.exp_award.
- PR #8 : RFC d'API transactionnelle Pokémon ; proposition documentaire, pas une API moteur implémentée.
- PR #9 : pipeline de bundle Lua source, génération au build, tests staging et packaging.
- Commit de merge PR #8 : e68febd862a9e92de2959457f92c55b6877d6e1.
- Commit de merge PR #9 / baseline main actuelle : baa81b25501da7dcd28eb75280830f845f0899ff.
- PR #9 a été fusionnée le 30 octobre 2026 à 14:14:51 UTC.
- La comparaison de main avant/après PR #9 ne contient aucun changement sous third_party/gen1recomp ; le gitlink et le code moteur n'ont pas été modifiés.

## 2. Architecture de bibliothèque maintenant intégrée

Décision retenue : **Option A — sources Lua modulaires dans Git, bundle Lua source généré pendant le build**.

- Sources : mods/pokemon-rpg-economy/lib/*.lua.
- Configuration versionnée : mods/pokemon-rpg-economy/.lua-bundle.json.
- Générateur : scripts/build_lua_bundle.py.
- Bundle runtime : lib/runtime.bundle.lua, généré dans les artefacts, pas maintenu à la main.
- main.lua fait une lecture mod:read("lib/runtime.bundle.lua") et un load() dans le sandbox.
- Le ZIP contient le bundle généré et exclut les modules sources individuels, .lua-bundle.json et les tests.
- make test crée une copie staging, y génère le bundle puis charge cette copie avec le véritable SDK headless.
- make bundle MOD=pokemon-rpg-economy génère une copie inspectable dans build/.
- La suite CI #41056713666 est réussie sur le commit d'implémentation f163c3f5e1e9348d66f02f10c50e243caf749943 : syntaxe shell/Python, lint, tests headless, smoke-template et packaging.
- Le bundle distribué est du texte Lua, compilé au chargement par le sandbox. Aucun binaire natif ni bytecode LuaJIT.

Le chargeur historique lib/bootstrap.lua a été retiré par PR #9 et remplacé par la factory contenue dans le bundle généré.

## 3. Comportement gameplay déjà présent

### Bibliothèque privée

Le mod comporte :
- validation.lua : validation de nombres, identifiants, enums et tableaux ;
- result.lua : résultats typés ;
- cache.lua : cache FIFO borné ;
- persistence.lua : enveloppe versionnée mod.save data-only ;
- diagnostics.lua : diagnostics opt-in et déduplication bornée.

### Suppression EXP/EV en combat

Le hook battle.exp_award interrompt volontairement le pipeline complet, car le moteur attribue les EV avant l'EXP. Les tests fusionnés établissent une baseline native et vérifient les combats sauvages/dresseurs, Pokémon participant et Exp. Share. CI PR #7 : run #41045978256, succès, 85/85 assertions.

Couverture restante : miniboss/boss, Pokérus et autres multiplicateurs d'EV, événements/messages de montée de niveau et validation réelle en jeu.

## 4. RFC transactionnelle (PR #8) — limite inchangée

docs/mods/pokemon-rpg-economy/POKEMON_TRANSACTION_API.md définit :
- des références Pokémon opaques et stables ;
- des snapshots détachés ;
- des transactions couvrant Pokémon, argent, sac et modData ;
- staging, validation globale, commit durable, reçus idempotents, erreurs typées et reprise ;
- le Day Care en deux commits afin d'éviter double consommation et reroll.

**Cette RFC reste une proposition, même après sa fusion.** Aucune façade publique API 3 de mutation/consommation générique ou transaction Pokémon n'a été confirmée dans le moteur épinglé. Ne pas contourner : pas de mod.game.session, src.*, Party.* ou Storage.* depuis le mod.

## 5. Priorités de reprise

1. Synchroniser main et exécuter localement make bootstrap, make check, make test, make bundle, make smoke-template et make package.
2. Compléter les tests EXP/EV (boss/miniboss, Pokérus, objets multiplicateurs et événements de montée de niveau), puis organiser la validation en jeu.
3. Prototyper la mise à l'échelle des équipes de dresseurs via trainer.party et un suivi correct du contexte de carte.
4. Auditer l'interdiction des objets du sac en combats de dresseurs/boss et les événements de soin/PC.
5. Continuer à bloquer les fonctionnalités de consommation/mutation Pokémon tant qu'une API publique transactionnelle n'existe pas.

## 6. Commandes locales de reprise

~~~bash
git switch main
git pull --ff-only
git submodule update --init --recursive
git status --short --branch
git submodule status
make bootstrap
make check
make test
make bundle MOD=pokemon-rpg-economy
make smoke-template
make package
~~~

Rapporter les sorties réellement obtenues ; ne pas présumer que les commandes passent sur chaque environnement local.

## 7. Garde-fous

- Répondre en français.
- Vérifier l'état live de GitHub avant chaque écriture.
- Petites PR séparées, sans fusionner sans demande explicite.
- Aucun binaire natif, bytecode LuaJIT, ffi ou permission engine_internals.
- Le bundle ne crée aucune capacité moteur supplémentaire et ne justifie aucun accès interne.
- Ne jamais présenter une preuve headless partielle comme une validation en jeu.
