# ToyTT

This repo contains my implementation of miniTT with parser.

## Usage
```
stack build
stack exec miniTT-exe [FILE]
```

## Sample Code
`semantics.minitt`, available in `test/` folder.

## Semantics

### Unit Elimination
I find that there's a rule forgotten in the paper : the elimination rule for unit type. I wrote a type checker that follows the rule presented in the paper faithfully, and I found that the 4th example, namely `boolElim` cannot pass type-checking. It will complain that an inferred type is not equal to a checked type.

Let's expand it a little more:
```
bool : U 
     = Sum (True 1 | False 1)
;

elimBool : ∀ c : bool → U . c false → c true → ∀ b : bool . c b
         = λ c . λ h0 . λ h1 . fun (True _ → h1 | False _ → h0)
; 
```
The type checker will check the term `λ _ . h1` against the type `Π x₃ : 1. (Π b : bool . x₀ b) (True x₃)`, and then (by following the rules) check the term `h1` against the type `x₀ (True x₃)`, where `x₃` is the generic value produced when checking a lambda-term. However, according to typing context, the inferred type for `h1` is `x₀ (True 0)`. It's clear to us that `x₃` has type unit, and therefore must be `0` (by elimination rule), but type checker can't witness this.

To resolve this, the language is added a premitive construct `rec₁` (the recursor for unit type), with the following rules:
* (formation) `⊢ 1 : U`
* (construction) `⊢ 0 : 1`
* (elimination) `⊢ M ⟸ inst f 0` implies `⊢ rec₁ M ⟸ Π 1 f`
* (computation) `(rec₁ M) 0 ≡ M`

And in the case tree, choice of the form `c → M` is parsed into `rec₁ M` (and hence the 2nd retriction in syntax as listed below).

### Identity Type (an incomplete branch)
When I was trying to extend miniTT to handle identity type (with the usual J-eliminator, and the syntax is augmented with `J(_ & _ & _ & _ ...)` as a whole J-eliminator term), I found that it may be better if I use DeBruijn index (or locally nameless). Because when infering the type for `J` with predicate `c : ∀ x : A . ∀ y : A . ∀ p : x ≡A y . U` , we need to check that the base case has type `t = ∀ x : A . c x x reflₓ`. But I have trouble in creating such lambda term with only the value of `c` at hand.

## Syntax
There're minor changes to the original syntax (mainly for parsing purpose) :

* expression variable should start with lower case, while constructor should start with upper case.

* for a labelled sum, if a label `c` is associated with unit type, the case analysis function for it should always be in sugared form, i.e. fun (c → ...). Otherwise the program may not pass type-check.

* `Pi`, `∀` and `Π` are allowed syntax for Pi type.

* `Sigma` and `Σ` are allowed syntax for Sigma type.

* `->` and `→` are allowed syntax for arrow type.

* `*` and `×` are allowed syntax for product type.

* a complete program consists of a series of declaration (without an expression at the end).

## TODO
* Use DeBrujin index.

## Original Repo and Commit History
[miniTT](https://github.com/KomaEc/Type-Systems)
