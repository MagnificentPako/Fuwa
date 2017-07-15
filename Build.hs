import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util

main :: IO ()
main = shakeArgs shakeOptions{shakeFiles="_build"} $ do
    want ["dist/main.lua"]

    phony "clean" $ do
        putNormal "Cleaning files in dist"
        removeFilesAfter "dist" ["//*"]

    "dist//*.lua" %>  \out -> do
        let src = "src" </> (dropDirectory1 $ out -<.> "lisp")
        need [src]
        cmd "lua" "/home/paul/doc/bin/urn/bin/urn.lua" src "-o" (out -<.> "") "-i" "lib" "--emit-lua"