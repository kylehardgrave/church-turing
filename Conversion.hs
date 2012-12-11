module Conversion where

import Data.Map (Map)
import Data.List (intersperse)
import Church
import Turing
import LCs
import TMs


-- | Given a LC term and a term to apply it to, convert them into a TM
-- and tape to run it on, respectively.
lcToTM :: Term -> Tape
lcToTM = tapeFromList . (intersperse ' ') . lcToTM' where
  lcToTM' (Var n)     = varToTape n
  lcToTM' (Lam n t)   = "\\" ++ (varToTape n) ++ lcToTM' t
  lcToTM' (App t1 t2) = "[" ++ (lcToTM' t1) ++ "][" ++ (lcToTM' t2) ++ "]"


-- | Covert a variable to a string printable on a TM tape.
varToTape :: Name -> String
varToTape n = varMap' n allNames where
  varMap' n (n0:ns) | n == n0   = "x"
                    | otherwise = '\'' : (varMap' n ns)

fun :: (TMState, Alphabet) -> (TMState, Alphabet, Dir)
fun (s, w) = case (s, w) of
  (nf, x')  -> (nf,  x', R) -- Var -> do nothing
  (nf, x)   -> (e,   x,  R)
  
  (nf,  l)  -> (lam, l,  R) -- Lam: reduce term
  (lam, x') -> (lam, x', R)
  (lam, x)  -> (nf,  x,  R)
  
  (nf,  bl) -> (wnf, h,  R) -- Do whnf

  (wnf, lb) -> (wnf, a,  R) -- Do whnf
  (wnf, _)  -> (ret, _,  L) -- Not an app - leave wnf
--  (ret -- Return from WNF
   -- TODO: Figure out how to leave "function call"

  where
    nf = 0
    lam = 2
    e = 3
    x = 'x'
    x' = '\''
    bl = '['
    br = ']'
    l = '\\'
    h = '#'
    a = '&'
