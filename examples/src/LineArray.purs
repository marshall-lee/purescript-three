module Examples.LineArray where

import           Prelude
import           Control.Monad
import           Control.Monad.Eff
import           Control.Monad.Eff.Console
import           Control.Monad.Eff.Ref
import           Data.Array
import           DOM
import qualified Graphics.Three.Camera      as Camera
import qualified Graphics.Three.Geometry    as Geometry
import qualified Graphics.Three.Material    as Material
import qualified Graphics.Three.Renderer    as Renderer
import qualified Graphics.Three.Scene       as Scene
import qualified Graphics.Three.Object3D    as Object3D
import           Graphics.Three.Math.Vector
import           Graphics.Three.Types
import qualified Data.Int                   as Int
import qualified Math           as Math

import Examples.Common

lineProps = {
          cols   : 30
        , rows   : 10
        , padCol : 10.0
        , padRow : 10.0
        , radius : 20.0 -- influence radius
    }

initUniforms = {
        amount: {
             "type" : "f"
            , value : 0.0
        }
    }

vertexShader :: String
vertexShader = """
    #ifdef GL_ES
    precision highp float;
    #endif

    void main() {
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
"""

fragmentShader :: String 
fragmentShader = """
    #ifdef GL_ES
    precision highp float;
    #endif

    void main() {
        gl_FragColor = vec4(1.0,0.0,0.0,1.0);
    }
"""

v3 = createVec3

render :: forall eff. Ref StateRef ->
                          Context ->
                          Array Object3D.Line ->
                          Eff (trace :: CONSOLE, ref :: REF, three :: Three | eff) Unit
render state context lines = do
    modifyRef state $ \(StateRef s) -> stateRef (s.frame + 1.0) s.pos s.prev
    s'@(StateRef s) <- readRef state

    renderContext context


createLine :: forall a eff. (Material.Material a) => Dimensions -> 
                                                    Scene.Scene -> 
                                                    a -> 
                                                    Number -> 
                                                    Number -> 
                                                    Array Object3D.Line ->
                                                    Pos -> 
                                                    Eff (three :: Three | eff) (Array Object3D.Line)
createLine dims scene mat colWidth rowHeight acc (Pos p) = do
    let x =  (p.x + lineProps.padCol/2.0) - (dims.width/2.0)
        y = -(p.y + lineProps.padCol/2.0) + (dims.height/2.0)
    
    geometry <- Geometry.create [v3 0.0 (h/2.0) 0.0, v3 0.0 (-h/2.0) 0.0]
    line     <- Object3D.createLine geometry mat Object3D.LineStrip

    Object3D.setPosition line x y 0.0
    Scene.addObject scene line

    return $ line:acc
    where
        w = colWidth  - lineProps.padCol
        h = rowHeight - lineProps.padRow

createLineList :: forall a eff. (Material.Material a) => Scene.Scene -> a -> Eff (dom :: DOM, three :: Three | eff) (Array Object3D.Line)
createLineList scene mat = do
    canvas <- getElementsByTagName "canvas"
    dims   <- nodeDimensions canvas
    
    let colWidth  = dims.width  / (Int.toNumber lineProps.cols)
        rowHeight = dims.height / (Int.toNumber lineProps.rows)
        
    let l = gridList lineProps.cols lineProps.rows $ 
            \i j -> pos (Math.floor ((Int.toNumber i) *colWidth )) (Math.floor ((Int.toNumber j) * rowHeight))
            
    foldM (createLine dims scene mat colWidth rowHeight) [] l


main = do
    ctx@(Context c) <- initContext Camera.Orthographic
    state           <- newRef initStateRef
    material        <- Material.createLineBasic { color: "red", linewidth: 10 }

    lineList <- createLineList c.scene material

    doAnimation $ render state ctx lineList


