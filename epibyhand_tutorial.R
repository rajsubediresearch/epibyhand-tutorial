# =============================================================================
#
#   epibyhand: the complete tutorial
#   Classical epidemiological measures that show their work
#
#   https://cran.r-project.org/package=epibyhand
#   https://github.com/rajsubediresearch/epibyhand
#
#   HOW TO USE THIS SCRIPT
#   Run it one line at a time with Ctrl+Enter (Cmd+Enter on a Mac) and read
#   the output as you go. The output IS the lesson -- every function prints
#   the reasoning that produced its answer, not just the answer.
#
#   Press Ctrl+Shift+O to open the document outline and jump between sections.
#
# =============================================================================


# Setup -----------------------------------------------------------------------

# This tutorial needs epibyhand 0.2.0 or later.
# install.packages() alone will not upgrade a version you already have, so
# check first.

needed <- "0.2.0"

if (!requireNamespace("epibyhand", quietly = TRUE) ||
    packageVersion("epibyhand") < needed) {
  install.packages("epibyhand")
}

# If CRAN has not propagated the newest version to your mirror yet, fall back
# to the development version on GitHub.
if (packageVersion("epibyhand") < needed) {
  if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
  remotes::install_github("rajsubediresearch/epibyhand")
}

library(epibyhand)
packageVersion("epibyhand")

# Everything the package exports. Sixteen functions; this script uses all of
# them.
sort(getNamespaceExports("epibyhand"))


# 1. The 2 x 2 table ----------------------------------------------------------

# Everything starts here. epi2x2() takes the four cell counts in the standard
# epidemiological orientation used by Rothman and Greenland:
#
#                  Case    Non-case
#     Exposed        a         b
#     Unexposed      c         d
#
# So the argument order is a, b, c, d -- across the top row, then across the
# bottom row.
#
# OUR FIRST DATASET
# A church picnic is followed by an outbreak of gastroenteritis. All 120
# attendees are interviewed and asked whether they ate the potato salad.
#   - Of the 70 who ATE the potato salad, 54 became ill.
#   - Of the 50 who did NOT, 8 became ill.

picnic <- epi2x2(54, 16, 8, 42,
                 exposure = c("Ate potato salad", "Did not eat"),
                 outcome  = c("Ill", "Well"))
picnic

# The exposure and outcome arguments only change the labels -- they do not
# change any arithmetic. But labelling the table honestly is worth the extra
# few characters, because it is what stops you from reading the output of a
# case-control study as though it were a cohort.

# INPUT FROM A MATRIX
# If your data already live in a matrix or a table, pass it directly. Note
# byrow = TRUE -- the natural reading order matches a, b, c, d.

m <- matrix(c(54, 16,
              8, 42), nrow = 2, byrow = TRUE)
epi2x2(m)

# If the matrix carries dimnames, the labels are picked up automatically.

m2 <- matrix(c(54, 16, 8, 42), nrow = 2, byrow = TRUE,
             dimnames = list(c("Ate potato salad", "Did not eat"),
                             c("Ill", "Well")))
epi2x2(m2)

# WHAT THE OBJECT ACTUALLY IS
# No S4, no reference classes -- a plain list with a class attribute. Reach
# into it whenever that is more convenient than a function call.

str(unclass(picnic))
picnic$a
picnic$a + picnic$b            # total exposed

# INPUT VALIDATION
# The constructor refuses malformed input rather than producing a wrong answer
# quietly.

try(epi2x2(54, 16, 8))                      # only three counts
try(epi2x2(matrix(1:6, nrow = 2)))          # not 2 x 2
try(epi2x2(-5, 16, 8, 42))                  # negative count

# A NOTE ON ORIENTATION
# Getting a, b, c, d in the wrong order is the single most common source of a
# wrong answer in this whole tutorial. If your odds ratio comes out as the
# reciprocal of what you expected, you have almost certainly swapped the rows
# or the columns. Nothing in the software can catch this for you -- the table
# is valid either way.


# 2. Risk ratio ---------------------------------------------------------------

# This is a COHORT: we followed a defined group forward and counted who fell
# ill. Risk is therefore estimable -- cases divided by people at risk -- and
# the risk ratio is available to us.

risk_ratio(picnic)

# Read the derivation top to bottom and notice what it is doing.
#
# Steps 1 and 2 compute the two risks separately before dividing them. This
# matters pedagogically: a student who computes 54/70 = 0.7714 and stops has
# done step 1 correctly. Telling them "wrong, the answer is 4.82" hides that
# from both of you.
#
# Step 3 is the ratio.
#
# Steps 4-6 build the confidence interval on the LOG scale and then
# exponentiate. That is why the interval is not symmetric around the estimate:
# 4.82 sits closer to 2.52 than to 9.22 arithmetically, but exactly in the
# middle on the log scale. Ratios are multiplicative, and their sampling
# distribution is far closer to normal after a log transform.


# 3. Risk difference ----------------------------------------------------------

risk_difference(picnic)

