# PRD — « MyBody:RPG »

> Application mobile Android de musculation avec un système de progression
> **RPG façon Solo Leveling** : chaque entraînement te fait gagner de l'XP,
> monter de niveau, augmenter tes stats et grimper dans les rangs (E → S).

- **Statut :** Brouillon v1 (à itérer)
- **Plateforme :** Android (Flutter, iOS possible plus tard)
- **Cible :** débutants → intermédiaires qui veulent rester motivés grâce au jeu

### Décisions actées (v1)
- **Nom :** MyBody:RPG.
- **Avatar/visuel :** on commence **simple** (icônes + barres), priorité au
  fond (le moteur de jeu) ; la forme (illustrations/avatar) viendra plus tard.
- **Stats :** **répartition automatique** + un **test initial** qui fixe le
  niveau et les stats de départ (voir §3.6).
- **Unités :** **kg uniquement** au MVP.
- **Discipline :** **musculation uniquement** au début (cardio/poids du corps
  plus tard).

---

## 1. Vision & pitch

Beaucoup d'apps de muscu sont des « tableurs glorifiés » : on note ses séries,
mais rien ne donne envie de revenir. **LevelUp Gym** transforme chaque séance
en une session de jeu : tu es un *chasseur* qui se renforce. Plus tu
t'entraînes (régulièrement, intensément, avec progression), plus tu gagnes de
l'XP, plus ton personnage monte de niveau et de rang.

**Phrase d'accroche :** « Ton corps est ton personnage. Entraîne-toi pour
monter de niveau dans la vraie vie. »

### Objectifs produit
1. Rendre la **régularité** addictive (streaks, quêtes quotidiennes).
2. Récompenser le **vrai progrès** (charges, volume, records) et pas juste
   le fait d'ouvrir l'app.
3. Garder une **boucle de jeu claire** : Séance → XP → Niveau → Stats → Rang.

### Non-objectifs (v1)
- Pas de coaching nutritionnel poussé.
- Pas de multijoueur temps réel / guildes (prévu plus tard).
- Pas de wearables/montres connectées (prévu plus tard).

---

## 2. Personas

| Persona | Besoin | Ce que l'app apporte |
|---|---|---|
| **Léo, 19 ans, débutant** | Ne sait pas par où commencer, se décourage vite | Programmes guidés + récompenses immédiates (XP, level up) |
| **Sarah, 27 ans, intermédiaire** | A déjà une routine, veut rester motivée | Suivi des records, quêtes, stats détaillées, rangs |
| **Karim, 34 ans, occupé** | Manque de temps et de régularité | Séances courtes, streaks, rappels, quêtes quotidiennes |

---

## 3. La boucle de gameplay (cœur du produit)

```
┌──────────────┐   loggue ses séries   ┌──────────────┐
│  Entraînement │ ────────────────────▶ │  Calcul d'XP  │
└──────────────┘                        └──────┬───────┘
        ▲                                       │
        │ nouvelles quêtes / défis              ▼
┌──────────────┐                        ┌──────────────┐
│  Motivation   │ ◀──────────────────── │  Level up /   │
│  (revenir)    │   stats, rang, loot   │  progression  │
└──────────────┘                        └──────────────┘
```

### 3.1 Système d'XP

L'XP récompense **3 choses** (pondérées) :

