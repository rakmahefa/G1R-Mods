# Proposition — API transactionnelle Pokémon

**Statut :** contrat proposé à l'équipe moteur ; aucune API de transaction Pokémon n'est encore implémentée.  
**Cible du premier mod :** Pokémon Emerald, API 3.  
**Référence auditée :** Gen1Recomp commit 0be34bc76cecf996e91d2f905d1b4bb5f14d43ae.

Ce document décrit le contrat minimal nécessaire pour les fonctionnalités de Pokémon RPG Economy qui lisent, déplacent, modifient, consomment ou créent des Pokémon. Il ne donne pas au mod l'autorisation d'accéder aux internes du moteur. La proposition doit être revue et implémentée dans le moteur, avec sa propre suite de tests, avant que le mod ne l'utilise.

## 1. Décision d'architecture

Le moteur doit exposer une façade publique et versionnée, liée au jeu courant :

- une API de consultation renvoyant des snapshots détachés et des références Pokémon opaques ;
- un coordinateur transactionnel qui combine plusieurs opérations de jeu dans une seule transaction ;
- des reçus et des erreurs typées, avec idempotence persistante ;
- une identité Pokémon stable au sein d'une sauvegarde/playthrough, indépendante de la place du Pokémon dans l'équipe ou une boîte.

Le mod ne doit jamais recevoir une table mutable de session, une référence vers session.party, session.storage ou un objet Pokemon interne. Il ne doit pas appeler Party.*, Storage.*, Schema.*, SaveData.*, ni utiliser mod.game.session.

Les noms de méthodes ci-dessous sont illustratifs : l'API finale appartient au moteur et doit suivre sa convention de versionnement. Le contrat sémantique, lui, est la demande.

## 2. Constats vérifiés dans le moteur épinglé

### 2.1 Une place n'est pas une identité

Dans src/core/game3/storage.lua :

- l'équipe est une liste compacte ; Storage.deposit, withdraw, moveMon, pickUpMon et restoreHeldMon peuvent insérer, retirer, déplacer ou compacter ses entrées ;
- les boîtes stockent les Pokémon dans storage.boxes[box].mons[slot] ; les opérations de déplacement peuvent échanger deux Pokémon ou changer de boîte ;
- Storage.releaseMon retire un Pokémon de sa boîte et retourne la table retirée ;
- les fonctions de déplacement manipulent les tables Pokémon, pas des identifiants persistants.

Un indice d'équipe, de boîte ou de case ne peut donc pas servir de clé durable : il identifie une position temporaire. L'espèce, le surnom, le Dresseur d'origine, la personnalité ou le PID ne constituent pas non plus une clé applicative garantie unique et immuable.

### 2.2 Les copies et la sauvegarde préservent des données, pas une identité

Dans src/core/game3/party.lua, Party.takeOpaque et Party.writeBack copient toutes les paires de chaque table Pokémon, et copient également ses sous-tables d'un niveau. Party.applyBattleFields ne met à jour qu'une liste blanche de champs de combat.

Schema.toSaveTable exporte l'équipe et sérialise le PC par Storage.serialize ; Schema.fromSaveTable reconstruit l'équipe et le stockage, puis compacte la liste de l'équipe. Storage.serialize conserve les tables Pokémon des cases non vides. SaveSerializer sérialise les tables de données avec une grammaire Lua restreinte.

Le format possède déjà session.meta.playthroughId, qui identifie le playthrough, mais aucun identifiant stable propre à chaque Pokémon n'a été confirmé dans le modèle audité. Une identité persistante doit donc être ajoutée et maintenue par le moteur, pas reconstruite par le mod à partir de champs de jeu.

### 2.3 Les points d'entrée publics actuels ne suffisent pas

src/world/game3/WorldAPI.lua fournit notamment reorderParty, une action contrôlée de réorganisation. Il ne fournit pas d'API générale pour parcourir les Pokémon de l'équipe et des boîtes, inspecter un Pokémon par référence, le modifier ou le consommer.

mod.save est adossé au compartiment du mod dans session.modData, donc à la sauvegarde normale. mod.storage est un espace indépendant par mod/playthrough, écrit séparément. Il n'est pas adapté à une transaction qui doit modifier un Pokémon, l'argent, le sac et l'état du mod en même temps.