# The risk difference is 0.61 -- 61 additional cases per 100 people exposed.
#
# The output also reports the NUMBER NEEDED TO EXPOSE, the reciprocal of the
# risk difference. Here roughly 2 people had to eat the potato salad to
# produce one extra case. (In a treatment context the same arithmetic gives
# the number needed to treat.)
#
# RATIOS AND DIFFERENCES ANSWER DIFFERENT QUESTIONS
#   - Risk ratio (4.82): how many TIMES more likely are the exposed to fall
#     ill? A question about strength of association, relevant to causation.
#   - Risk difference (0.61): how many EXTRA CASES does the exposure produce?
#     A question about impact, relevant to deciding where to spend money.
#
# A rare exposure can have a huge risk ratio and a negligible risk difference.
# Neither number is more correct; the confusion between them is behind a great
# deal of bad science communication.
#
# Unlike the ratio measures, the risk difference interval is symmetric -- it is
# built on the natural scale, because a difference is already additive.


# 4. Odds ratio ---------------------------------------------------------------

# Odds are not risks. The ODDS of an event are the number of times it happens
# divided by the number of times it does not -- a/b, not a/(a+b).

odds_ratio(picnic)

# The odds ratio is 17.72, while the risk ratio for the very same table was
# 4.82.
#
# That is not an error. THE ODDS RATIO IS ALWAYS FURTHER FROM 1 THAN THE RISK
# RATIO, and the gap widens as the outcome becomes more common. Here 77% of
# the exposed fell ill -- an extremely common outcome -- so the two diverge
# dramatically.
#
# Notice the package said so itself, unprompted, in the note beneath the
# result. Because the data are tabulated as a cohort it knows risk is
# estimable, so it reports what the risk ratio would be rather than letting
# you walk off with the odds ratio unexamined.
#
# WHY USE THE ODDS RATIO AT ALL?
# Because it has a property no other measure has: it is ESTIMABLE FROM A
# CASE-CONTROL STUDY. When you sample on the outcome -- deliberately
# recruiting cases and controls in whatever ratio is convenient -- you destroy
# your ability to estimate risk. But the odds ratio is unchanged whether you
# condition on exposure or on outcome, which is what the note in step 3 means
# by OR = ad/bc.

# THE RARE DISEASE ASSUMPTION, DEMONSTRATED
# Fix the risk ratio at exactly 2.0 and vary only how common the outcome is.

options(epibyhand.verbose = 0)   # results only, no derivations

for (R0 in c(0.001, 0.01, 0.05, 0.10, 0.20, 0.40)) {
  n <- 100000
  c_cell <- R0 * n;      d_cell <- n - c_cell
  a_cell <- 2 * R0 * n;  b_cell <- n - a_cell
  tab <- epi2x2(a_cell, b_cell, c_cell, d_cell)
  cat(sprintf("baseline risk %5.3f   RR = %.3f   OR = %.4f\n",
              R0, estimate(risk_ratio(tab)), estimate(odds_ratio(tab))))
}

options(epibyhand.verbose = 2)

# The risk ratio is pinned at 2.000 in every row. The odds ratio drifts from
# 2.002 to 6.000.
#
# This is the rare disease assumption made concrete. When the outcome is rare
# (under roughly 5-10%), the odds ratio approximates the risk ratio, which is
# why case-control studies of rare diseases can report an OR and have
# epidemiologists read it as a risk ratio. When the outcome is common,
# treating an odds ratio as though it were a risk ratio BADLY OVERSTATES THE
# EFFECT -- and this happens constantly in published abstracts.


# 5. Confidence levels, and one trap ------------------------------------------

# Every measure takes a conf_level argument.

options(epibyhand.verbose = 0)

estimate(odds_ratio(picnic))
confint(odds_ratio(picnic))                      # default 95%
confint(odds_ratio(picnic, conf_level = 0.99))   # 99%
confint(odds_ratio(picnic, conf_level = 0.90))   # 90%

# THE TRAP
# confint() on an epibyhand object CANNOT HONOUR a level argument. The level is
# fixed when the derivation is built, not when you extract from it. Since
# version 0.2.0 it warns rather than quietly handing back the wrong interval.

d <- odds_ratio(picnic)                # built at 95%

confint(d, level = 0.99)               # LOOKS like 99% -- it is not
confint(d)                             # identical
confint(odds_ratio(picnic, conf_level = 0.99))   # this is the 99% interval

# confint(d, level = 0.99) warns and returns the 95% interval, because the
# interval was already computed and stored when odds_ratio() ran. The warning
# names the fix.
#
# Before 0.2.0 it returned the wrong interval silently -- which is exactly the
# failure mode this package exists to prevent, so it was fixed as a
# correctness bug rather than documented as a quirk.
#
# This is a consequence of the package's design -- the whole point is that the
# derivation shows the arithmetic that produced THAT interval, so an extractor
# cannot silently produce a different one. But it is a real trap, because
# confint() on a model object in base R does honour level.
#
# RULE: set the level where the measure is computed, never where it is
# extracted.


