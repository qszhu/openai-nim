import std/[
  algorithm,
  asyncdispatch,
  json,
  logging,
  sequtils,
  strformat,
  strutils,
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

  return res["choices"][0]["message"]["content"].getStr # TODO: multiple choices



type Embeddings = seq[float]

proc embeddings*(self: OpenAi, text: string,
  model = "text-embedding-ada-002",
): Future[Embeddings] {.async.} =
  let res = await self.createEmbeddings(
    model = model,
    input = text,
  )
  logging.debug "response: ", res

  return res["data"][0]["embedding"].getElems.mapIt(it.getFloat)



# Chat

type
  ChatSession* = ref object
    systemMessage: string
    messages: seq[string]

proc newChatSession*(examples: seq[string],
  systemMessage: string = "You are a helpful assistant."
): ChatSession =
  doAssert examples.len mod 2 == 0

  result.new
  result.messages = examples
  result.systemMessage = systemMessage

type
  ChatSessionSamples = object
    system: string
    samples: seq[tuple[prompt: string, completion: string]]

proc newChatSession*(jsonFileName: string): ChatSession =
  let css = jsonFileName.readFile.parseJson.to(ChatSessionSamples)
  var samples = newSeq[string]()
  for sample in css.samples:
    samples.add sample.prompt
    samples.add sample.completion
  newChatSession(samples, systemMessage = css.system)

proc getPrompt(self: ChatSession): seq[ChatMessage] =
  # TODO: limit number of tokens
  result = newSeq[ChatMessage]()
  result.add ChatMessage(role: System, content: self.systemMessage)
  for i, msg in self.messages:
    let role = if i mod 2 == 0: User else: Assistant
    result.add ChatMessage(role: role, content: msg)

proc userInput*(self: OpenAi, session: ChatSession, content: string,
  model = "gpt-3.5-turbo",
): Future[string] {.async.} =
  session.messages.add content
  let messages = session.getPrompt
  logging.debug "prompt: ", messages

  let res = await self.createChatCompletion(
    model = model,
    messages = session.getPrompt
  )
  logging.debug "response: ", res

  result = res["choices"][0]["message"]["content"].getStr # TODO: multiple choices
  session.messages.add result



# QA

type
  EmbeddingsDB* = ref object of RootObj
  QueryResult* = seq[tuple[text: string, score: float]]

method query*(self: EmbeddingsDB, input: Embeddings, limit = 5): QueryResult {.base.} =
  discard

proc createQAContext(queryResult: QueryResult, maxLen = 1800): string =
  let res = queryResult.sortedByIt(1 - it.score)
  for r in res:
    if result.len + r.text.len > maxLen: break
    result &= r.text

proc answerQuestion*(self: OpenAi, db: EmbeddingsDB, question: string,
  model = "gpt-3.5-turbo",
  promptTmpl = """Answer the question based on the context below, and if the question can't be answered based on the context, say \"I don't know\"\n\nContext: {context}"""
): Future[string] {.async.} =
  let
    questionEmbeddings = await self.embeddings(question)
    queryResult = db.query(questionEmbeddings)
    context = createQAContext(queryResult)
    prompt = promptTmpl.replace("{context}", context)
    messages = @[
      ChatMessage(role: System, content: prompt),
      ChatMessage(role: User, content: question),
    ]
  logging.debug "prompt: ", messages

  let res = await self.createChatCompletion(
    model = model,
    messages = messages
  )
  logging.debug "response: ", res

  result = res["choices"][0]["message"]["content"].getStr # TODO: multiple choices
