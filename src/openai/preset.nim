import std/[
  asyncdispatch,
  json,
  logging,
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