# 6. Zero cells ---------------------------------------------------------------

# A zero cell makes a ratio and its standard error undefined. Many packages
# silently add 0.5 to every cell and hand you a number. epibyhand does not.

options(epibyhand.verbose = 0)
odds_ratio(epi2x2(10, 0, 5, 20))

# You get Inf, a NaN limit, and an explanation of what a continuity correction
# would do and why you might not want it.
#
# This is deliberate. The Haldane-Anscombe correction -- adding 0.5 to every
# cell -- is a defensible choice, but it BIASES THE ESTIMATE TOWARD THE NULL
# and makes the confidence interval approximate. That is a decision the
# analyst should make and report, not something software should do behind
# their back.
#
# If you want the correction, apply it explicitly so that it appears in your
# code and therefore in your methods section.

corrected <- epi2x2(10 + 0.5, 0 + 0.5, 5 + 0.5, 20 + 0.5)
odds_ratio(corrected)

# The estimate is now finite (26.6) with a usable interval -- but it is a
# number you chose to create. The uncorrected answer was Inf, and Inf is the
# honest description of a table where nobody in the exposed group avoided the
# outcome.


# 7. Controlling the output ---------------------------------------------------

# Two global options control everything the print method does.

options(epibyhand.verbose = 0)   # the answer alone
odds_ratio(picnic)

options(epibyhand.verbose = 1)   # add the symbolic formulas, drop the numbers
odds_ratio(picnic)

options(epibyhand.verbose = 2)   # full worked solution (the default)
options(epibyhand.digits  = 3)   # and round to 3 significant digits
odds_ratio(picnic)

# You can also override per call, without touching the global setting --
# useful inside a script or a report where the default should stay put.

options(epibyhand.digits = 4)                     # restore the default
print(odds_ratio(picnic), verbose = 1, digits = 2)

# A natural teaching pattern: verbose = 2 when introducing a measure for the
# first time, verbose = 1 when the class already knows the formula and you are
# reminding them, verbose = 0 once you are just doing analysis.


# 8. check_work() -------------------------------------------------------------

# This is the feature no other package has. Give it a value and it compares
# against the final answer. When that does not match, it searches EVERY
# INTERMEDIATE STEP for one that does.

options(epibyhand.verbose = 2)
d <- odds_ratio(picnic)

check_work(d, 17.72)

check_work(d, 3.375)

# That second student did not fail. They computed the odds among the exposed
# (54/16 = 3.375) and stopped -- a completely different problem from an
# arithmetic slip, needing a different sentence from the person teaching them.
#
# Compare a genuine arithmetic error:

check_work(d, 9.99)

# No intermediate step matches, so the tool says so and tells you to compare
# the derivation line by line.

# TARGETING A SPECIFIC STEP
# By symbol:

check_work(d, 0.1905, step = "odds0")    # odds among the unexposed: 8/42

# ...or by number:

check_work(d, 3.375, step = 1)

# Ask for a step that does not exist and it tells you what is available:

try(check_work(d, 1.0, step = "RR"))

# TOLERANCE
# The default tolerance is relative and loose enough to accept a value rounded
# to two decimal places. Tighten it when you want to insist on precision.

check_work(d, 17.7, tol = 0.005)     # accepted at the default tolerance
check_work(d, 17.7, tol = 0.0001)    # rejected when you demand more precision

# THE RETURN VALUE
# check_work() prints for humans but also returns TRUE/FALSE invisibly, so you
# can build a grading script on top of it.

result <- check_work(d, 17.72)
result

submissions <- c(17.72, 3.375, 9.99, 17.7188)
vapply(submissions, function(v) {
  invisible(capture.output(ok <- check_work(d, v)))
  ok
}, logical(1))


# 9. Attributable fractions ---------------------------------------------------

# An attributable fraction asks: what proportion of disease would disappear if
# we removed the exposure? There are two versions and confusing them is a
# classic exam mistake.

attributable_fraction(picnic, among = "exposed")

# AFe = 0.79. Among people who ate the potato salad, 79% of their illness is
# attributable to it. The remaining 21% is background -- they would have been
# ill anyway.
#
# Note the second step: the same quantity comes out of (RR - 1)/RR using only
# the risk ratio. That is why AFe can be computed from a case-control study,
# where absolute risks are unavailable but the ratio is estimable.

attributable_fraction(picnic, among = "population")

# PAF = 0.69, lower than the AFe of 0.79.
#
# Why? Only 58% of attendees ate the potato salad. The unexposed 42%
# contribute cases to the denominator but have nothing attributable to remove,
# which dilutes the fraction.
#
# THE THREE FORMULAS
# The derivation computes the PAF three ways -- directly from risks, by
# Levin's formula from exposure prevalence, and by Miettinen's formula from
# the proportion of cases exposed -- and they agree to the last digit.
#
# Textbooks present these as alternatives to choose between. They are not.
# They are ONE QUANTITY WRITTEN THREE WAYS, and which you use depends only on
# which inputs you happen to have:
#   - Direct:    you have the full table.
#   - Levin:     you have a risk ratio from one study and exposure prevalence
#                from another.
#   - Miettinen: you have a case-control study and know what fraction of cases
#                were exposed.

