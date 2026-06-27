# Barèmes de force — Test initial (MyBody:RPG)

> Sert au **test initial** (§3.6 du PRD) : à partir du max du joueur sur quelques
> exercices, on calcule son **rang de départ** (E → S), son **niveau** et ses
> **stats**. On compare le ratio **force / poids de corps**, pas la charge brute.

- **Statut :** proposition v1 (à valider / ajuster)
- **Référence :** standards de force courants (style StrengthLevel)
- **Base :** valeurs pour **homme** (ajustement femme prévu plus bas)

> ℹ️ **Le test initial reste volontairement léger** : uniquement les gros
> exercices polyarticulaires (mesure fiable et rapide). Les exercices de bras
> et d'isolation sont gérés dans la **bibliothèque d'exercices** (voir
> `bibliotheque-exercices.md`), pour les vraies séances et la progression au
> quotidien — pas dans le test d'évaluation.

---

## 1. Principe : le ratio force/poids

Pour chaque exercice :

```
ratio = 1RM (kg) / poids_de_corps (kg)
```

- **1RM** = charge max sur **1 répétition**. Si le joueur ne la connaît pas, on
  l'estime depuis « charge × reps » avec la formule d'Epley :
  `1RM ≈ charge × (1 + reps / 30)`.
- On compare ensuite ce ratio aux paliers ci-dessous → ça donne un **rang**.

---

## 2. Barèmes par exercice (ratio × poids de corps)

> Lecture : « C = 1.00 » pour le bench veut dire « soulever **1 × ton poids de
> corps** au développé couché = rang C ».

### 💪 Développé couché (bench press)
| Rang | E | D | C | B | A | S |
|---|---|---|---|---|---|---|
| Ratio (×PC) | 0.50 | 0.75 | 1.00 | 1.25 | 1.50 | 2.00 |

### 💪 Squat
| Rang | E | D | C | B | A | S |
|---|---|---|---|---|---|---|
| Ratio (×PC) | 0.75 | 1.25 | 1.50 | 1.75 | 2.25 | 2.75 |

### 💪 Soulevé de terre (deadlift)
| Rang | E | D | C | B | A | S |
|---|---|---|---|---|---|---|
| Ratio (×PC) | 1.00 | 1.50 | 1.75 | 2.00 | 2.50 | 3.00 |

### ⚡ Développé militaire (overhead press)
| Rang | E | D | C | B | A | S |
|---|---|---|---|---|---|---|
| Ratio (×PC) | 0.35 | 0.55 | 0.70 | 0.85 | 1.10 | 1.40 |

### 🛡️ Tractions (reps max au poids du corps)
> Ici on compte des **répétitions**, pas un ratio.
| Rang | E | D | C | B | A | S |
|---|---|---|---|---|---|---|
| Reps | 1 | 5 | 8 | 12 | 16 | 20 |

---

## 3. Exemple concret (homme de 80 kg)

| Exercice | Sa perf | Ratio | Rang obtenu |
|---|---|---|---|
| Bench | 80 kg | 1.00 | **C** |
| Squat | 120 kg | 1.50 | **C** |
| Deadlift | 160 kg | 2.00 | **B** |
| Overhead | 50 kg | 0.625 | **D** (entre 0.55 et 0.70) |
| Tractions | 10 reps | — | **C** |

**Rang global** = moyenne des rangs → ici ≈ **C**.
Ce rang global fixe le **niveau de départ** et la **répartition des stats**.

---

## 4. Du rang aux stats de départ

Chaque exercice nourrit surtout **une stat** :

| Exercice | Stat principale |
|---|---|
| Bench / Overhead | 💪 Force (haut) |
| Squat / Deadlift | 💪 Force (bas) + ❤️ Vitalité |
| Tractions | 🛡️ Volonté + 🔥 Endurance |

Le rang obtenu sur chaque exercice donne une **valeur de stat de départ**
(ex. E=10, D=20, C=35, B=50, A=70, S=90, à équilibrer au code).

---

## 5. À valider / à compléter (plus tard)

- **Femmes :** appliquer un coefficient (≈ 0.65 sur le haut du corps, ≈ 0.75
  sur le bas) ou un barème dédié — à caler en v1.1.
- **Âge :** éventuel ajustement léger pour les seniors (optionnel).
- Affiner les valeurs de stats exactes par rang lors du codage du moteur.
```