Dans src/core/Game3.lua, Game3:saveGame reconstruit le tableau de sauvegarde à partir de la session active puis appelle SaveData.save. La propriété game.save est un tableau de sauvegarde projeté/rafraîchi au cycle de sauvegarde ; ce n'est pas une autorisation de modifier directement la session active.

## 3. Identité et référence opaque

Le moteur doit fournir un identifiant opaque, unique à l'intérieur d'un playthrough, pour chaque Pokémon possédé et chaque Pokémon géré temporairement par un service.

Une référence exposée peut avoir cette forme logique :

~~~lua
{
  id = "<opaque-engine-id>",
  playthrough = "<opaque-playthrough-id>",
  revision = "<opaque-version-token>"
}
~~~

Le moteur peut représenter ces données différemment. Les garanties nécessaires sont :

1. **Stable à travers les positions.** La référence continue de désigner le même Pokémon après un changement d'ordre d'équipe, dépôt/retrait PC, échange de cases, déplacement entre boîtes ou compactage.
2. **Persistante au rechargement.** Elle reste valable après sauvegarde puis continuation du même playthrough.
3. **Non réutilisable.** Après consommation/libération définitive, l'identifiant ne doit pas être affecté à un autre Pokémon.
4. **Scopée.** Une référence d'un autre playthrough ou d'une autre version de jeu est rejetée.
5. **Versionnée.** Toute mutation pertinente ou tout déplacement invalide l'ancien jeton revision. Une transaction fondée sur une vue périmée échoue avec stale_reference ou revision_conflict.
6. **Opaque et non positionnelle.** Aucun chemin de fichier, slot brut, pointeur Lua ou table interne n'est retourné au mod.

Le champ technique qui porte l'identité reste un choix moteur. Un identifiant réservé dans la table Pokémon sérialisée est un candidat : les copies de l'équipe et les déplacements de boîte conservent aujourd'hui les autres paires de la table. Il faut toutefois tester les chemins de normalisation, import/export et conversion avant de le retenir. Les identifiants internes ne font pas partie du format Pokémon natif de la cartouche ; importer une sauvegarde externe peut donc créer une nouvelle lignée d'identités et invalider les anciennes références.

## 4. Surface publique minimale proposée

### 4.1 Consultation détachée

Une façade liée au jeu courant pourrait fournir :

~~~lua
local view, code, message = mod.pokemon:list({
  locations = { "party", "boxes" },
})

-- view.revision est un jeton global de vue.
-- Chaque entrée contient une référence opaque et un snapshot data-only.
local mon = view.entries[1]
local detail = mod.pokemon:inspect(mon.ref)
~~~

Chaque snapshot est détaché et non modifiable. Les entrées indiquent la localisation à titre informatif, mais le mod ne doit jamais utiliser la localisation comme clé. La consultation peut être filtrée (équipe, boîtes, œufs, etc.) et doit avoir des limites explicites de nombre d'entrées et de données retournées.

### 4.2 Transactions composées

Pour des opérations qui combinent plusieurs ressources, une seule façade de transaction est préférable à une série d'appels indépendants :

~~~lua
local receipt, code, message = mod.transactions:commit({
  idempotencyKey = "daycare:start:<request-id>",
  expectedViewRevision = view.revision,

  operations = {
    { type = "pokemon.consume", ref = eggA.ref },
    { type = "pokemon.consume", ref = eggB.ref },
    { type = "wallet.delta", amount = -serviceFee },
    { type = "pokemon.create", definition = generatedPokemon,
      destination = "party_or_pc" },
  },

  -- Écrit uniquement dans le compartiment propre à ce mod.
  modState = {
    daycare = updatedDaycareState,
  },
})
~~~

Cette forme est indicative, et les types d'opération doivent être explicitement autorisés et validés par le moteur. Le mod ne fournit jamais une fonction Lua arbitraire à exécuter dans la transaction.

La première version doit couvrir au minimum :

| Opération | Contrat |
|---|---|
| pokemon.consume | Résout une référence et la retire définitivement si la révision correspond et si les règles de sécurité sont respectées |
| pokemon.update | Modifie une liste blanche de champs avec validation spécifique à chaque champ |
| pokemon.create | Construit un Pokémon valide avec les générateurs du moteur, puis le place dans l'équipe ou le PC selon la politique choisie |
| pokemon.transfer | Déplace/échange un Pokémon entre équipe et boîte sans changer son identité |
| wallet.delta | Vérifie le solde et applique un delta sans dépassement |
| bag.add / bag.remove | Vérifie les limites de poche, quantité et capacité avant la mutation |
| modState | Met à jour les seules données persistantes du mod appelant, dans la même sauvegarde |