# PROTECTIVE EXPOSURES GIVE NEGATIVE FRACTIONS

options(epibyhand.verbose = 0)
protective <- epi2x2(10, 40, 30, 20)     # exposure looks protective

estimate(risk_ratio(protective))
estimate(attributable_fraction(protective, among = "exposed"))

# A negative attributable fraction is not an error. The package does NOT
# silently switch to reporting a PREVENTED fraction, which is a different
# quantity with a different formula -- that kind of quiet reinterpretation is
# exactly what this package exists to avoid. If you want the prevented
# fraction, compute it deliberately: PFe = 1 - RR.
#
# THE WARNING THAT MATTERS
# PAF depends on how common the exposure is, so IT DOES NOT TRANSFER BETWEEN
# POPULATIONS the way a risk ratio does. A strong risk factor that is rare has
# a small PAF; a weak one that is universal can have a large one. Quoting a
# PAF from one country's study as though it applied to another is a real and
# common error.


# 10. Stratified data ---------------------------------------------------------

# THE WHICKHAM DATA
# In 1972-74 a survey in Whickham, England recorded whether each participant
# smoked. Twenty years later the survivors were identified. What follows is
# the 1314 women in that cohort -- the standard illustration of Simpson's
# paradox (Appleton, French and Vanderpump, 1996, The American Statistician
# 50, 340-341).
#
# Start where a student would: smoking and death, ignoring everything else.

whickham_crude <- epi2x2(139, 443, 230, 502,
                         exposure = c("Smoker", "Non-smoker"),
                         outcome  = c("Dead", "Alive"))

options(epibyhand.verbose = 1)
odds_ratio(whickham_crude)
risk_ratio(whickham_crude)

# THE ODDS RATIO IS 0.68 AND THE CONFIDENCE INTERVAL EXCLUDES 1.
#
# Read naively: smoking is protective, and significantly so. The risk ratio
# agrees. A report written at this point would be internally consistent,
# statistically significant, and FALSE.

# BUILDING STRATIFIED DATA
# epi_strata() accepts four different input shapes. All produce the same
# object -- use whichever matches how your data already look.

# 1. Four counts per stratum, as separate arguments
whickham <- epi_strata(
  c(15, 270,  12, 327),   # 18-44:  smoker dead/alive, non-smoker dead/alive
  c(80, 167,  53, 147),   # 45-64
  c(44,   6, 165,  28),   # 65+
  labels   = c("18-44", "45-64", "65+"),
  exposure = c("Smoker", "Non-smoker"),
  outcome  = c("Dead", "Alive")
)

whickham

# 2. A named list -- names become the stratum labels
from_list <- epi_strata(list(
  "18-44" = c(15, 270,  12, 327),
  "45-64" = c(80, 167,  53, 147),
  "65+"   = c(44,   6, 165,  28)
))

# 3. A 2 x 2 x K array, as produced by table()
arr <- array(c(15, 12, 270, 327,
               80, 53, 167, 147,
               44, 165,  6,  28),
             dim = c(2, 2, 3),
             dimnames = list(c("Smoker", "Non-smoker"),
                             c("Dead", "Alive"),
                             c("18-44", "45-64", "65+")))
from_array <- epi_strata(arr)

# 4. A list of epi2x2 objects you built earlier
from_objects <- epi_strata(list(
  epi2x2(15, 270,  12, 327),
  epi2x2(80, 167,  53, 147),
  epi2x2(44,   6, 165,  28)
))

# All identical
c(estimate(mh_odds_ratio(whickham)),
  estimate(mh_odds_ratio(from_list)),
  estimate(mh_odds_ratio(from_array)),
  estimate(mh_odds_ratio(from_objects)))

# A stratified analysis needs at least two strata, and the constructor
# enforces it.

try(epi_strata(c(15, 270, 12, 327)))

# COLLAPSING BACK DOWN
# collapse_strata() adds the strata cell by cell, discarding the stratifying
# variable. The result is the CRUDE table -- the one you would have had if you
# had never stratified.

collapse_strata(whickham)

# which is exactly the crude table we started with
whickham_crude

# That round trip is worth doing once in a class. It makes concrete that the
# crude and stratified analyses use THE SAME DATA -- nothing was added or
# removed. All that changed is whether age was allowed to be invisible.


# 11. Mantel-Haenszel odds ratio ----------------------------------------------

# Look inside each age group first, before pooling anything.

options(epibyhand.verbose = 0)
round(mh_odds_ratio(whickham)$stratum_estimates, 3)

# ALL THREE AGE GROUPS GIVE AN ODDS RATIO ABOVE 1. The crude estimate was
# 0.68. Adjustment here does not merely shift the estimate -- it REVERSES it.
#
# Now pool them.

