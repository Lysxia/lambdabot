{-# OPTIONS -cpp #-}
-- 
-- Implement a Posix.popen compatibility mapping.
--
-- TODO win32 pre-6.4 support.
--

module PosixCompat (popen) where

#if __GLASGOW_HASKELL__ >= 604
import System.IO
import System.Process
#else
import qualified Posix as P
#endif

#if __GLASGOW_HASKELL__ >= 604

type ProcessID = ProcessHandle

popen :: FilePath -> [String] -> Maybe String -> IO (String,String,ProcessID)
popen file args minput = do
       
    (inp,out,err,pid) <- runInteractiveProcess file args Nothing Nothing

    case minput of
        Just input -> hPutStr inp input >> hClose inp -- importante!
        Nothing    -> return ()

    waitForProcess pid -- blocks without -threaded. you're warned.

    output <- hGetContents out
    errput <- hGetContents err
    return (output,errput,pid)

#else

popen :: FilePath -> [String] -> Maybe String -> IO (String,String,P.ProcessID)
popen = P.popen

#endif
