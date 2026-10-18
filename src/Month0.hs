{-# OPTIONS_GHC -Wunused-imports #-}

-- 赤ん坊の内部状態は外部から観察できない!
module Month0
  ( Behavior (..),
    Diaper (..),
    Name, -- コンストラクタは隠し、mkNameからだけ作らせる
    mkName,
    unName,
    Minutes (..),
    addMinutes,
    Baby, -- (..)を外してコンストラクタを隠す
    newBaby, -- スマートコンストラクタを使って生まれる
    behaviorOf,
    elapse,
    diaperCheck,
    cry,
    milk,
    hold,
    walk,
    putToSleep,
    changeDiaper,
    takeBath,
    describe,
  )
where

-- | 赤ん坊の外から見える振る舞い
data Behavior = Crying | Sleeping | CalmAwake deriving (Show, Eq)

-- | おむつの状態
data Diaper = Wet | Clean deriving (Show, Eq)

newtype Minutes = Minutes Int deriving (Show, Eq, Ord)

newtype Name = Name String deriving (Show, Eq)

-- | 空の名前を作れなくする
mkName :: String -> Maybe Name
mkName "" = Nothing
mkName s = Just $ Name s

-- | 名前を文字列として取り出す
unName :: Name -> String
unName (Name s) = s

-- レコード構文を使うと各フィールドを取り出す関数がフィールドと同名で生成される。
data Baby = Baby
  { name :: Name,
    behavior :: Behavior,
    diaper :: Diaper,
    sinceChange :: Minutes -- おむつを変えてからの経過時間
  }
  deriving (Show, Eq)

-- | 生まれたての赤ん坊。内部状態の初期値はモジュールの外からは決められない。
newBaby :: Name -> Baby
newBaby babyName = Baby {name = babyName, behavior = Sleeping, diaper = Clean, sinceChange = Minutes 0}

-- | 外から見える振る舞い
-- フィールド名をエクスポートするとモジュールの外からレコード更新できてしまうため、読み取り専用の関数を公開する。
behaviorOf :: Baby -> Behavior
behaviorOf baby = behavior baby

-- おむつの交換が必要な時間(m)
wetAfter :: Minutes
wetAfter = Minutes 150

-- | 時間を進めて条件を満たした時におむつを濡らす
elapse :: Minutes -> Baby -> Baby
elapse dt baby
  | diaper baby == Clean && elapsed >= wetAfter = advanced {diaper = Wet}
  | otherwise = advanced
  where
    elapsed = addMinutes (sinceChange baby) dt
    advanced = baby {sinceChange = elapsed}

-- | おむつチェック。おむつの状態を確かめるだけで、赤ん坊の状態は変えない(読み取り専用)
diaperCheck :: Baby -> Diaper
diaperCheck baby = diaper baby

-- | 時間を経過させる
addMinutes :: Minutes -> Minutes -> Minutes
addMinutes (Minutes a) (Minutes b) = Minutes $ a + b

-- | オムツ替え
changeDiaper :: Baby -> Baby
changeDiaper baby = baby {diaper = Clean, sinceChange = Minutes 0}

cry :: Baby -> Baby
cry baby = baby {behavior = Crying}

-- | 一旦腹いっぱいになると一旦ご機嫌にはなる。
milk :: Baby -> Baby
milk baby = baby {behavior = CalmAwake} -- レコード構文の機能

-- | お散歩。外の景色を見ると泣き止む
walk :: Baby -> Baby
walk baby = baby {behavior = CalmAwake}

-- | 寝かしつけ。寝るまで続けるので必ず寝る
putToSleep :: Baby -> Baby
putToSleep baby = baby {behavior = Sleeping}

-- | 抱っこがうまくいく確率
holdSuccessProbability :: Double
holdSuccessProbability = 0.7

-- | 抱っこ。rollは0.0〜1.0の乱数で、確率を下回ればうまくいって泣き止み、失敗すると泣く
-- 抱っこされているかどうかは状態として持たない(抱っこ→床に置く、の順序を守らせる必要をなくすため)。
hold :: Double -> Baby -> Baby
hold roll baby
  | roll < holdSuccessProbability = baby {behavior = CalmAwake}
  | otherwise = baby {behavior = Crying}

-- | 風呂に入ると泣く確率
bathCryProbability :: Double
bathCryProbability = 0.3

-- | 風呂。おむつを外すのでおむつの状態はリセットされ、ある確率で泣く
takeBath :: Double -> Baby -> Baby
takeBath roll baby
  | roll < bathCryProbability = washed {behavior = Crying}
  | otherwise = washed
  where
    washed = baby {diaper = Clean, sinceChange = Minutes 0}

-- | 外から見える振る舞いを文章にする
describe :: Baby -> String
describe baby = case behavior baby of
  Crying -> unName (name baby) <> " is crying!! (T_T)"
  Sleeping -> unName (name baby) <> " is sleeping... (-_-)zzz"
  CalmAwake -> unName (name baby) <> " is seeing something. \\(^,^)/"
