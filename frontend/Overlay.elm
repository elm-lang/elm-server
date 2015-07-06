module Overlay where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal
import Color

import Styles exposing (..)
import Model
import SideBar.Controls as Controls
import SideBar.Watches as Watches


view : Signal.Address Model.Action -> Model.Model -> Html
view addr state =
  div
    []
    [ sidebar addr showSwap state
    , eventBlocker state.paused
    ]


eventBlocker : Bool -> Html
eventBlocker visible =
  div
    [ id "elm-reactor-event-blocker"
    , style
        [ "position" => "absolute"
        , "top" => "0"
        , "left" => "0"
        , "width" => "100%"
        , "height" => "100%"
        , "display" => if visible then "block" else "none"
        ]
    ]
    []


sidebar : Signal.Address Model.Action -> Model.Model -> Html
sidebar addr state =
  let
    constantStyles =
      [ "background-color" => colorToCss darkGrey
      , "width" => intToPx sidebarWidth
      , "position" => "absolute"
      , "top" => "0"
      , "bottom" => "0"
      , "transition-duration" => "0.3s"
      , "opacity" => "0.97"
      , "z-index" => "1"
      ]
    
    toggleStyles =
      if state.sidebarVisible
      then [ "right" => "0" ]
      else [ "right" => intToPx -sidebarWidth ]

    dividerBar =
      div
        [ style
            [ "height" => "1px"
            , "width" => intToPx sidebarWidth
            , "opacity" => "0.3"
            , "background-color" => colorToCss Color.lightGrey
            ]
        ]
        []
  in
    div
      [ id "elm-reactor-side-bar"
      -- done in JS: cancelBubble / stopPropagation on this
      , style (constantStyles ++ toggleStyles)
      ]
      [ toggleTab state
      , Controls.view addr state
      , dividerBar
      , Watches.view state.watches
      ]


tabWidth = 25

toggleTab : Signal.Address Model.Action -> Model.Model -> Html
toggleTab state =
  div
    [ style
        [ "position" => "absolute"
        , "width" => intToPx tabWidth
        , "height" => "60px"
        , "top" => "50%"
        , "left" => intToPx -tabWidth
        , "border-top-left-radius" => "3px"
        , "border-bottom-left-radius" => "3px"
        , "background" => colorToCss darkGrey
        ]
    , onClick
        sidebarVisibleMailbox.address
        (SidebarVisible <| not state.sidebarVisible)
    ]
    []

sidebarVisibleMailbox : Signal.Mailbox Bool
sidebarVisibleMailbox =
  Signal.mailbox True

-- SIGNALS    

main : Signal Html
main =
  -- TODO: move showSwap to the #@$ model
  Signal.map (view showSwap) scene


scene : Signal Model.Model
scene =
  Signal.foldp Model.update Model.startModel aggregateUpdates


