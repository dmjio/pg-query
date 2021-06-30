pg_query
===============================

Haskell bindings to [`libpg_query`](https://github.com/pganalyze/libpg_query)

Access the entire PostgreSQL lexing / parsing phase from Haskell.

Returns PostgreSQL-flavored SQL as an AST in JSON form.

## Installation

Install [`libpg_query`](https://github.com/pganalyze/libpg_query)

```sh
git clone -b 13-latest git://github.com/pganalyze/libpg_query
cd libpg_query
make
sudo make install
```

```sh
git clone https://github.com/dmjio/pg-query
cd pg-query && cabal build
```


## Nix installation

```
nix-build
```

## Usage

```haskell
{-# LANGUAGE TypeApplications #-}
module Main where

import           Data.Aeson (decode)
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
```

## Result

```haskell
{
    "stmts": [
        {
            "stmt": {
                "SelectStmt": {
                    "op": "SETOP_NONE",
                    "targetList": [
                        {
                            "ResTarget": {
                                "location": 7,
                                "val": {
                                    "A_Const": {
                                        "location": 7,
                                        "val": {
                                            "Integer": {
                                                "ival": 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    ],
                    "limitOption": "LIMIT_OPTION_DEFAULT"
                }
            }
        }
    ],
    "version": 130003
}
```
