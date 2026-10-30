# Roadmap & Test Plan

## 1. Règle de départ

Aucune implémentation de gameplay ne doit commencer avant la validation du jeu cible, des règles économiques et des extensions moteur listées dans la faisabilité.

Le dépôt possède déjà un template API 3, un SDK de tests headless et les commandes de validation du modkit. Les tests de logique pourront être automatisés sans ROM ; les interactions réelles avec les cartes, le PC, les Centres Pokémon et les combats devront aussi être vérifiées en jeu.

## 2. Phases proposées

### Phase 0 — Validation du design

Livrables :
- jeu de départ fixé ;
- table des paliers et plafonds de niveau ;
- définition des cycles de rematch ;
- règles définitives de vente/consommation ;
- économie initiale et modèle de coût des services ;
- inventaire des villes, routes et zones optionnelles ;
- densité des boss validée.

Critère de sortie : aucun désaccord sur les règles qui modifient la progression ou détruisent volontairement un Pokémon.

### Phase 1 — Prototypes techniques moteur/API

Prouver les éléments bloquants :
- suppression simultanée EXP/EV ;
- niveau des dresseurs selon la zone ;
- détection des soins et du PC ;
- interaction d'un PNJ et ouverture d'un écran ;
- combat de boss sauvage et combat de boss dresseur ;
- mutation et consommation atomiques d'un Pokémon ;
- interdiction des objets de combat.

Si une capacité n'existe pas dans l'API publique, définir une extension moteur documentée et testée avant de poursuivre. Ne pas contourner le sandbox en utilisant des modules internes.

Critère de sortie : tous les prototypes ont un résultat explicite — support existant, extension moteur acceptée ou décision de réduire le périmètre.

### Phase 2 — Première boucle économique jouable

Contenu limité à une zone de départ et une route :
- EXP/EV neutralisés ;
- entraînement payé et plafond de badge ;
- tableau de contrats ;
- remise/rachat transactionnel d'une capture ;
- quelques dresseurs renouvelables ;
- prix des Poké Balls et premières dépenses ;
- sauvegarde et reprise sans duplication.

Critère de sortie : un joueur peut capturer, vendre, gagner des Pokédollars, entraîner son équipe et continuer sans softlock.

### Phase 3 — Services et optimisation de l'équipe

Ajouter progressivement :
- changement de nature ;
- IV ;
- EV ;
- apprentissage de techniques ;
- évolution par service ;
- TM très chers ;
- Day Care et egg-moves ;
- échange de cinq œufs.

Critère de sortie : les donneurs sont correctement consommés, les Pokémon cibles sont modifiés correctement, les limites IV/EV sont respectées et chaque transaction est atomique.

### Phase 4 — Défis optionnels et matériaux

Ajouter :
- minibosses des villes ;
- deux minibosses par segment de route ;
- boss sauvage caché ;
- boss dresseur ;
- PNJ d'information ;
- matériaux et recettes d'objets tenus.

Commencer par une ville et un segment de route entièrement produits et équilibrés, avant de généraliser à toute la région.

Critère de sortie : tous les boss sont facultatifs, non agressifs, correctement sauvegardés et leurs récompenses ne peuvent pas être dupliquées.

### Phase 5 — Couverture de la région et équilibrage

- Compléter la carte de contenu.
- Étendre les contrats locaux.
- Vérifier la progression badge par badge.
- Simuler les flux d'argent et les coûts.
- Vérifier la compatibilité LeafGreen si elle est retenue.
- Préparer le packaging et les notes de version.

## 3. Matrice de tests

| Domaine | Vérifications |
|---|---|
| EXP | Aucun gain en combat sauvage, dresseur, miniboss ou boss |
| EV | Aucun gain de combat, même avec Exp Share, Pokérus ou objets multiplicateurs |
| Niveau | Un achat ne dépasse pas le cap ; capture ou retrait de boîte ne contourne pas la règle |
| Dresseurs | Niveaux cohérents avec la zone et les badges |
| Rematch | Un dresseur ne paie qu'une fois par cycle ; reset uniquement après repos effectif |
| Argent | Aucun paiement dupliqué ; aucun solde négatif ; coûts correctement affichés |
| Contrats | Espèce et zone valides ; contrat accepté avant capture ; capture remise une seule fois |
| Consommation | Bon donneur consommé, cible préservée, transaction annulée sans perte en cas d'erreur |
| Nature | Sexe, shiny, aptitude et forme restent valides après changement |
| IV/EV | IV entre 0 et 31 ; 252 EV par stat au maximum ; 510 EV au total |
| Moves | Compatibilité vérifiée ; pas de doublon ou de move invalide |
| Évolution | Espèce cible correcte ; pas de duplication ni de perte du Pokémon |
| Day Care | Egg-move légal ; cinq œufs consommés une seule fois ; espèce reçue non légendaire et non évoluée |
| Objets | Aucun objet de sac utilisable en combat de dresseur ou de boss ; Poké Balls encore utilisables en combat sauvage ordinaire |
| Boss | Pas d'auto-déclenchement ; option de refuser ; une seule récompense unique |
| Sauvegarde | Progression, matériaux, contrats et flags conservés après sauvegarde, fermeture et reprise |
| Désactivation | Le comportement vanilla revient sans laisser d'état corrompu |

## 4. Tests headless et tests en jeu

### Tests headless

Le SDK du moteur permet de charger un mod API 3 et de tester les hooks, registres, écrans et états simulés. Il doit être utilisé pour les règles déterministes et les transactions.

Exemples de cas à couvrir :
- contrats acceptés, complétés, refusés et payés ;
- cycle de rematch avec zéro, un ou plusieurs dresseurs vaincus ;
- calcul des caps et tarifs ;
- règles de consommation des donneurs ;
- sélection aléatoire reproductible pour l'échange d'œufs ;
- sauvegarde/reprise et protection contre la duplication.

### Tests en jeu

Les tests réels sont nécessaires pour :
- les scripts des Centres Pokémon ;
- le PC et les boîtes ;
- les animations et dialogues ;
- le placement et la persistance des PNJ ;
- les combats et les objets de sac ;
- les combats déclenchés via interaction ;
- le comportement après défaite et retour au Centre.

## 5. Équilibrage

Avant toute généralisation, relever sur le jeu cible :
- prix de vente et d'achat des objets ;
- prix des outils de capture ;
- niveaux et gains d'argent des dresseurs ;
- tables d'espèces et taux de rencontre ;
- niveaux des Champions et des boss narratifs ;
- durée moyenne d'un contrat ;
- coût cumulé d'un entraînement de l'équipe ;
- nombre de contrats et rematchs requis par badge.

Un tableau de simulation économique devra ensuite vérifier que les revenus attendus couvrent les dépenses essentielles sans rendre les TM, les améliorations ou les boss insignifiants.

## 6. Critères globaux de qualité

- Pas de softlock économique.
- Pas de perte de Pokémon non confirmée.
- Pas de duplication d'argent, d'œufs, de matériaux ou de récompenses.
- Pas de reset involontaire de flags de l'histoire originale.
- Pas de boss imposé.
- Pas de dépendance à une API interne non documentée.
- Toutes les règles importantes sont visibles et expliquées au joueur.
