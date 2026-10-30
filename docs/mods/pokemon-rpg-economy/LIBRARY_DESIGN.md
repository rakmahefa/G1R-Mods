# Bibliothèque interne — Pokémon RPG Economy

**Statut :** architecture retenue ; socle initial et suppression EXP/EV intégrés dans main ; bundle Lua source implémenté dans la PR #9 (brouillon, CI réussie)
**Périmètre :** mod pokemon-rpg-economy, Gen1Recomp API 3, Pokémon Emerald uniquement  
**Référence moteur auditée :** 0be34bc76cecf996e91d2f905d1b4bb5f14d43ae

## 1. Objectif et garantie réaliste

La bibliothèque privée centralise la validation, les résultats/erreurs, la persistance versionnée, les caches bornés et les diagnostics. Elle réduit les duplications et les points de régression sans devenir un second moteur Pokémon ni un framework générique.

La bibliothèque réduit les risques ; elle ne garantit pas l'absence absolue de bugs. Cette garantie dépend aussi des contrats de l'API moteur, des tests headless, des tests en jeu et des limites imposées aux fonctionnalités.

**Décision d'architecture :** les sources restent des modules Lua séparés et maintenables dans Git ; le build les assemble dans un unique bundle source Lua inclus dans le ZIP d'installation. Ce n'est ni une bibliothèque native ni du bytecode LuaJIT.

## 2. Règles d'isolation obligatoires

- Tous les modules sources résident dans mods/pokemon-rpg-economy/lib/ et appartiennent exclusivement à ce mod.
- Les modules n'ajoutent aucune globale, ne modifient aucun prototype, aucune table partagée du moteur et aucune fonction native.
- Le mod utilise exclusivement les services publics fournis dans mod : événements, hooks, stockage, sauvegarde, UI, monde et combat selon leur contrat documenté.
- Aucun require("src.*"), accès à package, dofile, loadfile, io, ffi ou permission engine_internals pour contourner l'API.
- Chaque module reçoit explicitement ses dépendances ; le générateur fournit un chargeur local limité aux modules inclus dans le bundle.
- Un module reste pur au chargement : pas d'abonnement, mutation de sauvegarde, génération aléatoire ou parcours du monde pendant son import.
- Le fonctionnement du mod ne dépend d'aucun autre mod ; aucune bibliothèque tierce n'est requise.
- Les identifiants, clés de sauvegarde et événements personnalisés restent préfixés par le namespace du mod.

## 3. Génération du bundle Lua source

Le fichier caché .lua-bundle.json à la racine du mod décrit explicitement la version du format, le chemin de sortie et la liste ordonnée des modules à inclure. Il ne fait pas partie de l'archive distribuée.

Le générateur scripts/build_lua_bundle.py :

