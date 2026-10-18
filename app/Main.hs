{-# LANGUAGE DataKinds #-}
{-# OPTIONS_GHC -Wunused-imports #-}

module Main (main) where

import Control.Monad.IO.Class (liftIO)
import Month0
import Options.Declarative

-- | `-n` / `--name` で名前を受け取り、赤ん坊を誕生させる
birth ::
  Flag "n" '["name"] "String" "baby name" (Def "Sin" String) ->
  Cmd "Baby Functional Domain Modeling" ()
birth babyName = liftIO $ do
  -- liftIOはIOのアクションを他のモナドの中で実行できるようにする持ち上げ
  let b0 = newBaby $ get babyName
      b1 = cry b0
  putStrLn $ get babyName ++ " is born!"
  putStrLn $ describe b0
  putStrLn $ describe b1

main :: IO ()
main = run_ birth