La liste finale dépendra des services que l'équipe moteur accepte de prendre en charge. Les opérations non implémentées doivent échouer explicitement ; pas de fallback sur les internes.

## 5. Sémantique de commit et persistance

Une transaction qui consomme un Pokémon ou modifie une ressource de jeu doit respecter toutes les étapes suivantes :

1. **Préconditions.** Vérifier le playthrough, les références, les révisions, les doublons, l'espèce, l'éligibilité, les quantités, les capacités du sac/PC et les protections configurées.
2. **Staging.** Construire une version candidate détachée des données affectées. Aucune mutation visible du jeu n'a encore lieu.
3. **Validation globale.** Vérifier l'ensemble de l'état candidat : limites d'équipe/PC, présence du dernier Pokémon utilisable, solde, données Pokémon et état de mod. Un échec ne modifie rien.
4. **Commit unique.** Produire une seule nouvelle génération de sauvegarde qui contient ensemble l'équipe, les boîtes, l'argent, le sac, les métadonnées et le modData du mod. Ne pas répartir une transaction logique entre mod.save et une écriture séparée mod.storage.
5. **Publication.** Publier l'état candidat dans la session active seulement selon le protocole de commit du moteur. Les références aux anciennes tables conservées par les menus, scripts ou systèmes de combat ne doivent pas pouvoir réintroduire un état obsolète.
6. **Reçu durable.** Retourner committed uniquement lorsque le moteur sait que l'opération est enregistrée et récupérable après redémarrage. Si la sauvegarde échoue, retourner une erreur technique explicite et ne jamais annoncer au joueur un résultat aléatoire.

Le cycle de sauvegarde actuel utilise des fichiers principaux, temporaires et de sauvegarde de secours avec une logique de récupération. Il ne faut pas assimiler cela à un rename atomique du système de fichiers. Le service transactionnel doit réutiliser ce mécanisme de manière contrôlée ou introduire un journal de transaction durable, puis tester les interruptions à chaque étape d'écriture.

### 5.1 Idempotence et reprise

Chaque commit exige une clé d'idempotence générée pour une action utilisateur. Le moteur conserve dans la même sauvegarde un reçu compact comprenant au minimum la clé, l'empreinte de la requête, le statut et le résultat.

- même clé + même requête : renvoyer le reçu précédent sans rejouer l'opération ni le hasard ;
- même clé + requête différente : rejeter avec idempotency_conflict ;
- commit non durable : aucune confirmation de réussite ; l'appelant peut réessayer avec la même clé ;
- commit déjà durable : un retry ou un redémarrage ne doit jamais consommer ou donner une seconde fois.

Le journal peut être borné, mais sa politique de rétention ne doit jamais réintroduire un double paiement ou un reroll pour les transactions encore susceptibles d'être rejouées.

### 5.2 Erreurs typées

Codes minimaux à stabiliser :

- stale_reference, revision_conflict, not_found, wrong_playthrough ;
- ineligible_pokemon, protected_pokemon, last_usable_pokemon ;
- party_full, pc_full, bag_full, insufficient_funds, invalid_operation ;
- idempotency_conflict, already_committed, persistence_failed, recovery_required.

Une erreur technique ne doit jamais être convertie silencieusement en résultat de gameplay (par exemple « 10 % de chance de ne rien recevoir »).

## 6. Application au Day Care — workflow en deux commits

Le Day Care a deux étapes irréversibles/logiques, séparées par le choix du joueur. Un seul gros callback ne doit pas englober l'affichage UI ni rester ouvert pendant plusieurs frames.

### Étape A — lancement confirmé

Une fois l'avertissement accepté, le premier commit doit :

- revalider les références des cinq œufs et vérifier qu'ils sont toujours des œufs admissibles ;
- vérifier qu'un résultat Pokémon pourra être livré (ou établir une réservation de capacité) ;
- consommer les cinq œufs ;
- générer les dix Pokémon de niveau 5, sur dix espèces distinctes autorisées ;
- stocker les dix résultats générés et l'identifiant d'offre dans l'état persistant du mod, dans la même sauvegarde que la consommation des œufs ;
- enregistrer un reçu idempotent pour l'action de lancement.

