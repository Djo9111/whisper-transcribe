# 🗣️ Transcription Audio avec Whisper (Docker & Google Colab)

Ce guide explique deux méthodes fiables pour transcrire des fichiers audio (réunions, entretiens, cours, etc.) en texte :  
- **Méthode 1 :** via **Docker** (exécution locale, sans dépendances globales)  
- **Méthode 2 :** via **Google Colab** (GPU gratuit, exécution en cloud temporaire)

Les deux approches utilisent le modèle **Whisper** d’OpenAI, réputé pour sa précision et sa robustesse multilingue.

---

## 🧩 1️⃣ Pré-requis généraux

- Fichier audio (formats acceptés : `.mp3`, `.wav`, `.m4a`, `.mp4`, etc.)
- Connexion internet pour le premier téléchargement du modèle
- Environ 2 à 10 Go d’espace disque selon le modèle choisi

---

## 🐳 2️⃣ Méthode 1 — Utilisation avec Docker (exécution locale)

### 📁 Structure du projet
Crée un dossier de travail, par exemple :
```

D:\whisper-transcription\

```

Y placer :
```

whisper-transcription/
│
├── Dockerfile
├── docker-compose.yml
├── reunion.mp3              ← ton fichier audio
└── out/                     ← dossier où les résultats seront générés

````

### 🧱 Dockerfile (CPU)

```dockerfile
FROM python:3.11-slim

# Installer ffmpeg pour lire l’audio
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg git \
    && rm -rf /var/lib/apt/lists/*

# Variables pip pour éviter les erreurs de hash
ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DEFAULT_TIMEOUT=120 \
    PIP_REQUIRE_HASHES=0

RUN python -m pip install --upgrade pip setuptools wheel

# Installer PyTorch CPU + Whisper
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
RUN pip install openai-whisper

WORKDIR /app
CMD ["bash"]
````

### ⚙️ docker-compose.yml

```yaml
services:
  whisper:
    build: .
    container_name: whisper-transcriber
    working_dir: /app
    volumes:
      - .:/app
    entrypoint: ["bash","-lc"]
    command: >
      mkdir -p out &&
      whisper "reunion.mp3" --model small --language fr --output_dir out &&
      echo "✅ Transcription terminée. Fichiers dans ./out"
```

### ▶️ Exécution

```bash
docker-compose up --build --abort-on-container-exit
```

Les fichiers générés :

```
out/
├── reunion.txt   ← transcription texte
├── reunion.srt   ← sous-titres
└── reunion.vtt   ← sous-titres WebVTT
```

---

## ☁️ 3️⃣ Méthode 2 — Utilisation sur Google Colab (GPU)

### 🔗 Étapes dans le Notebook

1. Ouvrir [Google Colab](https://colab.research.google.com)
2. **Exécution → Modifier le type d’exécution → Matériel accélérateur → GPU**
3. Copier les cellules suivantes dans ton notebook :

#### 🔹 Installation

```python
!pip install -q openai-whisper
!pip install -q torch torchvision torchaudio
!apt-get install -y ffmpeg
```

#### 🔹 Importer l’audio

Dans la colonne de gauche, cliquer sur 📁 puis **Téléverser** → choisir `reunion.mp3`.

#### 🔹 Transcription

```python
import whisper

model = whisper.load_model("small")  # ou base, medium, large-v3, etc.
result = model.transcribe("/content/reunion.mp3", language="fr")

with open("transcription.txt", "w", encoding="utf-8") as f:
    f.write(result["text"])

print("✅ Transcription terminée !")
print(result["text"][:800])
```

#### 🔹 Télécharger le fichier

```python
from google.colab import files
files.download("transcription.txt")
```

---

## 🎧 4️⃣ Modèles disponibles (choix selon ressources)

| Modèle               | Taille  | Vitesse | Précision              | Recommandé pour            |
| :------------------- | :------ | :------ | :--------------------- | :------------------------- |
| `tiny`               | ~75 MB  | ⚡⚡⚡     | Faible                 | Tests rapides              |
| `base`               | ~142 MB | ⚡⚡      | Moyenne                | Audio court                |
| `small`              | ~462 MB | ⚡       | Bonne                  | Réunions simples           |
| `medium`             | ~1.4 GB | ⏳       | Très bonne             | Audio long, accents variés |
| `large` / `large-v2` | ~3 GB   | 🐢      | Excellente             | Transcription multilingue  |
| `large-v3`           | ~3.1 GB | 🐢      | 🔥 Meilleure précision | Machines GPU (Colab)       |

---

## 🔒 5️⃣ Notes de sécurité et confidentialité

### 🧱 **Docker (local)**

* Tout le traitement se fait **sur ta machine**.
* Aucun fichier n’est envoyé à OpenAI ni sur Internet.
* Parfait pour des **enregistrements confidentiels** (réunions internes, entretiens).
* Les données restent dans `./out` tant que tu ne les partages pas.

### ☁️ **Google Colab (cloud)**

* L’audio est stocké **temporairement** sur un conteneur isolé (Google VM).
* Les fichiers sont **automatiquement supprimés** à la fermeture de la session.
* Aucune donnée n’est transmise à OpenAI, tout est exécuté localement sur la VM.
* Risques faibles mais non nuls : **ne pas connecter Google Drive** si les données sont sensibles.
* Supprimer le fichier audio après usage :

  ```bash
  !rm reunion.mp3
  ```

---

## 🧠 6️⃣ Points clés à retenir

* Whisper excelle pour la **transcription multilingue** (notamment le français).
* Il **ne sépare pas les voix** ; pour la *diarization*, utiliser **WhisperX** ou **pyannote.audio**.
* Sur CPU : privilégier `small` ou `base`.
* Sur GPU : `medium`, `large`, ou `large-v3` donnent des résultats quasi professionnels.
* Les deux méthodes garantissent la **confidentialité** si les bonnes pratiques sont suivies.

---

## 🏁 7️⃣ Résumé rapide

| Plateforme | Avantages                               | Inconvénients                 | Sécurité                              |
| ---------- | --------------------------------------- | ----------------------------- | ------------------------------------- |
| 🐳 Docker  | 100 % local, aucune dépendance externe  | Plus lent sur CPU             | 🔒 Données privées                    |
| ☁️ Colab   | GPU rapide et gratuit, rien à installer | Temporaire, dépend d’Internet | 🔐 Données isolées, à supprimer après |

---

