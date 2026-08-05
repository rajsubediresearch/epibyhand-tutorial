# epibyhand-tutorial

A hands-on tutorial for the [**epibyhand**](https://cran.r-project.org/package=epibyhand)
R package — classical epidemiological measures that show their work.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/rajsubediresearch/epibyhand-tutorial/blob/main/epibyhand_tutorial.ipynb)

Click the badge to run the whole thing in your browser. No installation, no
local R, nothing to configure beyond switching the Colab runtime to R.

## What's here

`epibyhand_tutorial.ipynb` — the tutorial, with cells left unrun so you get
your own results rather than reading someone else's.

It covers **every exported function in the package**.

| Part | Topic |
|---|---|
| 1 | Building a 2 x 2 table — `epi2x2()` |
| 2 | Risk ratio — `risk_ratio()` |
| 3 | Risk difference — `risk_difference()` |
| 4 | Odds ratio — `odds_ratio()` |
| 5 | Confidence levels, and one trap |
| 6 | Zero cells and continuity corrections |
| 7 | Controlling output — `verbose`, `digits` |
| 8 | Checking hand calculations — `check_work()` |
| 9 | Attributable fractions — `attributable_fraction()` |
| 10 | Stratified data — `epi_strata()`, `collapse_strata()` |
| 11 | Pooling odds ratios — `mh_odds_ratio()` |
| 12 | Pooling risk ratios — `mh_risk_ratio()` |
| 13 | Homogeneity — `homogeneity()` |
| 14 | Programmatic use — `estimate()`, `confint()`, `steps_table()` |
| 15 | Extending the package — `derivation()`, `derivation_step()` |
| 16 | A complete analysis, start to finish |

Plus a function reference table and **ten exercises** with worked answers,
covering study design and measure choice, the rare disease assumption,
distinguishing confounding from effect modification, diagnosing student errors,
handling zero cells, constructing Simpson's paradox from scratch, and writing
your own measure with the derivation API.

Answers are hidden behind collapsible sections, so the exercises work as
exercises.

## Running it

**In Colab (easiest).** Click the badge above, then
**Runtime → Change runtime type → R**. Run the first cell to install the
package.

**Locally.** Any Jupyter installation with
[IRkernel](https://irkernel.github.io/), or open the notebook in VS Code with
the R extension.

**Just reading.** GitHub renders the notebook's text and code, though you
will need to run it to see the derivations the package prints.

## For instructors

The tutorial is built around two datasets:

* A **fabricated foodborne outbreak** for the basic measures — small enough to
  hand-compute, with a common outcome so that the odds ratio and risk ratio
  diverge visibly.
* The **Whickham cohort** (Appleton, French & Vanderpump, 1996) for
  confounding, where the crude odds ratio of 0.68 reverses to 1.35 after age
  adjustment.
* A **screening test** example in Part 15, where 90% sensitivity and 90%
  specificity produce a positive predictive value of 33%.

Everything is self-contained — no data files, no dependencies beyond the
package itself, which imports only `stats`.

The material is free to adapt for teaching. If you use it in a course, an
acknowledgement is welcome but not required.

## The package

* CRAN: https://cran.r-project.org/package=epibyhand
* Source: https://github.com/rajsubediresearch/epibyhand

```r
install.packages("epibyhand")
```

## Reference

Appleton, D. R., French, J. M. and Vanderpump, M. P. J. (1996). Ignoring a
covariate: an example of Simpson's paradox. *The American Statistician*
**50**(4), 340-341.

## Licence

MIT.
