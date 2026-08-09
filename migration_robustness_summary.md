# Migration Robustness: What Was Coded and Why

Status of the selective-out-migration threat to identification, and the four
checks now implemented to address it.

**Update (9 Aug 2026):** the code has now actually been run (see §7). The
results below in §§1–6 are the design writeup from before that run; §7 covers
what the run found, a real bug it exposed (now fixed), and what the surviving
numbers say.

---

## 1. Background: why this was reopened

The paper's "Threats to identification" subsection (currently commented out in
`main.tex`, around line 259) argues that selective out-migration of older adults
is not a meaningful threat. It rests on two supports, and both had problems:

| Support | Problem found |
|---|---|
| `\citep{StecklovWintersStampiniDavis2005Demography}` | The paper reports no estimates for household members aged 65+. Our own footnote concedes this. The citation does not cover the age group the mortality result is about. |
| Appendix Tables `at:migration_rob` / `at:migration_rob_agefe` | The generating code was stranded in `codes/archive/02_mortality_06_27_26.do` when that file was split into 02/03/04. It is not in the live pipeline, so the tables cannot be regenerated. The static outputs on disk are frozen and internally inconsistent with their own notes. |

Worse, the frozen output of the simple table did **not** show the null the prose
claims. Pooled Levels: `Intensity1999 x Post = 147.996***`,
`Intensity2005 x Post = -386.425***`. The DDD table printed `0.000***` in every
single cell with blank means — not a real estimate.

---

## 2. Bugs found and fixed in the ported code

All in `codes/04_extra_robustness.do`, documented inline as `FIX 0`–`FIX 3`.

**FIX 0 — blank "Mean" rows (both tables).** `post` is coded
`{1 = 1997-2006, 2 = 1991-1996}` in this pipeline, but the archived code
summarized `if post == 0`, which never matches. `r(mean)` was always missing.
Corrected to `post == 2`.

**FIX 1 — intensity denominator (superseded once, see §3).**

**FIX 2 — per-column municipality counts.** Log and Poisson columns reused
column 1's `Nmun`. Wrong whenever `log(0)` drops zero-elderly cells that the
other columns keep. Each column now computes its own.

**FIX 3 — the `0.000***` DDD table.** Standard errors do not independently round
to exactly zero in every cell, so this was not a small-but-real estimate. Likely
mechanism: `_b[]`/`_se[]` on a coefficient name `reghdfe` did not estimate return
literal `0`; `abs(0/0)` is Stata missing (`.`); and `.` compares as `+infinity`
against the significance thresholds, so every cell silently received `***`.
Defenses added: explicit hand-built interaction variables instead of factor
syntax, `_rc`/`e(N)` guards leaving `n/a` rather than fabricated values, and 4
decimals instead of 3.

**Post-dummy bug introduced and then caught.** Replacing factor syntax with
hand-built interactions initially produced `inten1999 * post * old65`. Because
`post` is `{1,2}` and not `{0,1}`, the pre-period entered with weight 2 instead
of 0. Now builds `postd = (post == 1)` first. **Worth checking anywhere else in
the codebase that hand-builds interactions off `post`.**

---

## 3. The denominator question (§FIX 1, revised)

An earlier version of this fix put the adjustment on the **left-hand side** —
65+ population per 100 households. That was withdrawn: it is the wrong side of
the regression and is actively harmful. If Progresa induced general
out-migration, `popover65_` and `hh_tot` fall *together*, the ratio barely moves,
and the test returns a comforting null in precisely the case it exists to catch.
A denominator shared with the outcome **masks** migration rather than
controlling for it.

The contamination is on the **right-hand side**. The default treatment variable
is a snapshot of `intensity_new = pgbenef_new/hh_tot` taken at 1999/2005 — a
household count measured *after* rollout. Program-induced changes in household
counts therefore enter the regressor itself, which is circular in a regression
asking whether the program moved population.

Implemented as a switch, `$mig_intensity`, applied to **both** migration tables:

| Option | Variable | Property |
|---|---|---|
| `yearvar` *(default)* | `inten1999` / `inten2005` | Snapshot-year (post-program) denominator. The main design's own variable — keep as default for comparability with every other exhibit, but this is the contaminated one. |
| `pv_fixed` | `inten1999_fix` / `inten2005_fix` | Parker & Vogl base `hog1997_fixed = 0.3*HH1990 + 0.7*HH2000`. Fixed across snapshots, so it cannot move with the outcome year. **Caveat: interpolates through the 2000 census, already post-program — fixed, but not strictly predetermined.** |
| `pre1990` | `pgbenef_*/hh_tot1990` | 1990 census count, seven years pre-rollout. Strictly predetermined; no program-induced population change can enter the regressor. Cleanest for *this table* — not proposed for the main mortality spec. |

