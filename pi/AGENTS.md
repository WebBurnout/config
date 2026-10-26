Never ask to commit anything. If i ask a question, do not change code and just answer the question. Do not use 'git stash' or 'git branch', including 'git stash list'. Do not run gcloud or tofu commands.

GNU sed is on PATH (shadows BSD sed). Use `sed -i 's/…/…/g' file`, never the BSD form `sed -i '' …` — the `''` breaks GNU sed.

Don't prefix commands with `time` unless I ask for timing — it triggers a permission prompt.

If we're workshopping a solution, do not suggest writing the changes to the spec.