options(epibyhand.verbose = 2)
mh_odds_ratio(whickham)

# THE WEIGHTS ARE THE POINT
# Almost no software shows you this. S_i is what each stratum contributes, and
# the pooled estimate is a WEIGHTED AVERAGE of the stratum odds ratios with
# weights S_i.
#
# That has a consequence you can check by eye: OR_MH MUST FALL BETWEEN THE
# SMALLEST AND LARGEST STRATUM ESTIMATE. Here 1.350 sits between 1.244 and
# 1.514. If yours does not, your arithmetic is wrong.
#
# The crude estimate of 0.68 does not fall in that range, and could not,
# because it is NOT AN AVERAGE OF THESE NUMBERS AT ALL. It is a different
# quantity that happens to be computed from the same table.
#
# You can verify the weighted-average identity directly:

d <- mh_odds_ratio(whickham)

S_i  <- d$steps[[2]]$table$S_i      # the weights, from step 2
OR_i <- d$stratum_estimates

sum(S_i * OR_i) / sum(S_i)          # the weighted average
estimate(d)                         # what the package reports

# THE CONFIDENCE INTERVAL
# The interval uses the ROBINS-BRESLOW-GREENLAND variance, which is consistent
# both when you have a few large strata and when you have many small ones.
# That generality is why it is the standard choice, and why the formula in
# step 4 is so unwieldy.
#
# The package's value matches stats::mantelhaen.test to ten decimal places:

arr2 <- array(c(15, 12, 270, 327,
                80, 53, 167, 147,
                44, 165,  6,  28), dim = c(2, 2, 3))
ref <- mantelhaen.test(arr2, correct = FALSE)

c(epibyhand = estimate(d), stats = unname(ref$estimate))
rbind(epibyhand = confint(d), stats = as.numeric(ref$conf.int))

# THE ADJUSTED INTERVAL CROSSES 1
# OR_MH = 1.350, 95% CI 0.961 to 1.896. The crude interval excluded 1; the
# adjusted one does not.
#
# This is worth sitting with. Adjustment is about getting the RIGHT answer,
# not a bigger or more significant one. The honest conclusion from these 1314
# women is that smoking is associated with higher 20-year mortality, with an
# effect estimate compatible with anything from a trivial protective effect to
# nearly a doubling. The confidently significant protective effect was an
# artifact.


# 12. Mantel-Haenszel risk ratio ----------------------------------------------

# The same pooling logic applied to risks. This is a cohort, so risks are
# estimable and the risk ratio is the more interpretable measure.

mh_risk_ratio(whickham)

# RR_MH = 1.148, 95% CI 0.983 to 1.341, using the GREENLAND-ROBINS variance --
# the risk-ratio counterpart to Robins-Breslow-Greenland.
#
# Compare the two pooled estimates:
#
#     mh_odds_ratio()   1.350   95% CI 0.961 to 1.896
#     mh_risk_ratio()   1.148   95% CI 0.983 to 1.341
#
# The odds ratio is further from 1, exactly as in section 4 and for the same
# reason: death within 20 years is not a rare outcome in this cohort,
# particularly in the oldest stratum. FOR THESE DATA THE RISK RATIO IS THE
# NUMBER YOU SHOULD REPORT.
#
# Both objects carry the same structure, so everything works on either.

options(epibyhand.verbose = 0)
r <- mh_risk_ratio(whickham)

round(r$stratum_estimates, 3)
r$crude
estimate(r)


# 13. Homogeneity -------------------------------------------------------------

# A single pooled estimate only means something if ONE ODDS RATIO UNDERLIES
# EVERY STRATUM. If the strata genuinely differ, the stratifying variable is
# an EFFECT MODIFIER, and pooling destroys the finding rather than reporting
# it.
#
# The Breslow-Day test asks whether the observed spread is more than chance.

options(epibyhand.verbose = 2)
homogeneity(whickham)

# X-squared = 0.118 on 2 degrees of freedom, p = 0.94. The stratum estimates
# (1.51, 1.33, 1.24) are about as homogeneous as random variation allows, and
# no single stratum strains against the others. Pooling is comfortable here.
#
# Step 1 is worth reading carefully: A_i is what cell a would be if that
# stratum had exactly the pooled odds ratio, holding its margins fixed.
# Solving the quadratic for it is the one step in this package you would not
# do by hand -- everything else is arithmetic.

# TARONE'S CORRECTION
# Applied by default. Without it the statistic is slightly too large.

options(epibyhand.verbose = 0)
c(with_tarone    = estimate(homogeneity(whickham, tarone = TRUE)),
  without_tarone = estimate(homogeneity(whickham, tarone = FALSE)))

# The correction subtracts a term that accounts for the pooled estimate having
# been estimated from the same data. It is small here, but it is the version
# Breslow and Day's own later work recommends, so it is the default.
#
# THE CAVEAT THE FUNCTION PRINTS ANYWAY
# A LARGE P-VALUE IS NOT EVIDENCE THAT THE ODDS RATIOS ARE EQUAL. This test
# has poor power, especially with small strata, so it will often fail to
# reject whether or not effect modification is present. The stratum-specific
# estimates you inspected before pooling remain the more informative thing.

