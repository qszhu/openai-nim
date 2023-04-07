import std/[
  math,
  sequtils,
]


type Embeddings* = seq[float]

proc dot(a, b: Embeddings): float {.inline.} =
  a.zip(b).mapIt(it[0] * it[1]).sum

proc len2(a: Embeddings): float {.inline.} =
  a.mapIt(it * it).sum.sqrt

proc distances_from_embeddings*(a, b: Embeddings): float {.inline.} =
  a.dot(b) / a.len2 / b.len2
