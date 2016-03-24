module Graphics.Three.Math.Color where

import Graphics.Three.Types (ThreeEff)
import Graphics.Three.Util (ffi)

foreign import data Color :: *

create :: Int -> Int -> Int -> ThreeEff Color
create = ffi ["r", "g", "b"]
    "new THREE.Color(r, g, b)"

createFromInt :: Int -> ThreeEff Color
createFromInt = ffi ["hex"]
    "new THREE.Color(hex)"

createFromString :: String -> ThreeEff Color
createFromString = ffi ["str"]
    "new THREE.Color(str)"
