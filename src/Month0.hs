{-# OPTIONS_GHC -Wunused-imports #-}

-- 赤ん坊の内部状態は外部から観察できない!
module Month0
  ( Behavior (..),
    Diaper (..),
    Name,
    Minutes (..),
    Baby (..),
    newBaby,
    cry,
    milk,
    hold,
    changeDiaper,
    takeBath,
    describe,
  )
where

-- import Control.Monad.State (State, evalState, state, runState)
-- import GHC.Clock (getMonotonicTime)
-- import System.Random (Random, RandomGen, StdGen, mkStGen, random)

-- | 赤ん坊の外から見える振る舞い
data Behavior = Crying | Sleeping | CalmAwake deriving (Show, Eq)

-- | 不快か、そうでないかしかない。
data InnerStatus = Happy | UnHappy deriving (Show, Eq)

-- | おむつの状態
data Diaper = Wet | Clean | Poo deriving (Show, Eq)

type Name = String

newtype Minutes = Minutes Int deriving (Show, Eq, Ord)

-- randomSt :: (RandomGen g, Random r) => State g r
-- randomSt = state random

-- レコード構文を使うと各フィールドを取り出す関数がフィールドと同名で生成される。
data Baby = Baby
  { name :: Name,
    behavior :: Behavior,
    innerStatus :: InnerStatus,
    diaper :: Diaper
  }
  deriving (Show, Eq)

-- | 生まれたての赤ん坊。内部状態の初期値はモジュールの外からは決められない。
newBaby :: Name -> Baby
newBaby babyName = Baby {name = babyName, behavior = Sleeping, innerStatus = Happy, diaper = Clean}

cry :: Baby -> Baby
cry baby = baby {behavior = Crying}

-- | 一旦腹いっぱいになると一旦ご機嫌にはなる。
milk :: Baby -> Baby
milk baby = baby {behavior = CalmAwake, innerStatus = Happy} -- レコード構文の機能

-- | 抱っこ
hold :: Baby -> Baby
hold baby = baby {innerStatus = Happy}

-- | オムツ替え
changeDiaper :: Baby -> Baby
changeDiaper baby = baby {diaper = Clean}

diaperCheck ::

-- | 風呂
takeBath :: Baby -> Baby
takeBath baby = baby {behavior = Sleeping}

-- | 外から見える振る舞いを文章にする
describe :: Baby -> String
describe baby = case behavior baby of
  Crying -> name baby <> " is crying!(T_T)"
  Sleeping -> name baby <> " is sleeping(-_-)zzz"
  CalmAwake -> name baby <> " is seeing something \\(^,^)/"
