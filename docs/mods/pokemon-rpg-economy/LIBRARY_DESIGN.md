# Bibliothèque interne — Pokémon RPG Economy

**Statut :** architecture retenue pour la première implémentation ; code non commencé  
**Périmètre :** mod `pokemon-rpg-economy`, Gen1Recomp API 3, Pokémon Emerald uniquement  
**Référence moteur auditée :** `0be34bc76cecf996e91d2f905d1b4bb5f14d43ae`

## 1. Objectif et garantie réaliste

Le mod doit réduire au maximum les risques de régression, de conflit avec d'autres mods, de ralentissement et de corruption de sauvegarde. Une petite bibliothèque privée au mod centralise les contrôles communs et évite que chaque service recode sa propre validation, persistance ou gestion d'erreur.

La bibliothèque réduit les risques ; elle ne peut pas garantir l'absence absolue de bugs. Cette garantie dépend aussi des contrats de l'API moteur, des tests headless, des tests en jeu et des limites imposées aux fonctionnalités.

La bibliothèque n'est **pas** un second moteur Pokémon, un framework générique ni une couche de compatibilité cachée.

## 2. Règles d'isolation obligatoires

- Tous les fichiers résident dans `mods/pokemon-rpg-economy/lib/` et appartiennent exclusivement à ce mod.
- Les modules n'ajoutent aucune globale, ne modifient aucun prototype, aucune table partagée du moteur et aucune fonction native.
- Le mod utilise les services publics fournis dans `mod` : événements, hooks, stockage, sauvegarde, UI, monde et combat selon leur contrat documenté.
- Aucun `require("src.*")`, accès à `package`, `dofile`, `loadfile`, `io`, `ffi` ou permission `engine_internals` pour contourner l'API.
- Chaque module reçoit explicitement `mod` et ses dépendances. Pas de singleton global, de dépendance implicite ou d'accès à une variable d'un autre module.
- Un module reste pur au chargement : pas d'abonnement, mutation de sauvegarde, génération aléatoire ou parcours du monde pendant son import.
- Les intégrations entre mods sont facultatives. Le fonctionnement principal ne doit dépendre d'aucun autre mod ; `mod.find` et les exports ne seront utilisés qu'avec vérification de disponibilité et de version.
- Les identifiants, clés de sauvegarde, événements personnalisés et exports sont préfixés par le namespace du mod.

## 3. Chargement des modules dans le sandbox

Le moteur fournit `mod:read(relative)` pour lire les fichiers du mod et `load(source, chunkname)` pour compiler une source dans le même environnement sandboxé que le code principal. Cette paire permet de charger les fichiers locaux sans exposer le chargeur global Lua.

Le petit chargeur de `lib/bootstrap.lua` doit :

1. connaître une table blanche explicite de noms de modules et chemins relatifs ;
2. refuser tout nom inconnu au lieu de transformer une entrée externe en chemin ;
3. lire uniquement avec `mod:read` et compiler uniquement avec le `load` sandboxé ;
4. garder un cache local des modules déjà chargés ;
5. détecter et refuser les cycles d'import ;
6. ne mettre en cache que les modules chargés avec succès ;
7. ajouter le nom du module au message d'erreur puis laisser l'échec remonter au chargeur du mod.

Le chargeur ne doit pas fournir une version permissive de `require` ou accepter des chemins arbitraires. Les erreurs de démarrage doivent faire échouer le chargement du mod proprement ; le chargeur moteur gère alors son rollback d'enregistrement.

Exemple de forme attendue dans le point d'entrée :

```lua
return function(mod)
  local source, readErr = mod:read("lib/bootstrap.lua")
  assert(source, readErr or "missing lib/bootstrap.lua")
  local chunk, compileErr = load(source, "@lib/bootstrap.lua")
  assert(chunk, compileErr or "cannot compile lib/bootstrap.lua")
  local createLibrary = chunk()
  local lib = createLibrary(mod)

  local validate = lib.load("validation")
  local result = lib.load("result")
  -- Démarrer ensuite les services du mod avec leurs dépendances explicites.
end
```

Le code réel devra rester compatible avec la version Lua utilisée par le moteur et passer le loader headless ; cet extrait décrit le contrat, pas un module déjà livré.

## 4. Modules de départ

Ne créer que les primitives réellement utilisées par les premières tranches verticales.