1. **Le volume travaillé** — `séries × reps × charge` (tonnage).
2. **La régularité** — bonus de streak (jours d'affilée).
3. **Le dépassement** — bonus si nouveau record (PR) ou progression vs séance précédente.

**Formule proposée (v1, à équilibrer) :**

```
XP_seance = XP_base
          + (tonnage / facteur_volume)
          + bonus_streak
          + bonus_PR
          + bonus_quetes

XP_base          = 50            // juste pour avoir fait la séance
facteur_volume   = 100           // 1 XP par 100 kg soulevés (tous exercices cumulés)
bonus_streak     = min(jours_streak, 7) × 10   // +10/jour jusqu'à +70
bonus_PR         = 75 par record personnel battu dans la séance
bonus_quetes     = somme des XP des quêtes complétées
```

> ⚠️ Garde-fou anti-triche : plafonner l'XP/jour et détecter les charges
> aberrantes pour éviter le « farm » de niveaux.

### 3.2 Niveaux

Courbe d'XP **progressive** (chaque niveau coûte un peu plus) :

```
XP_pour_niveau(n) = round(100 × n^1.5)

Niv 1 → 2 :  100 XP
Niv 2 → 3 :  283 XP
Niv 5 → 6 :  1118 XP
Niv 10 → 11 : 3162 XP
```

À chaque montée de niveau : animation « LEVEL UP », +1 point de stat à
répartir (ou réparti auto), et parfois un déblocage (titre, thème, exercice).

### 3.3 Stats du personnage (RPG)

Les stats montent automatiquement selon le **type** de travail effectué :

| Stat | Monte avec | Représente |
|---|---|---|
| **💪 Force (STR)** | charges lourdes, faibles reps | force max |
| **🔥 Endurance (END)** | hautes reps, cardio, circuits | résistance |
| **⚡ Explosivité (AGI)** | mouvements rapides/pliométrie | vitesse |
| **🛡️ Volonté (WIL)** | régularité, streaks | discipline |
| **❤️ Vitalité (VIT)** | fréquence + récup respectée | santé globale |

Profil radar (toile d'araignée) pour visualiser l'équilibre du « build ».

### 3.4 Rangs

Paliers de niveau qui débloquent un **rang de chasseur** (cosmétique + fierté) :

| Rang | Niveau requis | Couleur/badge |
|---|---|---|
| **E** | 1–9 | gris |
| **D** | 10–19 | vert |
| **C** | 20–34 | bleu |
| **B** | 35–49 | violet |
| **A** | 50–69 | orange |
| **S** | 70+ | doré (animé) |

### 3.5 Quêtes & défis

- **Quêtes quotidiennes** (renouvelées chaque jour) : ex. « Fais 3 exercices »,
  « Bats 1 record », « 20 min minimum ». Récompense en XP.
- **Quêtes hebdo** : ex. « Entraîne-toi 4 fois cette semaine ».
- **Défis de boss** (mensuel) : objectif de volume/PR à atteindre, grosse
  récompense + titre exclusif.
- **Streak** : compteur de jours, avec « gel de streak » (1-2 jokers/mois).

### 3.6 Test initial (« Évaluation du chasseur »)

À la création du personnage, le joueur passe un **bilan de force** qui fixe son
**niveau et ses stats de départ** (au lieu de partir tout le monde au niveau 1).
Ça personnalise l'expérience et évite à un confirmé de « regrinder » depuis zéro.

**Principe :** le joueur renseigne (ou teste) sa **performance max** sur
quelques exercices de référence couvrant les grands groupes musculaires :

| Mouvement de référence | Stat principale |
|---|---|
| Développé couché (bench) | 💪 Force (haut du corps) |
| Squat | 💪 Force (bas du corps) |
| Soulevé de terre (deadlift) | 💪 Force (chaîne postérieure) |
| Tractions / rowing (reps max) | 🛡️ Volonté + 🔥 Endurance |
| Développé militaire (overhead) | ⚡ Explosivité / épaules |

**Saisie possible de 2 façons :**
- **1RM connu** (charge max sur 1 rep), ou
- **charge × reps** → on **estime le 1RM** via la formule d'Epley :
  `1RM ≈ charge × (1 + reps / 30)`.

**Normalisation par le poids de corps** (ratio force/poids) pour comparer
équitablement : `ratio = 1RM / poids_corps`. On mappe ensuite le ratio sur des
paliers (ex. bench : débutant <0.75×PC, intermédiaire ~1×PC, avancé ~1.5×PC)
pour calculer le **niveau de départ**, le **rang** et la **répartition initiale
des stats**.

> Le test est **optionnel/rapide** : le joueur peut sauter et démarrer au
> niveau 1, ou ne remplir que les exercices qu'il connaît. Il pourra **refaire
> l'évaluation** plus tard pour réajuster (utile après une longue pause).

---

### 3.7 Progression guidée (double progression)

L'app **dit au joueur quoi faire** pour progresser, exercice par exercice.

- À la création du profil, le joueur choisit un **objectif** qui fixe la
  fourchette de répétitions visée :
  - 🔋 **Endurance** → 12–20 reps
  - 🧱 **Prise de masse** → 8–12 reps
  - 🏋️ **Force** → 5–8 reps
- Sur chaque exercice, tant que le joueur réussit son objectif :
  **+1 rep** à la séance suivante.
- Quand il atteint le **haut de la fourchette** sur toutes ses séries :
  **palier débloqué** → on augmente le poids et on repart au bas de la
  fourchette. Chaque palier = mini « level up » de l'exercice (XP + record).
- **Pas d'augmentation du poids** selon le groupe musculaire :
  - 💪 Bras (biceps/triceps) et épaules → **+2 kg**
  - 🫁 Pecs, dos, jambes → **+5 kg**

> ⚠️ La progression « +1 rep / +poids » est gérée **par exercice**, pas via le
> niveau global du personnage (qui, lui, cumule toutes les séances).

### 3.8 Perte de progression (désentraînement)

Pour donner une vraie raison de revenir, l'XP **diminue** en cas d'inactivité
prolongée — façon « désentraînement » réel, mais en douceur :

- **Délai de grâce : 4 jours.** Se reposer jusqu'à 4 jours ne coûte rien.
- Au-delà, perte d'**XP par jour** d'inactivité.
- **Calibrage : ~2 semaines (14 jours) sans séance = environ 1 niveau perdu.**
- **Plancher de sécurité : on ne descend jamais sous son rang.** Ex. rang C
  (niveaux 20-34) → on peut retomber jusqu'au niveau 20, jamais en rang D.

> Objectif : motiver sans décourager. La perte est lente, plafonnée par le
> rang, et vite récupérable dès qu'on reprend l'entraînement. (Les jokers de
> « gel de streak » du §3.5 peuvent aussi protéger d'un imprévu.)

### 3.9 Équipement & exercices adaptés

À la création du profil, le joueur **coche l'équipement qu'il possède** (dans sa
salle ou chez lui). L'app ne lui propose alors que les exercices **réalisables**
avec ce matériel.

- Équipements cochables : barre + disques, haltères, banc, machines guidées,
  poulie/câble, barre de traction.
- Le **poids du corps** est toujours disponible (pas besoin de le cocher).
- Un exercice n'apparaît que si **tout** son équipement requis est coché
  (ex. développé couché = barre **+** banc).
- Le joueur peut modifier son équipement plus tard (s'il change de salle).

> Exemple : « haltères + banc » à la maison → ~13 exercices proposés ;
> « poids du corps » seul → ~6 ; salle complète → tout le catalogue.

## 4. Fonctionnalités (scope)

### MVP (v1) — indispensable
- [ ] Onboarding + création de personnage (pseudo, poids de corps, objectif).
- [ ] **Sélection de l'équipement disponible** (salle, maison, poids du corps)
      → l'app ne propose que les exercices réalisables (§3.9).
- [ ] **Test initial** d'évaluation (§3.6) → niveau, rang et stats de départ.
- [ ] Bibliothèque d'exercices (groupe musculaire, équipement, consignes).
- [ ] Lancement d'une séance : ajouter exercices, séries (reps × charge),
      minuteur de repos.
- [ ] Calcul & attribution d'XP en fin de séance + écran « récompenses ».
- [ ] Niveaux, stats, rang, barre d'XP.
- [ ] Quêtes quotidiennes.
- [ ] Streak + rappel/notification quotidienne.
- [ ] Historique des séances + records (PR) par exercice.
- [ ] Stockage **local hors-ligne** (l'app marche sans compte/internet).

### v1.1 — important
- [ ] Programmes/templates de séances (Push/Pull/Legs, Full-body…).
- [ ] Graphiques de progression (volume, charge max par exercice).
- [ ] Quêtes hebdo + boss mensuel.
- [ ] Personnalisation d'avatar via déblocages.

### v2 — plus tard
- [ ] Compte cloud + synchro multi-appareils.
- [ ] Social : amis, classement (leaderboard), guildes.
- [ ] Intégration Google Fit / Health Connect / montres.
- [ ] Saisons (ladder qui reset) à la « battle pass ».

---

## 5. Écrans (UX)

1. **Onboarding** — bienvenue, objectif, création du chasseur.
2. **Accueil / Dashboard** — perso (niveau, rang, barre d'XP), radar de stats,
   quêtes du jour, streak, bouton « Démarrer une séance ».
3. **Nouvelle séance** — sélection d'exercices, saisie séries (reps/charge),
   minuteur de repos, total en direct.
4. **Récompenses (post-séance)** — XP gagné détaillé, level up animé, PR battus,
   quêtes complétées.
5. **Bibliothèque d'exercices** — recherche/filtre par muscle & équipement.
6. **Progression** — historique, graphiques, records.
7. **Profil / Personnage** — stats détaillées, rang, titres, avatar, succès.
8. **Quêtes** — quotidiennes, hebdo, boss.
9. **Paramètres** — unités (kg/lb), notifications, thème, export/sauvegarde.

**Direction artistique :** sombre, accents néon (façon « interface de
chasseur »), animations satisfaisantes (level up, gain d'XP qui se remplit,
ouverture de récompense). Sons/vibrations optionnels.

---

## 6. Architecture technique (Flutter)

- **Langage/Framework :** Dart + Flutter (Android d'abord, iOS-ready).
- **State management :** Riverpod (ou Bloc) — à confirmer.
- **Base de données locale :** Drift (SQLite typé) ou Isar — hors-ligne d'abord.
- **Navigation :** go_router.
- **Graphiques :** fl_chart.
- **Notifications :** flutter_local_notifications.
- **Tests :** unitaires sur la **logique d'XP/niveaux/stats** (cœur critique).

### Modèle de données (esquisse)

```
User        { id, pseudo, poidsCorps, objectif, equipement[], level, xp, rank, createdAt }
Stat        { userId, str, end, agi, wil, vit }
Assessment  { id, userId, date, exerciseId, charge, reps, oneRmEstime }  // test initial

Exercise    { id, nom, groupeMusculaire, equipement, type }   // catalogue
Workout     { id, userId, date, dureeMin, xpGagne }
WorkoutSet  { id, workoutId, exerciseId, reps, charge, ordre }
PersonalRecord { userId, exerciseId, charge, reps, date }
Quest       { id, type(quotidien/hebdo/boss), description, xpReward, etat }
Streak      { userId, joursActuels, record, dernierJour, jokersRestants }
```

### Organisation du code (proposition)

```
lib/
  core/        // thème, constantes, utils
  data/        // modèles, base locale (drift), repositories
  features/
    onboarding/
    home/
    workout/
    rewards/
    library/
    progress/
    profile/
    quests/
  game/        // ⭐ moteur de jeu : XP, niveaux, stats, rangs, quêtes
  main.dart
```

> Le dossier `game/` est le cœur du produit : 100% testable, sans dépendance UI.

---

## 7. Indicateurs de succès (KPI)

- **D1 / D7 retention** (revient à J+1, J+7).
- **Séances/utilisateur/semaine.**
- **Longueur moyenne des streaks.**
- **% de quêtes quotidiennes complétées.**

---

## 8. Risques & points à valider

| Risque | Mitigation |
|---|---|
| Équilibrage de l'XP (trop lent/rapide = démotivant) | Constantes centralisées + playtests, ajustables |
| Triche / farm d'XP | Plafond d'XP/jour, détection de valeurs aberrantes |
| Saisie fastidieuse pendant la séance | UX rapide : valeurs précédentes pré-remplies, gros boutons |
| Saturation des notifications | 1 rappel/jour max, personnalisable |

---

## 9. Roadmap proposée

1. **Sprint 0** — setup projet Flutter, thème, navigation, base locale.
2. **Sprint 1** — moteur de jeu (`game/`) + tests : XP, niveaux, stats, rangs.
3. **Sprint 2** — flux séance (saisie + minuteur) + écran récompenses.
4. **Sprint 3** — dashboard, profil/perso, historique & records.
5. **Sprint 4** — quêtes quotidiennes + streak + notifications.
6. **Sprint 5** — polish (animations, sons), onboarding, bêta interne.

---

## 10. Décisions & questions restantes

**Tranché :**
- ✅ Nom : **MyBody:RPG**.
- ✅ Visuel : icônes/barres au début, focus sur le fond.
- ✅ Stats : **auto** + **test initial** pour le niveau/stats de départ.
- ✅ Unités : **kg** uniquement.
- ✅ Discipline : **musculation** uniquement au MVP.

**Encore à trancher :**
- Liste exacte des exercices du test initial (5 proposés en §3.6 — OK ?).
- Paliers de ratio force/poids par exercice (à caler avec des barèmes connus).
- Répartition fine des points de stat par type de série (à équilibrer au code).
- Plafond d'XP/jour anti-farm (valeur ?).
```