# WHAT EFFECT MODIFICATION ACTUALLY LOOKS LIKE
# A fabricated study where an exposure is harmful in younger people and null
# in older ones.

em <- epi_strata(
  c(60, 40, 30, 70),      # under 50:     OR = (60*70)/(40*30) = 3.5
  c(50, 50, 50, 50),      # 50 and over:  OR = (50*50)/(50*50) = 1.0
  labels = c("Under 50", "50 and over")
)

round(mh_odds_ratio(em)$stratum_estimates, 3)
estimate(mh_odds_ratio(em))

options(epibyhand.verbose = 1)
homogeneity(em)

# X-squared = 9.34, p = 0.002. The strata disagree.
#
# The Mantel-Haenszel estimate for these data is 1.81 -- a number that
# describes neither group. It is the average of a real effect and no effect,
# and reporting it alone would hide the actual finding: THE EXPOSURE MATTERS
# FOR YOUNGER PEOPLE AND NOT FOR OLDER ONES.
#
# CONFOUNDING AND EFFECT MODIFICATION ARE DIFFERENT THINGS:
#
#   Confounding         A nuisance distorting the crude estimate.
#                       Adjust it away, report the pooled estimate.
#
#   Effect modification A real feature of how the world works.
#                       Report the strata separately -- it IS the finding.


# 14. Using derivations programmatically --------------------------------------

# Every function returns the same kind of object, so the same extractors work
# everywhere.

options(epibyhand.verbose = 0)
d <- mh_odds_ratio(whickham)

estimate(d)      # the point estimate
confint(d)       # the interval
class(d)

# steps_table() returns the whole derivation as a data frame -- the basis for
# answer keys, grading scripts, and rendering the working somewhere the
# package does not reach.

tt <- steps_table(d)
str(tt)

tt[, c("step", "symbol", "label", "result")]

# Six columns: step, symbol, label, formula, substituted, result. Steps that
# only carry a per-stratum table (like the weights) have NA in result, because
# they do not evaluate to a single number.
#
# Here is the substituted arithmetic -- the middle line of each printed step:

tt[!is.na(tt$substituted), c("symbol", "substituted", "result")]

# WHAT ELSE THE OBJECT CARRIES
# Stratified derivations attach two extras that are not in the steps table.

d$stratum_estimates    # named vector, one per stratum
d$crude                # the crude estimate, for comparison
d$notes                # the assumption notes printed under the result
d$conf_level
d$method

# A WORKED USE: GENERATING AN ANSWER KEY

key <- steps_table(mh_odds_ratio(whickham))
answer_key <- setNames(round(key$result, 4), key$symbol)
answer_key[!is.na(answer_key)]

# And a worksheet with the answers stripped out, ready to hand to students:

worksheet <- key[, c("step", "symbol", "label", "formula")]
worksheet$your_answer <- ""
worksheet


# 15. Predictive values -------------------------------------------------------

# Everything so far has measured an association between an exposure and an
# outcome. predictive_value() asks a different question: given what a
# diagnostic test just told me, what should I believe?
#
# The table goes in the same shape as every other table in this package, once
# you read "exposed" as "test positive" and "case" as "diseased":
#
#                  Diseased   Healthy
#     Test +          a (TP)    b (FP)
#     Test -          c (FN)    d (TN)

options(epibyhand.verbose = 2)

screening <- epi2x2(90, 180, 10, 1720,
                    exposure = c("Test positive", "Test negative"),
                    outcome  = c("Diseased", "Healthy"))

predictive_value(screening)

# PPV = 0.33. A test that is 90% sensitive and 90% specific, applied to a
# population where 5% are actually ill, is WRONG TWO TIMES OUT OF THREE WHEN
# IT SAYS YOU ARE SICK.
#
# This is the most counter-intuitive result in introductory epidemiology, and
# the derivation shows exactly why: step 3 puts prevalence on the page, and
# step 4 shows it entering the formula. Sensitivity and specificity never
# move. The prevalence does all the work.

options(epibyhand.verbose = 1)
predictive_value(screening, which = "negative")

# NPV = 0.994. The same test that is nearly useless at confirming disease is
# excellent at ruling it out. That asymmetry is entirely a consequence of the
# disease being rare, not of anything about the test.

# MOVING THE TEST TO ANOTHER POPULATION
# The prevalence argument is what makes this function worth having. Supply one
# and the test's sensitivity and specificity are applied to a population with
# that prevalence instead of the one in the table, via Bayes' theorem.
#
# That is how you take validation data from a hospital clinic -- where
# prevalence is high because patients were referred -- and ask what the same
# test would do as a population screen.

options(epibyhand.verbose = 0)

