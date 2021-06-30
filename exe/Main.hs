{-# LANGUAGE TypeApplications #-}
module Main where

import           Data.Aeson (decode, Value)
import           Data.Aeson.Encode.Pretty (encodePretty)
import qualified Data.ByteString.Lazy.Char8 as B8
import           Postgres.Query.Parse (parseSQL, parse_tree)
import           System.Environment (getArgs)

main :: IO ()
main = do
  bytes <- B8.pack . parse_tree <$> parseSQL "select 1"
  case decode @Value bytes of
    Just val -> B8.putStrLn (encodePretty val)
    _ -> pure ()
