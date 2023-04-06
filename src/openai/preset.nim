import std/[
  asyncdispatch,
  json,
  logging,
  sequtils,
  strformat,
  unicode,
]

import ../openai



proc translate*(self: OpenAi, text, fromLang, toLang: string,
  model = "gpt-3.5-turbo",
): Future[string] {.async.} =
  let prompt = &"Translate the following {fromLang.title} text to {toLang.title}: \"{text}\""
  logging.debug "prompt: ", prompt

  let res = await self.createChatCompletion(
    model = model,
    messages = @[ChatMessage(role: User, content: prompt)]
  )
  logging.debug "response: ", res

  return res["choices"][0]["message"]["content"].getStr

proc embeddings*(self: OpenAi, text: string,
  model = "text-embedding-ada-002",
): Future[seq[float]] {.async.} =
  let res = await self.createEmbeddings(
    model = model,
    input = text,
  )
  logging.debug "response: ", res

  return res["data"][0]["embedding"].getElems.mapIt(it.getFloat)
