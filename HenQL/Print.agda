{-# OPTIONS --safe --without-K #-}

module HenQL.Print where

open import Prometea.Core
open import HenQL.Syntax
open import Data.Nat.Show using (show)
open import Data.String   using (String; _++_)
open import Data.List     using (List; []; _∷_)

private
  commas : List String → String
  commas []           = ""
  commas (x ∷ [])    = x
  commas (x ∷ y ∷ t) = x ++ ", " ++ commas (y ∷ t)

  opSym : MatchOp → String
  opSym meq    = "="
  opSym mregex = "=~"

  prettyMatcher : {M : Model} → Matcher M → String
  prettyMatcher m =
    Matcher.label m ++ opSym (Matcher.op m)
                    ++ "\"" ++ Matcher.value m ++ "\""

  prettyMatchers : {M : Model} → List (Matcher M) → String
  prettyMatchers []           = ""
  prettyMatchers (x ∷ [])    = prettyMatcher x
  prettyMatchers (x ∷ y ∷ t) = prettyMatcher x ++ "," ++ prettyMatchers (y ∷ t)

  selector : {M : Model} → String → List (Matcher M) → String
  selector n []        = n
  selector n (x ∷ xs)  = n ++ "{" ++ prettyMatchers (x ∷ xs) ++ "}"

prettyExpr : {M : Model} {τ : PromType} → Expr M τ → String
prettyExpr (scalar s)             = s
prettyExpr (metric nm)            = nm
prettyExpr (litVec s)             = s
prettyExpr (range nm w)           = nm ++ "[" ++ show w ++ "m]"
prettyExpr (metricSel nm ms)      = selector nm ms
prettyExpr (rangeS nm ms w)       = selector nm ms ++ "[" ++ w ++ "]"
prettyExpr (rate e)               = "rate(" ++ prettyExpr e ++ ")"
prettyExpr (changes e)            = "changes(" ++ prettyExpr e ++ ")"
prettyExpr (sumBy lbls e)         =
  "sum by (" ++ commas lbls ++ ") (" ++ prettyExpr e ++ ")"
prettyExpr (a - b)                =
  "(" ++ prettyExpr a ++ " - " ++ prettyExpr b ++ ")"
prettyExpr (a ÷ b)                =
  "(" ++ prettyExpr a ++ " / " ++ prettyExpr b ++ ")"
prettyExpr (histogramQuantile q e) =
  "histogram_quantile(" ++ q ++ ", " ++ prettyExpr e ++ ")"
prettyExpr (toScalar e)           = "scalar(" ++ prettyExpr e ++ ")"