1. valide strictement la configuration et les noms des modules ;
2. vérifie que la liste déclarée correspond exactement aux fichiers lib/*.lua présents ;
3. refuse les fichiers absents, les liens symboliques, les noms ambigus, le code vide et les sources non UTF-8 ;
4. enveloppe chaque module dans une fabrique locale du bundle, sans concaténer des statements Lua au même niveau ;
5. produit un fichier texte déterministe, sans date, chemin absolu ou bytecode ;
6. ne modifie jamais les sources versionnées.

Chaque fabrique est chargée paresseusement par library.load(name). Le chargeur local conserve les tables importées, détecte les cycles et refuse les noms absents. Une fabrique reçoit la fonction loadModule comme premier argument afin de charger explicitement une dépendance ; aucun accès global au chargeur n'est fourni.

### Contrat runtime

main.lua :

1. lit uniquement lib/runtime.bundle.lua via mod:read ;
2. compile le code source par le load() fourni dans le sandbox ;
3. valide l'objet retourné et crée une instance locale de bibliothèque ;
4. récupère les modules requis via library.load.

Le chemin de démarrage fait une lecture mod:read et une compilation load du bundle. Les modules restent paresseux au niveau de leur initialisation. Le bénéfice attendu concerne le coût de chargement et de compilation des fichiers, pas une accélération automatique de l'exécution des fonctions gameplay.

### Distribution et développement

- make bundle MOD=pokemon-rpg-economy génère build/bundles/pokemon-rpg-economy/lib/runtime.bundle.lua pour inspection locale.
- make test copie le mod dans build/headless-mods/, génère le bundle dans cette copie, puis le charge avec le vrai SDK headless du moteur.
- make package génère le bundle directement pendant la préparation du ZIP.
- L'archive inclut lib/runtime.bundle.lua, mais pas les modules sources listés dans .lua-bundle.json, ni les tests ou la configuration de build.
- make clean supprime les artefacts générés dans build/ et dist/.

Le moteur rejette le bytecode Lua et contrôle load() pour que les chunks compilés héritent de l'environnement sandboxé. Le bundle distribué reste donc du texte Lua ; il est compilé par le sandbox du moteur au démarrage. Aucun .so, .dll, .dylib ou bytecode LuaJIT ne doit être chargé depuis le mod.

## 4. Modules sources

| Module | Responsabilité | Limites |
|---|---|---|
| validation.lua | Vérification de nombres finis, entiers, bornes, identifiants, enums et structures | Fonctions pures, sans mutation |
| result.lua | Format uniforme succès/échec et codes d'erreur | Ne masque jamais une exception inattendue |
| persistence.lua | Enveloppe versionnée de mod.save, validation des données et migrations | mod.storage est différé ; aucune transaction physique n'est inventée |
| cache.lua | Cache paresseux, borné et invalidable pour données statiques | Ne conserve pas de références vivantes à l'équipe, au jeu ou à la session |
| diagnostics.lua | Logs désactivables par catégorie et limitation des répétitions | Aucun log par frame, aucune donnée sensible |

Un module transactions.lua ne sera ajouté qu'avec un périmètre prouvé. Il pourra orchestrer l'idempotence des données possédées par le mod. Il ne devra jamais annoncer un rollback atomique d'un Pokémon, d'un objet ou d'argent du moteur si l'API publique ne garantit pas cette opération.

Ne pas créer prématurément une bibliothèque UI, un bus d'événements, un moteur de règles ou une couche de Pokémon. Utiliser d'abord les services déjà fournis par Gen1Recomp.

## 5. Contrats de robustesse

### Validation et erreurs

- Valider toutes les entrées externes avant toute mutation ou dépense.
- Refuser NaN, infini, valeurs fractionnaires lorsque l'entier est requis, identifiants inconnus et listes hors limites.
- Utiliser des codes d'erreur stables et compréhensibles ; ne pas convertir silencieusement une donnée invalide en valeur par défaut si cela peut modifier le résultat économique.
- Les erreurs techniques doivent rester distinctes des résultats aléatoires prévus par le gameplay.
- Une erreur ne doit pas être avalée après qu'une partie de l'opération a déjà modifié l'état.

### Sauvegarde et transactions

- Utiliser mod.save pour le petit état qui doit suivre la sauvegarde normale du joueur ; utiliser mod.storage pour les données durables indépendantes, conformément à la documentation moteur.
- Versionner les données et valider les structures à chaque lecture.
- Écrire lors des transitions d'état, pas dans une boucle d'animation ou à chaque frame.
- Rendre les opérations idempotentes avec un identifiant d'opération enregistré avant leur finalisation et vérifié à la reprise.
- Distinguer annulation utilisateur, échec technique et résultat de gameplay (par exemple le tirage volontaire de non-réception du Day Care).
- Pour une opération touchant à la fois les Pokédollars et un Pokémon moteur, exiger une API moteur atomique ou un protocole de transaction officiellement pris en charge. Une succession de fonctions internes n'est pas une transaction.

### Performance

- Aucun scan global de l'équipe, du PC, des cartes ou des données à chaque frame.
- Préférer les événements documentés aux boucles de polling.
- Calculer paresseusement et mettre en cache seulement les données immuables ou dérivées clairement invalidables.
- Borner les caches et les listes ; prévoir leur invalidation lors d'un changement de sauvegarde, de jeu ou de contexte.
- Éviter les copies profondes répétées, les tris inutiles et les traitements synchrones lourds dans les callbacks.
- Ne pas créer de threads, timers ou tâches de fond dans le mod ; toute opération longue nécessitera un mécanisme public/documenté et une mesure préalable.
- Le bundle n'autorise pas à déplacer du travail lourd au chargement : les modules restent paresseux et les traitements gameplay restent déclenchés par leurs besoins.
- Mesurer les chemins fréquents avant d'optimiser ; pas de micro-optimisation qui rend le code opaque.

### Compatibilité et conflits

- S'abonner une seule fois à chaque événement nécessaire et éviter les hooks redondants.
- Une enveloppe de hook appelle next exactement une fois lorsqu'elle étend le comportement existant. Ne pas court-circuiter la chaîne sauf politique explicitement exclusive (comme la suppression de récompense EXP/EV), documentée et testée.
- Choisir des priorités normales ; justifier toute priorité non standard.
- Ne pas modifier les flags, scripts ou récompenses des dresseurs narratifs Emerald sans exigence explicite.
- Ne jamais supposer qu'un autre mod est installé ou qu'il utilise le même ordre de chargement.

## 6. Arborescence source et artefacts

~~~text
mods/pokemon-rpg-economy/
  main.lua
  manifest.json
  .lua-bundle.json
  lib/
    validation.lua
    result.lua
    persistence.lua
    cache.lua
    diagnostics.lua
  tests/
    pokemon-rpg-economy_test.lua

build/
  bundles/pokemon-rpg-economy/lib/runtime.bundle.lua
  headless-mods/pokemon-rpg-economy/lib/runtime.bundle.lua
~~~

Les dossiers services/, ui/ et data/ seront créés lorsque des fonctionnalités testées en auront besoin. Aucun dossier vide n'est requis.

## 7. Stratégie de tests et critères d'acceptation

- Tests unitaires purs des modules validation, result, cache et des migrations.
- Tests du générateur : configuration invalide, module manquant, source non déclarée, nom invalide, sortie déterministe et absence de mutation des sources.
- Test runtime : bundle généré chargé par le vrai T.sdk.loadMod, compilation dans le sandbox, exposition des modules et rejet d'un nom absent.
- Test de packaging : présence du bundle, absence des sources séparées, absence des tests et ZIP vérifiable.
- Tests des opérations de persistance : données corrompues, ancienne version, migration, écriture impossible, rechargement et reprise.
- Tests d'idempotence : double callback, double interaction, rechargement au milieu d'une opération et même identifiant de commande répété.
- Tests de limites : grande équipe/boîte, listes invalides, données manquantes, événements répétés et état de session remplacé.
- Tests de non-régression : les événements vanilla continuent, les hooks coopèrent, le mod désactivé ne laisse aucune modification et les autres mods ne reçoivent aucun état global.
- Lint, chargement par le SDK headless, suites make test, make check, make smoke-template et packaging font partie des portes de validation.
- Tests en jeu obligatoires pour menus, scripts Emerald, combat, sauvegarde réelle et performances sur une session représentative.

**Critères d'acceptation :** main.lua charge le bundle avec une seule lecture et une seule compilation sandboxée ; la CI charge exactement le bundle généré ; l'archive ne contient pas les sources séparées ou la configuration de build ; le sous-module moteur et ses sources restent inchangés.

**Limite fonctionnelle inchangée :** le bundle ne peut pas ajouter des capacités absentes de l'API publique. Les services nécessitant une mutation Pokémon ou une transaction atomique non exposée restent bloqués.
