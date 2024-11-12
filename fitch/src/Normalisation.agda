module Normalisation where
open import Relation.Binary.PropositionalEquality hiding ([_])
open import Data.Product renaming (_,_ to _،_; _×_ to Product)
open import Relation.Nullary
open import Data.Empty 
open import Data.Nat
open import Base
open import Terms
open import Subst
open import Simul
open import Trans

private variable
    t  u  l  r  t₁  t₂  u₁  u₂  v₁  v₂  w : _ ⊢ _
    t′ u′ l′ r′ t₁′ t₂′ : _ ⊢ _
    A B : Type
    Γ Γ₁ Γ₂ : Context

data Value : Γ ⊢ A → Set where
    Vƛ : {t : Γ , B ⊢ A} → Value (ƛ t) 
    Vz : Value {Γ = Γ} zer
    Vs : Value t → Value (suc t)
    Vb : Value (box t)

    V× : Value ⟨ t , u ⟩
    Vl : {B : Type} → Value (inl {B = B} t)
    Vr : {A : Type} → Value (inr {A = A} t)

infix 1 _⇓_
_⇓_ : Γ ⊢ A → Γ ⊢ A → Set
t ⇓ v = Product (t ↝⋆ v) (Value v)

-- Indistinguishability is syntactic equality on values
ind-eql : (n : ∅ ⊢ Nat) → (m : ∅ ⊢ Nat) → Value n → Value m → ∅ ⊢ n ~ m ∶ Nat → n ≡ m
ind-eql zer     zer     Vz      Vz      sim-zer       = refl
ind-eql (suc n) (suc m) (Vs vn) (Vs vm) (sim-suc sim) with ind-eql n m vn vm sim
... | refl = refl 

ind-eql′ : {n : ∅ ⊢ Nat} → {m : ∅ ⊢ Nat} → Value n → Value m → ∅ ⊢ n ~ m ∶ Nat → n ≡ m
ind-eql′ {n = n} {m = m} vn vm sim = ind-eql n m vn vm sim 

sim-value : (n : ∅ ⊢ Nat) 
          → (m : ∅ ⊢ Nat)
          → ∅ ⊢ n ~ m ∶ Nat 
          → Value n 
          ---------
          → Value m
sim-value zer zer sim-zer Vz = Vz
sim-value (suc n) (suc m) (sim-suc sim) (Vs vn) with sim-value n m sim vn 
... | v = Vs v  