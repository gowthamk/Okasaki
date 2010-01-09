{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses #-}

module Ex03_09 (module Set, RedBlackSet(..), Color(..),
                toSortedList, color, countRedBlack, 
                printSet, printCharSet,
                fromOrdList) where

import Set


data Color = R | B
           deriving (Eq, Show)

data RedBlackSet a = E
                   | T Color (RedBlackSet a) a (RedBlackSet a)
                   deriving (Eq, Show)


balance B (T R (T R a x b) y c) z d = T R (T B a x b) y (T B c z d)
balance B (T R a x (T R b y c)) z d = T R (T B a x b) y (T B c z d)
balance B a x (T R (T R b y c) z d) = T R (T B a x b) y (T B c z d)
balance B a x (T R b y (T R c z d)) = T R (T B a x b) y (T B c z d)
balance color a x b = T color a x b


instance Ord a => Set RedBlackSet a where
  emptySet = E
  
  memberSet x E = False
  memberSet x (T _ a y b) =
    if x < y then memberSet x a
    else if x > y then memberSet x b
         else True
  
  insertSet x s = T B a y b
    where ins E = T R E x E
          ins s@(T color a y b) =
            if x < y then balance color (ins a) y b
            else if x > y then balance color a y (ins b)
                 else s
          T _ a y b = ins s  -- guaranteed to be non-empty


toSortedList :: Ord a => RedBlackSet a -> [a]
toSortedList E = []
toSortedList (T _ a x b) = (toSortedList a) ++ (x : toSortedList b)


-- Ex 3.9
fromOrdList :: Ord a => [a] -> RedBlackSet a
fromOrdList [] = E
fromOrdList xs = let T _ a x b = fromOrdList' False B xs
                 in T B a x b
  where fromOrdList' _     c []  = E
        fromOrdList' True  c [x] = T c E x E
        fromOrdList' False _ [x] = T R E x E
        fromOrdList' known c xs  = let (a, rest) = splitAt (length xs `div` 2) xs
                                       (x, b) = (head rest, tail rest)
                                       sa = fromOrdList' known (inverseColor c) a
                                       ca = color sa
                                   in T (inverseColor ca) sa x (fromOrdList' True ca b)

                                   --     sa = fromOrdList' known ca a
                                   --     cx = if known then c 
                                   --          else (inverseColor $ color sa)
                                   --     cb = if known then ca else color sa
                                   -- in T cx sa x (fromOrdList' True cb b)

inverseColor c = if c == B then R else B


-- Helpers
color E = B
color (T c _ _ _) = c

countRedBlack E = (0, 0)
countRedBlack (T c t1 _ t2) = let (r1, b1) = countRedBlack t1
                                  (r2, b2) = countRedBlack t2
                                  (r,  b)  = if c == R then (1, 0) else (0, 1)
                              in (r + r1 + r2, b + b1 + b2)


printSet :: Ord a => (a -> String) -> RedBlackSet a -> IO ()
printSet showF = printSet' 0
  where printSet' _ E = return ()
        printSet' n (T c a x b) = do printSet' (n+1) a
                                     putStrLn $ (replicate (1*n) ' ') ++ showF x ++
                                                (if c == R then "!" else "")
                                     printSet' (n+1) b

printCharSet = printSet (:[])
