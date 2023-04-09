import std/[
  asyncdispatch,
  httpclient,
  json,
  options,
  strformat,
  tables,
  uri,
]



const HOST = parseUri("https://api.openai.com/v1")

type
  OpenAi* = ref object
    apiKey, organization, user: string
    proxy: Proxy

proc newOpenAi*(apiKey: string, organization = "", user = "", proxy: Proxy = nil): OpenAi =
  result.new
  result.apiKey = apiKey
  result.organization = organization
  result.user = user
  result.proxy = proxy

proc newClient(self: OpenAi): AsyncHttpClient =
  result = newAsyncHttpClient(proxy = self.proxy)
  result.headers = newHttpHeaders({
    "Content-Type": "application/json",
    "Authorization": &"Bearer {self.apiKey}",
    "OpenAI-Organization": self.organization,
  })

# Models

proc listModels*(self: OpenAi): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "models"
  let resp = await client.request(url)
  result = (await resp.body).parseJson

proc retrieveModel*(self: OpenAi, model: string): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "models" / model
  let resp = await client.request(url)
  result = (await resp.body).parseJson

# Completions

proc createCompletion*(self: OpenAi, model: string,
  prompt: string = "<|endoftext|>", # TODO: seq[string], seq[token], seq[seq[token]]
  suffix: Option[string] = none(string),
  max_tokens: int = 16,
  temperature: float = 1,
  top_p: float = 1,
  n: int = 1,
  stream: bool = false,
  logprobs: Option[int] = none(int),
  `echo`: bool = false,
  stop: Option[string] = none(string), # TODO: seq[string]
  presence_penalty: float = 0,
  frequency_penalty: float = 0,
  best_of: int = 1,
  logit_bias: Table[string, float] = initTable[string, float](),
  user: string = self.user,
): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "completions"

  var body = %*{
    "model": model,
    "prompt": prompt,
    "suffix": suffix,
    "max_tokens": max_tokens,
    "temperature": temperature,
    "top_p": top_p,
    "n": n,
    "stream": stream,
    "logprobs": logprobs,
    "echo": `echo`,
    "stop": stop,
    "presence_penalty": presence_penalty,
    "frequency_penalty": frequency_penalty,
    "best_of": best_of,
    "logit_bias": logit_bias,
    "user": user,
  }

  let resp = await client.request(url, HttpPost, $body)
  result = (await resp.body).parseJson

# Chat

type
  ChatRole* {.pure.} = enum
    System = "system"
    User = "user"
    Assistant = "assistant"

  ChatMessage* = object
    role*: ChatRole
    content*: string

proc createChatCompletion*(self: OpenAi, model: string, messages: seq[ChatMessage],
  temperature: float = 1,
  top_p: float = 1,
  n: int = 1,
  stream: bool = false,
  stop: Option[string] = none(string), # TODO: seq[string]
  max_tokens: Option[int] = none(int),
  presence_penalty: float = 0,
  frequency_penalty: float = 0,
  logit_bias: Table[string, float] = initTable[string, float](),
  user: string = self.user,
): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "chat" / "completions"

  var body = %*{
    "model": model,
    "messages": messages,
    "temperature": temperature,
    "top_p": top_p,
    "n": n,
    "stream": stream,
    "stop": stop,
    "max_tokens": max_tokens,
    "presence_penalty": presence_penalty,
    "frequency_penalty": frequency_penalty,
    "logit_bias": logit_bias,
    "user": user,
  }

  let resp = await client.request(url, HttpPost, $body)
  result = (await resp.body).parseJson

# Edits

proc createEdit*(self: OpenAi, model: string, instruction: string,
  input: string = "",
  n: int = 1,
  temperature: float = 0,
  top_p: float = 1,
): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "edits"

  var body = %*{
    "model": model,
    "input": input,
    "instruction": instruction,
    "n": n,
    "temperature": temperature,
    "top_p": top_p,
  }

  let resp = await client.request(url, HttpPost, $body)
  result = (await resp.body).parseJson

# Images

# proc createImage*(self: OpenAi)

# proc createImageEdit*(self: OpenAi)

# proc createImageVariation(self: OpenAi)

# Embeddings

proc createEmbeddings*(self: OpenAi, model: string, input: string, # TODO: seq[string], seq[seq[string]]
  user: string = self.user
): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "embeddings"

  var body = %*{
    "model": model,
    "input": input,
    "user": user,
  }

  let resp = await client.request(url, HttpPost, $body)
  result = (await resp.body).parseJson

# Audio

# proc createTranscription*(self: OpenAi)

# proc createTranslation*(self: OpenAi)

# Files

proc listFiles*(self: OpenAi): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "files"

  let resp = await client.get(url)
  result = (await resp.body).parseJson

proc uploadFile*(self: OpenAi, fileName: string,
  purpose = "fine-tune",
): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "files"

  var form = newMultipartData()
  form.addFiles({ "file": fileName })
  form["purpose"] = purpose

  let resp = await client.post(url, multipart = form)
  result = (await resp.body).parseJson

proc deleteFile*(self: OpenAi, file_id: string): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "files" / file_id

  let resp = await client.delete(url)
  result = (await resp.body).parseJson

proc retrieveFile*(self: OpenAi, file_id: string): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "files" / file_id

  let resp = await client.get(url)
  result = (await resp.body).parseJson

proc retrieveFileContent*(self: OpenAi, file_id: string): Future[JsonNode] {.async.} =
  var client = self.newClient
  let url = HOST / "files" / file_id / "content"

  let resp = await client.get(url)
  result = (await resp.body).parseJson

# Fine-tunes

# proc createFineTune*(self: OpenAi)

# proc listFineTunes*(self: OpenAi)

# proc retrieveFineTune*(self: OpenAi)

# proc cancelFineTune*(self: OpenAi)

# proc listFineTuneEvents*(self: OpenAi)

# proc deleteFineTuneModel*(self: OpenAi)

# Moderations

# proc createModeration*(self: OpenAi)
