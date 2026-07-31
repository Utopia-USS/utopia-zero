---
description: Start (or resume) the utopia-zero wizard — from idea to a developable app, guided end to end
argument-hint: "[kontynuuj | pro | your first words about the idea]"
allowed-tools: Skill, Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, WebFetch, WebSearch, Agent, TodoWrite
model: inherit
---

# Utopia Zero — start

Invoke the `utopia-zero` skill (Skill tool) and follow it end to end, starting with
its **session entry protocol** (read `zero/config.json` + `zero/STATE.md`, detect
language, print the stage banner, resume or begin stage 0).

Raw arguments: `$ARGUMENTS`

- The language of the arguments (or of the user's next message if empty) sets the
  conversation language.
- "kontynuuj" / "continue" → resume from STATE without re-asking anything already decided.
- "pro" / "jestem programistą" / "I'm a developer" → Pro mode (skip the tutorial).
- No `zero/config.json` in the project → the skill's **self-serve bootstrap** applies;
  offer it instead of failing.
