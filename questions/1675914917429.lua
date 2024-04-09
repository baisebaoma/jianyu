-- 试卷来源：https://www.gkzenti.cn/paper/1675914917429，答案来源：https://www.gkzenti.cn/answer/1675914917429，
-- 由爬虫自动生成，请手动检查：
-- 1. 添加公式/删除其中含有图片的题目；
-- 2. 修改英文冒号为中文冒号；
-- 3. 修改百分号为双百分号；
-- 4. 把所有填入画横线部分的线画出来。
-- 已检查在此打勾：【v】

local questions = {
  -- 1
  {
    [[党的二十大报告指出，从现在起，中国共产党的中心任务就是团结带领全国各族人民全面建成社会主义现代化强国、实现第二个百年奋斗目标，以中国式现代化全面推进中华民族伟大复兴。下列对中国式现代化的理解，正确的有几项？<br>
①坚持把实现人民对美好生活的向往作为现代化建设的出发点和落脚点<br>
②共同富裕是社会主义的本质要求，是中国式现代化的重要特征<br>
③在物质文明方面超越西方发达国家，是中国式现代化的主要目标<br>
④遵循世界各国现代化的共同模式，是中国式现代化道路的基本经验<br>
⑤中国式现代化新道路，创造了人类文明新形态]],
    {
      [[A、2项]],
      [[B、3项]],
      [[C、4项]],
      [[D、5项]],
    },
    [[B]],
  },
  -- 2
  {
    [[党的二十大报告指出，要发展全过程人民民主，保障人民当家作主。关于人民民主，下列表述正确的是：<br>
①人民民主是社会主义的生命，是全面建设社会主义现代化国家的应有之义<br>
②全过程人民民主是社会主义民主政治的本质属性，是最广泛、最真实、最管用的民主<br>
③协商民主是实践全过程人民民主的重要形式<br>
④党内民主是全过程人民民主的重要体现]],
    {
      [[A、①③④]],
      [[B、①②④]],
      [[C、①②③]],
      [[D、②③④]],
    },
    [[C]],
  },
  -- 3
  {
    [[党的二十大报告指出，要增进民生福祉，提高人民生活品质。下列有关表述正确的是：]],
    {
      [[A、就业是人民生活的安全网和社会运行的稳定器]],
      [[B、人民健康是最基本的民生]],
      [[C、健全的社会保障体系是民族昌盛和国家强盛的重要标志]],
      [[D、分配制度是促进共同富裕的基础性制度]],
    },
    [[D]],
  },
  -- 4
  {
    [[党的二十大报告指出，新时代十年来“党和国家事业取得历史性成就、发生历史性变革”。关于新时代十年来取得的历史性成就，下列表述错误的是：]],
    {
      [[A、谷物总产量稳居世界首位]],
      [[B、制造业规模、外汇储备稳居世界第一]],
      [[C、全社会研发经费支出跃居世界第一]],
      [[D、建成世界最大的高速铁路网]],
    },
    [[C]],
  },
  -- 5
  {
    [[中共中央、国务院印发了《黄河流域生态保护和高质量发展规划纲要》，根据该纲要，下列表述错误的是：]],
    {
      [[A、到2035年黄河流域生态保护和高质量发展取得重大战略成果]],
      [[B、河湟-藏羌文化区是农耕文化与游牧文化交汇相融的过渡地带]],
      [[C、支持青海、甘肃等风能、太阳能丰富地区构建风光水多能互补系统]],
      [[D、水土保持区以内蒙古高原南缘、宁夏中部等为主]],
    },
    [[D]],
  },
  -- 6
  {
    [[下列与金融活动相关的说法错误的是：]],
    {
      [[A、有价证券的债务人可以请求债权人支付相应对价]],
      [[B、开展储蓄业务有助于实现货币购买力和商品供应量的平衡]],
      [[C、分红型商业保险的收益与保险公司的经营状况有关]],
      [[D、办理国家助学贷款的学生不需要办理贷款担保或抵押]],
    },
    [[A]],
  },
  -- 7
  {
    [[根据《中华人民共和国乡村振兴促进法》，下列说法正确的是：]],
    {
      [[A、全面实施乡村振兴战略，应当坚持乡村城镇融合、城镇优先发展带动乡村原则]],
      [[B、国家构建以高质量绿色发展为导向的新型农业补贴政策体系]],
      [[C、省、自治区、直辖市人民政府应当采取措施确保耕地总量稳步增加]],
      [[D、乡镇人民政府应设立法律顾问和公职律师，根据需要在村民委员会建立公共法律服务工作室]],
    },
    [[B]],
  },
  -- 8
  {
    [[根据《中华人民共和国退役军人保障法》，下列说法正确的是：]],
    {
      [[A、参战退役军人的随迁子女入学可以得到优先保障]],
      [[B、退役的军士和义务兵可以逐月领取退役金]],
      [[C、已被大学录取的现役军人可以在退伍后四年内入学]],
      [[D、退役军人创办企业可以享受免税、贷款免息等优惠政策]],
    },
    [[A]],
  },
  -- 9
  {
    [[根据《中华人民共和国生物安全法》，下列说法错误的是：]],
    {
      [[A、境外组织不得在我国从事中、高风险的生物技术研究、开发活动]],
      [[B、任何单位和个人未经批准，不得擅自引进、释放或者丢弃外来物种]],
      [[C、对高致病性的病原微生物，一律不得从事相关实验活动]],
      [[D、国家对我国人类遗传资源和生物资源享有主权]],
    },
    [[C]],
  },
  -- 10
  {
    [[根据《中华人民共和国噪声污染防治法》，下列噪声污染情形与作出责令改正或处罚决定的主体对应错误的是：]],
    {
      [[A、甲企业在噪声敏感建筑物集中区域改建厂房造成工业噪声污染——住房和城乡建设部门]],
      [[B、乙企业无排污许可证排放工业噪声——生态环境主管部门]],
      [[C、丙商场在促销时持续使用高音喇叭发出噪声——地方人民政府指定的部门]],
      [[D、丁驾驶拆除消声器的机动车轰鸣行驶——公安机关交通管理部门]],
    },
    [[A]],
  },
  -- 11
  {
    [[关于个人信息保护，下列说法不符合我国法律规定的是：]],
    {
      [[A、通过自动化决策方式向个人进行商业营销，应同时提供不针对其个人特征的选项或便捷的拒绝方式]],
      [[B、通过人脸识别技术所收集的个人图像、身份识别信息只能用于维护公共安全目的]],
      [[C、个人信息和隐私有密切的关系，个人信息当中的私密信息适用有关隐私权的规定]],
      [[D、用户量巨大的个人信息处理者需要定期发布个人信息保护社会责任报告]],
    },
    [[B]],
  },
  -- 12
  {
    [[关于电信诈骗，下列说法错误的是：]],
    {
      [[A、非法使用“伪基站”实施电信诈骗的以非法侵入计算机信息系统罪追究刑事责任]],
      [[B、实施电信诈骗最高可被判处无期徒刑]],
      [[C、电信诈骗受害人可以通过诉讼程序要求服务存在缺陷的电信运营商承担相应责任]],
      [[D、负责招募他人实施电信网络诈骗犯罪活动的，以共同犯罪论处]],
    },
    [[A]],
  },
  -- 13
  {
    [[下列与交通安全有关的说法错误的是：]],
    {
      [[A、机动车载运放射性危险物品应当经公安机关批准后按指定的时间、路线、速度行驶]],
      [[B、在允许拖拉机通行的道路上，拖拉机可以从事货运，但是不得用于载人]],
      [[C、行人故意碰撞机动车造成交通事故的，机动车一方承担次要责任]],
      [[D、前车为执行紧急任务的救护车、工程救险车的，后车不得超车]],
    },
    [[C]],
  },
  -- 14
  {
    [[根据《中华人民共和国职业教育法》，关于企业开展职业教育，下列说法错误的是：]],
    {
      [[A、企业设立产教融合实训基地的，在公共事业费用上享受高于职业学校的优惠政策]],
      [[B、企业应当按照职工工资总额一定比例提取使用职工教育经费]],
      [[C、用于一线职工职业教育的经费应当达到国家规定的比例]],
      [[D、企业安排职工到职业学校接受职业教育的，应支付职业教育期间工资]],
    },
    [[A]],
  },
  -- 15
  {
    [[近年来，我国不断推进水生态修复保护工作。生态塘是包含水生动植物和微生物的一种水生态修复方式。下列与之相关的说法，错误的是：]],
    {
      [[A、狐尾藻可用于富营养化水体的生态修复是因其可吸收氮磷]],
      [[B、可以用生石灰对生态塘沿岸土壤进行消毒处理]],
      [[C、池塘中的水体出现黑臭时可通过种植芦苇等植物进行改善]],
      [[D、生态塘中的青鱼等肉食性鱼类主要在池塘上层水体活动]],
    },
    [[D]],
  },
  -- 16
  {
    [[下列与古人出行有关的说法错误的是：]],
    {
      [[A、“开远门前万里堠”中的“堠”是一种路标，可以用来导航和计程]],
      [[B、“乘舟而惑者，不知东西，见斗极则寤矣”中的“极”就是北极星]],
      [[C、“东有启明，西有长庚”中指示方向的“启明”“长庚”是不同天体]],
      [[D、“过洋牵星术”是通过测量星辰的高度指数来确定船只所处位置的]],
    },
    [[C]],
  },
  -- 17
  {
    [[下列关于化石的说法正确的是：]],
    {
      [[A、三叶虫化石是侏罗纪地层中的典型化石]],
      [[B、硅化木是树木埋入地下后形成的化石]],
      [[C、琥珀的硬度比和田玉大]],
      [[D、大多数化石是在侵入岩中被发现的]],
    },
    [[B]],
  },
  -- 18
  {
    [[下列与氢燃料电池车有关的说法错误的是：]],
    {
      [[A、氢燃料电池车的最终排出物是水]],
      [[B、氢气可以通过生物发酵和电解水等方法制取]],
      [[C、北京冬奥会中大量使用了氢燃料电池车]],
      [[D、氢气和氧气在内燃机中反应产生电能]],
    },
    [[D]],
  },
  -- 19
  {
    [[关于自然节律变化，下列说法错误的是：]],
    {
      [[A、惊蛰后华北地区可能会出现“万里雪飘”的现象]],
      [[B、2月北回归线附近会出现“儿童急走追黄蝶，飞入菜花无处寻”的现象]],
      [[C、冬至时，在广东汕头竖直立杆会出现“立竿无影”的现象]],
      [[D、谷雨前后江浙地区可能会出现“一把青秧趁手青，轻烟漠漠雨冥冥”的现象]],
    },
    [[C]],
  },
  -- 20
  {
    [[关于人体的生理现象，下列说法正确的是：]],
    {
      [[A、人体在流汗时汗腺内的盐分浓度会降低]],
      [[B、蚊虫叮咬造成的皮肤发痒属于过敏反应]],
      [[C、打嗝声是由胃部痉挛和声带闭合造成的]],
      [[D、皮肤受伤流血处的血管会先扩张后收缩]],
    },
    [[B]],
  },
  -- 21
  {
    [[“双减”政策带给作业改革的最大变化，是理念的改变，让我们回到了作业的原点：为什么要布置作业？归根到底，是为了育人。这彻底扭转了之前作业管理中的“________”现象，改变了传统作业管理中“眼中有作业、有分数，但唯独没有人”的痼疾，厘清了“好作业”的标准或者尺度。<br>
填入画横线部分最恰当的一项是：]],
    {
      [[A、揠苗助长]],
      [[B、本末倒置]],
      [[C、缘木求鱼]],
      [[D、徒有其表]],
    },
    [[B]],
  },
  -- 22
  {
    [[红树林的地下部分长期处于厌氧环境，减缓了根系和凋落物的分解速率，加速了碳埋藏速率。此外，红树林大多分布于沉积型海岸河口，由上游河流和海洋潮汐共同作用带来的大量外源性碳，被它们固定并快速沉积下来。这“________”的组合拳使得红树林成为海岸带蓝碳碳汇的主要贡献者。<br>
填入画横线部分最恰当的一项是：]],
    {
      [[A、取长补短]],
      [[B、标本兼治]],
      [[C、开源节流]],
      [[D、一举两得]],
    },
    [[C]],
  },
  -- 23
  {
    [[人造血即血氧液，能够用来代替人类血液，满足临床需求，缓解血液短缺状况。而且人造血标准化的生产流程能够确保其________，输入人造血不用再担心会感染艾滋病、肝炎等疾病，可最大程度降低输血相关传染病的风险。因此，研制和批量生产人造血成为当前的热点。<br>
填入画横线部分最恰当的一项是：]],
    {
      [[A、安全性]],
      [[B、可靠性]],
      [[C、规范性]],
      [[D、稳定性]],
    },
    [[A]],
  },
  -- 24
  {
    [[“反觇”思维是从事物甲和乙之间的联系，反推出乙同甲的另一种联系的方法。在作战指挥中，敢于“反道而觇之”，往往能跳出局部观全局、打破常规辟蹊径，面对复杂多变的战场形势，指挥员若能换位于敌、________定式，从侧面甚至反向来决策，及时________行动部署，就会拥有战场制敌的更大胜算。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、突破 扭转]],
      [[B、摒弃 校正]],
      [[C、摆脱 规划]],
      [[D、忽略 调整]],
    },
    [[B]],
  },
  -- 25
  {
    [[相比于其他全球卫星导航系统采取单一轨道星座构型，北斗系统________，坚定选择了混合星座的特色发展之路，并首创短文通报模式，开创了通信导航一体化的独特服务模式，信息发送能力从一次120个汉字提升到一次1200个汉字，遇到突发情况时无需________，足以将情节一次性说清楚。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、与众不同 言简意赅]],
      [[B、独树一帜 字斟句酌]],
      [[C、遥遥领先 删繁就简]],
      [[D、迎难而上 惜墨如金]],
    },
    [[B]],
  },
  -- 26
  {
    [[课程思政的显性功能是提升课程的内涵和质量。不少教师认为课程思政是________于传统教学之外的附加行为，这种认识是错误的。对教学而言，课程思政不是________，更不是特立独行，它首先是为提升教学质量服务的，是深层次的教学改革，因为只有高水平的教学活动才能吸引学生，进而影响学生。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、游离 喧宾夺主]],
      [[B、隔绝 照本宣科]],
      [[C、徘徊 削足适履]],
      [[D、独立 敷衍了事]],
    },
    [[A]],
  },
  -- 27
  {
    [[翻开古代农书，几千年间古人对于土地的保养，几乎与当代耕作学关注的措施________，其中历代农书涉及最多的是施肥。在中国古人的摸索中，施肥成为一种讲究，何时、何地施肥，施何种肥，怎样施肥，形成了一个________的体系，在每个年度的农业生产进程中，精心安排在各个时节。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、一脉相承 科学]],
      [[B、如出一辙 固定]],
      [[C、别无二致 完整]],
      [[D、不谋而合 复杂]],
    },
    [[C]],
  },
  -- 28
  {
    [[指尖上的形式主义是“以痕迹论政绩”的错误政绩观，关注点在于形式美观，而________了根本政绩——人民群众的满意度。指尖上减负就是要把基层干部从________的“虚功”中解救出来，务求实效、扎根基层，用实践检验政绩，把工作落实与否、群众满意与否作为衡量政绩的客观标准。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、偏离 阳奉阴违]],
      [[B、遗忘 哗众取宠]],
      [[C、淡化 花拳绣腿]],
      [[D、忽视 华而不实]],
    },
    [[D]],
  },
  -- 29
  {
    [[我们确立和坚持马克思主义在意识形态领域指导地位的根本制度，新时代党的创新理论________，社会主义核心价值观广泛传播，中华优秀传统文化得到创造性转化、创新性发展，文化事业日益繁荣，网络生态持续向好，意识形态领域形势发生________、根本性转变。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、振聋发聩 历史性]],
      [[B、深入人心 全局性]],
      [[C、高屋建瓴 实质性]],
      [[D、硕果累累 显著性]],
    },
    [[B]],
  },
  -- 30
  {
    [[补齐公共服务短板，首先要善于发现深层次问题。要深入调研、综合分析、精准掌握，弄清问题的本质和关键，做到________。同时，补齐公共服务短板不是简单的打打补丁，也不会________。有一些短板和弱项是随着时代发展而凸显的系统性问题，只有通过推动经济社会高质量发展才能从根本上解决。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、循序渐进 一成不变]],
      [[B、细致入微 完美无缺]],
      [[C、一针见血 水到渠成]],
      [[D、有的放矢 一劳永逸]],
    },
    [[D]],
  },
  -- 31
  {
    [[对于新业态新模式冲击本地的传统产业，是包容审慎，还是________？对于非本地人才就业创业、非本地企业项目立项推广，能否________，甚至千方百计降门槛、清路障以留人留项目？纵观先进制造业集群所在地，无一不是当地政府部门怀着“开放之心”，营造出良好的创新生态。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、如芒在背 一视同仁]],
      [[B、退避三舍 不偏不倚]],
      [[C、拒之门外 开诚布公]],
      [[D、推三阻四 海纳百川]],
    },
    [[A]],
  },
  -- 32
  {
    [[法律惩罚的正当性一定程度上源于公众朴素的道德期待。在具体执法时，不能仅仅________地依赖客观后果，进行简单归责和惩戒，而应全面考察当事人的主观认知、动机目的等情节，并综合________其社会危害性，由此来审慎决定是否启动惩罚机制。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、机械 评估]],
      [[B、单纯 辨别]],
      [[C、盲目 分析]],
      [[D、草率 判断]],
    },
    [[A]],
  },
  -- 33
  {
    [[在普通人看来，法律都是________的，自己一辈子都不会和法律打交道。但在瞬息万变的社会里，人们随时可能触及法律的红线。很多人平时法律观念和意识不强，柔性执法不仅可以起到________作用，而且有利于提高群众的学法懂法意识。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、高高在上 教育]],
      [[B、高深莫测 预防]],
      [[C、遥不可及 警戒]],
      [[D、事不关己 提醒]],
    },
    [[C]],
  },
  -- 34
  {
    [[长期以来，城管执法部门对职责内的执法事项通常是________“用力”，对所有的执法对象“一碗水端平”，以体现执法的公平性、公正性。但对于超大城市而言，由于城管执法事项繁多，涉及市场主体庞杂，而城管执法力量是有限的，实践中很难做到________，进而可能会影响执法效果和执行力。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、精准 滴水不漏]],
      [[B、均衡 百无一失]],
      [[C、精确 精益求精]],
      [[D、平均 面面俱全]],
    },
    [[D]],
  },
  -- 35
  {
    [[开展未成年人网络环境整治，势在必行且________。网络上可能存在的色情、暴力、过度娱乐等有害信息，会对普遍拥有智能设备、全面触网的未成年人产生潜移默化的不良影响。只有________清朗洁净的网络空间，才能让青少年健康成长。实现这一愿景，需要发挥多主体多领域联动优势，________合力，撑起清朗网络蓝天。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、蓄势待发 创设 形成]],
      [[B、刻不容缓 营造 凝聚]],
      [[C、迫在眉睫 构筑 集成]],
      [[D、任重道远 共建 汇聚]],
    },
    [[B]],
  },
  -- 36
  {
    [[随着技术发展，以数字手段为支撑的“沉浸式”“交互式”网上博物馆日益增多，提高了展览的________。但随着智能终端的普及，人们难免会对数字博物馆产生________。博物馆在利用数字技术的基础上，也不能忽视实物展览内涵的提升，使之兼备文化和教育功能，突出________的特点。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、科技性  排斥  润物无声]],
      [[B、便捷性  厌倦  触手可及]],
      [[C、趣味性  疲劳  寓教于乐]],
      [[D、交融性  失望  与时俱进]],
    },
    [[C]],
  },
  -- 37
  {
    [[传统戏曲中所蕴含的价值理念以及________的表演节奏，很难与当代青年人的生活节奏与审美趣味相合拍。因而，关于戏曲衰亡的声音________。事实上，戏曲相对于互联网时代知识文化的________、快餐式传播，其可重复欣赏和耐咀嚼的品格显得更为可贵，其特有的艺术价值决定了它不可能退出历史舞台，更不会走向消亡。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、不疾不徐 如雷贯耳 碎片化]],
      [[B、从容不迫 不绝于耳 肤浅化]],
      [[C、四平八稳 甚嚣尘上 机械化]],
      [[D、慢条斯理 此起彼伏 泡沫化]],
    },
    [[D]],
  },
  -- 38
  {
    [[没有中华文化沃土的滋养，就不可能有中国特色社会主义制度的________。我们过去对制度的实践基础强调比较多，对制度的文化支撑关注不够。其实，制度绝不只是一系列外在的________行为规范，还是内在的文化思维价值认同。这种文化不可能是外来的强加或移植，必须是内在的演化和________。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、勃勃生机  强制性  积淀]],
      [[B、枝繁叶茂  约束性  渗透]],
      [[C、历久弥新  指导性  转化]],
      [[D、欣欣向荣  系统性  升华]],
    },
    [[A]],
  },
  -- 39
  {
    [[环境整治关键要不留死角、不存盲点，光靠人为监管恐怕会________。目前，“互联网＋”数字技术已成为环境监测的利器，为生态环境监测布下“天罗地网”。这张网使任何“________”，都能充分暴露在数据“阳光”之下，让环境监测和污染防治变得更加________、更加具象。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、捉襟见肘 一举一动 有效]],
      [[B、力不从心 风吹草动 精细]],
      [[C、顾此失彼 小打小闹 动态]],
      [[D、收效甚微 蛛丝马迹 直观]],
    },
    [[B]],
  },
  -- 40
  {
    [[竞争与创新总是________。平台反垄断最终要在抑制垄断与鼓励创新之间达到平衡。一方面，要加快健全市场准入制度、公平竞争审查机制，预防和________滥用行政权力限制竞争，充分________市场竞争机制的强大动能；另一方面，要引导和激励平台企业把更多精力用在创新上。唯有如此，平台经济方能为全社会注入持久的创新活力。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、如影随形  约束  调控]],
      [[B、互为表里  杜绝  挖掘]],
      [[C、相辅相成  打击  激发]],
      [[D、息息相关  制止  释放]],
    },
    [[D]],
  },
  -- 41
  {
    [[当前，社会治理形势复杂，仅靠职能部门、专业力量远远不够，迫切需要人民群众和社会各界的积极支持与参与，共同创造公共价值。众包是公众和外包的组合词，意指发包方依托互联网或其衍生工具，在数字平台上设计规则与任务并向广泛、非确定的公众发包，公众根据自身能力自愿接包并完成特定事务。众包强调大众参与的开放式合作，促使组织边界向更广泛的大众群体开放，旨在挖掘隐藏在公众中的巨大潜力。因此，相较于政府购买等专业性较强的政府合同外包服务，政府众包展现出更开放的社会治理格局。<br>
最适合做这段文字标题的是：]],
    {
      [[A、众包：共享经济下的新型用工模式]],
      [[B、政府众包：公众参与社会治理新方式]],
      [[C、公众参与：开放式合作的新形式]],
      [[D、“互联网+”：公共管理新范式]],
    },
    [[B]],
  },
  -- 42
  {
    [[在市场经济时期，劳动密集型制造工厂普遍采用流水线技术，工人被高度“去技能化”，几乎不需要技能便可完成装配操作，企业没有需求也没有动力去培养中高级技术工人。但是，当一个国家的产业结构向中高端迈进时，高水平职业教育的支撑作用就会显现出来。技术进步与人力资本相互影响、相互促进：企业引进的高端生产线，需要技术工人去操作和维护，否则技术改造和升级就无法实现；如果没有配套的职业技能培训体系，企业的转型升级就难以达到预期效果。<br>
这段文字意在说明：]],
    {
      [[A、产业结构转型升级需要职业教育的支撑]],
      [[B、技术进步对人力资本提出了更高要求]],
      [[C、“技工荒”会随产业结构升级更趋严重]],
      [[D、职业技能培训需求与经济增长有相关性]],
    },
    [[A]],
  },
  -- 43
  {
    [[作为经典的艺术门类，绘画在历史长河中并非独立发展。在原始艺术中，音乐、诗歌、舞蹈三位一体，密不可分，绘画则将载歌载舞的场景留存于世。不同艺术门类成熟之后各自独立，但在发展的过程中又相互吸收、相互依托、相互影响。各艺术门类之间的吸收与借鉴、配合与结合，是艺术发展创新的重要手段。古典名画是人类审美情趣的集中体现，很长一段时间是深藏在博物馆中的高雅艺术，名画想要真正“活”化，还需要借助跨界融合。<br>
这段文字意在强调：]],
    {
      [[A、绘画是诗歌和舞蹈传承的重要载体]],
      [[B、不同艺术门类的跨界融合由来已久]],
      [[C、古典名画可以借助跨界融合重焕生机]],
      [[D、打破形式壁垒是艺术创新的重要手段]],
    },
    [[C]],
  },
  -- 44
  {
    [[火山灰是指火山爆炸性喷发形成的，直径小于2毫米的喷发碎屑。在爆炸性火山活动中，围岩和岩浆被炸碎成细小的颗粒，形成火山灰。火山灰从火山口喷发到大气中，经过大气搬运再沉降到各类环境中，整个过程通常只有数年，从地质时间尺度来看，几乎只是瞬间。所以在各种地质记录中，火山灰是一种高精度的绝对时间标志层。火山灰年代学正是利用地质记录中的火山灰层来确定地质年代的科学，该学科可以解决一些重要的科学问题，比如大型火山喷发事件与气候变化、人类演化之间的关系，以及气候快速变化的区域差异等。<br>
这段文字主要介绍了：]],
    {
      [[A、火山灰的形成过程与主要特点]],
      [[B、火山灰年代学的研究思路和价值]],
      [[C、火山灰在自然环境中的分布状态]],
      [[D、火山喷发对环境和人类的影响]],
    },
    [[B]],
  },
  -- 45
  {
    [[________。十八大以来，国内外形势新变化和实践新要求，迫切需要我们从理论和实践的结合上深入回答关系党和国家事业发展、党治国理政的一系列重大时代课题。我们党勇于进行理论探索和创新，以全新的视野深化对共产党执政规律、社会主义建设规律、人类社会发展规律的认识，取得重大理论创新成果，集中体现为新时代中国特色社会主义思想。<br>
填入画横线部分最恰当的一项是：]],
    {
      [[A、马克思主义是我们立党立国、兴党兴国的根本指导思想]],
      [[B、坚持和发展马克思主义，必须同中华优秀传统文化相结合]],
      [[C、我们必须坚定历史自信、文化自信。坚持古为今用、推陈出新]],
      [[D、推进马克思主义中国化时代化是一个追求真理，揭示真理，笃行真理的过程]],
    },
    [[D]],
  },
  -- 46
  {
    [[肺鱼是一类可用“肺”呼吸的肉鳍鱼，它们的“肺”是特化的鱼鳔，能吸收空气。这一特殊技能使其可以摆脱水的束缚，在河水干涸时潜入洞穴，躲在分泌物形成的茧中，等待雨季到来。此外，肺鱼还是能“啃硬骨头”的鱼，它们咬合力强大，一些带壳的无脊椎动物也是其捕食对象，这种能吃带壳动物的能力，被称为食壳性或甲食性，泥盆纪早期的奇异鱼被认为是最原始的肺鱼，已经具有典型的肺鱼食壳性特征，比如有发达的齿板与短而粗壮的下颌。而杨氏鱼的系统发育位置较奇异鱼更为原始，是研究肺鱼类食壳性起源的关键。<br>
这段文字接下来最可能介绍：]],
    {
      [[A、关于杨氏鱼的最新研究成果]],
      [[B、动物食壳性特征的产生原因]],
      [[C、肺鱼在生物演化史上的重要意义]],
      [[D、杨氏鱼与其他泥盆纪物种的区别]],
    },
    [[A]],
  },
  -- 47
  {
    [[我国在改革开放后逐渐认识到保护民间文学艺术作品的重要性，并在1990年著作权法规定保护办法另行规定。但时隔三十余年，保护办法仍未出台。尽管如此，在著作权法颁布后，学界就民间文学艺术作品法律保护展开研究讨论，提出多种保护方案，涉及权利客体、权利主体、权利内容、保护期限、权利限制等方面的问题。当然，也有个别学者反对用著作权法保护民间文学艺术作品，主张通过公法加以保护。与此同时，国家版权局也加快推进相关立法，但因质疑声音过大而夭折。<br>
作者可能赞同下列哪一观点？]],
    {
      [[A、通过公法保护民间文学艺术作品是最可行的路径]],
      [[B、围绕民间文学艺术作品法律保护的争议流于表面]],
      [[C、国家版权局应就民间文学保护倾听多方面意见]],
      [[D、民间文学艺术作品法律保护缺位状态亟需改变]],
    },
    [[D]],
  },
  -- 48
  {
    [[传统X射线在对抗癌细胞时，无法主动辨别正常细胞和癌细胞，在进入人体后实施无差别杀伤。与之不同，重离子束在穿越生物组织的过程中，不会在沿途不断地释放能量，而会在某个深度形成一个剂量高峰，科学界称之为“布拉格峰”。也就是说，在穿透过程中，重离子束只是路过，并不施加伤害；当它到达癌细胞时，才开始杀敌。这样，正常细胞终于可以不再被误伤，这有利于保护正常组织和关键器官。<br>
根据这段文字，与传统射线相比，重离子束：]],
    {
      [[A、堪称“蒙面杀手”]],
      [[B、采用“游击战术”]],
      [[C、具有更强的“穿透力”]],
      [[D、能精确“区分敌我”]],
    },
    [[D]],
  },
  -- 49
  {
    [[传统成像技术都是对视域内的物体进行观测，非视域成像技术则能够对隐藏在视线外的物体进行拍照，实现“视线拐弯”“隔墙观物”，极大地拓展了人类的成像能力。这一技术的实现过程通常是将激光脉冲发射到中介墙上，利用中介墙使激光散射到被遮挡的非视域场景中，该场景中的隐藏物体再次将激光散射到中介墙上，最终由中介墙散射至接收系统，整个过程激光经历了3次漫反射，通过记录光量子的飞行时间实现对非视域场景的重构。然而，由于激光经过多次漫反射，整个光路存在巨大的衰减，使得非视域成像目前仅能在实验室内进行短距离的原理性验证。此外，多次漫反射导致的时空信息混杂，使得成像算法成为一个科研难题。<br>
关于非视域成像技术，这段文字未提及：]],
    {
      [[A、基本原理]],
      [[B、突出优势]],
      [[C、应用前景]],
      [[D、技术难题]],
    },
    [[C]],
  },
  -- 50
  {
    [[事实推定是指法官在确证基础事实之上，借助经验法则推定待证事实的一种司法认知方法，这实际上是法官价值判断的过程，受个人经验、情感、家庭背景等因素的影响，法官进行价值判断时可能具有个体特征，价值判断联通了基础事实与推定事实，对各类事实所作的价值判断不同，得出的判决结论也将不同。因此，________。<br>
填入画横线部分最恰当的一项是：]],
    {
      [[A、对事实推定价值判断的说理可提升判决的可接受性]],
      [[B、需要对事实推定中的价值判断进行规范]],
      [[C、程序正义有助于减少法官个体差异对判决的影响]],
      [[D、价值判断不仅要符合形式合理性也要及时回应社会关切]],
    },
    [[B]],
  },
  -- 51
  {
    [[①同样，市场规模更大的企业将能够更好地摊薄其供应链成本，从而在低毛利环境中生存下来，打败竞争对手<br>
②有些生鲜平台称呼其商业模式为“自来水模式”，立志要让好的食材像自来水一样，触手可得<br>
③在互联网领域，生鲜电商能否盈利不是问题，谁能成为最后的赢家才是问题<br>
④由于生鲜电商平台具备很强的消费者粘性，先占据更多核心区消费者的企业便能获得先发优势，后进入者往往需要付出更高的获客成本<br>
⑤这种现象在经济学上被称作“自然垄断”，即某些产品和服务由单个企业大规模生产经营比多个企业同时生产经营更有效率<br>
⑥而“自来水行业”便是自然垄断最普遍出现的行业<br>
将以上6个句子重新排列，语序正确的是：]],
    {
      [[A、②⑤⑥①④③]],
      [[B、②④⑤①③⑥]],
      [[C、④①⑤②⑥③]],
      [[D、④⑤③①②⑥]],
    },
    [[C]],
  },
  -- 52
  {
    [[①这会使病情恶化，并最终导致相关的关节功能障碍<br>
②大量临床及基础研究显示，软骨病理性钙化是导致骨关节病软骨退变的关键致病机制之一<br>
③软骨病理性钙化通过诱导软骨细胞表型改变，最终呈现出一种病理状态<br>
④关节软骨渐进性退变是骨关节病最主要的病理改变<br>
⑤这些病态的软骨细胞通过有丝分裂增加自身数量，并通过分泌炎症因子、降解软骨基质引发组织炎症，最终发生凋亡<br>
⑥凋亡小体在吸收钙离子后，又会成为新的病理性矿化结晶，循环往复，致使软骨退变加重、剥脱<br>
将以上6个句子重新排列，语序正确的是：]],
    {
      [[A、④②③⑤⑥①]],
      [[B、④③⑤①②⑥]],
      [[C、②③⑤⑥④①]],
      [[D、②⑤④③①⑥]],
    },
    [[A]],
  },
  -- 53
  {
    [[“高精尖”产业是辐射带动力强的产业集群，对经济具有极强的拉动作用，不仅能实现中心城市的经济高质量发展，而且能带动周边地区的产业联动转型。京津冀协同发展中，产业对接协作是区域战略的核心内容之一，产业升级是三地的共同任务，在疏解非首都核心功能的过程中，天津和河北是北京产业转移的主要承接者。然而，两地仅简单承接北京转移的一般产业是远远不够的，迫切需要发展“高精尖”产业，带动区域科技创新与成果转化，促进区域产业联动，形成经济协同发展的格局。<br>
这段文字意在说明：]],
    {
      [[A、“高精尖”产业承担着高水平创新的重大使命]],
      [[B、形成“高精尖”产业是城市群建设的长远目标]],
      [[C、我国区域经济发展应以“高精尖”产业为依托]],
      [[D、“高精尖”产业对京津冀协同发展有重要意义]],
    },
    [[D]],
  },
  -- 54
  {
    [[要推动老旧小区的适老化改造和无障碍环境建设，关键是提升整个社会对适老化改造的思想认识，实现适老化改造特别是居家适老化改造“心理无障碍”。要多渠道、全方位宣传引导居家适老化改造的政策与价值，转变老人、子女和社会对居家适老化改造的认知；同时，要通过养老服务中心、居家养老服务中心等载体，打造居家适老化改造样板房，强化直观感受，转变老人的传统观念，让老人逐步形成“为养老服务买单”、让子女形成更加关注父母居家养老环境的社会意识，提升适老化改造的家庭主观能动性。<br>
这段文字强调要：]],
    {
      [[A、平衡主体利益，因地制宜推动适老化改造]],
      [[B、统筹各方资源，激活适老化改造的多元力量]],
      [[C、补位标准规范，提升适老化改造的品质与效率]],
      [[D、加强宣传引导，做到适老化改造“心理无障碍”]],
    },
    [[D]],
  },
  -- 55
  {
    [[科学家早就知道月球有两面：面向地球的一面较为平坦，背向地球的一面凹凸不平，遍布撞击坑，月球为何具有截然不同的两副面孔，是其众多谜团之一。近日，科学家提出一种全新解释：数十亿年前，形成月球背面盆地的巨大撞击，产生了足以传遍月球的巨大热量，促成月幔物质的熔化，其中的稀土和放射性生热元素钍以及钾、磷等被携带到与撞击区域对称的月面，形成克里普岩，分布在月球正面风暴洋及其周围，放射性生热元素的集中，产生了月球表面的熔岩流，最终形成月球正面的火山平原。<br>
最适合做这段文字标题的是：]],
    {
      [[A、盆地与平原：两副面孔，两种材质]],
      [[B、月球上的熔岩流：亟待开发的宝藏]],
      [[C、双面月球：一次撞击，两种结局]],
      [[D、放射性生热元素：月球的化妆师]],
    },
    [[C]],
  },
  -- 56
  {
    [[生态修复请求分为生态修复的行为请求和费用请求，前者是为了防止生态环境权益损害的发生或扩大，请求责任人停止污染破坏行为；当被破坏的生态环境无法恢复时，请求责任人进行人工修复。如果责任人不具有修复能力或意愿，可请求责任人承担修复费用。因此，修复行为请求应作为首要诉求，在责任人不能或不愿进行修复时，才能提出修复费用请求。在司法实践中，很多公益诉讼人却往往将修复费用请求作为首要诉求，但由于诉求和判决的修复费用数额不易确定，责任主体短期内难以承担修复费用，生态修复工作很难有效开展。<br>
这段文字意在说明：]],
    {
      [[A、应该制定生态修复费用的分级标准]],
      [[B、修复费用请求往往很难得到有效落实]],
      [[C、应根据责任人的能力确定生态修复诉求]],
      [[D、生态修复诉讼应当首先提出修复行为请求]],
    },
    [[D]],
  },
  -- 57
  {
    [[在银河系中，恒星形成于巨型分子云的引力塌缩。而塌缩的残留物会围绕着新生的恒星转动，形成一个富含尘埃的气体盘，称为“原行星盘”。在年轻恒星中，周围存在原行星盘的比例会随恒星年龄增长而下降，存在的时长中值约为200万~300万年。然而，正是通过原行星盘获得气体及所需物质，许多行星才能在这短短几百万年内大致演化成型。对于类似地球的其他行星而言，经历了原行星盘阶段，早期物质至少演化成了行星胚胎，并在原行星盘消散后经历进一步的碰撞和演化，最终形成现在的类地行星。<br>
根据这段文字，下列说法正确的是：]],
    {
      [[A、恒星和原行星盘的存在时间大致相同]],
      [[B、原行星盘是类地行星形成中的必经阶段]],
      [[C、巨型分子云引力塌缩后随即形成行星和恒星]],
      [[D、行星在运动中不断从原行星盘中获取所需物质]],
    },
    [[B]],
  },
  -- 58
  {
    [[从“市场体系”到“统一市场”再到“全国统一大市场”，实际就是从建设市场到建设一体化市场，再到建设大市场和强市场。我们的市场人均收入和消费水平低，虽然人口多，但是市场呈现为行政分割状态，因此只是潜在规模大，实际规模并不具有竞争优势。对此，除了要通过深化改革，释放生产力、提升工资水平、分好国民收入这块蛋糕，还要处理好两个重要问题：一是大力纠正导致市场分割的因素；二是加快资本市场化建设，提高财产性收入比重。这是在扩大工资占比条件受限的前提下，迅速做大做强市场的关键。<br>
这段文字针对的主要问题是：]],
    {
      [[A、行政区域分割和非一体化抑制了有效竞争]],
      [[B、财产性收入在国民收入中的比重还比较低]],
      [[C、我国市场潜在规模优势还未转化为现实优势]],
      [[D、消费需求疲软阻碍了全国统一大市场的形成]],
    },
    [[C]],
  },
  -- 59
  {
    [[颠覆性技术在军事领域的应用，使现代空袭作战向陆、海、空、天、电、网等领域发展。电子战飞机、预警指挥机在现代空袭体系中的作用愈发重要；第四代隐身飞机投入实战大大增强了空袭体系的突防能力；空射导弹等精确制导弹药智能化水平、抗干扰能力和目标识别能力增强，作战效能大大提高。未来将进一步提高精确制导弹药的命中精度，空袭体系的精确打击能力将进一步增强。同时，运用小型或超小型无人机，在战场上对重要目标实施“蜂群”式打击，会给重要目标的防护造成很大困难。<br>
这段文字意在说明：]],
    {
      [[A、颠覆性技术提高了空袭作战的综合打击能力]],
      [[B、军事领域的颠覆性技术研究取得突破性进展]],
      [[C、精确打击能力的增强提升了空袭作战的效能]],
      [[D、智能化时代的空中防御体系面临着空前挑战]],
    },
    [[D]],
  },
  -- 60
  {
    [[立案登记制改革的初衷是保护当事人依法享有的诉权，所谓“有案必立、有诉必理”，只是指那些符合法律规定立案条件的案件，起诉到人民法院后，法院必须立案，否则法院就没有必要受理。所以，，对此，可能有人认为，设立立案标准等于为立案设置了门槛，很难保障当事人通过诉讼解决纠纷的权利。其实任何权利都有限度，不存在没有边界的权利，当事人通过诉讼解决纠纷的权利同样如此。只有符合立案标准，这种权利才能通过法院诉讼得以实现。<br>
填入画横线部分最恰当的一项是：]],
    {
      [[A、推行立案登记制并不意味着“是案就立”]],
      [[B、不能将“立案难”与司法公正简单关联起来]],
      [[C、明确立案标准才能保障当事人的合法权益]],
      [[D、应正确理解司法资源作为公共产品的有限性]],
    },
    [[C]],
  },
  -- 61
  {
    [[一项工作甲独立完成需要3小时，乙独立完成的用时比其与甲合作完成多4小时，且乙和丙合作完成需要4小时。问丙独立完成需要多少小时？]],
    {
      [[A、10]],
      [[B、12]],
      [[C、6]],
      [[D、8]],
    },
    [[B]],
  },
  -- 62
  {
    [[在一块正方形土地中，画一条经过某个顶点的规划线，将其分割为三角形和梯形两块土地，且梯形土地的面积正好是三角形土地的2倍。问三角形和梯形土地的周长之比是多少？]],
    {
      [[A、1：2]],
      [[B、5：7]],
      [[C、(1+√5)：(2+√5)]],
      [[D、(5+√13)：(7+√13)]],
    },
    [[D]],
  },
  -- 63
  {
    [[已知A、B两种设备定价相同，C设备单价为8000元/台。现A、B两种设备分别打六折、七折促销，购买1台B设备的费用比购买A、C设备各1台的总费用高2万元。问促销期间1000万元预算最多可以购买多少台A设备？]],
    {
      [[A、35]],
      [[B、51]],
      [[C、59]],
      [[D、77]],
    },
    [[C]],
  },
  -- 64
  {
    [[某单位有甲和乙2个办公室，分别有职工5人和4人。每周从这9名职工中随机抽取1人下沉社区担任志愿者（同一人有可能被连续、重复选中）。问7月前2周的志愿者均来自甲办公室的概率在以下哪个范围内？]],
    {
      [[A、不到25%%]],
      [[B、25%%~35%%之间]],
      [[C、35%%~45%%之间]],
      [[D、超过45%%]],
    },
    [[B]],
  },
  -- 65
  {
    [[公园里有一片四边形草坪，沿对角线修建的小道相交于O点，O到四个顶点A、B、C、D的距离之比正好为1：2：3：4，一名工人花费1天正好完成AOB区域的修剪，问第二天至少需要额外增加多少名效率相同的工人一起工作，才能在当天内完成剩余草坪的修剪？<br>
]],
    {
      [[A、8]],
      [[B、10]],
      [[C、11]],
      [[D、12]],
    },
    [[B]],
  },
  -- 66
  {
    [[单位将10个培训名额分配给4个分公司，要求在每个分公司至少分配1个名额的所有分配方案中，随机选择1个方案实施，问4个分公司中有3个分配名额数量相同的概率为多少？]],
    {
      [[A、3/50]],
      [[B、1/10]],
      [[C、3/25]],
      [[D、1/7]],
    },
    [[D]],
  },
  -- 67
  {
    [[某次会议邀请4所高校每所各2位学者作报告。在某日上午、下午和晚上的三个时间段分别安排3位、3位和2位学者依次作报告，且同一所高校的2位学者不安排在同一时间段内作报告。问8人的报告次序有多少种不同的安排方式？]],
    {
      [[A、不到5000种]],
      [[B、5000~10000种之间]],
      [[C、10001~20000种之间]],
      [[D、超过20000种]],
    },
    [[C]],
  },
  -- 68
  {
    [[一辆汽车从甲地开往乙地，先以40千米/小时的速度匀速行驶一半的路程，然后均匀加速；行驶完剩下路程的一半时，速度达到80千米/小时；此后均匀减速，到达乙地时的速度正好降为0。问其全程的平均速度在以下哪个范围内？]],
    {
      [[A、不到44千米/小时]],
      [[B、在44~45千米/小时之间]],
      [[C、在45~46千米/小时之间]],
      [[D、超过46千米/小时]],
    },
    [[A]],
  },
  -- 69
  {
    [[甲、乙、丙三家科技企业2021年的收入之和比2020年提升了20%%。其中甲企业的收入上升了400万元，乙企业的收入下降了100万元且是甲企业收入的一半，丙企业的收入上升了30%%且其2020年的收入与甲、乙两企业同年收入之和相同。问2020年甲企业的收入比乙企业高多少万元？]],
    {
      [[A、900]],
      [[B、1100]],
      [[C、400]],
      [[D、600]],
    },
    [[D]],
  },
  -- 70
  {
    [[一个圆柱体零件A和一个圆锥体零件B分别用甲、乙两种合金铸造而成。A的底面半径和高相同，B的底面半径是高的2倍，两个零件的高相同，质量也相同。问甲合金的密度是乙合金的多少倍？]],
    {
      [[A、4/3]],
      [[B、3/4]],
      [[C、2/3]],
      [[D、3/2]],
    },
    [[A]],
  },
  -- 71
  -- 该题已被删除，因为是图形推理题
  -- 72
  -- 该题已被删除，因为是图形推理题
  -- 73
  -- 该题已被删除，因为是图形推理题
  -- 74
  -- 该题已被删除，因为是图形推理题
  -- 75
  -- 该题已被删除，因为是图形推理题
  -- 76
  -- 该题已被删除，因为是图形推理题
  -- 77
  -- 该题已被删除，因为是图形推理题
  -- 78
  -- 该题已被删除，因为是图形推理题
  -- 79
  -- 该题已被删除，因为是图形推理题
  -- 80
  -- 该题已被删除，因为是图形推理题
  -- 81
  {
    [[微量鉴定是指运用物理学、化学和仪器分析等方法，通过对案件现场有关物质材料（材料特点多为体小量微、不易注意）的成分及其结构进行定性、定量分析，对检材的种类、检材和嫌疑样本的同类性和同一性进行鉴定。<br>
根据以上定义，下列涉及交通事故的鉴定属于微量鉴定的是：]],
    {
      [[A、对车辆驾驶人采血，分析血液中的酒精含量，判断驾驶人是否存在酒后驾车嫌疑]],
      [[B、现场提取、检验受害人毛发、衣物纤维，认定受害人是否与嫌疑人车辆存在接触]],
      [[C、拆解车辆特定部位，查明车辆故障原因，用以鉴定其属于人为责任还是机械故障]],
      [[D、通过人体损伤程度检验，确定伤害损伤部位与交通事故伤害后果的关联程度]],
    },
    [[B]],
  },
  -- 82
  {
    [[架构创新是指组成产品的基本元件不变，但是整体结构布局改变，即将相同元件进行整体结构的重新调整，进而产生新功能的创新。<br>
根据上述定义，下列属于架构创新的是：]],
    {
      [[A、陶瓷底板电熨斗与传统不锈钢底板电熨斗相比，其底板的耐磨性更强，具有更高的光滑度，使用起来更顺畅]],
      [[B、某款手机聊天软件增加了拜年红包功能，用户可以在给亲朋好友发送红包时，编辑拜年吉祥语、自定义红包图片，满足个性化需求]],
      [[C、可拆卸手柄锅将原手柄设计成可从锅具上拆卸下来，并提供多个手柄可安装在锅具边缘的任意位置上，满足烹饪需要]],
      [[D、某板材厂改良制作工艺，将原来的轧制工序分成两步进行，同时增加砂光工序，生产出满足市场需要的薄板]],
    },
    [[C]],
  },
  -- 83
  {
    [[民宿是指利用当地民居等相关闲置资源，经营用客房不超过4层、建筑面积不超过800平方米，主人参与接待，为游客提供体验当地自然、文化与生产生活方式的小型住宿设施。<br>
根据上述定义，下列属于民宿的是：]],
    {
      [[A、王某在市中心有一套两居室的房子，过了马路就是知名的景区公园。王某将闲置房间租给那些节假日来旅游的家庭，并提供导游服务]],
      [[B、某家庭农场开发亲子休闲旅游业务，建设了农业科普、亲子游玩场所，为孩子和家长营造一处寓教于乐的乡村乐园]],
      [[C、李某通过某网上平台找到心仪城市的会员“交换”旅行，即双方各自为对方提供住宿，住在对方家中深入体验当地的风土人情]],
      [[D、张某在古镇上有一所老宅。他和某平台签订合同，将老宅租给该平台运营。该平台将老宅装修，并提供完善的酒店式服务机制]],
    },
    [[A]],
  },
  -- 84
  {
    [[体验式采访是指直接投入到所要报道的新闻事件中去体验生活，以获得新闻报道所需要的素材，以及对新闻事件的认识。<br>
根据上述定义，下列不属于体验式采访的是：]],
    {
      [[A、某报社要求年轻记者沉入生活，了解基层，以改变写官话、说套话的文风]],
      [[B、某作家为了解包身工的悲惨遭遇，深入到工厂中，写出报告文学《包身工》]],
      [[C、某记者为了解传销组织的真面目，打入到传销组织内部，揭示传销组织的骗局]],
      [[D、某电视台推出专栏《体验三百六十行》，派记者体验各职业一周并进行系列报道]],
    },
    [[A]],
  },
  -- 85
  {
    [[伴性遗传是指控制性状的基因位于性染色体上，遗传总是与性别相关联，不同性别出现某一性状的概率不同的遗传。限性遗传是指控制性状的基因位于性染色体上，性状只在一种性别上得以表现，而在另一性别上完全不能表现的遗传。从性遗传是指控制性状的基因位于常染色体上，但由于受到性激素的作用，基因在不同性别中表达不同的遗传。<br>
根据上述定义，下列属于限性遗传的是：]],
    {
      [[A、抗维生素D佝偻病是伴X染色体显性遗传病，女性发病率高，常表现为世代遗传]],
      [[B、人类外耳道多毛症为伴Y染色体遗传病，在家族男性亲属中代代遗传]],
      [[C、遗传性斑秃为常染色体显性遗传病，男性会出现早秃，而女性则不会出现]],
      [[D、红绿色盲症是伴X染色体隐性遗传病，男性发病率高，表现出交叉遗传和隔代遗传]],
    },
    [[B]],
  },
  -- 86
  {
    [[预判设计是一种能够引导用户、缩短用户行为路径的有效设计手段。它可以根据用户的行为或用户所在的场景，让功能“主动找到”用户，并让用户与之产生自然的交互，为用户提供更好的使用体验，本质就是为用户多想一步，让用户使用起来尽量简单。<br>
根据上述定义，下列不属于预判设计的是：]],
    {
      [[A、某购物软件，根据用户输入的搜索关键词，将商品按与关键词的相关性排列]],
      [[B、某翻译软件，用户第一次点击播放，语音速度正常；再次点击，语音速度变慢]],
      [[C、某外卖软件，当用户对店家给出差评，系统自动勾选“将评价设为匿名评价”]],
      [[D、某购物软件，所选商品缺货时，出现“找相似”按钮，点击可看到同款、相似商品]],
    },
    [[A]],
  },
  -- 87
  {
    [[负性偏向是指负性信息比其他信息得到优先的注意和加工，这是人类在先天遗传和后天经验基础上存在的一种普遍性认知倾向，即给予负性事物更大的权重，并在注意、记忆、情绪、决策等方面遵循“坏比好重要”的心理原则。<br>
根据上述定义，下列没有体现负性偏向的是：]],
    {
      [[A、“3·15”晚会报道侵犯消费者权益的违法行为，以期政府各级管理部门有效管理]],
      [[B、被试对负面词汇的再认正确率比正面词汇高，能更精准识别某负面词汇是否在语料中]],
      [[C、新闻传播过程中，模糊信息中的一些负面细节更容易被人们关注并作进一步负面解读]],
      [[D、应聘者的优缺点与职位具有同等相关性，但招聘者往往更关注应聘者的缺点]],
    },
    [[A]],
  },
  -- 88
  {
    [[单元素导语是指在撰写新闻导语（即消息的开头）时，突出表现一个新闻事实的导语。单元素导语按新闻五要素可分为：①何人导语，突出报道显要或影响大的新闻人物；②何事导语，突出报道新闻事实本身；③何时导语，突出报道读者关心的事情什么时候会发生或进行；④何地导语，突出报道一些重要或有特殊意义的地方发生重大变化的消息；⑤为什么导语，突出报道一个事件的起因。<br>
根据上述定义，下列导语与其分类对应正确的是：]],
    {
      [[A、亲爱的读者，你知道为什么夏天夜空里看到的星星比冬天夜空里看到的多？——④]],
      [[B、1964年10月16日，我国第一颗原子弹爆炸成功——②]],
      [[C、杨先生带着2岁的女儿到市医院看病，没想到看一个“咳嗽”就要花1000多元——①]],
      [[D、谁是高考状元？这个一年一度的热门话题，今年却在XX省消失了——③]],
    },
    [[B]],
  },
  -- 89
  {
    [[子弹时间即计算机辅助的摄影技术模拟变速特效，是一种使用在电影、电视节目或电脑游戏等领域的摄影技术模拟变速特效，例如强化的慢镜头、时间静止等效果。<br>
根据上述定义，下列描述符合子弹时间的是：]],
    {
      [[A、电视剧中，男主角因车祸去世，女主角目睹了这个过程，此后很多年，她的眼前无数次闪现出车祸发生的过程]],
      [[B、江阿姨的丈夫去世之后，她每天的大部分时间都用来反复看他们以前拍摄的视频，时间在她身上似乎静止了]],
      [[C、科幻小说中，小明因考试结束时还没有答完卷子，祈祷时间暂停，然后他发现时间真的静止了，只有他可以答卷]],
      [[D、通过电视转播，观众们看到滑雪运动员的身体缓慢地在空中划出优美的曲线，翻转瞬间的每个动作都无比清晰]],
    },
    [[D]],
  },
  -- 90
  {
    [[联合式构词法是由两个意义相同、相反或相对的词根联合起来构成新词的方法，在词内两个词根是平等的，没有主从、正副之分。<br>
根据上述定义，下列使用了联合式构词法的是：]],
    {
      [[A、“叮当”，因摹拟动作的声音而构成的词]],
      [[B、“椅子”，在单字“椅”后面附加“子”而构成的词]],
      [[C、“蹉跎”，由韵母相同的两个单字组合构成意义与单字无关的词]],
      [[D、“开关”，由“开”和“关”两个单字组合而构成的词]],
    },
    [[D]],
  },
  -- 91
  {
    [[铜镜：化妆镜]],
    {
      [[A、门帘：纱帘]],
      [[B、木碗：汤碗]],
      [[C、金簪：发簪]],
      [[D、瓷瓶：古瓶]],
    },
    [[B]],
  },
  -- 92
  {
    [[小计：总计]],
    {
      [[A、平均值：总值]],
      [[B、被乘数：总数]],
      [[C、单科分：总分]],
      [[D、分目录：总目]],
    },
    [[C]],
  },
  -- 93
  {
    [[海棠红：南瓜橙]],
    {
      [[A、苏丹红：景泰蓝]],
      [[B、孔雀蓝：柠檬黄]],
      [[C、日落黄：鱼肚白]],
      [[D、橄榄绿：梅子青]],
    },
    [[D]],
  },
  -- 94
  {
    [[脱脂棉：原棉]],
    {
      [[A、白酒：烧酒]],
      [[B、黑陶：黏土]],
      [[C、摄像头：镜头]],
      [[D、视力：视力表]],
    },
    [[B]],
  },
  -- 95
  {
    [[匿名投票：实名投票：现场投票]],
    {
      [[A、早间会议：午间会议：工作会议]],
      [[B、战国文字：象形文字：古代汉字]],
      [[C、金融危机：粮食危机：生态危机]],
      [[D、油料作物：糖料作物：经济作物]],
    },
    [[A]],
  },
  -- 96
  {
    [[春季过敏：花粉：喷嚏]],
    {
      [[A、肺炎：咳嗽：支原体]],
      [[B、乙型脑炎：病毒：发热]],
      [[C、失眠：恐惧：噩梦]],
      [[D、秋季腹泻：饮食：脱水]],
    },
    [[B]],
  },
  -- 97
  {
    [[资产评估：审核通过：股票发售]],
    {
      [[A、预定新车：加装内饰：购买车险]],
      [[B、修剪草坪：设备检修：园林养护]],
      [[C、选购家电：上门安装：维修保养]],
      [[D、收看节目：视频连线：观众互动]],
    },
    [[C]],
  },
  -- 98
  {
    [[标清：高清：超清]],
    {
      [[A、亚音速：音速：超音速]],
      [[B、厅级：市级：省级]],
      [[C、迁怒：愤怒：暴怒]],
      [[D、幽静：寂静：安静]],
    },
    [[A]],
  },
  -- 99
  {
    [[深空探测 对于 （    ） 相当于 （    ） 对于 公益组织]],
    {
      [[A、无人采样；慈善捐款]],
      [[B、遥感技术；红十字会]],
      [[C、宇宙空间；公益事业]],
      [[D、火星探测；社会组织]],
    },
    [[D]],
  },
  -- 100
  {
    [[刑事警察 对于 （    ） 相当于 （    ） 对于 对外交涉]],
    {
      [[A、公安机关；维护主权]],
      [[B、刑事案件；驻外武官]],
      [[C、打击犯罪；外交人员]],
      [[D、交通警察；外交领事]],
    },
    [[C]],
  },
  -- 101
  {
    [[深度学习是一系列复杂的算法，使计算机能够识别数据中的模式并作出预测。研究人员利用深度学习技术训练AI系统自动读取视网膜扫描数据，并识别那些在接下来的一年中患心脏病风险较高的人。研究人员认为该项技术有可能彻底改变传统的心脏病筛查方式。<br>
上述论证的成立须补充以下哪项作为前提？]],
    {
      [[A、视网膜扫描数据反映的微小血管变化是预测心脏疾病较为灵敏的指标]],
      [[B、心脏病筛查需要进行复杂且昂贵的超声心动图或心脏磁共振成像检查]],
      [[C、视网膜扫描相对便宜，并且在许多配镜服务中被使用]],
      [[D、AI系统是解开自然界中存在的复杂模式的绝佳工具]],
    },
    [[A]],
  },
  -- 102
  {
    [[人们感受气味通过嗅觉受体实现。研究发现：随着人类的演化，编码人类嗅觉受体的基因不断突变，许多在过去能强烈感觉气味的嗅觉受体已经突变为对气味不敏感的受体，与此同时，人类嗅觉受体的总体数目也随时间推移逐渐变少。由此可以认为，人类的嗅觉经历着不断削弱、逐渐退化的过程。<br>
以下哪项如果为真，最能支持上述结论？]],
    {
      [[A、随着人类进化，嗅觉中枢在大脑皮层中所占面积逐渐减少]],
      [[B、相对于视觉而言，嗅觉在人类感觉系统中的重要性较低]],
      [[C、人类有大约1000个嗅觉受体相关基因，其中只有390个可以编码嗅觉受体]],
      [[D、不同人群之间嗅觉存在很大差异，老年人的嗅觉敏感性明显低于年轻人]],
    },
    [[A]],
  },
  -- 103
  {
    [[调查显示，84.8%%的家长倾向于给孩子购买标有“儿童”字样的食品。几乎每一款“儿童食品”都宣称“无添加，适合孩子健康成长”。家长热衷于购买有“儿童”标签的食品是因为他们觉得，标有“儿童”字样的食品更加营养健康，更适合儿童。<br>
以下哪项如果为真，最能质疑家长的观点？]],
    {
      [[A、我国目前并没有设置专门的“儿童食品”分类，“儿童食品”缺乏专门的法律法规与食品安全国家标准]],
      [[B、孩子在不同年龄阶段，对各种营养物质的需求量会发生变化，而几乎所有“儿童食品”都没有明确的年龄分段和食用提示]],
      [[C、所谓的“儿童食品”，成分通常与普通食品没什么区别，甚至可能因为添加过量的调味物质而有害儿童健康]],
      [[D、儿童食品的外包装设计和食品形状设计都更符合儿童的审美，会导致儿童因为喜欢外形而过量进食]],
    },
    [[C]],
  },
  -- 104
  {
    [[电商直播可以为农产品的营销提供一条有效的渠道，在农产品供应链的运作上要明显优于传统的“农户批发商分销商消费者”模式。但目前在很多地方，电商直播营销模式并没有有效解决农产品卖难买难的问题。有从业者认为只要完善农产品物流配送体系，提高直播人员素质，就能有效解决这一问题。<br>
以下哪项如果为真，不能支持上述从业者的观点？]],
    {
      [[A、直播内容重复单调，易引起消费者审美疲劳，不利于树立起良好的产品形象，影响了农产品直播的效果]],
      [[B、部分地区没有对农产品的生产、包装、运输以及销售等环节制定统一的标准，对农产品的质检投入不足]],
      [[C、在电商直播模式下，对物流的需求会增加，现有的冷链物流水平无法满足日益增长的农产品消费需求]],
      [[D、许多地区的农户居住比较分散，农产品出村进城“最先一公里”的物流运输难题，始终未能完全得到解决]],
    },
    [[B]],
  },
  -- 105
  {
    [[R行星是位于太阳系的一颗小行星，质量不大，平均直径不足500米。在对R行星进行长达一年的观测后，人们发现其表面长期漂浮着砂粒，且砂粒在漂浮一段时间后，还会重新落在行星表面。由于R行星表面没有稳定的大气层，因此人们认为砂粒漂浮的现象主要来自静电，原因是太阳风进入行星表面产生电场时，砂粒会因静电力的作用离开行星表面漂浮游动起来，当没有太阳风时，砂粒又会回落下来。<br>
以下哪项如果为真，没有质疑上述观点？]],
    {
      [[A、R行星与彗星组成类似，彗星靠近太阳时，受太阳风产生的静电影响，其表面砂粒将会漂浮]],
      [[B、R行星表面存在一氧化碳、干冰等挥发性物质，其升华会带动砂粒的释放与漂浮]],
      [[C、R行星质量小，静电作用只能扬起毫米级的砂粒，但目前其表面漂浮的砂粒尺寸都很大]],
      [[D、R行星自转速度快，星球上的物体受到离心作用强，其表面尘埃与石块会脱离引力束缚，剥落散逸]],
    },
    [[A]],
  },
  -- 106
  -- 该题已被删除，因为是资料分析题
  -- 107
  -- 该题已被删除，因为是资料分析题
  -- 108
  -- 该题已被删除，因为是资料分析题
  -- 109
  -- 该题已被删除，因为是资料分析题
  -- 110
  -- 该题已被删除，因为是资料分析题
  -- 111
  -- 该题已被删除，因为是资料分析题
  -- 112
  -- 该题已被删除，因为是资料分析题
  -- 113
  -- 该题已被删除，因为是资料分析题
  -- 114
  -- 该题已被删除，因为是资料分析题
  -- 115
  -- 该题已被删除，因为是资料分析题
  -- 116
  -- 该题已被删除，因为是资料分析题
  -- 117
  -- 该题已被删除，因为是资料分析题
  -- 118
  -- 该题已被删除，因为是资料分析题
  -- 119
  -- 该题已被删除，因为是资料分析题
  -- 120
  -- 该题已被删除，因为是资料分析题
  -- 121
  -- 该题已被删除，因为是资料分析题
  -- 122
  -- 该题已被删除，因为是资料分析题
  -- 123
  -- 该题已被删除，因为是资料分析题
  -- 124
  -- 该题已被删除，因为是资料分析题
  -- 125
  -- 该题已被删除，因为是资料分析题
  -- 126
  -- 该题已被删除，因为是资料分析题
  -- 127
  -- 该题已被删除，因为是资料分析题
  -- 128
  -- 该题已被删除，因为是资料分析题
  -- 129
  -- 该题已被删除，因为是资料分析题
  -- 130
  -- 该题已被删除，因为是资料分析题
}

return questions
