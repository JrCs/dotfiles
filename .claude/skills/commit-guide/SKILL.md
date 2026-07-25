---
name: commit-guide
description: Conventions et procédure de création de commits pour ce dépôt (conventional-commit en français, forme nominale, granularité, technique non interactive revert-and-replay, changements cassants). À consulter AVANT de créer un commit.
---

# Guide de commit

Format **conventional-commit**. Le **sujet et le corps sont rédigés en français** ; seul `type` reste technique.

Ce guide s'applique au dépôt **dotfiles** (`bash/`, `bin/`, `vim/`, scripts `install`/`upgrade`,
modules embarqués — dont `tmux/`). L'objectif est de garder un historique lisible et actionnable sur des
changements de configuration et d'outillage shell.

## Format

```
<type>: <résumé nominal>

[corps optionnel]
[footer optionnel]
```

## Sujet (première ligne)

- **type** — nature du changement. Liste **fermée** (n'utiliser que ces types) :
  `feat` (fonctionnalité), `fix` (correction de bug), `refactor` (refonte sans changement de comportement), `docs`, `test`, `chore` (maintenance), `ci`, `build`, `perf`, `style`.
- **résumé** — formulation **nominale** (`ajout`, `simplification`, `réorganisation`, `correction`, `suppression`…), **jamais un verbe conjugué ni un infinitif** (`ajouter…` est proscrit), sans majuscule initiale ni point final.
- **≤ 72 caractères au total**, préfixe `type:` compris.

## Corps & footer

- **Recommandé** dès qu'un changement n'est pas trivial — _trivial_ = mécanique, sans décision de conception (typo, formatage, renommage local) ; facultatif sinon. Séparé du sujet par une ligne vide.
- **Paragraphe** — le _pourquoi_ : le problème ou la limite qui existait avant ce changement, formulé de façon **générale et intemporelle**. C'est le cœur du corps, toujours présent — sauf si le sujet seul est déjà assez explicite pour s'en passer.
- **Puces** (`- `) — le _quoi_ : **facultatives**, elles détaillent les modifications **importantes** lorsqu'il y en a plusieurs à énumérer, au **même format nominal** que le sujet. Une puce peut s'étendre sur **plusieurs lignes** : les lignes de continuation sont indentées pour s'aligner sous le texte de la puce, et chacune respecte la limite de longueur ci-dessous.
- Limiter les lignes du corps à 100 caractères maximum.
- **Pas de constat de diagnostic** : ne pas relater l'investigation qui a mené au changement
  (ex. « Vu en live pendant un `./upgrade` : sur ma machine le prompt cassait après source »).
  Ni le nom d'une machine précise, ni la séquence d'observation (commandes lancées,
  sorties obtenues, chronologie) n'ont leur place dans le corps — décrire uniquement
  le problème général et sa cause, pas la manière dont il a été découvert.
- **Changement cassant** : suffixer le type d'un `!` (`feat(bash)!: …`) et ajouter un footer `BREAKING CHANGE: <description>`.
- **Références d'issue** : en footer, p. ex. `Closes #123`, `Fixes #123`, `Refs #123`.

## Granularité des commits

- **Un commit porte sur un seul changement non trivial**, jamais « par fichier ».
  Regrouper par changement logique, sans se soucier du nombre de fichiers touchés :
  un même changement peut en impliquer plusieurs.
- Les modifications triviales (typo, formatage, renommage local) ne font pas l'objet
  d'un commit dédié : les embarquer dans un commit non trivial connexe (à défaut,
  un commit dédié les regroupant).
