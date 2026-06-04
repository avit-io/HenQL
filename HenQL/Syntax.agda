module HenQL.Syntax where

open import Prometea.Core
open import Data.Nat    using (ℕ)
open import Data.String using (String)
open import Data.List   using (List)

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
  rate   : Expr M RangeVector                  → Expr M InstantVector
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
