# Airline Review Analytics

Predicting whether a passenger recommends an airline, from their ratings and the words they wrote — with two validation designs that a random split can't see.

**Stack:** Python · pandas · scikit-learn · matplotlib
**Data:** 23,171 reviews, 20 columns. Not included (coursework data).

---

## What I found

**Text and numbers together beat either alone.** Combining service ratings, engineered sentiment, categorical features and TF-IDF reaches **F1 0.936 / AUC 0.989** — about 2 F1 points above numbers alone and 8.5 above text alone.

**A hand-built sentiment scorer works.** Rather than pulling in a heavy NLP dependency, I wrote a lexicon scorer with negation handling ("not very good" flips correctly) and square-root length normalisation. It separates recommenders from detractors cleanly, and it runs with no model downloads.

**General and domain sentiment disagree — usefully.** Two lexicons run in parallel: general emotional language, and airline-operational language (*queue, baggage, overbooked, legroom, lounge*). Where they disagree, the review is usually one where the passenger liked the crew but hated the operation. That disagreement is itself a feature.

**Contradictions were kept, not cleaned away.** Reviews rating 3/10 but recommending — and 8/10 but not recommending — are audited and retained rather than deleted. They're real nuance in customer language, and they feed the failure analysis.

**Two stress tests probe what a random split hides.** Both hold the model fixed and change only the split rule, so any drop is attributable to distribution shift, not retuning:
- **Temporal** — train on the earliest 75% of reviews, test on the most recent 25%. Does a model trained on the past still work on the future?
- **Airline holdout** — remove the single most-reviewed carrier from training entirely and test on it alone. Does it generalise to an airline it has never seen?

A random stratified split puts the same airline on both sides, so the model can quietly memorise carrier-specific rating habits. These two designs are what stop that going unnoticed.

---

## Method

Single-command pipeline, no notebook cells, no NLP corpus downloads.

| Stage | What happens |
|---|---|
| Schema validation | All 20 expected columns enforced up front; fails loudly with the missing names |
| Cleaning | Duplicate removal, ordinal-suffix date parsing, target/verified standardisation, range audit against declared valid ranges, median imputation with midpoint fallback |
| Audits | Missing-value profile before *and* after, out-of-range counts, logical-conflict counts — a documented before/after evidence trail |
| Features | Custom tokeniser (domain stopwords removed, negations preserved), two lexicon sentiment scores, disagreement flag, word count, TF-IDF (700 features, min_df 10) |
| Models | Logistic regression via SGD and Complement NB, across numeric / text / combined feature sets |
| Validation | Stratified 75/25 split, grid search, plus the two stress tests |

Everything sits inside a scikit-learn `Pipeline`, so scaling and vectorisation are fitted per fold — no leakage across cross-validation.

---

## Results

| Feature set | Model | Accuracy | Precision | Recall | F1 | ROC AUC |
|---|---|---|---|---|---|---|
| Combined | Logistic Regression (SGD) | **0.956** | 0.912 | 0.961 | **0.936** | **0.989** |
| Numeric | Logistic Regression (SGD) | 0.942 | 0.896 | 0.936 | 0.915 | 0.985 |
| Text | Logistic Regression (SGD) | 0.895 | 0.816 | 0.888 | 0.851 | 0.953 |
| Text | Complement NB | 0.863 | 0.750 | 0.890 | 0.814 | 0.931 |
| Numeric | Complement NB | 0.809 | 0.667 | 0.866 | 0.754 | 0.893 |

Logistic regression beats Naive Bayes on every feature set. 5,793 test rows.

---

## Figures

![Service attribute gap](outputs/05_management_service_gap_chart.png)

The difference in mean rating between passengers who recommend and those who don't, per service attribute — sorted. This is the operational view: which parts of the service actually separate promoters from detractors, rather than which correlate with the overall score.

---

## Limitations

- **Overall rating predicts recommendation almost by definition.** They're near-redundant expressions of the same judgement, which is most of why numeric-only accuracy already sits at 0.94. Stated plainly rather than presented as predictive skill.
- **Imputation is fitted before the split**, so the median constant leaks a little test information.
- **Two-fold cross-validation** and unigrams only — a deliberately light search for reproducible single-threaded runtime, not exhaustive tuning.
- Complement NB was not run on the combined feature set.

---

## Run it

```bash
pip install pandas numpy matplotlib scikit-learn
python airline_review_analysis.py
```

Place the source CSV alongside the script. Every figure and table is regenerated in one command, with a timestamped run log acting as a manifest.

---

## Notes

Written in Python with AI assistance for code drafting; the analysis design, feature engineering choices and interpretation are my own.