for (p in c(0.001, 0.01, 0.05, 0.20, 0.50)) {
  cat(sprintf("prevalence %6.3f   PPV %.4f   NPV %.4f\n", p,
      estimate(predictive_value(screening, prevalence = p)),
      estimate(predictive_value(screening, which = "negative",
                                prevalence = p))))
}

# Nothing about the test changed across those five rows. The PPV moves from
# under 1% to over 90%.
#
# This is why a test that performs well in a clinic can be useless as a
# population screen, and it is the single most important idea in screening
# epidemiology. It is also why "the test is 99% accurate" is a meaningless
# sentence without knowing who is being tested.
#
# No confidence interval is reported when you supply a prevalence. The
# derivation says why: the result is no longer a proportion estimated from
# these data, so there is nothing to put an interval around.

confint(predictive_value(screening))          # an interval
predictive_value(screening, prevalence = 0.40)$ci   # NULL


# 16. Extending the package ---------------------------------------------------

# derivation() and derivation_step() are exported, which means YOU CAN ADD A
# MEASURE THE PACKAGE DOES NOT HAVE and it will print, tabulate, and check
# exactly like a built-in one.
#
# This is how you should handle a method you teach that is not covered -- write
# it once, and it behaves like the rest.
#
# A WORKED EXAMPLE: LIKELIHOOD RATIOS
# Part 15 covered predictive values, which the package provides. Their natural
# companion, the likelihood ratio, it does not. Let's add it.
#
#     LR+ = Sens / (1 - Spec)          LR- = (1 - Sens) / Spec

likelihood_ratio <- function(x, ..., which = c("positive", "negative")) {
  which <- match.arg(which)
  x <- epi2x2(x, ...)

  TP <- x$a; FP <- x$b; FN <- x$c; TN <- x$d
  sens <- TP / (TP + FN)
  spec <- TN / (FP + TN)
  lr <- if (which == "positive") sens / (1 - spec) else (1 - sens) / spec

  derivation(
    method   = paste0("Likelihood ratio of a ", which, " test"),
    estimate = lr,
    symbol   = if (which == "positive") "LR+" else "LR-",
    data     = x,
    steps = list(
      derivation_step(
        label = "Sensitivity", symbol = "Sens",
        formula     = "TP / (TP + FN)",
        substituted = paste0(TP, " / (", TP, " + ", FN, ")"),
        result      = sens),
      derivation_step(
        label = "Specificity", symbol = "Spec",
        formula     = "TN / (FP + TN)",
        substituted = paste0(TN, " / (", FP, " + ", TN, ")"),
        result      = spec),
      derivation_step(
        label   = paste0("Likelihood ratio of a ", which, " test"),
        symbol  = if (which == "positive") "LR+" else "LR-",
        formula = if (which == "positive") "Sens / (1 - Spec)" else
                                           "(1 - Sens) / Spec",
        substituted = if (which == "positive") {
          paste0(round(sens, 4), " / (1 - ", round(spec, 4), ")")
        } else {
          paste0("(1 - ", round(sens, 4), ") / ", round(spec, 4))
        },
        result = lr,
        note = paste("Built only from sensitivity and specificity, so unlike",
                     "a predictive value this does not change with",
                     "prevalence."))
    ),
    notes = paste("Multiply the pre-test odds by this to get the post-test",
                  "odds. A LR+ above 10 or a LR- below 0.1 is usually taken",
                  "as decisive.")
  )
}

# The same screening test from Part 15.

options(epibyhand.verbose = 2)
likelihood_ratio(screening)

# LR+ = 9.5. A positive result multiplies the pre-test odds of disease by
# about nine and a half.
#
# Now put that beside Part 15. The predictive value of this test ranged from
# under 1% to over 90% depending on who was tested. THE LIKELIHOOD RATIO DOES
# NOT MOVE AT ALL -- it is built from sensitivity and specificity, which are
# properties of the test.
#
# That is the whole reason clinicians are taught likelihood ratios. They
# travel between populations; predictive values do not.

options(epibyhand.verbose = 0)

# LR+ is the same regardless of who you apply the test to...
estimate(likelihood_ratio(screening))

# ...while the predictive value it implies is not
vapply(c(0.01, 0.20), function(p)
  estimate(predictive_value(screening, prevalence = p)), numeric(1))

# YOUR FUNCTION IS NOW A FIRST-CLASS CITIZEN
# Everything in the package works on it, because it returns the same kind of
# object.

lr <- likelihood_ratio(screening)

estimate(lr)
steps_table(lr)[, c("symbol", "result")]
check_work(lr, 0.90, step = "Sens")
print(lr, verbose = 1)

# THE PATTERN
#   1. Compute your numbers.
#   2. Wrap each intermediate in derivation_step(label, formula, substituted,
#      result, symbol, note).
#   3. Wrap the list in derivation(method, estimate, symbol, data, steps,
#      notes).
#
# That is the whole API. derivation_step() also takes a `table` argument for a
# per-unit grid, which is how the Mantel-Haenszel weights are displayed.
#
# Because all display logic lives in one print method, you write arithmetic
# and never write display code. You also did not write the verbosity handling,
# the steps table, or check_work() support -- those came free.


