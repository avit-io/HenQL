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

prettyExpr : {M : Model} {τ : PromType} → Expr M τ → String
prettyExpr (scalar s)             = s
prettyExpr (metric nm)            = nm
prettyExpr (litVec s)             = s
prettyExpr (range nm w)           = nm ++ "[" ++ show w ++ "m]"
prettyExpr (rate e)               = "rate(" ++ prettyExpr e ++ ")"
prettyExpr (sumBy lbls e)         =
  "sum by (" ++ commas lbls ++ ") (" ++ prettyExpr e ++ ")"
prettyExpr (a - b)                =
  "(" ++ prettyExpr a ++ " - " ++ prettyExpr b ++ ")"
prettyExpr (a ÷ b)                =
  "(" ++ prettyExpr a ++ " / " ++ prettyExpr b ++ ")"
prettyExpr (histogramQuantile q e) =
  "histogram_quantile(" ++ q ++ ", " ++ prettyExpr e ++ ")"
prettyExpr (toScalar e)           = "scalar(" ++ prettyExpr e ++ ")"