- Si un même fichier mélange **plusieurs changements distincts**, les committer
  séparément avec la technique **revert-and-replay** (équivalent non interactif de
  `git add -p`) :
  1. Sauvegarder l'état final **hors du dépôt**, dans un répertoire temporaire
     (`/tmp` ci-dessous à titre d'exemple — utiliser le répertoire temporaire
     disponible dans l'environnement) : `cp bash/aliases /tmp/aliases.final`.
  2. Revenir à HEAD : `git checkout HEAD -- bash/aliases`. **Cas du fichier
     nouveau** (absent de HEAD) : cette commande échoue — le supprimer à la place
     (`rm bash/aliases`), il sera reconstruit hunk par hunk à l'étape 4.
  3. Identifier chaque _hunk_ et son type (hunk A = feat, hunk B = chore…).
  4. Pour chaque hunk, dans l'ordre logique (indépendants d'abord — imports,
     constantes — puis dépendants) : **éditer le fichier pour n'introduire que ce
     hunk** (les précédents restent en place), puis committer. Ex. :
     ```bash
     printf '%s\n' "feat(bash): ajout d'un alias git de diagnostic" > /tmp/commit-msg
     git add bash/aliases
     git commit -F /tmp/commit-msg
     ```
  5. **Vérification obligatoire** (ne jamais la sauter) : l'état final doit être
     identique à la sauvegarde, puis nettoyer :
     ```bash
     diff bash/aliases /tmp/aliases.final   # doit être vide
     rm /tmp/aliases.final
     ```

## Spécificités de ce dépôt

- **Commits orientés usage** : regrouper les changements par comportement utilisateur
  (ex. prompt shell, alias git, bootstrap, ergonomie tmux) et non par arborescence.
- **Modules embarqués** (`ack/`, `autojump/`, `tmux/`, `git-extras/`, `todo.txt-cli/`...)
  : éviter les commits de masse non intentionnels. Ne modifier ces répertoires que si
  la mise à jour est explicite, documentée et testée. `tmux/` est le framework
  [gpakosz/.tmux](https://github.com/gpakosz/.tmux) — la personnalisation locale se fait
  dans `tmux.conf.local` (racine), pas dans `tmux/` ; `tmux.conf` n'est qu'un lien
  symbolique vers `tmux/.tmux.conf`.
- **Mise à jour de sous-module** (bump de pointeur, ex. `chore(autojump): mise à jour vers v22.5.3`)
  : commit dédié, sans mélanger ce bump avec une modification de configuration locale
  (ex. `tmux.conf.local`) dans le même commit.
- **Scripts exécutables** (`bin/`, `install`) : conserver les permissions d'exécution et
  mentionner dans le corps l'impact Linux/macOS si pertinent. `upgrade` est un lien
  symbolique vers `install` : les changements de comportement se font dans `install`.
- **Fichiers de config sensibles** (`bashrc`, `vimrc`, `tmux.conf.local`, `gitconfig*`)
  : privilégier de petits commits thématiques pour faciliter le rollback ciblé.
- **Cross-plateforme** : quand un changement est spécifique à macOS/Linux, l'indiquer
  explicitement dans le corps du commit.
- **Scopes indicatifs** (liste **ouverte**, contrairement à `type`) : `bash`, `bash/config`,
  `bin`, `vim`, `tmux`, `git`, `install`, ou le nom d'un module embarqué.

## Règles

- **Rédaction du message** : les messages français contiennent souvent apostrophes et accents,
  qui cassent l'inline bash (`git commit -m "$(cat <<'EOF' …)"` → « unexpected EOF » fallacieux).
  Toujours écrire le message dans un fichier temporaire (`printf`, outil Write…) puis committer
  avec `git commit -F <fichier>`. Ne jamais supprimer les apostrophes/accents pour contourner.
- Pas de signature `Co-Authored-By` dans les commits.
- Ne committer/pusher que lorsque l'utilisateur le demande.

## Exemples

Sujets seuls :

```
feat(bash): ajout d'alias git de diagnostic
fix(tmux): correction de la détection de la session active
refactor(vim): réorganisation des mappings par section
docs: clarification des règles de commit
chore(bin)!: suppression d'un script obsolète
```

Commit complet avec corps :

```
refactor(bash): réorganisation du chargement des aliases

Le chargement des aliases mélangeait déclaration et conditions de plateforme,
ce qui compliquait l'évolution et introduisait des divergences discrètes.

- extraction des aliases communs dans bash/aliases
- regroupement des branches conditionnelles dans bash/config.darwin
- suppression des redéfinitions dupliquées
```