# 17. A complete analysis, start to finish ------------------------------------

options(epibyhand.verbose = 0)

# --- 1. Look at the crude association ----------------------------------
cat("CRUDE\n")
cat("  OR:", estimate(odds_ratio(whickham_crude)),
    " CI:", confint(odds_ratio(whickham_crude)), "\n")
cat("  RR:", estimate(risk_ratio(whickham_crude)),
    " CI:", confint(risk_ratio(whickham_crude)), "\n")

# --- 2. Inspect strata BEFORE pooling ----------------------------------
cat("\nSTRATUM-SPECIFIC ODDS RATIOS\n")
print(round(mh_odds_ratio(whickham)$stratum_estimates, 3))

# --- 3. Test the pooling assumption ------------------------------------
h <- homogeneity(whickham)
cat("\nHOMOGENEITY (Breslow-Day, Tarone corrected)\n")
cat("  X2 =", round(estimate(h), 3),
    " p =", round(steps_table(h)$result[4], 3), "\n")

# --- 4. Pool -----------------------------------------------------------
mh <- mh_odds_ratio(whickham)
cat("\nADJUSTED\n")
cat("  OR_MH:", estimate(mh), " CI:", confint(mh), "\n")

# --- 5. Quantify the confounding ---------------------------------------
cat("\nCONFOUNDING\n")
cat("  crude    :", mh$crude, "\n")
cat("  adjusted :", estimate(mh), "\n")
cat("  change   :", round(100 * (mh$crude - estimate(mh)) / estimate(mh), 1),
    "%\n")

# Five steps, in the only order that is defensible:
#
#   1. CRUDE FIRST, so you can see what you would have concluded without
#      thinking.
#   2. STRATA BEFORE POOLING -- always. A pooled number computed before you
#      look at what it is pooling is a number you cannot defend.
#   3. HOMOGENEITY, to check that pooling means anything at all.
#   4. POOL, if step 3 allowed it.
#   5. QUANTIFY THE CONFOUNDING, so the reader can see what adjustment did
#      rather than taking your word for it.


# Function reference ----------------------------------------------------------

# epi2x2(a, b, c, d)                Build a 2 x 2 table from counts or a matrix
# epi_strata(...)                   Build stratified tables from counts, a
#                                   list, or a 2 x 2 x K array
# collapse_strata(x)                Add strata cell by cell to recover the
#                                   crude table
# risk_ratio(x)                     Risk ratio, log-scale interval
# risk_difference(x)                Risk difference, number needed to expose
# odds_ratio(x)                     Odds ratio, Woolf interval
# attributable_fraction(x, among)   AFe or PAF, three formulas shown to agree
# mh_odds_ratio(x)                  Mantel-Haenszel OR, Robins-Breslow-
#                                   Greenland interval
# mh_risk_ratio(x)                  Mantel-Haenszel RR, Greenland-Robins
#                                   interval
# homogeneity(x, tarone)            Breslow-Day test, Tarone corrected by
#                                   default
# predictive_value(x, which,        PPV or NPV by Bayes' theorem, at the
#   prevalence)                     table's prevalence or a supplied one
# check_work(x, value, step, tol)   Locate where a hand calculation diverged
# steps_table(x)                    Derivation as a data frame
# estimate(x)                       Extract the point estimate
# confint(x)                        Extract the interval (warns if given
#                                   `level` -- see section 5)
# derivation(), derivation_step()   Build your own measure
#
# OPTIONS
#   epibyhand.verbose   0 result only, 1 add formulas, 2 full working (default)
#   epibyhand.digits    Significant digits, default 4
#   Both can be overridden per call: print(d, verbose = 1, digits = 2)
#
# ARGUMENTS COMMON TO THE MEASURES
#   conf_level            all measures        Confidence level, default 0.95
#   exposure, outcome     epi2x2, epi_strata  Row and column labels
#   labels                epi_strata          Stratum names
#   among                 attributable_...    "exposed" (default) or
#                                             "population"
#   tarone                homogeneity         Tarone's correction, default TRUE
#   which, prevalence     predictive_value    "positive"/"negative"; optional
#                                             target prevalence
#   step, tol             check_work          Target step and relative
#                                             tolerance


# Where to go next ------------------------------------------------------------

# Package documentation   help(package = "epibyhand")
# The vignette            vignette("epibyhand")
# CRAN                    https://cran.r-project.org/package=epibyhand
# Source and issues       https://github.com/rajsubediresearch/epibyhand
#
# REFERENCE
# The Whickham data are from Appleton, D. R., French, J. M. and Vanderpump,
# M. P. J. (1996). Ignoring a covariate: an example of Simpson's paradox.
# The American Statistician 50(4), 340-341.

citation("epibyhand")

# Restore defaults
options(epibyhand.verbose = 2, epibyhand.digits = 4)

# =============================================================================
# End of tutorial
# =============================================================================
