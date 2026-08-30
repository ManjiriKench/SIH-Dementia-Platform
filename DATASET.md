# 📊 Dataset Information

Our project uses **3 types of datasets**. Each dataset has a different purpose.

* **Type A – ADNI:** Dementia and Alzheimer's research data
* **Type B – LASI / LASI-DAD:** Indian dementia and ageing research data
* **Type C – Game Performance Dataset:** Gameplay data that we will use for our ML model

---

# Type A — Dementia Research Dataset

## ADNI

### What is ADNI?

**ADNI (Alzheimer's Disease Neuroimaging Initiative)** is a research dataset related to **Alzheimer's disease and cognitive decline**.

It contains information collected from people participating in Alzheimer's research.

### What does it contain?

* Clinical information
* Cognitive test results
* Brain imaging data
* Biomarker information
* Genetic/genomic information

### Why are we using it?

We can use ADNI to understand:

* How dementia and cognitive decline are studied
* What factors are related to cognitive performance
* Which cognitive features may be useful for our project

ADNI is mainly useful for **research and understanding dementia**, not directly for our game-performance model.

### Access

ADNI data requires researchers to follow its data-use rules and apply for access.

**Research Link:**
https://support.adni4.org/hc/en-us/articles/31090030057236-I-am-a-researcher-how-do-I-access-ADNI-research-data-or-samples

---

# Type B — Indian Dementia Research Dataset

## LASI / LASI-DAD

### What is LASI?

**LASI (Longitudinal Ageing Study in India)** is a large study about **ageing and health in the Indian population**.

**LASI-DAD** is the dementia-related part of this research and focuses more on **cognitive health and dementia**.

### What does it contain?

* Demographic information
* Cognitive test results
* Neuropsychological tests
* Interviews with participants/informants
* Health-related information
* Ageing-related information

### Why is it important for our project?

This dataset is especially useful because it focuses on the **Indian population**.

It can help us understand:

* Cognitive ageing in India
* Dementia-related patterns in Indian people
* Important demographic and cognitive factors
* How we can make our project more relevant to the Indian population

### Research Link

https://pubmed.ncbi.nlm.nih.gov/36637034/

---

# Type C — Game Performance Dataset

## Synthetic Cognitive Game Dataset

### What is this dataset?

This is the **main dataset for our ML model**.

Our project needs data showing **how a person performs while playing cognitive games**.

For example:

* How accurately did they play?
* How much time did they take?
* How many hints did they use?
* What was their previous score?
* Should the next game be easier or harder?

Currently, we may not find a public dataset with all these exact game-related features.

Therefore, we will initially create **synthetic data**.

### What does Synthetic Data mean?

Synthetic data means **artificially generated data** that is designed to look like real data.

It does **not** represent real patients or real users.

We can generate around:

**10,000–50,000 game sessions**

---

## 📋 Features in Our Dataset

| Feature           | Simple Meaning                           |
| ----------------- | ---------------------------------------- |
| `age`             | Age of the user                          |
| `game`            | Type of game played                      |
| `level`           | Current game difficulty                  |
| `accuracy`        | How many answers/tasks were correct      |
| `time`            | Time taken to complete the game          |
| `hints`           | Number of hints used                     |
| `previous_score`  | Score from the previous session          |
| `next_difficulty` | Difficulty recommended for the next game |

---

## Example

| Age | Game    | Level | Accuracy | Time | Hints | Previous Score | Next Difficulty |
| --: | ------- | ----: | -------: | ---: | ----: | -------------: | --------------: |
|  71 | Memory  |     2 |      91% |  32s |     0 |             85 |               3 |
|  76 | Memory  |     4 |      48% |  94s |     3 |             65 |               3 |
|  69 | Pattern |     3 |      82% |  40s |     1 |             78 |               3 |

### Example 1

A user has:

* **91% accuracy**
* **32 seconds**
* **0 hints**
* **85 previous score**

This indicates good performance, so the system may recommend a **higher difficulty**.

### Example 2

A user has:

* **48% accuracy**
* **94 seconds**
* **3 hints**
* **65 previous score**

This indicates lower performance, so the system may recommend **maintaining or reducing the difficulty**.

---

# 🧠 What Patterns Will We Create?

While generating synthetic data, we will try to create realistic user behaviour.

### 1. High Performance

User performs well:

**Accuracy ↑ | Time ↓ | Hints ↓ | Score ↑**

The system can increase the difficulty.

### 2. Medium Performance

User performs normally:

**Average Accuracy | Average Time | Some Hints**

The system can keep a similar difficulty.

### 3. Low Performance

User is struggling:

**Accuracy ↓ | Time ↑ | Hints ↑ | Score ↓**

The system can reduce or maintain the difficulty.

---

# 📈 Performance Over Multiple Sessions

We also need to show how performance changes over time.

### Improvement

A user may get better after playing regularly:

**Accuracy ↑ → Time ↓ → Score ↑ → Difficulty ↑**

### Fatigue

A user may become tired after playing for a long time:

**Accuracy ↓ → Time ↑ → Hints ↑**

### Decline

The dataset can also contain a gradual decline pattern:

**Accuracy ↓ → Time ↑ → Score ↓**

This will help us test whether our ML model can identify changes in performance.

---

# 🤖 How Will We Use This Dataset?

The Game Performance Dataset will be used for our ML model.

The basic flow will be:

```text
User plays game
       ↓
Game data is collected
       ↓
Accuracy + Time + Hints + Score
       ↓
ML Model
       ↓
Analyse performance
       ↓
Recommend next difficulty
```

The model can eventually help us provide **personalized game difficulty** based on the user's previous performance.

---

# 🔄 Future Plan

For now:

**Synthetic Data → ML Model Development → Testing**

Later:

**Real Users → Real Gameplay Data → Model Validation → Model Improvement**

Once we start getting real gameplay data from pilot users, we can use it to check whether our synthetic-data-based model actually works in real situations.

---

# 📌 Quick Summary

| Dataset                      | What is it?                              | Why do we need it?                        |
| ---------------------------- | ---------------------------------------- | ----------------------------------------- |
| **ADNI**                     | Alzheimer's/dementia research data       | Understand dementia and cognitive decline |
| **LASI / LASI-DAD**          | Indian ageing and dementia research data | Understand the Indian population context  |
| **Game Performance Dataset** | Artificial gameplay data                 | Train and test our ML model               |

### In Simple Words

**ADNI + LASI/LASI-DAD → Help us understand the dementia/cognitive research side.**

**Synthetic Game Data → Helps us build and test our ML model.**

**Real Game Data in the future → Helps us validate and improve the final system.**
