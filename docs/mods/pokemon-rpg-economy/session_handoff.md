# Session Handoff — Pokémon RPG Economy

**Dernière mise à jour :** 2026-10-30  
**Dépôt :** https://github.com/rakmahefa/G1R-Mods  
**Mod :** pokemon-rpg-economy  
**Jeu cible :** Pokémon Emerald uniquement  
**État :** PR #6 et PR #7 fusionnées ; PR #8 ouverte pour revue de la proposition transactionnelle.

## 1. Baseline Git vérifiée

- PR #3 : design initial, fusionnée.
- PR #4 : spec et handoff, fusionnée.
- PR #5 : architecture de bibliothèque et garde-fous, fusionnée.
- PR #6 : socle de bibliothèque API 3 Emerald, fusionnée le 30 octobre 2026.
- PR #7 : blocage EXP/EV pendant les combats, fusionnée le 30 octobre 2026.
- main après la fusion #7 : a359f7c17df1b9240e43fbf385cf849bc9805993.
- Sous-module Gen1Recomp : toujours épinglé à 0be34bc76cecf996e91d2f905d1b4bb5f14d43ae lors du dernier contrôle.
- PR #8 : https://github.com/rakmahefa/G1R-Mods/pull/8 ; proposition d'API transactionnelle Pokémon, branche docs/pokemon-transaction-api-proposal. Elle doit être alignée sur le main courant ; la CI du premier commit de cette PR (#41047173942) a réussi, mais la révision réalignée devra être retestée.

## 2. Code déjà fusionné

### Bibliothèque privée — PR #6

Le mod se trouve sous mods/pokemon-rpg-economy/ et cible API 3 / Emerald uniquement. Il contient :
- un chargeur local allowlisté reposant sur mod:read + load dans le sandbox ;
- validation d'entrées et résultats typés ;
- un cache FIFO borné ;
- persistance versionnée data-only via mod.save ;
- diagnostics opt-in avec déduplication bornée ;
- tests ROM-free qui chargent le mod via le SDK Gen 3 headless.

La PR #6 a fusionné sans modifier le sous-module moteur. Le mod n'utilise pas de modules src.* privés ni mod.game.session.

### Suppression de l'EXP et des EV en combat — PR #7

Le mod intercepte battle.exp_award et ne poursuit pas next, afin de supprimer le pipeline d'attribution natif complet. Un hook exp.gain seul aurait laissé les EV attribués avant Experience.apply.

Le test headless :
- établit d'abord une baseline sans mod, où EXP et EV sont bien attribués ;
- charge le vrai mod via le SDK API 3 ;
- vérifie les combats sauvages et de dresseurs ;
- vérifie le participant et le détenteur d'Exp. Share ;
- confirme l'appel du hook public.

CI la plus récente avant fusion : run #41045978256, réussite, 85/85 assertions ; make check, make test, make smoke-template et make package ont réussi.

Couverture restante : miniboss/boss, Pokérus et autres multiplicateurs d'EV, messages/événements de montée de niveau et validation réelle en jeu. Ne pas annoncer ces cas comme validés.

## 3. Blocage majeur : identité et transactions Pokémon

L'audit du moteur épinglé confirme :
- les positions équipe/boîte ne sont pas des identifiants stables ; transferts et compactages changent les indices ;
- les primitives Party.* et Storage.* sont internes ;
- mod.world:party() renvoie un snapshot détaché ;
- mod.save est rattaché au modData de la sauvegarde normale, tandis que mod.storage est écrit indépendamment ;
- aucune façade publique API 3 de consultation/mutation/consommation générique par référence Pokémon n'a été confirmée.

Ne pas contourner ce blocage : aucun accès direct à mod.game.session, aucune importation src.* et aucune manipulation des fonctions internes Party/Storage depuis le mod.

### RFC de la PR #8

Le document docs/mods/pokemon-rpg-economy/POKEMON_TRANSACTION_API.md propose :
- des références Pokémon opaques et stables à travers équipe, boîtes et rechargement ;
- des snapshots détachés ;
- un coordinateur de transactions composées couvrant Pokémon, argent, sac et données du mod ;
- une validation/staging puis un commit durable ;
- des reçus idempotents, erreurs typées et reprise après panne ;
- un flux Day Care en deux commits, pour éviter double consommation et reroll du hasard.

C'est une proposition, pas une API disponible. Il faut la faire relire puis, si elle est acceptée, proposer le changement correspondant dans le dépôt moteur avec des tests dédiés.

## 4. Décisions de gameplay conservées

- Emerald uniquement, API 3.
- Aucun gain d'EXP/EV en combat.
- Pas de Nuzlocke ni permadeath.
- Niveaux achetés via un service ; plafond lié aux badges, barème encore à équilibrer.
- Objets du sac interdits en combats de dresseurs/boss ; objets tenus proposés comme autorisés, à confirmer.
- Boss facultatifs, déclenchés volontairement.
- Day Care : cinq œufs consommés au lancement confirmé ; dix Pokémon de niveau 5 de dix espèces admissibles distinctes sont générés ; choix d'un candidat ; tirage unique 90 % pour recevoir exactement le choisi / 10 % pour ne rien recevoir. Une erreur technique ne doit jamais être traitée comme le résultat volontaire à 10 %.

Les décisions non résolues sont listées dans OPEN_DECISIONS.md. Ne pas arbitrer silencieusement les règles destructives.

## 5. Priorités suivantes

1. Réaligner la PR #8 sur le main après les fusions #6/#7, garder son contenu documentaire et vérifier sa CI.
2. Faire relire/valider le contrat POKEMON_TRANSACTION_API.md.
3. Si la RFC est acceptée, réaliser l'API dans le dépôt moteur (références stables, transactions, sauvegarde/idempotence/reprise) et fournir tests d'injection de panne. Ne pas toucher le sous-module de ce dépôt de mods en silence.
4. Compléter les tests EXP/EV (boss/miniboss, Pokérus/objets multiplicateurs, événements de niveau) et organiser les tests en jeu.
5. Prototyper les niveaux d'équipes de dresseurs via trainer.party et le suivi de carte.
6. Auditer l'interdiction des objets de sac dans les combats et les événements de soin/PC.
7. Ne pas implémenter de services qui consomment ou mutent des Pokémon avant disponibilité d'une API transactionnelle publique.

## 6. Commandes locales de reprise

Dans un clone :

~~~bash
git switch main
git pull --ff-only
git submodule update --init --recursive
git status --short --branch
git submodule status
make check
make test
make smoke-template
make package
~~~

Rapporter les sorties réellement obtenues ; ne pas présumer que les tests passent.

## 7. Garde-fous

- Répondre en français.
- Vérifier l'état live de GitHub avant chaque écriture.
- Petites PR séparées, sans fusionner sans demande explicite.
- Ne jamais présenter une proposition documentaire comme une API codée.
- Ne jamais présenter une preuve headless partielle comme une validation en jeu.
