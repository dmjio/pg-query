{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ForeignFunctionInterface  #-}
module Postgres.Query.Parse.Internal where

import Control.Monad
import Foreign
import Foreign.C
import Foreign.Marshal.Utils
import Foreign.Storable

#include "pg_query.h"

instance Storable PgQueryError where
  sizeOf _ = #{size PgQueryError}
  alignment _ = #{alignment PgQueryError}
  peek ptr = do
    message <- getCString =<< peek (#{ptr PgQueryError, message} ptr)
    funcname <- getCString =<< peek (#{ptr PgQueryError, funcname} ptr)
    filename <- getCString =<< peek (#{ptr PgQueryError, filename} ptr)
    lineno <- peek (#{ptr PgQueryError, lineno} ptr)
    cursorpos <- peek (#{ptr PgQueryError, cursorpos} ptr)
    context <- getCString =<< peek (#{ptr PgQueryError, context} ptr)
    pure PgQueryError {..}
  poke _ _ = fail "PgQueryParseResult poke: not implemented"

data PgQueryError = PgQueryError
  { message   ::  !String
  , funcname  ::  !String
  , filename  ::  !String
  , lineno    ::  !Int
  , cursorpos ::  !Int
  , context   ::  !String
  } deriving (Show, Eq)

data PgQueryParseResult = PgQueryParseResult
  { parse_tree    ::  !String
  , stderr_buffer ::  !String
  , error         ::  !(Maybe PgQueryError)
  } deriving (Show, Eq)

instance Storable PgQueryParseResult where
  sizeOf _ = #{size PgQueryParseResult}
  alignment _ = #{alignment PgQueryParseResult}
  peek ptr = do
    parse_tree <- getCString =<< peek (#{ptr PgQueryParseResult, parse_tree} ptr)
    stderr_buffer <- getCString =<< peek (#{ptr PgQueryParseResult, stderr_buffer} ptr)
    errPtr <- peek (#{ptr PgQueryParseResult, error} ptr)
    error <-
      if errPtr == nullPtr
        then pure Nothing
        else Just <$> peek errPtr
    pure PgQueryParseResult {..}
  poke _ _ = fail "PgQueryParseResult poke: not implemented"

getCString :: CString -> IO String
getCString ptr | nullPtr == ptr = pure mempty
               | otherwise = peekCString ptr

foreign import ccall "get_sql" get_sql :: CString -> IO (Ptr PgQueryParseResult)

foreign import ccall "free_sql" free_sql :: Ptr PgQueryParseResult -> IO ()

parseSQL :: String -> IO PgQueryParseResult
parseSQL sql =
  withCString sql $ \inp -> do
    ptr <- get_sql inp
    result <- peek ptr
    free_sql ptr
    pure result
