module NonInterference where
open import Base
open import Terms
open import Trans
open import Relation.Binary.PropositionalEquality hiding ([_])
open import Relation.Nullary
open import Function hiding (id)
open import Data.Bool 
open import Data.Empty
open import Data.Nat
open import Data.Product renaming (_,_ to _،_)
open import Normalisation
open import Subst
open import Simul
open Simul.Lemmas

private variable
    t t′ t₁ t₂ t₁′ t₂′ a a₁ a₂ a′ b b₁ b₂ b′ : _ ⊢ _
    A B : Type
    Γ Δ Δ′ Γ₁ Γ₂ : Context
    σ σ′ σ₁ σ₂ τ τ′ : _ ⇉ _ 

ius : (t₁ t₂ : Γ ⊢ A)
    → (σ₁ σ₂ : Δ ⇉ Γ)
    -----------------------------------
    → Γ     ⊢ t₁          ~ t₂          ∶ A 
    → Δ , Γ ⊢ σ₁          ~ σ₂ 
    -----------------------------------
    → Δ     ⊢ (sub σ₁ t₁) ~ (sub σ₂ t₂) ∶ A
ius _ _ σ₁ σ₂ (sim-nat n)     simσ = sim-nat n
ius _ _ σ₁ σ₂ (sim-mon t₁ t₂) simσ = sim-mon (sub σ₁ t₁) (sub σ₂ t₂)
--------------------------------------------------------------------
ius _ _ _       _       (sim-var Z)     (simσ-• simσ x) = x
ius _ _ (σ • t) (τ • u) (sim-var (S x)) (simσ-• simσ _) 
    = ius (var x) (var x) σ τ (sim-var x) simσ
----------------------------------------------
ius (l₁ ∙ r₁) (l₂ ∙ r₂) σ₁ σ₂ (sim-app simₗ simᵣ) simσ with sit′ simₗ | sit′ simᵣ
... | refl | refl = sim-app (ius l₁ l₂ σ₁ σ₂ simₗ simσ) 
                            (ius r₁ r₂ σ₁ σ₂ simᵣ simσ)
-------------------------------------------------------
ius (ƛ t₁) (ƛ t₂) σ₁ σ₂ (sim-lam sim) simσ with sit′ sim
... | refl = sim-lam (ius t₁ t₂ (σ+ σ₁) (σ+ σ₂) sim (lemma-σ+ simσ))


-- Non-interference relation is a single-step bisimulation      
bisim : pure A
      → Γ ⊢ t₁ ~ t₂ ∶ A 
      → t₁ ↝ t₁′ 
      ------------------------------------------------------
      → Σ[ t₂′ ∈ Γ ⊢ A ] ((t₂ ↝ t₂′) × (Γ ⊢ t₁′ ~ t₂′ ∶ A))

bisim {t₁ = (ƛ t₁) ∙ r₁} p (sim-app {t₂′ = r₂} (sim-lam {t′ = t₂} simₗ) simᵣ) βƛ with sit′ simₗ | sit′ simᵣ 
... | refl | refl = t₂ [ r₂ ] 
                  ، βƛ 
                  ، ius t₁ t₂ 
                       (Subst.id • r₁) (Subst.id • r₂) 
                       simₗ 
                       (simσ-• simσ-refl simᵣ)

bisim {t₁ = l₁ ∙ r₁} {t₂ = l₂ ∙ r₂} p sim@(sim-app simₗ simᵣ) (ξappl step)
                         with  sit′ sim | sit′ simₗ | sit′ simᵣ 
... | refl | refl | refl with bisim (p⇒ p) simₗ step
... | l₂′ ، step ، sim′ = l₂′ ∙ r₂ ، ξappl step ، sim-app sim′ simᵣ

bisim {t₁ = ƛ t₁} {t₂ = ƛ t₂} (p⇒ p) (sim-lam sim) (ξlamd step) 
                         with sit′ sim
... | refl               with bisim p sim step
... | t₂′ ، step ، sim′ = ƛ t₂′ ، ξlamd step ، sim-lam sim′

-- B

-- If x : T (A) ` M : B for some non-monadic type B, and ` N1 , N2 : T (A), then M [N1 /x] = M [N2 /x].
-- non-interference : (V : ∅ , M A ⊢ B) 
--                  → (t : ∅       ⊢ M A)
--                  → (u : ∅       ⊢ M A)
--                  → (V [ t ] ≡ V [ u ])
-- non-interference V t u = 
--     let t~u = sim-mon t u
--         V~V = sim-refl V
--         sub = ius V V (id • t) (id • u) V~V (simσ-• simσ-ε t~u)
--         Vt′ ، step ، Vtn  = normalising (V [ t ])
--         Vu′ ، step ، Vsim = bisim ? ? 
--     in {!   !}