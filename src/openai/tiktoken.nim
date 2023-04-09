import std/[
  os,
]

import dotenv
load()

import nimpy / py_lib
pyInitLibPath(getEnv("LIBPYTHON_PATH"))

import nimpy
discard pyImport("sys").path.append(getEnv("PYTHON_LIB"))

let py = pyBuiltinsModule()
let tiktoken = pyImport("tiktoken")

proc numTokens*(text: string, encoding = "cl100k_base"): int =
  let encoding = tiktoken.get_encoding(encoding)
  py.len(encoding.encode(text)).to(int)
