import std/[
  asyncdispatch,
  httpclient,
  json,
  logging,
  os,
]

import dotenv
load()


import ../src/openai
import ../src/openai/preset


proc main() {.async.} =
  let proxy = newProxy("http://127.0.0.1:8888")
  let openai = newOpenAi(
    apiKey = getEnv("OPENAI_API_KEY"),
    organization = getEnv("OPENAI_ORG", ""),
    user = getEnv("OPENAI_USER", ""),
    proxy = proxy
  )

  # echo (await openai.listModels).pretty

  # echo (await openai.retrieveModel("text-davinci-003")).pretty

  # echo (await openai.createCompletion(
  #   model = "text-davinci-003",
  #   prompt = "Say this is a test",
  #   max_tokens = 7,
  #   temperature = 0,
  # )).pretty

  # echo (await openai.createChatCompletion(
  #   model = "gpt-3.5-turbo",
  #   messages = @[ChatMessage(role: User, content: "Hello!")]
  # )).pretty

  # echo (await openai.createEdit(
  #   model = "text-davinci-edit-001",
  #   input = "What day of the wek is it?",
  #   instruction = "Fix the spelling mistakes",
  # )).pretty

  # echo (await openai.createEmbeddings(
  #   model = "text-embedding-ada-002",
  #   input = "The food was delicious and the waiter...",
  # )).pretty

  # addHandler(newConsoleLogger(levelThreshold = lvlDebug))

  # let res = await openai.translate("Hello!", "english", "french")
  # echo res

  # let res = await openai.embeddings("The food was delicious and the waiter...")
  # echo res.len

  # var session = newChatSession(@[
  #   "Who won the world series in 2020?",
  #   "The Los Angeles Dodgers won the World Series in 2020."
  # ])
  # while true:
  #   stdout.write "input> "
  #   let question = stdin.readLine
  #   if question.len == 0: break

  #   let res = await openai.userInput(session, question)
  #   echo res
  #   echo ""

  # echo (await openai.uploadFile("finetune.json")).pretty

  echo (await openai.listFiles).pretty

  # echo (await openai.retrieveFile("file-alPRPxuqLkFWXsusD2OoqKWB")).pretty

  # echo (await openai.retrieveFileContent("file-alPRPxuqLkFWXsusD2OoqKWB")).pretty

  # echo (await openai.deleteFile("file-alPRPxuqLkFWXsusD2OoqKWB")).pretty

when isMainModule:
  waitFor main()
