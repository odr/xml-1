{-# LANGUAGE TemplateHaskell #-}

module Main (main) where

import           Criterion.Main
import           Criterion.Types
import qualified Data.ByteString
import qualified Data.ByteString.Lazy
import           Data.Default
import           Data.FileEmbed
import qualified Text.XML
import qualified Text.XML.Hexml
import qualified Xeno.DOM

main :: IO ()
main = defaultMainWith
  defaultConfig { csvFile = Just "out.csv" }
  [ bgroup "dom" (dom inputBs)
  ]

dom :: Data.ByteString.ByteString -> [Benchmark]
dom bs =
  [ bench "hexml" $ whnf
    ( \input -> case Text.XML.Hexml.parse input of
        Left _  -> error "Unexpected parse error"
        Right v -> v )
    bs
  , bench "xeno" $ nf
    ( \input -> case Xeno.DOM.parse input of
        Left _  -> error "Unexpected parse error"
        Right v -> v )
    bs
  , bench "xml-conduit" $ nf
    ( \input -> Text.XML.parseLBS_ def input )
    ( Data.ByteString.Lazy.fromStrict bs )
  ]

inputBs :: Data.ByteString.ByteString
inputBs = $(embedFile "in.xml")
