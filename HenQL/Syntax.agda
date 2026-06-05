{-# OPTIONS --safe --without-K #-}

module HenQL.Syntax where

open import Prometea.Core
open import Data.Nat    using (ℕ)
open import Data.String using (String)
open import Data.List   using (List)

-- ╔════════════════════════════════════════════════════════════════════╗
-- ║  Label matchers per i selettori PromQL: {Label=Value, …}.          ║
-- ║                                                                    ║
-- ║  Le label PromQL sono APERTE (nessuno schema): qui non c'è prova   ║
-- ║  di esistenza, solo un AST ben formato. Due operatori:             ║
-- ║   • meq    →  `=`   (uguaglianza esatta);                          ║
-- ║   • mregex →  `=~`  (regex). Grafana interpola le variabili multi  ║
-- ║                       come alternanza `v1|v2`, che con `=~` resta  ║
-- ║                       fedelmente "uno di {v1, v2}".                ║
-- ╚════════════════════════════════════════════════════════════════════╝
data MatchOp : Set where
  meq    : MatchOp
  mregex : MatchOp

record Matcher (M : Model) : Set where
  constructor mkMatcher
  field
    label : String
    op    : MatchOp
    value : String

-- Typed query expression indexed by PromType, parametric on Model M.
-- M is phantom in all constructors: it enforces that expressions from
-- semantically distinct models cannot be mixed at the call site.
data Expr (M : Model) : PromType → Set where
  scalar : String                               → Expr M Scalar
  metric : String                               → Expr M InstantVector
  -- Literal numeric vector — appare nei calcoli con promozione scalare
  -- di PromQL, es. `1 - rate(...)`. Penelope emette la stringa così com'è.
  litVec : String                               → Expr M InstantVector
  range  : String → ℕ                          → Expr M RangeVector
  -- Selettore strutturato: `name{l₁ op₁ "v₁", …}`. Permette label matcher
  -- tipati invece di incollarli nel nome.
  metricSel : String → List (Matcher M)         → Expr M InstantVector
  -- Range-vector strutturato: name{matchers}[window]. window è una
  -- stringa per accomodare i token Grafana come `$__interval`.
  rangeS : String → List (Matcher M) → String  → Expr M RangeVector
  rate   : Expr M RangeVector                  → Expr M InstantVector
  -- changes(range-vector): numero di cambi di valore sulla finestra.
  changes : Expr M RangeVector                 → Expr M InstantVector
  sumBy  : List String → Expr M InstantVector  → Expr M InstantVector
  -- Aritmetica vettoriale (Prometheus promuove vector↔scalar).
  _-_    : Expr M InstantVector → Expr M InstantVector → Expr M InstantVector
  _÷_    : Expr M InstantVector → Expr M InstantVector → Expr M InstantVector
  -- histogram_quantile(q, vector) — q come stringa (es. "0.99").
  histogramQuantile : String → Expr M InstantVector → Expr M InstantVector
  -- scalar(vector) — collassa un instant vector in uno scalare.
  toScalar : Expr M InstantVector → Expr M Scalar

infixl 6 _-_
infixl 7 _÷_
