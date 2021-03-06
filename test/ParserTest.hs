

module ParserTest where

import Syntax
import Lexer
import Parser
import Control.Monad
    
decl1 :: String
decl1 = "id : Π a : U . a → a = λ a . λ x . x;"
    
decl2 :: String
decl2 = "bool : U = Sum (True 1 | False 1);"

decl3 :: String
decl3 = "elimBool : Π c : bool → U . c (False 0) → c (True 0) → Π b : bool . c b\n = λ c . λ h0 . λ h1 . fun (True _ → h1 | False _ → h0);"

decl4 :: String
decl4 = "rec natrec : ∀ c : nat → U . c Zero → (∀ n : nat . c n → c (Succ n)) → ∀ n : nat . c n = λ c . λ a . λ g . fun (Zero → a | Succ n → g n (natrec c a g n));"

decls :: [String]
decls = [decl1, decl2, decl3, decl4]

testParser :: IO ()
testParser = 
    forM_ decls $ \decl -> do
        putStrLn "parse result: "
        either print print $ parseExpr "<test>" decl
    