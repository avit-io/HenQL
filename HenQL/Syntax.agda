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
  range  : String → ℕ                          → Expr M RangeVector
  rate   : Expr M RangeVector                  → Expr M InstantVector
  sumBy  : List String → Expr M InstantVector  → Expr M InstantVector
