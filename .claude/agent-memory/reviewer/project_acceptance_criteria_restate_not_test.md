---
name: spec-acceptance-criteria-restate-not-test
description: Recurring spec weakness — criteria that assert a property (e.g. "paths don't mask each other") via an observable that cannot distinguish it
metadata:
  type: project
---

A repeating pattern in this repo's specs: an acceptance criterion names a strong property but the command + observable it specifies cannot actually distinguish that property from an already-covered case. Seen on the 2026-09-10 `--fail-on-drift` spec, where criterion 7 claimed to prove two failure paths "don't mask each other" but ran the identical command as criterion 4 with the identical expected exit code — only the fixture differed, and exit status is one bit.

**Why:** Exit-code-only criteria collapse distinct causes into the same observable. Proving non-masking requires both conditions true *simultaneously* plus assertions on the distinct output lines, not two separate single-cause fixtures.

**How to apply:** When a criterion's prose claims interaction/independence/non-interference between two mechanisms, check: does the fixture actually activate both at once, and is the asserted observable rich enough to tell them apart? If not, it's a warning — the criterion is not wrong, it just tests something weaker than its label. Suggest splitting into an honest narrow criterion plus a real combined-fixture one. Also check the code for whether the combined state is even reachable (in `syncRoster()` a missing file `continue`s before the divergence check, so one file can never be both — the fixture needs two files).

Related: [[bootstrap-quiet-flag-silences-checks]]
