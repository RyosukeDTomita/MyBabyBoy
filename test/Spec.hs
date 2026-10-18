{-# OPTIONS_GHC -Wunused-imports #-}

import Month0 hiding (describe)
import Month0 qualified
import Test.Hspec

baby :: Baby
baby = case mkName "Taro" of
  Just n -> newBaby n
  Nothing -> error "テスト用の名前が不正"

main :: IO ()
main = hspec $ do
  describe "mkName" $ do
    it "空の名前は作れない" $
      mkName "" `shouldBe` Nothing

    it "空でない名前は作れる" $
      fmap unName (mkName "Taro") `shouldBe` Just "Taro"

  describe "cry" $ do
    it "泣いている状態になる" $
      behaviorOf (cry baby) `shouldBe` Crying

  describe "elapse" $ do
    it "交換から150分たつとおむつが濡れる" $
      diaperCheck (elapse (Minutes 150) baby) `shouldBe` Wet

    it "150分未満ならおむつはきれいなまま" $
      diaperCheck (elapse (Minutes 149) baby) `shouldBe` Clean

  describe "changeDiaper" $ do
    it "濡れたおむつがきれいになる" $
      diaperCheck (changeDiaper $ elapse (Minutes 150) baby) `shouldBe` Clean

    it "交換すると経過時間がリセットされる" $
      diaperCheck (elapse (Minutes 1) $ changeDiaper $ elapse (Minutes 150) baby) `shouldBe` Clean

  describe "walk" $ do
    it "お散歩すると泣き止む" $
      behaviorOf (walk $ cry baby) `shouldBe` CalmAwake

  describe "putToSleep" $ do
    it "泣いていても寝かしつけると寝る" $
      behaviorOf (putToSleep $ cry baby) `shouldBe` Sleeping

  describe "hold" $ do
    it "乱数が確率を下回ると抱っこがうまくいって泣き止む" $
      behaviorOf (hold 0.1 $ cry baby) `shouldBe` CalmAwake

    it "乱数が確率以上だと抱っこに失敗して泣く" $
      behaviorOf (hold 0.9 baby) `shouldBe` Crying

  describe "takeBath" $ do
    it "乱数が確率を下回ると泣く" $
      behaviorOf (takeBath 0.1 baby) `shouldBe` Crying

    it "乱数が確率以上なら泣かない" $
      behaviorOf (takeBath 0.9 baby) `shouldBe` Sleeping

    it "おむつがリセットされる" $
      diaperCheck (takeBath 0.9 $ elapse (Minutes 150) baby) `shouldBe` Clean

    it "風呂のあとは経過時間もリセットされる" $
      diaperCheck (elapse (Minutes 1) $ takeBath 0.9 $ elapse (Minutes 150) baby) `shouldBe` Clean

