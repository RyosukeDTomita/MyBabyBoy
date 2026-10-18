{-# LANGUAGE DataKinds #-}
{-# OPTIONS_GHC -Wunused-imports #-}

module Main (main) where

import Control.Monad.IO.Class (liftIO)
import Month0
import Options.Declarative
import System.Random (StdGen, initStdGen, randoms)

-- | `-n` / `--name` で名前を受け取り、赤ん坊を誕生させる
birth ::
  Flag "n" '["name"] "String" "baby name" (Def "Sin" String) ->
  Cmd "Baby Functional Domain Modeling" ()
-- liftIOはIOのアクションを他のモナドの中で実行できるようにする持ち上げ
birth babyName = liftIO $ do
  gen <- initStdGen
  case mkName $ get babyName of
    Nothing -> putStrLn "empty name"
    Just n -> mapM_ putStrLn $ simulateOneDay gen n

-- | 赤ん坊に起きる出来事
data Action = Cry | CheckDiaper | ChangeDiaper | Milk | Hold | Walk | PutToSleep | Bath
  deriving (Show)

-- | 1日の流れ。(前の出来事からの経過時間, 起きたこと)の列
oneDay :: [(Minutes, Action)]
oneDay =
  [ (Minutes 120, Cry),
    (Minutes 5, CheckDiaper),
    (Minutes 0, ChangeDiaper),
    (Minutes 10, Milk),
    (Minutes 5, Hold),
    (Minutes 30, PutToSleep),
    (Minutes 180, Cry),
    (Minutes 5, CheckDiaper),
    (Minutes 0, ChangeDiaper),
    (Minutes 10, Milk),
    (Minutes 5, Hold),
    (Minutes 30, PutToSleep),
    (Minutes 120, Cry),
    (Minutes 5, CheckDiaper),
    (Minutes 0, ChangeDiaper),
    (Minutes 10, Milk),
    (Minutes 5, Hold),
    (Minutes 30, Cry),
    (Minutes 5, Walk),
    (Minutes 60, Hold),
    (Minutes 10, Cry),
    (Minutes 10, CheckDiaper),
    (Minutes 0, ChangeDiaper),
    (Minutes 10, Milk),
    (Minutes 5, CheckDiaper),
    (Minutes 0, ChangeDiaper),
    (Minutes 10, Milk),
    (Minutes 5, Hold),
    (Minutes 30, PutToSleep),
    (Minutes 140, Cry),
    (Minutes 5, CheckDiaper),
    (Minutes 0, ChangeDiaper),
    (Minutes 10, Milk),
    (Minutes 5, Hold),
    (Minutes 180, Cry),
    (Minutes 5, CheckDiaper),
    (Minutes 0, ChangeDiaper),
    (Minutes 10, Milk),
    (Minutes 60, Bath),
    (Minutes 10, Milk),
    (Minutes 10, Cry),
    (Minutes 30, Hold),
    (Minutes 10, PutToSleep)
  ]

-- | 出来事を赤ん坊への操作に変換する。rollは確率で結果が変わる出来事に使う乱数
applyAction :: Double -> Action -> Baby -> Baby
applyAction _ Cry baby = cry baby
applyAction _ CheckDiaper baby = baby -- 確かめるだけなので状態は変わらない
applyAction _ ChangeDiaper baby = changeDiaper baby
applyAction _ Milk baby = milk baby
applyAction roll Hold baby = hold roll baby
applyAction _ Walk baby = walk baby
applyAction _ PutToSleep baby = putToSleep baby
applyAction roll Bath baby = takeBath roll baby

-- | 時間を進めてから出来事を起こす
advance :: (Minutes, Baby) -> (Double, (Minutes, Action)) -> (Minutes, Baby)
advance (clock, baby) (roll, (dt, action)) = (addMinutes clock dt, applyAction roll action $ elapse dt baby)

-- | 赤ん坊が生まれてからの出来事を文章の列にする
-- scanlは各出来事を順に適用し、途中経過の状態をすべて返す。
-- 乱数のジェネレータを引数で受け取るので、この関数自体は純粋関数のまま。
simulateOneDay :: StdGen -> Name -> [String]
simulateOneDay gen n =
  (unName n ++ " is born!")
    : report "Born" start
    : zipWith reportStep oneDay (drop 1 timeline)
  where
    start = (Minutes 0, newBaby n)
    -- 出来事1つにつき乱数を1つ割り当てる(randomsは無限リスト)
    timeline = scanl advance start $ zip (randoms gen) oneDay

-- | 出来事を1行にする。出来事の名前は、出来事のあとの赤ん坊から決める
reportStep :: (Minutes, Action) -> (Minutes, Baby) -> String
reportStep (_, action) (elapsed, baby) = report (actionLabel action baby) (elapsed, baby)

-- | 出来事の表示名。おむつチェックは確かめた結果も表示する
actionLabel :: Action -> Baby -> String
actionLabel CheckDiaper baby = "CheckDiaper(" ++ show (diaperCheck baby) ++ ")"
actionLabel action _ = show action

-- | ある時点の出来事と赤ん坊の様子を1行にする
report :: String -> (Minutes, Baby) -> String
report label (elapsed, baby) =
  "[" ++ formatClock elapsed ++ "] " ++ label ++ ": " ++ describe baby

-- | 0:00からの経過時間を時刻(H:MM)にする。24時間を超えたら0:00に戻る。
formatClock :: Minutes -> String
formatClock (Minutes m) = show hours ++ ":" ++ pad minutes
  where
    (hours, minutes) = (m `mod` (24 * 60)) `divMod` 60
    pad x = if x < 10 then '0' : show x else show x

main :: IO ()
main = run_ birth
