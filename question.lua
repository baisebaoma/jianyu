local Question = {}
-- randomseed 已经在主程序里被设定，我们无需设定
-- TODO：换一个占用空间更小的方式来存储题目及答案，目前有点太大了
Question.question_set = require "packages/jianyu/questions/init"

-- 随机返回一个问题
---@return any[] @ 返回一个列表，其中第一个是问题String，第二个是答案列表，第三个是正确答案String
Question.getRandomQuestion = function()
  local paper_index = math.random(#Question.question_set)
  local question_index = math.random(#Question.question_set[paper_index])
  local question = Question.question_set[paper_index][question_index]
  return question
end

Question.questionCount = function()
  local count = 0
  for _, i in ipairs(Question.question_set) do
    count = count + #i
  end
  return #Question.question_set, count
end

return Question
