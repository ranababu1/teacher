# Course content audit brief

Repo: the root of this checkout (Flutter learning app). Content: assets/curriculum/<course>/*.json.
You own ONLY the JSON files named in your task. Read every one of them completely, every field, and fix problems in place.

## The owner's instructions (follow all)
1. Eliminate AI-generated writing patterns: remove generic introductions, repetitive conclusions, filler, unnecessary explanation; overused AI vocabulary, predictable transitions, formulaic headings; the same point restated in new words; excess bullets and needless sectioning. Rewrite robotic, over-polished or textbook-like prose into natural instructional language.
2. Improve teaching: clear, progressive, right level; practical real-world programming scenarios; code that shows the actual concept; explain WHY, not just what; nothing that sounds informative but teaches nothing; introduce terms naturally.
3. Technical accuracy: validate code for syntax, correctness, version compatibility; verify claims, algorithms, formulas, ML concepts, terminology. Never invent APIs, libraries, benchmarks, references or outputs. Code must be executable or explicitly labelled as pseudocode/fragment. Follow language conventions.
4. Originality: no generic explanation that could fit any topic; add practical insight, implementation detail, edge cases, common mistakes where genuinely thin; do not reuse the same example or analogy across lessons.
5. Integrity: preserve learning objectives, technical meaning, difficulty, lesson structure, quizzes, exercises, code blocks, references, metadata. Do not delete useful explanation just to shorten. Do not introduce unverified information.
Targeted corrections, not blind rewriting. FLAG questionable claims you cannot verify instead of guessing. Voice: an experienced engineer who knows how to teach. Accuracy > polish.

## House tics to cut (these are the AI-slop signature of this corpus)
It has ~16,000 " -- " asides and thousands of intensifiers. Cut where they add nothing: genuinely/genuine, actually, exactly, precisely, specifically, directly, entirely, explicitly, deliberately, simply, real/concrete/structural as intensifiers, load-bearing, honest, "worth being precise/explicit about", "this is exactly the...", "the single most...", "the whole/entire point", "not just X but Y" / "isn't X -- it's Y" contrast formulas, "it's tempting to", "silently"/"quietly" as drama, "at its core", closing sentences that restate the section, meta-commentary ("this concept is explicit that", "the concept names", "this question targets", "the misconception this tests", "as covered in this module").
Replace chained " -- " with commas, periods, colons, parentheses or a new sentence; keep the occasional one. Keep a word like "exactly" when it carries meaning ("exactly once").
Aim: at least halve tic density in the prose of explanation bodies and example explanations, where most words are, then misconception clarifications, exercise explanations, modelAnswers, MCQ explanations. Never run a blind regex over prose: each sentence must still read well. Writing your replacements through a Python script of exact old->new strings is efficient and fine. Do not replace tics with other cliches.

## Hard constraints (validator enforces many)
- Do not change: any id, type, key set, array lengths/order of concepts, exercises, assessments, examples, misconceptions, options; learningObjectives meaning; difficulty; prerequisites; estimatedMinutes; correctOptionIndex. You may merge prose within sections, but keep the number of explanation sections (you may retitle a formulaic heading).
- MCQs: only change prompt/option wording to fix an inaccuracy, ambiguity, or a genuinely bad item (the correct option's POSITION must stay). Keep the correct option from becoming the longest if it isn't already. Never mention options by letter/number/position. MCQ explanations quote wrong options as “first words…” (curly quotes, ellipsis): each such quote must remain a verbatim prefix of exactly one WRONG option. If you edit a wrong option, keep its beginning or update the quote.
- misconceptions[].fact (if present) must be a true standalone sentence. If you find it false, fix it. `description` is deliberately false.
- predictOutput expectedAnswer must match what code really prints. Debugging exercises' `code` is deliberately broken in the described way: keep the bug, but it must be the ONLY bug and solutionCode must fix it.
- Keep the files' JSON formatting style (2-space indent, key order) and newline style. Non-ASCII stays as is.
- Content may say that a fragment is incomplete via a short comment in the code ("# fragment: assumes X_train exists"). Prefer making it runnable when that takes a few lines.

## Verifying
- Local tools: Python 3.13 (numpy, scipy, sklearn, pandas available; no torch/statsmodels), Node 24, JDK 21. No Go, Postgres, Spring. Do not install anything, do not start Docker, no network calls from lesson code. Run code only in your own scratch dir, with a timeout.
- Already-run results for your course: the results file named in your task (JSON list: id, type, lang, st, out, err, exp, code). "error" may be intended (exercise about an error), a missing import in the environment, or a real defect: judge each. Compare `out` against what the lesson CLAIMS is printed (comments, explanation numbers, expectedAnswer). That is the most valuable accuracy check: do it for every item.
- For facts you are unsure of (API defaults, versions, quotas), use WebSearch/WebFetch if you have them, otherwise flag.

## Validate before finishing (must print OK)
python docs/content_audit/validate.py <your json files>
(Run from the repo root. Keep scratch work in a temp folder outside the repo.)
It also prints tic density before/after.

Do NOT run git write commands, flutter, or edit anything outside your files and your own scratch dir. Do not spawn other agents.

## Final report (short, under 350 words)
- Accuracy errors fixed (id: what was wrong -> now), most important first.
- Code defects fixed.
- Flagged for human verification (id + why). Only real doubts.
- Prose: density before/after, and which files/fields you read fully vs did not get to. Be exact: do not claim coverage you did not do.

## Added rules (from the first round)
- NO mechanical pass: never generate edits by regex/word-list substitution over prose. Write each replacement yourself after reading the sentence. Regex only for FINDING candidates.
- Target 88-100% of original words per file. Under 85% means you cut teaching content: compare with `git show eb9164f:<path>` and restore the useful parts.
- Some files may already be edited by an earlier agent (validate.py shows tics/1k below ~20). For those: diff against `git show eb9164f:<path>`, check for lost content or changed meaning, finish what is missing, do not redo good work.
- One file at a time: read fully, check accuracy, edit, validate, then open the next.
- Accuracy outranks tic counts. Only change a technical claim when you have run it, traced it, or found it in official docs; otherwise flag it and leave it.
- Examples of real errors found so far: an SQL injection payload that did not bypass login as claimed; "filtered log calls never compute arguments" (only formatting is deferred); wrong traceback line numbers; an exercise whose prompt contradicted its code; a "failing" test that passed.