| Module | Responsabilité | Limites |
|---|---|---|
| `bootstrap.lua` | Chargement local allowlisté, cache des modules, détection de cycles | Aucun accès global au chargeur Lua |
| `validation.lua` | Vérification de nombres finis, entiers, bornes, identifiants, enums et structures | Fonctions pures, sans mutation |
| `result.lua` | Format uniforme succès/échec et codes d'erreur | Ne masque jamais une exception inattendue |
| `persistence.lua` | Enveloppe de `mod.save` / `mod.storage`, version de schéma, migrations et validation des données | N'invente pas de transaction physique |
| `cache.lua` | Cache paresseux, borné et invalidable pour données statiques | Ne conserve pas de références vivantes à l'équipe, au jeu ou à la session |
| `diagnostics.lua` | Logs désactivables par catégorie et limitation des répétitions | Aucun log par frame, aucune donnée sensible |

Un module `transactions.lua` ne sera ajouté qu'avec un périmètre prouvé. Il pourra orchestrer l'idempotence des données possédées par le mod. Il ne devra jamais annoncer un rollback atomique d'un Pokémon, d'un objet ou d'argent du moteur si l'API publique ne garantit pas cette opération.

Ne pas créer prématurément une bibliothèque UI, un bus d'événements, un moteur de règles ou une couche de Pokémon. Utiliser d'abord les services déjà fournis par Gen1Recomp.

## 5. Contrats de robustesse

### Validation et erreurs

- Valider toutes les entrées externes avant toute mutation ou dépense.
- Refuser NaN, infini, valeurs fractionnaires lorsque l'entier est requis, identifiants inconnus et listes hors limites.
- Utiliser des codes d'erreur stables et compréhensibles ; ne pas convertir silencieusement une donnée invalide en valeur par défaut si cela peut modifier le résultat économique.
- Les erreurs techniques doivent rester distinctes des résultats aléatoires prévus par le gameplay.
- Une erreur ne doit pas être avalée après qu'une partie de l'opération a déjà modifié l'état.

### Sauvegarde et transactions

- Utiliser `mod.save` pour le petit état qui doit suivre la sauvegarde normale du joueur ; utiliser `mod.storage` pour les données durables indépendantes, conformément à la documentation moteur.
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
- Mesurer les chemins fréquents avant d'optimiser ; pas de micro-optimisation qui rend le code opaque.

### Compatibilité et conflits

- S'abonner une seule fois à chaque événement nécessaire et éviter les hooks redondants.
- Une enveloppe de hook appelle `next` exactement une fois lorsqu'elle étend le comportement existant. Ne pas court-circuiter la chaîne sauf politique explicitement exclusive (comme la suppression de récompense EXP/EV), documentée et testée.
- Choisir des priorités normales ; justifier toute priorité non standard.
- Ne pas modifier les flags, scripts ou récompenses des dresseurs narratifs Emerald sans exigence explicite.
- Ne jamais supposer qu'un autre mod est installé ou qu'il utilise le même ordre de chargement.

## 6. Arborescence cible

```text
mods/pokemon-rpg-economy/
  main.lua
  manifest.json
  lib/
    bootstrap.lua
    validation.lua
    result.lua
    persistence.lua
    cache.lua
    diagnostics.lua
  services/
    progression/
    economy/
    contracts/
    daycare/
    bosses/
  ui/
  data/
  tests/
```

Les dossiers `services/`, `ui/` et `data/` sont une structure cible, pas une invitation à créer des fichiers vides. Un fichier apparaît lorsqu'une fonctionnalité testée en a besoin.

## 7. Stratégie de tests et critères d'acceptation

- Tests unitaires purs des modules `validation`, `result`, `cache` et des migrations.
- Tests du chargeur : module connu, module inconnu, fichier absent, erreur de compilation, exception pendant l'import, cache, cycle et rejet de chemins non autorisés.
- Tests des opérations de persistance : données corrompues, ancienne version, migration, écriture impossible, rechargement et reprise.
- Tests d'idempotence : double callback, double interaction, rechargement au milieu d'une opération et même identifiant de commande répété.
- Tests de limites : grande équipe/boîte, listes invalides, données manquantes, événements répétés et état de session remplacé.
- Tests de non-régression : les événements vanilla continuent, les hooks coopèrent, le mod désactivé ne laisse aucune modification et les autres mods ne reçoivent aucun état global.
- Lint, chargement par le SDK headless, suites `make test`, `make check`, `make smoke-template` et packaging font partie des portes de validation.
- Tests en jeu obligatoires pour menus, scripts Emerald, combat, sauvegarde réelle et performances sur une session représentative.

**Critère d'acceptation :** aucun service gameplay ne peut être ajouté à la production s'il n'utilise pas les validations communes pertinentes, n'a pas de tests headless et ne respecte pas les limites de l'API publique. Toute fonctionnalité dont la sûreté dépend d'une mutation atomique non disponible reste bloquée ou est réduite en périmètre.
