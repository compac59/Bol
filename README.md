# MyBody:RPG 💪🎮

Application Android (Flutter) de **musculation avec progression RPG** façon
Solo Leveling : chaque entraînement fait gagner de l'XP, monter de niveau,
augmenter ses stats et grimper dans les rangs (E → S).

> **État actuel :** toute la **logique de jeu** est codée et testée (en Dart pur,
> dans `engine/`). L'**application visuelle** (écrans Flutter) reste à construire
> sur un ordinateur.

## 📁 Structure du projet

```
docs/        Conception (à lire en premier)
  PRD.md                  Vision complète + toutes les mécaniques (§3.x)
  baremes-force.md        Barèmes du test de force / rangs
  bibliotheque-exercices.md  Liste des exercices
  seances.md              Méthode du générateur de séances (+ sources)

engine/      Le « cerveau » du jeu (Dart pur, 100% testé, sans UI)
  lib/       Les modules de logique
  test/      Les tests (77, tous verts)
  example/demo.dart   Démo qui montre tout le moteur en action
```

## 🧠 Modules du moteur (engine/lib)

| Fichier | Rôle |
|---|---|
| `assessment.dart` | Test initial : maxs → rang, niveau fin, stats |
| `baremes.dart` | Barèmes de force + score continu |
| `rank.dart` / `level_rank.dart` | Rangs E→S et correspondance niveau↔rang |
| `xp.dart` | XP d'une séance + courbe de niveaux |
| `progression.dart` | Double progression (+1 rep puis +poids) |
| `decay.dart` | Perte d'XP par inactivité (douce, plafonnée) |
| `catalog.dart` | 49 exercices + ~20 équipements + médias |
| `sessions.dart` | Génération de programmes (split, séries, repos) |
| `quests.dart` | 3 défis quotidiens selon le rang |
| `streak.dart` | Jours d'affilée + jokers de gel |
| `promotion.dart` | Examen de promotion du chasseur |
| `workout_session.dart` | Suivi de séance (validation + repos + bilan) |

## ▶️ Lancer les tests / la démo (sur un ordinateur)

1. Installer le SDK Dart (ou Flutter, qui l'inclut) : https://dart.dev/get-dart
2. Dans le dossier `engine/` :
   ```bash
   dart pub get
   dart test            # lance les 77 tests
   dart run example/demo.dart   # affiche le moteur en action
   ```

## 🚀 Prochaine étape : l'application Flutter

Quand tu es sur un ordinateur :

1. **Installer Flutter** : https://docs.flutter.dev/get-started/install
   (inclut Dart ; vérifier avec `flutter doctor`).
2. Créer l'app Flutter et **réutiliser le moteur `engine/`** (la logique est
   déjà prête et testée — il « suffit » de brancher les écrans dessus).
3. Construire les écrans (cf. PRD §5) : onboarding + équipement + test initial,
   accueil/personnage, séance (validation + minuteur), défis, profil.
4. Visuel volontairement **simple au début** (icônes/barres), on peaufinera.

## 🎯 Idées restantes (backlog)

- Relier les exercices aux stats pendant le jeu (curls → Force, etc.).
- Succès / titres, défi de boss mensuel.
- Recharge mensuelle des jokers de streak.
- Barème femmes (coefficient), illustrations/vidéos intégrées.
- Sauvegarde locale (base de données) puis synchro cloud.
