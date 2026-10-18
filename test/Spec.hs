{-# OPTIONS_GHC -Wunused-imports #-}

import Month0 hiding (describe)
import Month0 qualified
import Test.Hspec

baby :: Baby
baby = (newBaby "Taro") {diaper = Wet}

main :: IO ()
main = hspec $ do
  describe "cry" $ do
    it "泣いている状態になる" $
      behavior (cry baby) `shouldBe` Crying

  describe "changeDiaper" $ do
    it "おむつがきれいになる" $
      diaper (changeDiaper baby) `shouldBe` Clean

  describe "describe" $ do
    it "泣いているときの文章" $
      Month0.describe (cry baby) `shouldBe` "Taro is crying!(T_T)"
