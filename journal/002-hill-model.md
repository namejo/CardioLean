# 002 — Questions to work through with the Hill model

*Study scaffold, 2026-11-05. These prompts accompany a completed write-up and
executed illustrative notebook; they do not claim personal reading or understanding.*

## Work now available

[Chapter 1](../docs/models/Hill.md) walks from the original equation to explicit
assumptions and the checked Lean statements. The [notebook](../notebooks/hill-exploration.ipynb)
plots synthetic parameter choices and checks a finite set of numerical values.
The Lean implementation already contains six checked theorems; this writing session
adds explanations and experiments, rather than new formal results.

## Questions I want to answer myself

- Can I rearrange the equation without looking at the chapter, and explain why division is allowed?
- Why can a muscle have nonzero force when shortening velocity is zero?
- Which statements follow from algebra, and which need experimental evidence?
- Can I predict what changing `a` or `b` does, then explain the plotted result?
- Can I translate each named hypothesis of `velocity_nonneg` into an ordinary sentence?
- What is different about checking 101 plotted points and proving a statement for every admissible force?
- What does the original paper actually measure, and what have I not read yet?

## Space for my own notes

When I work through the chapter, I can add the date, my attempted derivations,
questions, and corrections here. I should distinguish a prediction, a numerical
observation, an informal argument, and a theorem checked by Lean.

Next possible proof exercise: derive the zero-load velocity and an upper bound.
At the time of this entry, those exercises were proposed work. The follow-up
session completed them as `velocity_at_zero` and `velocity_bounds`; see
[entry 003](003-from-hill-to-circulation.md).
