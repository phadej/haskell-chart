-----------------------------------------------------------------------------
-- |
-- Module      :  Graphics.Rendering.Chart.Plot.Points
-- Copyright   :  (c) Tim Docker 2006
-- License     :  BSD-style (see chart/COPYRIGHT)
--
-- Functions to plot sets of points, marked in various styles.

{-# OPTIONS_GHC -XTemplateHaskell #-}

module Graphics.Rendering.Chart.Plot.Points(
    PlotPoints(..),
    defaultPlotPoints,

    -- * Accessors
    -- | These accessors are generated by template haskell

    plot_points_title,
    plot_points_style,
    plot_points_values,
) where

import Data.Accessor.Template
import qualified Graphics.Rendering.Cairo as C
import Graphics.Rendering.Chart.Types
import Graphics.Rendering.Chart.Renderable
import Graphics.Rendering.Chart.Plot.Types
import Data.Colour (opaque)
import Data.Colour.Names (black, blue)

-- | Value defining a series of datapoints, and a style in
--   which to render them.
data PlotPoints x y = PlotPoints {
    plot_points_title_  :: String,
    plot_points_style_  :: CairoPointStyle,
    plot_points_values_ :: [(x,y)]
}

instance ToPlot PlotPoints where
    toPlot p = Plot {
        plot_render_     = renderPlotPoints p,
        plot_legend_     = [(plot_points_title_ p, renderPlotLegendPoints p)],
        plot_all_points_ = (map fst pts, map snd pts)
    }
      where
        pts = plot_points_values_ p

renderPlotPoints :: PlotPoints x y -> PointMapFn x y -> CRender ()
renderPlotPoints p pmap = preserveCState $ do
    mapM_ (drawPoint.pmap') (plot_points_values_ p)
  where
    pmap' = mapXY pmap
    (CairoPointStyle drawPoint) = (plot_points_style_ p)

renderPlotLegendPoints :: PlotPoints x y -> Rect -> CRender ()
renderPlotLegendPoints p r@(Rect p1 p2) = preserveCState $ do
    drawPoint (Point (p_x p1)              ((p_y p1 + p_y p2)/2))
    drawPoint (Point ((p_x p1 + p_x p2)/2) ((p_y p1 + p_y p2)/2))
    drawPoint (Point (p_x p2)              ((p_y p1 + p_y p2)/2))

  where
    (CairoPointStyle drawPoint) = (plot_points_style_ p)

defaultPlotPoints :: PlotPoints x y
defaultPlotPoints = PlotPoints {
    plot_points_title_  = "",
    plot_points_style_  = defaultPointStyle,
    plot_points_values_ = []
}

----------------------------------------------------------------------
-- Template haskell to derive an instance of Data.Accessor.Accessor
-- for each field.

$( deriveAccessors ''PlotPoints )