---

## 4. The interpolation problem (most important finding)

`01_mortality_data.do` (lines ~631–666) builds the 65+ population series by
**geometric interpolation** between census anchors 1990, 1995, 2000, 2005,
applying a constant per-municipality growth multiplier within each inter-census
segment.

Two consequences, both serious for the migration test:

1. **The break cannot exist where the DiD looks for it.** Within a segment every
   municipality grows at a constant rate *by construction*. The post-1997 break
   falls **inside** the 1995–2000 segment. So an estimated "post-1997 population
   effect" on the annual panel is not detecting anything that happened in 1997 —
   it is a re-expression of the difference between the 1995–2000 and 2000–2005
   census growth rates.

2. **N is inflated roughly 16-fold** relative to the number of genuinely observed
   population figures, so standard errors are far too small and significance is
   close to mechanical. This is the most likely explanation for the very tight,
   very significant `147.996***`.

Implemented as a second switch, `$mig_years`:

- `all` *(default)* — `inrange(year,1991,2006)`, the annual interpolated panel.
- `census` — `inlist(year,1995,2000,2005)`, years the population is actually
  *measured*. One pre-program and two post-program observations per municipality
  (1990 falls outside the panel). Thin, and with no scope for a pre-trend test,
  but honest.

**Read a disagreement between `all` and `census` as evidence that the annual
result is an interpolation artifact, not migration.**

---

## 5. New checks coded

### 5.1 Experimental 65+ attrition test — `codes/03_experimental.do`
Output: `tables/appendix/AT_attrition_elderly.tex`

Runs the age-65+ migration test Stecklov et al. did not, on the same
experimental evaluation, closing the exact gap our footnote concedes.

The panel keeps rondas 1/3/5 and drops post-1997 entrants, so it is a fixed 1997
cohort: everyone enumerated at baseline either reappears or does not. For the
baseline 65+ cohort we build `present98`/`present99` and regress on randomized
treatment, clustering at the locality (randomization) level with municipality FE
— the paper's own equation (`eq:exp_did`), minus the year interaction since the
outcome is defined once per person. Panel A: all 65+. Panel B: older-adults-only
households (direct food transfer only — strongest mechanical reason to move).

Because assignment is randomized, a null means the program did not
differentially remove older adults from treatment localities — exactly the
assumption the municipal DiD needs.

> **Caveat that must travel with this table:** roster disappearance =
> death + migration + ordinary survey attrition. ENCEL's 1997–99 rounds do not
> let us cleanly separate them here. This is a test of **differential total
> attrition**, not of migration alone. That is still the right test for the
> identification threat — any of the three channels, if differential by
> treatment, biases the mortality comparison — but it must not be written up as
> a pure migration estimate.

### 5.2 Population event study — `codes/04_extra_robustness.do`
Output: `figures/appendix/AF_migration_es.pdf`

The two tables report a single post-1997 interaction, which cannot separate "the
program moved population after 1997" from "these municipalities were already on
different population trajectories." Same construction as the mortality event
studies (reference 1996, `year_1995` index 1–16, municipality and year FE,
clustered at municipality) so they can be read side by side. Pooled/female/male.

If the apparent population effect is present **before** 1997, it is not the
program. Skipped automatically under `$mig_years == "census"` (too few years).

### 5.3 Mortality with a fixed pre-program offset — `codes/04_extra_robustness.do`
Output: `tables/appendix/AT_fixed_offset_poisson.tex`

**This is the check that makes the threat moot for the headline result rather
than merely testing it.**

Migration threatens the mortality estimate through the *denominator*:
`emr65 = death65*1000/popover65_` divides by a contemporaneous, post-program
population that migration can move. Modelling raw **death counts** with an offset
fixed at each municipality's **1996** 65+ population means no post-1997
population change can enter the estimate at all — by construction, not by
assumption.

- Column (1): contemporaneous offset (as in `AT4_functional_forms`).
- Column (2): offset fixed at 1996.

If (1) and (2) agree, migration cannot be driving the mortality null, whatever
the population tables show.

