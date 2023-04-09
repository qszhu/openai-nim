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

  addHandler(newConsoleLogger(levelThreshold = lvlDebug))

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

  # echo (await openai.uploadFile("finetune.jsonl")).pretty

  # let file_id = "file-kxAy89zcGppuL2YHoyhkyoNp"

  # echo (await openai.listFiles).pretty

  # echo (await openai.retrieveFile(file_id)).pretty

  # echo (await openai.retrieveFileContent(file_id)).pretty

  # echo (await openai.deleteFile(file_id)).pretty

  # echo (await openai.createFineTune(file_id)).pretty

  # let fine_tune_id = "ft-skbcfX2OdX30qk0mLTb4GaH5"

  echo (await openai.listFineTunes).pretty

  # echo (await openai.retrieveFineTune(fine_tune_id)).pretty

  # let model = "curie:ft-personal-2023-04-09-14-57-40"

  # echo (await openai.cancelFineTune(fine_tune_id)).pretty

  # echo (await openai.listFineTuneEvents(fine_tune_id)).pretty

  # echo (await openai.deleteFineTuneModel(model)).pretty

  # echo (await openai.createModeration("I want to kill myself.")).pretty

when isMainModule:
  waitFor main()
