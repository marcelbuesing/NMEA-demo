module Main where

import Control.Monad.Trans.Resource
import Data.Attoparsec.ByteString
import Data.Conduit as C
import Data.Conduit.Binary as CB
import Data.Monoid ((<>))
import qualified Data.Conduit.List as CL
import qualified Data.ByteString.Char8 as B
import NMEA.Sentence
import System.Hardware.Serialport
import System.IO

port :: String
port = "/dev/ttyUSB0"  -- Linux

serialHandle :: IO Handle
serialHandle = do
      h <- hOpenSerial port defaultSerialSettings { commSpeed = CS4800 }
      _ <- hSetBuffering h LineBuffering
      return h

main :: IO ()
main = do
  runResourceT $
    sourceIOHandle serialHandle
    =$= CB.lines
    =$= (CL.map (\x ->  (,) x (parseOnly (sentence 2000) x)))
    =$= CL.map (B.pack . (<> "\n"). show)
    $$ sinkHandle stdout
  main