---

## 6. Current state and what to do next

**Nothing has been re-activated in the paper.** Both `tables_app.tex` entries and
the `main.tex` migration paragraph remain commented out, deliberately —
uncommenting now would restore a "no migration threat" claim that the last known
numbers do not support.

Suggested order:

1. **Run `04_extra_robustness.do` under `$mig_years = "census"`** and compare to
   `"all"`. This is the cheapest and most diagnostic single step. If the
   `147.996***` collapses, the significant result was an interpolation artifact
   and the threat largely evaporates.
2. **Run the fixed-offset Poisson (§5.3).** If columns (1) and (2) agree, the
   headline null is immune regardless of how the population tables resolve.
3. **Run the experimental attrition test (§5.1).** This is the substantive
   answer and the one a referee will find most convincing, because it is
   randomized and it is about 65+ specifically.
4. **Look at the event study (§5.2)** to classify any surviving population effect
   as pre-existing trend vs. post-1997 break.
5. Only then decide what to un-comment, and rewrite the migration paragraph to
   match what the checks actually show.

### Caveats on what has and has not been verified

- **None of this code has been executed.** There is no Stata installation or
  underlying data in the environment where it was written. It is
  syntax-reviewed and brace-balanced, not run. Expect to debug on first
  execution.
- The `FIX 3` diagnosis of the `0.000***` bug is a **hypothesis**, not a
  confirmed root cause. The defenses added are sound either way, but confirm the
  DDD table produces sensible numbers before trusting it.
- The "58%" international-migration figure and the "under age 60" domestic
  cutoff attributed to Stecklov et al. in `main.tex` **could not be
  independently verified** — no local copy of the paper, and full-text hosts are
  blocked in this environment. The qualitative claims (physical-presence
  mechanism, international-vs-domestic split, no 65+ breakdown) were corroborated
  from secondary sources. A coauthor should check those two specific figures
  against the paper before the paragraph is un-commented.

---

## 7. The first real run (9 Aug 2026) and what it changed

The code was run for the first time (Windows machine, logs in
`codes/03_experimental_log.log` and `codes/04_extra_robustness_log.log`).
Three things came out of it.

### 7.1 A real bug, now found and fixed: `capture` was missing

`AT_migration_robustness.tex` and `AT_migration_robustness_ageFE.tex` both came
back with the Levels and Log columns showing `n/a`, Poisson showing real
numbers. Reading the log line by line, the `reghdfe` calls behind the `n/a`
columns **completed successfully** — valid coefficient table, correct N,
matching the values from the original archived run (e.g. panel A pooled Levels:
`147.9964`, exactly the old `147.996***`). The "reghdfe failed" message printed
immediately after that same, valid output.

Since a genuine estimation failure with no `capture` prefix halts the whole
do-file rather than falling through to an `else` branch, the only way that
branch could ever fire was a **stale, nonzero `_rc` left over from something
that didn't actually abort** — most likely `reghdfe`'s own internal handling of
the collinear `2.post#...` term it drops and reports as a `note:` (visible in
the log). `ppmlhdfe`, hit with the same collinearity note on the same data,
did not leave this residue — its columns came back fine on every table, in
every one of these regressions, without `capture`.

Confirming evidence: the two exhibits that already used `capture reghdfe` /
`capture ppmlhdfe` — the experimental attrition test and the fixed-offset
Poisson table — came back with **real numbers on every column, first try**. The
two that used bare `reghdfe`/`ppmlhdfe` did not.

**Fix:** every `reghdfe`/`ppmlhdfe` call in both migration tables in
`04_extra_robustness.do` is now `capture`-prefixed, matching the pattern that
was already working elsewhere. Documented in-code as `FIX 4`. This has not been
re-run to confirm the fix — the reasoning is solid (it converts the ambiguous
"what is `_rc` right now" into "what did *this* command return"), but it should
be verified on the next pass rather than assumed.

**Lesson for anywhere else in this codebase using the same
`if !_rc & e(N) > 0` guard after a bare (non-`capture`) command:** the guard
cannot do its intended job in that form. Without `capture`, a true failure halts
execution before the guard is ever reached, so the guard's `else` branch can
only ever fire on a false positive. Worth checking whether this pattern was
copied anywhere else in `04_extra_robustness.do` beyond what this task touched.

### 7.2 What actually ran, once the working columns are read

