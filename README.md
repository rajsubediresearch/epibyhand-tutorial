# epibyhand-tutorial

A hands-on tutorial for the [**epibyhand**](https://cran.r-project.org/package=epibyhand)
R package — classical epidemiological measures that show their work.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/rajsubediresearch/epibyhand-tutorial/blob/main/epibyhand_tutorial.ipynb)

Click the badge to run the whole thing in your browser. No installation, no
local R, nothing to configure beyond switching the Colab runtime to R.

## What's here

`epibyhand_tutorial.ipynb` — a complete worked tutorial with outputs already
rendered, so you can read it on GitHub without running anything.

| Part | Topic |
|---|---|
| 1 | Building a 2 x 2 table |
| 2 | Risk ratio and risk difference |
| 3 | Odds ratio, and when it approximates the risk ratio |
| 4 | Controlling how much detail you see |
| 5 | Checking a hand calculation with `check_work()` |
| 6 | Attributable fractions |
| 7 | Confounding and stratified analysis |
| 8 | Homogeneity and effect modification |
| 9 | Building problem sets |

Followed by **eight exercises** with worked answers and explanations, covering
study design and measure choice, the rare disease assumption, distinguishing
confounding from effect modification, diagnosing student errors, and
constructing Simpson's paradox from scratch.

Answers are hidden behind collapsible sections, so the exercises work as
exercises.

## Running it

**In Colab (easiest).** Click the badge above, then
**Runtime → Change runtime type → R**. Run the first cell to install the
package.

**Locally.** Any Jupyter installation with
[IRkernel](https://irkernel.github.io/), or open the notebook in VS Code with
the R extension.

**Just reading.** GitHub renders the notebook with all outputs intact.

## For instructors

The tutorial is built around two datasets:

* A **fabricated foodborne outbreak** for the basic measures — small enough to
  hand-compute, with a common outcome so that the odds ratio and risk ratio
  diverge visibly.
* The **Whickham cohort** (Appleton, French & Vanderpump, 1996) for
  confounding, where the crude odds ratio of 0.68 reverses to 1.35 after age
  adjustment.

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
