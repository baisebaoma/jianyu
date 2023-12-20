local Question = require 'packages/jianyu/_base'

-- 把randomseed定在这里，不用放到函数里去，反正有一个种子就够了，不用每次都换新的种子。
math.randomseed(os.time())

Question.question_set = require "packages/jianyu/questions/init"

-- 随机返回一个问题
---@return any[] @ 返回一个列表，其中第一个是问题String，第二个是答案列表，第三个是正确答案String
Question.getRandomQuestion = function()
  local paper_index = math.random(#Question.question_set)
  local question_index = math.random(#Question.question_set[paper_index])
  local question = Question.question_set[paper_index][question_index]
  return question
end

return Question