With Poisson as the only trustworthy column on this run:

| Table | Panel | Intensity 1999 × Post | Intensity 2005 × Post |
|---|---|---|---|
| `AT_migration_robustness` (Levels DDD-free) | Pooled | 0.104*** | 0.023 |
| | Female | 0.114*** | 0.043 |
| | Male | 0.094*** | 0.004 |
| `AT_migration_robustness_ageFE` (DDD) | Pooled | −0.0227 (ns) | 0.1531*** |
| | Female | −0.0434* | 0.2083*** |
| | Male | −0.0026 (ns) | 0.1040*** |

Two things worth flagging, provisionally (Levels/Log for both tables are still
unverified pending a re-run with the `capture` fix, so this reading is
Poisson-only and incomplete):

- The simple table's `Intensity1999 × Post` is **positive and significant**
  across all three panels — the population *count* interpretation (0.104 in
  Poisson's `exp(β)−1` scale is a coefficient near the boundary the code's
  formatting treats specially; treat the precise magnitude as unconfirmed until
  the Levels column reruns) points the same direction as the original archived
  run's `147.996***`: more population, not less, in higher-intensity
  municipalities post-1997. That is the *opposite* of the out-migration story,
  which would need this to be negative.
- The DDD table tells a more mixed story: `Intensity1999` (the main design's
  treatment variable) is small and **not significant** in Pooled and Male, and
  only marginally significant in Female — consistent with no differential 65+
  trend once the 50–64 control band absorbs general growth. But
  `Intensity2005` is positive and significant in all three panels, which the
  design did not anticipate and needs a substantive explanation before this
  table can be cited either way.

**Bottom line: this is not yet a clean read.** One-third of the evidence
(Levels/Log) was thrown away by the `_rc` bug and needs to be regenerated. The
Poisson-only picture that's left doesn't resolve to a simple "no migration
threat" story — it's genuinely mixed, and the interpolation-artifact hypothesis
(§4 above) has not been tested at all yet, since that run used
`$mig_years = "all"` (the default), not `"census"`.

### 7.3 Attrition and fixed-offset results (these ran cleanly, both columns)

**Experimental attrition** (`AT_attrition_elderly.tex`): among all 65+
individuals at baseline (Panel A), treatment has no effect on being observed in
1998 (0.001, ns) but a **significant negative effect on being observed in
1999** (−0.044***, against a 0.898 control-group mean). Panel B
(older-adults-only households) shows the same sign but is not significant
(−0.036, ns), on a much smaller N (1,894 vs. 6,836).

This is the most important single number to come out of this run. Panel A's
result is a real, randomization-based signal that older adults in treatment
localities were less likely to remain on the roster by 1999 — precisely the
identification threat this table was built to test. Recall the caveat that
must travel with it: this combines death, migration, and ordinary survey
attrition, and cannot separate them. It does **not** by itself mean people
migrated. But it also does not support dismissing the migration threat — if
anything, on this first pass, it points the opposite way (**a real, differential
effect exists**), which cuts against un-commenting the "not a meaningful
threat" paragraph as currently worded.

**Fixed pre-program offset Poisson** (`AT_fixed_offset_poisson.tex`): columns
(1) contemporaneous and (2) fixed-1996 offset are close for every panel
(Pooled: −2.69 vs. 0.19; Female: 5.92 vs. 9.33; Male: −10.02 vs. −7.38) — none
significant, same sign pattern, no coefficient flips. This is the reassuring
result: whatever is happening with population/migration, it is **not** moving
the headline mortality null. This is the one piece of unambiguous good news
from this run.

### 7.4 Revised next steps, replacing §6 above

1. **Re-run `04_extra_robustness.do`** now that `FIX 4` is in place, to get real
   Levels/Log numbers for both migration tables instead of `n/a`.
2. **Then run under `$mig_years = "census"`** and compare — this still hasn't
   been tested at all.
3. **Take the attrition result to coauthors now, separately from the rest.**
   A significant, randomization-based differential-attrition finding for 65+ by
   1999 is a real result on its own terms, independent of whatever the
   municipal-panel tables eventually show, and changes how the "Threats to
   identification" paragraph should be written — not as "not a meaningful
   threat" but as something that needs to be addressed head-on, with the
   fixed-offset result (§7.3) as the mitigating point (the mortality headline
   survives regardless).
4. The fixed-offset result is solid as-is and can be cited with confidence.
