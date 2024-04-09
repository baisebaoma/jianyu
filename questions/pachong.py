"""
这个文件会根据对应的试卷code，去网站上提取它的题目和答案，并处理成可以被简浴包分析的 Lua 文件。
请注意，生成文件后，你需要手动：
1. 添加公式/删除其中含有图片、含有资料的题目；
2. 修改英文冒号为中文冒号；
3. 修改百分号为双百分号；
4. 把所有填入画横线部分的线画出来。
目前的爬虫程序做不到这些。
"""

import requests
from bs4 import BeautifulSoup

code = "1706852967747"

# 获取选择题网页内容
url_questions = f'https://www.gkzenti.cn/paper/{code}'
response_questions = requests.get(url_questions)
html_content_questions = response_questions.text

# 使用BeautifulSoup解析HTML
soup_questions = BeautifulSoup(html_content_questions, 'html.parser')

# 找到所有包含选择题的div元素
questions_divs = soup_questions.find_all('div', class_='row')

# 定义Lua列表
lua_list = []

# 遍历每个问题的div元素
for idx, question_div in enumerate(questions_divs, start=1):
    # 检查是否包含正确的结构
    if question_div.find('div', class_='col-xs-1 left') is None or question_div.find('div', class_='col-xs-11 right') is None:
        continue

    # 获取题干内容，包括多行的情况
    question_text_elements = question_div.find('div', class_='col-xs-11 right').find_all('p')
    question_text = '<br>\n'.join([element.get_text(strip=True) for element in question_text_elements])

    # 寻找所有的选项，包括 <div class="col-xs-3">, <div class="col-xs-6"> 和 <div class="col-xs-12">
    options_divs = question_div.find_all('div', class_=['col-xs-3', 'col-xs-12', 'col-xs-6'])
    options = [option.get_text(strip=True) for option in options_divs]

    # 构建Lua语言中的列表结构
    lua_question = [
        question_text,
        [option for option in options],
        ""  # 此处使用空字符串，因为答案是一个字符串而不是列表
    ]

    lua_list.append(lua_question)

# 获取答案网页内容
url_answers = f'https://www.gkzenti.cn/answer/{code}'
response_answers = requests.get(url_answers)
html_content_answers = response_answers.text

# 使用BeautifulSoup解析HTML
soup_answers = BeautifulSoup(html_content_answers, 'html.parser')

# 找到包含答案的div元素
answers_divs = soup_answers.find_all('div', class_='col-xs-1-5')

# 获取所有答案信息
answers_info = [item.get_text(strip=True) for item in answers_divs]

# 将答案信息添加到相应题目的答案区域
for idx, lua_question in enumerate(lua_list):
    if idx < len(answers_info):
        lua_question[2] = answers_info[idx][-1]  # 只需要它后面的那个选项就行

# 将数据存储到文件中
with open(f'{code}.lua', 'w', encoding='utf-8') as file:
    file.write(f"-- 试卷来源：{url_questions}，答案来源：{url_answers}，\n"
               f"-- 由爬虫自动生成，请手动检查：\n"
               f"-- 1. 添加公式/删除其中含有图片、含有资料的题目；\n"
               f"-- 2. 修改英文冒号为中文冒号；\n"
               f"-- 3. 修改百分号为双百分号；\n"
               f"-- 4. 把所有填入画横线部分的线画出来。\n"
               f"-- 已检查在此打勾：【】\n\n")
    file.write("local questions = {\n")
    for idx, lua_question in enumerate(lua_list, start=1):
        file.write(f"  -- {idx}\n")
        # # 有一些这些题号的题目并不是这些题目
        #
        # if idx in range(71, 81):
        #     file.write(f"  -- 该题已被删除，因为是图形推理题\n")
        #     continue
        #
        # if idx in range(106, 131):
        #     file.write(f"  -- 该题已被删除，因为是资料分析题\n")
        #     continue

        file.write("  {\n")
        for item in lua_question:
            if isinstance(item, list):  # 如果这是一个列表（也就是选项的列表）
                file.write("    {\n")
                for subitem in item:
                    file.write(f'      [[{subitem}]],\n')
                file.write("    },\n")
            else:  # 如果这不是一个列表（也就是要么是题干，要么是正确答案）
                file.write(f'    [[{item}]],\n')
        file.write("  },\n")
    file.write("}\n\nreturn questions\n")
