module Project where

-- we import the Haskell prelude provided by agda2hs
-- It mimics the real Haskell prelude, so agda2hs doesn't compile
-- the agda2hs prelude to Haskell code but uses the Haskell prelude directly
open import Haskell.Prelude
  hiding (List; concat; length; map; concatMap)
open import Agda.Builtin.Equality


-- {-# FOREIGN AGDA2HS #-} blocks allow you to write Haskell code directly
-- Here, we hide concat & length from the Prelude
{-# FOREIGN AGDA2HS
import Prelude hiding (concat, length, map, concatMap)
#-}


data List (a : Set) : Set where
  Nil  : List a
  Cons : a → List a → List a

-- You can specify which definitions are compiled to Haskell
-- with a {-# COMPILE AGDA2HS #-} directive
{-# COMPILE AGDA2HS List deriving (Show, Eq) #-}
-- ^ Here we specify which Haskell instances should be derived

map : ∀ {a b : Set} → (a → b) → List a → List b
map f Nil = Nil
map f (Cons x xs) = Cons (f x) (map f xs)
{-# COMPILE AGDA2HS map #-}

length : ∀ {a} → List a → Nat
length Nil = 0
length (Cons x xs) = 1 + length xs
{-# COMPILE AGDA2HS length #-}

concat : ∀ {a} → List a → List a → List a
concat Nil ys = ys
concat (Cons x xs) ys = Cons x (concat xs ys)
{-# COMPILE AGDA2HS concat #-}

concatMap : ∀ {a b : Set} ⦃ MB : Monoid b ⦄ → (a → b) → List a → b
concatMap f Nil = mempty
concatMap f (Cons x xs) = f x <> concatMap f xs
{-# COMPILE AGDA2HS concatMap #-}



-- TYPECLASS INSTANCES

-- Every record instance will be exported as a typeclass instance
instance
  listFunctor : Functor List
  listFunctor .fmap = map
{-# COMPILE AGDA2HS listFunctor #-}

instance
  listFoldable : Foldable List
  listFoldable .foldMap f Nil = mempty
  listFoldable .foldMap f (Cons x xs) = f x <> foldMap f xs
{-# COMPILE AGDA2HS listFoldable #-}

instance
  listSemigroup : ∀ {a} → Semigroup (List a)
  listSemigroup ._<>_ = concat
{-# COMPILE AGDA2HS listSemigroup #-}

{-

instance
  listMonoid : ∀ {a} → Monoid (List a)
  listMonoid {a} .mempty = Nil
{-# COMPILE AGDA2HS listMonoid #-}

instance
  listApplicative : Applicative List
  listApplicative .pure x = Cons x Nil
  listApplicative ._<*>_ fs xs = concatMap (λ f → map f xs) fs
{-# COMPILE AGDA2HS listApplicative  #-}

instance
  listMonad : Monad List
  listMonad ._>>=_ x f = concatMap f x
{-# COMPILE AGDA2HS listMonad #-}

-}


-- PROVING PROPERTIES

concat-length : ∀ {a} (xs ys : List a)
              → length (concat xs ys) ≡ length xs + length ys 
concat-length Nil ys = refl
concat-length (Cons x xs) ys rewrite concat-length xs ys = refl

-- Notice how we do not export properties to Haskell
-- We only care about proofs on the Agda side