En cas d'échec technique avant commit durable, les cinq œufs doivent rester présents et l'offre ne doit pas être annoncée comme démarrée. Après un commit durable, les œufs sont consommés conformément à la règle de design.

### Étape B — choix et tirage final

Après que le joueur a choisi un des dix Pokémon :

- valider l'identifiant de l'offre, la sélection et l'état courant ;
- effectuer exactement un tirage 90 % / 10 % au sein du moteur ;
- enregistrer le choix et le résultat avant d'afficher la conclusion ;
- sur 90 %, livrer exactement le Pokémon choisi, pas une nouvelle génération ;
- sur 10 %, clore avec le résultat attendu « aucun Pokémon » ;
- si une erreur technique empêche la livraison après un tirage gagnant, conserver un état pending_delivery récupérable. Ne pas transformer ce cas en résultat 10 % et ne pas relancer le tirage.

Un rechargement, une répétition d'interaction ou un retry technique doit reprendre l'offre ou son résultat déjà enregistré, jamais régénérer les candidats ni consommer une nouvelle fois les œufs.

## 7. Protections indispensables

Le moteur doit appliquer ces préconditions de façon centrale, même si le mod affiche ses propres confirmations :

- ne pas consommer le dernier Pokémon utilisable de l'équipe sans politique explicite et sûre ;
- respecter un drapeau de protection/favori si cette fonctionnalité est activée ;
- détecter les Pokémon absents, déplacés, remplacés ou modifiés depuis le snapshot ;
- ne pas détruire un Pokémon si la destination ou l'espace requis pour un échange n'est pas garanti ;
- ne pas perdre un Pokémon si le PC ou l'équipe est plein ;
- ne pas accepter de doublons de références dans une seule transaction ;
- refuser une transaction pendant un combat, une animation de transfert, une sauvegarde concurrente ou un autre contexte où le jeu ne peut pas être gelé en sécurité.

## 8. Matrice de tests exigée côté moteur

| Cas | Résultat attendu |
|---|---|
| Déplacer équipe ↔ boîte, changer l'ordre, changer de case | Même identité ; ancienne révision périmée si la localisation change |
| Sauvegarder puis continuer | Même identité dans le même playthrough |
| Consommer puis réutiliser la référence | not_found / stale_reference, jamais un autre Pokémon |
| Deux Pokémon de champs de jeu identiques | Deux identités distinctes |
| Pokémon importé depuis un save externe | Identité attribuée/réconciliée ; anciennes références invalides |
| Transaction avec une opération invalide au milieu | Aucune modification partielle |
| Argent ou capacité insuffisants | Aucune mutation ni consommation |
| Deux commits concurrents sur la même révision | Un seul gagne ; l'autre reçoit un conflit |
| Retry même clé / même requête | Même reçu, aucun double effet |
| Retry même clé / requête différente | idempotency_conflict |
| Interruption avant/pendant/après l'écriture temporaire et principale | Ancienne ou nouvelle génération récupérable, jamais un état partiel incohérent |
| Échec de livraison après tirage gagnant | pending_delivery persistant ; aucune relance du hasard |
| Party et PC pleins | Le service refuse avant consommation, ou conserve une livraison en attente explicitement récupérable |

La suite doit inclure les chemins natifs de capture, éclosion d'œuf, génération, échange, libération, dépôt/retrait PC, déplacement, pickUpMon / placeHeldMon / restoreHeldMon, migration et conversion.

## 9. Séquence d'implémentation proposée

1. Concevoir l'identité opaque et sa migration de sauvegarde.
2. Ajouter les services de lecture de snapshots et de références versionnées.
3. Implémenter le coordinateur de transaction pour Pokémon + monnaie + sac + modData.
4. Tester la sauvegarde/récupération et l'idempotence par injection de pannes.
5. Exposer la façade publique API 3 avec des limites explicites et des erreurs stables.
6. Ajouter les appels du mod uniquement après publication et validation du contrat moteur.

**Aucun service économique qui consomme ou modifie un Pokémon ne doit être implémenté tant que les critères de cette proposition ne sont pas satisfaits.**