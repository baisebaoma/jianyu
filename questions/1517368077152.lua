-- 试卷来源：https://www.gkzenti.cn/paper/1517368077152，答案来源：https://www.gkzenti.cn/answer/1517368077152，
-- 由爬虫自动生成，请手动检查：
-- 1. 添加公式/删除其中含有图片、含有资料的题目；
-- 2. 修改英文冒号为中文冒号；
-- 3. 修改百分号为双百分号；
-- 4. 把所有填入画横线部分的线画出来。
-- 已检查在此打勾：【v】

local questions = {
  -- 1
  {
    [[《中华人民共和国民法总则》自2017年10月1日起施行。关于民法总则和民法通则的关系，下列说法错误的是：]],
    {
      [[A、民法总则施行后，民法通则暂不废止]],
      [[B、民法通则规定了我国民法的基本规则，而民法总则的内容更加广泛]],
      [[C、民法总则是编纂民法典的第一步，吸取和借鉴了民法通则的相关条款]],
      [[D、民法通则规定向人民法院请求保护民事权利的诉讼时效期间为二年，民法总则将其改为三年]],
    },
    [[B]],
  },
  -- 2
  {
    [[我国宪法对非公有制经济的规定进行了几次修改，按时间先后排序正确的是：<br>
①允许发展私营经济，采取“引导、监督、管理”的方针<br>
②在法律规定范围内的个体经济、私营经济等非公有制经济，是社会主义市场经济的重要组成部分<br>
③鼓励、支持和引导非公有制经济的发展，并对非公有制经济依法实行监督和管理<br>
④非公有制经济仅限于个体经济，不包括私营经济，且个体经济处于补充地位]],
    {
      [[A、①②④③]],
      [[B、①③②④]],
      [[C、④①③②]],
      [[D、④①②③]],
    },
    [[D]],
  },
  -- 3
  {
    [[下列关于国家监察体制改革试点的说法错误的是：]],
    {
      [[A、试点地区预防腐败局的相关职能被整合进监察委员会]],
      [[B、试点地区的监察委员会从属于行政系统]],
      [[C、试点地区的监察委员会由人民代表大会产生]],
      [[D、在北京市、山西省、浙江省开展国家监察体制改革试点]],
    },
    [[B]],
  },
  -- 4
  {
    [[下列关于“三农”问题的说法错误的是：]],
    {
      [[A、民政部门是农民专业合作社登记机关]],
      [[B、征地补偿费的使用、分配方案，经村民会议讨论决定方可办理]],
      [[C、深入推进农业供给侧结构性改革是当前和今后一个时期农业农村工作的主线]],
      [[D、村民委员会作出的决定侵害村民合法权益的，受侵害的村民可以申请人民法院予以撤销]],
    },
    [[A]],
  },
  -- 5
  {
    [[关于2015年中央军委改革工作会议召开以来进行的改革，下列说法错误的是：]],
    {
      [[A、全面停止军队有偿服务活动]],
      [[B、组建中央军委联勤保障部队]],
      [[C、军委机关由多部门制改为总部制]],
      [[D、成立陆军领导机构和战略支援部队]],
    },
    [[C]],
  },
  -- 6
  {
    [[下列情形所反映的权利类别与其他三项不同的是：]],
    {
      [[A、李女士送修电动车，后拒不支付修车费，店老板遂留置电动车]],
      [[B、小张向老刘借款6000元，并将祖传玉镯交与老刘，二人约定三年内还钱取镯，否则老刘有权变卖玉镯获偿]],
      [[C、某银行向购房人王先生发放了一笔按揭贷款，贷款期限25年]],
      [[D、某公司在地方政府组织的拍卖会上拍得一块土地，用于日后的商业开发]],
    },
    [[D]],
  },
  -- 7
  {
    [[下列情形中，甲和乙只需承担双方责任，无需承担共同责任的是：]],
    {
      [[A、甲养的羊误入乙的菜地，乙发现后不管不问导致损失扩大]],
      [[B、甲乙共同实施了故意伤害行为]],
      [[C、甲乙合伙办了一家快递企业，乙在运输过程中丢失包裹]],
      [[D、甲与乙协商共同买下一套房屋，二人约定各欠卖方十万元房款]],
    },
    [[A]],
  },
  -- 8
  {
    [[下列对法谚的解读正确的是：]],
    {
      [[A、法无授权不可为——每个公民都应当严格按照法律的规定作为]],
      [[B、枪炮作响法无声——战乱时，平常法律所维系的社会秩序荡然无存]],
      [[C、法律必须被信仰，否则它将形同虚设——法律规定与道德信仰相辅相成，互相促进]],
      [[D、法不阿贵，绳不挠曲——即使初衷是好的，如果触犯了法律还是要一视同仁]],
    },
    [[B]],
  },
  -- 9
  {
    [[下列哪一说法符合我国劳动合同法的规定？]],
    {
      [[A、王某3月1日与用人单位签订劳动合同，3月5日正式上班，劳动关系自3月1日起建立]],
      [[B、李某在签订劳动合同时，用人单位为防止其反悔，可向其收取500元押金做担保]],
      [[C、张某所在甲公司与另外一公司合并成立了乙公司，应由乙公司继续履行与之签订的劳动合同]],
      [[D、赵某在甲公司任职，同时在乙公司做兼职翻译，乙公司应当与其订立书面劳动合同]],
    },
    [[C]],
  },
  -- 10
  {
    [[下列有关律师的说法错误的是：]],
    {
      [[A、律师不得在同一案件中为双方当事人担任代理人]],
      [[B、律师根据案情的需要，可以申请人民法院通知证人出庭作证]],
      [[C、律师可以在多个律师事务所执业，律师执业不受地域限制]],
      [[D、律师担任辩护人的，有权查阅、摘抄、复制本案的案卷材料]],
    },
    [[C]],
  },
  -- 11
  {
    [[甲乙丙三人从丁处购买我国公民的个人信息，并组织人员利用网络电话实施诈骗行为，获利一百余万元，并由戊负责转账。下列说法错误的是：]],
    {
      [[A、若甲乙丙三人在境外实施该电信网络诈骗行为，则不予追究刑事责任]],
      [[B、甲乙丙三人为组织者，三人对全部的诈骗行为承担责任]],
      [[C、丁明知甲乙丙三人实施电信网络诈骗犯罪，依然非法向其出售公民个人信息，丁为共犯]],
      [[D、戊明知款项为诈骗所得，仍帮助甲乙丙在不同银行账户间频繁划转，戊为共犯]],
    },
    [[A]],
  },
  -- 12
  {
    [[甲乙两公司签订钢铁买卖合同，并约定货到付款。甲公司交货前夕得知乙公司全部账户因民事纠纷已被冻结，遂决定暂不向乙公司交货。关于甲公司的行为，下列说法正确的是：]],
    {
      [[A、因合同约定货到付款，甲公司能履行合同中的交货义务而不履行，属于违约行为]],
      [[B、甲公司决定暂不向乙公司交货后，应及时将此事告知乙公司]],
      [[C、甲公司可以依法要求乙公司先付款再交货]],
      [[D、甲公司将暂不交货的决定告知乙公司后，买卖合同自行解除]],
    },
    [[B]],
  },
  -- 13
  {
    [[下列与我国农村土地产权制度有关的说法错误的是：]],
    {
      [[A、不得以退出土地承包权作为农民进城落户的条件]],
      [[B、农村土地农民集体所有是农村基本经营制度的根本]],
      [[C、家庭承包经营的重要特征是土地所有权和承包经营权分离]],
      [[D、农村集体土地使用权不包括宅基地使用权]],
    },
    [[D]],
  },
  -- 14
  {
    [[下列金融机构与其可以从事的金融业务对应正确的是：]],
    {
      [[A、商业银行——股票承销业务]],
      [[B、人寿保险公司——医疗责任保险业务]],
      [[C、小额贷款公司——城乡居民储蓄存款业务]],
      [[D、中国出口信用保险公司——海外投资保险业务]],
    },
    [[D]],
  },
  -- 15
  {
    [[下列研究课题与其查阅的主要参考文献对应错误的是：]],
    {
      [[A、商周时代的艺术成就——《中国青铜时代》]],
      [[B、南宋都城的城市建设——《从平城到洛阳》]],
      [[C、晚清的政治改良运动——《从甲午到戊戌》]],
      [[D、明末中西文化交流史——《利玛窦与中国》]],
    },
    [[B]],
  },
  -- 16
  {
    [[某高校学生会干事小王负责策划一个民族文化展示周活动，下列哪个设计方案不合适？]],
    {
      [[A、请维吾尔族学生表演手鼓舞]],
      [[B、请蒙古族学生制作奶茶]],
      [[C、请朝鲜族学生展示唐卡]],
      [[D、请彝族学生展示花腰刺绣]],
    },
    [[C]],
  },
  -- 17
  {
    [[美国社会学家帕森斯认为：在公元前的第一个千年之内，“哲学的突破”以截然不同的方式分别发生在希腊、以色列、印度和中国等地。下列思想观点产生于这一时代的是：]],
    {
      [[A、致虚守静，道法自然]],
      [[B、心外无物，心外无理]],
      [[C、人民为主，工商皆本]],
      [[D、师夷长技，中体西用]],
    },
    [[A]],
  },
  -- 18
  {
    [[假如地球重力加速度减为现在的一半，下列数值不会发生变化的是：]],
    {
      [[A、鱼在相同水深下受到的压强]],
      [[B、船在水中的吃水深度]],
      [[C、人在体重计上的称量结果]],
      [[D、人可以举起的石块的最大质量]],
    },
    [[B]],
  },
  -- 19
  {
    [[关于下列地区的说法错误的是：]],
    {
      [[A、欧洲北海：既是著名产油区，又是著名渔场]],
      [[B、波斯湾地区：既是著名产油区，又是古文明发祥地]],
      [[C、湄公河流域：既是小麦主产区，又是佛教圣地]],
      [[D、五大湖区：既有世界上面积最大的淡水湖，又跨美加两国边境线]],
    },
    [[C]],
  },
  -- 20
  {
    [[下列与果树有关的说法正确的是：]],
    {
      [[A、富含氮的肥料可促进果树开花结果]],
      [[B、杏树是耐旱能力比较弱的树种]],
      [[C、冬季不需要对果树进行病虫防治]],
      [[D、嫁接是一种常用的果树繁殖方式]],
    },
    [[D]],
  },
  -- 21
  {
    [[生命在于运动，运动能塑造我们强健的身体，增强抵抗疾病的能力。当然，它对大脑也是有益的。但事实上，运动应该________，否则会使人反应迟钝。长时间大强度运动会使脑组织兴奋性降低，会使能源物质ATP（腺嘌呤核苷三磷酸）耗竭，对大脑机能造成损害。<br>
填入画横线部分最恰当的一项是：]],
    {
      [[A、因人而异]],
      [[B、张弛有道]],
      [[C、适可而止]],
      [[D、循序渐进]],
    },
    [[C]],
  },
  -- 22
  {
    [[如今，一批70后、80后甚至更年轻的年画传承人涌现出来。这些年轻人开始有了清醒的文化自觉，对中华传统文化怀有浓厚的兴趣，怀着敬畏之心钻研，并不________，急于进入市场大潮，冯骥才称他们为“年画的新力量”。<br>
填入画横线部分最恰当的一项是：]],
    {
      [[A、随波逐流]],
      [[B、沽名钓誉]],
      [[C、好高骛远]],
      [[D、人云亦云]],
    },
    [[A]],
  },
  -- 23
  {
    [[在联合国教科文组织通过的《文化多样性宣言》和《保护非物质文化遗产公约》里，文化的多样性都被比喻成生物的多样性。因为人类的文化创造和遗存就像人类的基因，包含了过去世代累积的信息和发展的可能性。有些看似________的东西，今天不知道它有什么重要性，但以后可能会影响到人类的发展。<br>
填入画横线部分最恰当的一项是：]],
    {
      [[A、司空见惯]],
      [[B、转瞬即逝]],
      [[C、微不足道]],
      [[D、一成不变]],
    },
    [[C]],
  },
  -- 24
  {
    [[中俄计划携手建设从莫斯科出发，穿越哈萨克斯坦通往北京的欧亚高速运输走廊。新铁路的兴建可能要耗时八至十年。从工程的规模及价值来看，它堪与苏伊士运河________。后者大幅缩短了通航里程及时间，迅速对全球贸易产生了________的影响。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、比肩  不可估量]],
      [[B、媲美  旷日持久]],
      [[C、争雄  超乎预期]],
      [[D、匹敌  源源不断]],
    },
    [[A]],
  },
  -- 25
  {
    [[一项世界规模的宏基因组研究显示，含耐药基因的微生物在自然界中________。这意味着人类有可能回到没有抗生素的时代，医疗体系中的很大一部分可能会退回到抗生素发明之前的境地，轻微的细菌感染都可能引起________的后果。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、比比皆是  意外]],
      [[B、不可胜数  可怕]],
      [[C、千差万别  严重]],
      [[D、无处不在  致命]],
    },
    [[D]],
  },
  -- 26
  {
    [[历史认识的局限性成就了历史研究的魅力。历史认识有局限性，才需要人们不断拷问、修正和创新。如果研究者因此而敬畏研究对象，兢兢业业，________，这正是历史研究的幸事。反之，如果把历史认识的局限性作为规避责任的遁词和主观臆断的托词，人们就会愈发相信历史毫无________可言。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、身体力行  科学性]],
      [[B、恪尽职守  公平性]],
      [[C、如履薄冰  客观性]],
      [[D、谨言慎行  系统性]],
    },
    [[C]],
  },
  -- 27
  {
    [[射电天文学的进步把人们的视线引向了宇宙遥远的边缘，那里________了更多有关宇宙起源和演化的关键线索。天文学家都渴望拥有威力更加强大的射电望远镜，谁拥有了这种望远镜，谁就更有可能站立在现代物理学和天文学的潮头，________，成为破解宇宙之谜的领军力量。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、暗藏  胜券在握]],
      [[B、隐藏  捷足先登]],
      [[C、埋藏  首当其冲]],
      [[D、潜藏  独占鳌头]],
    },
    [[B]],
  },
  -- 28
  {
    [[黄河三角洲是中国大河三角洲中海陆变迁最________的地区，特别是黄河口地区造陆速率之快、尾闾迁徙之频繁，更为世界罕见。黄河三角洲的________受黄河水沙条件和海洋动力作用的制约，黄河来沙使海岸堆积向海洋推进，海洋动力作用又使海岸侵蚀向陆地推进。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、壮观  形成]],
      [[B、复杂  形态]],
      [[C、剧烈  演化]],
      [[D、活跃  演变]],
    },
    [[D]],
  },
  -- 29
  {
    [[情绪并不是独立存在的，它常常伴随着信息而传播。作为一种态度，情绪不仅能够________人们对所传播信息的认知，还会在一定程度上指导人们的行为。积极的情绪会促进人们积极地认识世界，消极的情绪则可能给他人甚至整个社会带来破坏性后果。人在情绪失控时，很容易不顾后果地做出________的举动。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、影响  危险]],
      [[B、左右  出格]],
      [[C、干扰  反常]],
      [[D、支配  冲动]],
    },
    [[B]],
  },
  -- 30
  {
    [[开花的塔黄零星分布在空旷的流石滩上，蕈蚊是如何及时发现它们的呢？原来蕈蚊头上的触角就像人类的鼻子，能感受并________不同的气味。开花的塔黄会挥发20多种化合物，其中一种不常见的化合物（二甲基丁酸甲酯）占所有化合物的左右。野外诱导试验证实，这种化合物可以________传粉的蕈蚊，为其“导航”。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、记忆  引诱]],
      [[B、区分  吸引]],
      [[C、识别  刺激]],
      [[D、追踪  迷惑]],
    },
    [[B]],
  },
  -- 31
  {
    [[秦岭阻挡了中国腹地南北气候的交互，却挡不住秦巴两地行者的脚步。无论是“明修栈道，暗度陈仓”，还是“一骑红尘妃子笑”，都与一条条秦岭古道________。这些古道就如同一条条经线，沟通了关中与巴蜀，见证了中国历史的朝代兴替与政经融通，________出不少故事与传说。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、密不可分  演绎]],
      [[B、交相辉映  衍生]],
      [[C、休戚与共  涌现]],
      [[D、相伴相生  催生]],
    },
    [[A]],
  },
  -- 32
  {
    [[医疗改革方案将引导医疗机构、医务人员，通过提供更多更好的诊疗服务，获得________的补偿。对于过度治疗问题，该方案是一种________的做法，它让医生的收入与所开的药物、检查脱钩，让医疗工作者的劳动收入真正体现在明处。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、合法  立竿见影]],
      [[B、公正  行之有效]],
      [[C、适度  一劳永逸]],
      [[D、合理  釜底抽薪]],
    },
    [[D]],
  },
  -- 33
  {
    [[早在上世纪70年代末，钱学森就曾多次提出：国防科技的发展不能________于“追尾巴”“照镜子”，而是要________地开拓新领域和新方向。比如英国人针对重机枪机动性差的弱点，发明了坦克，一举撕裂了枪炮林立的僵持局面。这类非对称式的发展思路有助于打破先进国家的技术垄断，形成后发优势。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、拘泥  与众不同]],
      [[B、满足  独辟蹊径]],
      [[C、沉迷  标新立异]],
      [[D、止步  别具匠心]],
    },
    [[B]],
  },
  -- 34
  {
    [[就文学创作而言，人工智能未来有可能在编剧或网络文学方面有所________，毕竟除了一小部分杰出的作品外，无论剧本创作还是网络文学，都比较依赖标准化的情节与词语搭配。而文学作品的________程度越高，越有可能人工智能化。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、建树  程式化]],
      [[B、发展  通俗化]],
      [[C、贡献  规范化]],
      [[D、突破  模式化]],
    },
    [[D]],
  },
  -- 35
  {
    [[大国兴衰构成了世界历史的重要篇章，许多学者和政治家________探寻其中的逻辑线索，产生了许多著述宏论。然而，对大国兴衰的原因难有最终答案，这不仅在于问题本身的________，更是因为世界在变化，不同国家兴衰的轨迹不可能简单重复。因此，对这一问题的探讨永远不会________。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、殚精竭虑  阶段性  终结]],
      [[B、废寝忘食  多样性  沉寂]],
      [[C、呕心沥血  复杂性  过时]],
      [[D、兢兢业业  模糊性  停止]],
    },
    [[C]],
  },
  -- 36
  {
    [[近年来，西方观众对中国功夫片的套路、动作、术语等已颇为熟悉，中国功夫的神秘感、陌生感在他们眼中逐渐________，所以中国功夫片要体现作品的，很有难度。当下国产功夫电影在制作和传播方面并非________，收获的口碑和奖杯都很难超越传统功夫片。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、淡化  独特性  高枕无忧]],
      [[B、消失  差异性  一帆风顺]],
      [[C、褪去  艺术性  无懈可击]],
      [[D、消逝  创新性  尽善尽美]],
    },
    [[B]],
  },
  -- 37
  {
    [[一方面，受世界经济________影响，大宗资源产品价格走低，资源型企业纷纷陷入困境，资源型城市财政收入也急剧下降，无力增加投入；另一方面，随着经济发展进入新常态，大规模经济刺激已经________，来自中央政府的强力支持相应减弱，资源型城市债务扩张趋于收紧。资源型城市转型面临的资金约束日益________。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、下行  失效  紧张]],
      [[B、萎缩  放缓  强化]],
      [[C、低迷  弱化  严重]],
      [[D、恶化  减退  明显]],
    },
    [[C]],
  },
  -- 38
  {
    [[一些人对传统文化的理解存在误区，认为凡是老祖宗传下来的文化遗产，就不能有丝毫的改变，必须在当代________地得到传承。这种认识或许有助于________传统文化的经典性，但这也决定了传统文化只能被小众欣赏。这名为保护传统，实则________了传统与现实，终将使得传统文化被历史尘埃所湮没。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、一板一眼  凸显  混淆]],
      [[B、原汁原味  维护  模糊]],
      [[C、原封不动  保持  割裂]],
      [[D、一字不差  发扬  阻断]],
    },
    [[C]],
  },
  -- 39
  {
    [[漆画有其他画种达不到的效果，同时也有它的________。它不能像油画、水粉画那样自由地运用冷暖色彩，不能像素描那样丰富地运用明暗层次，不善于逼真地、________地再现对象。事实上，在似与不似之间表现对象，才是漆画最________的地方。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、问题  出神入化  出色]],
      [[B、短板  惟妙惟肖  难得]],
      [[C、缺陷  面面俱到  独到]],
      [[D、局限  栩栩如生  擅长]],
    },
    [[D]],
  },
  -- 40
  {
    [[在执行任务期间，“反潜持续追踪无人艇”一旦发现目标的________，就会使用声纳系统对目标进行________定位并跟踪，同时借助传感器技术进行信息________。逼近目标时，无人艇会通过声学图像，确定目标潜艇的型号等信息，再将数据传输到反潜指挥中心，由中心指派就近的反潜平台赶往目标海域，摧毁敌艇。<br>
依次填入画横线部分最恰当的一项是：]],
    {
      [[A、踪迹  精确  搜集]],
      [[B、意图  精准  汇总]],
      [[C、动向  主动  筛选]],
      [[D、线索  自动  匹配]],
    },
    [[A]],
  },
  -- 41
  {
    [[烙画古称“火针刺绣”，是一门传承千年的艺术。烙画以火为“墨”，用火烧热特制铁笔，在物体上烫出烙痕作画，因炭化程度不同而呈现出浅褐色、深褐色和黑色等色调。烙画讲究火候和力度，讲究轻重缓急、深浅浓淡，一支铁笔在手，下笔的力度和时机都决定着画作的质量，任何环节掌握不好都会功亏一篑。<br>
这段文字主要介绍了：]],
    {
      [[A、评价烙画水平的标准]],
      [[B、烙画制作工艺的特点]],
      [[C、制作烙画的关键环节]],
      [[D、烙画独有的艺术魅力]],
    },
    [[B]],
  },
  -- 42
  {
    [[食品行业是关系人民群众切身需求与经济社会和谐稳定的民生行业。但目前来看，我国食品供给体系总体呈现出中低端产品过剩、中高端和个性化产品供给严重不足的问题，消费者对国外产品的依赖程度越来越高。特别在当前速度换挡、结构调整、动力转换的经济新常态下，深入推进食品行业供给侧改革，是实现食品行业健康、长远发展的必然选择。食品标准既是国家食品安全治理体系中的重要组成部分，又是引导食品生产质量的主要风向标，因此，深化食品行业供给侧结构性改革的关键在于构建一套先进的食品行业标准。<br>
这段文字接下来最可能讲的是：]],
    {
      [[A、目前国内食品行业存在的主要问题]],
      [[B、国外构建食品行业标准的经验教训]],
      [[C、构建食品行业标准要重点关注的问题]],
      [[D、深化食品行业供给侧改革的具体措施]],
    },
    [[C]],
  },
  -- 43
  {
    [[南京在历史上的名字变化或褒或贬，根本源头在于统治者的好恶。不惟南京，同样原因也引发了其他地名的变迁，宋廷平定方腊起义之后，深恨江南百姓造反，艺术修养最高的皇帝宋徽宗遂在地名上做文章：方腊的两个活动区域，歙州被改成徽州，取的是“徽”的本意“捆绑束缚”；睦州则被改成严州，意思更是不言自明的。相比之下，朱元璋为避国号讳，取“海定则波宁”之义，将明州改成宁波，已是很“友好”了。<br>
这段文字主要介绍了：]],
    {
      [[A、地名变迁背后的政治因素]],
      [[B、历史事件对地名的影响]],
      [[C、古代帝王在地名方面的偏好]],
      [[D、统治者对某些地域的好恶]],
    },
    [[A]],
  },
  -- 44
  {
    [[从医学角度看，非酒精性脂肪肝是因为脂代谢紊乱等多种因素引起了肝细胞内中性脂肪（主要是甘油三酯和脂肪酸）过度堆积。脂代谢紊乱引发的多种重要组织损伤，特别是心脑血管和肝脏损害，对健康造成极大威胁，因此其机制和防治策略研究一直是国际上医学研究的前沿领域。专家指出，尽管饮食控制和改变生活方式对高脂血症及脂肪肝有明显的改善作用，但在现实生活中很难实施，患者往往由于各种因素不能严格执行医嘱。到目前为止，人类尚未研发出可以彻底根治和阻止肝脏脂代谢紊乱的有效药物。<br>
关于脂代谢紊乱，文中没有提及：]],
    {
      [[A、主要危害]],
      [[B、研究状况]],
      [[C、改善途径]],
      [[D、发病机理]],
    },
    [[D]],
  },
  -- 46
  {
    [[新工业革命浪潮中，很多制造业大国都在押注智能制造。中国既是制造大国，也是使用大国，如果数据是工业4.0时代创造价值的原材料，那中国无疑是资源最多的国家。但数据并不会直接创造价值，就像是现金流而非固定资产决定一个企业的兴衰一样。真正为企业带来价值的是数据流，是数据经过实时分析后及时地流向决策链的各个环节，成为面向用户、创造价值与服务的内容和依据。虽然德国是工业4.0的发起者，但作为控制器、物联网技术和生产设备的提供者，德国只是基础技术的供应商，直接面向客户的价值创造端却是中国。<br>
这段文字意在强调：]],
    {
      [[A、我国在新工业革命浪潮中面临新的机遇]],
      [[B、我国应当充分挖掘数据资源的潜在价值]],
      [[C、数据资源拥有者在智能制造方面更具优势]],
      [[D、数据流是企业在工业4.0时代领先的关键]],
    },
    [[B]],
  },
  -- 47
  {
    [[自海洋石油钻井平台、潜艇等超大型货物相继出现以来，半潜船才渐渐找寻到自己的用武之地。半潜船装运货物既可利用独特的沉浮方式，又能借助码头设施采用滚装、滑装、吊装等多种方式，具有很强的灵活性和方便性。此外，半潜船大多具有自航能力，航速可达到15节以上，能大大缩短重要设备的运输周期。同时，由于自身携带设备少，燃料消耗少，半潜船续航能力可达到数万公里。更为重要的是，半潜船是通过半潜方式在水中航行，吃水较深，甲板常常与水面一致，因而抗击大风大浪的稳定性极高。<br>
根据这段文字，以下说法正确的是：]],
    {
      [[A、半潜船仅能采用沉浮方式装载货物]],
      [[B、半潜船的主要不足是速度相对缓慢]],
      [[C、半潜船较稳是由于航行时吃水较深]],
      [[D、在超大型货物出现后半潜船才出现]],
    },
    [[C]],
  },
  -- 48
  {
    [[民族的文化传统和历史的文化信息被大量地记载于历史经典文献中。除了经典文献，还有各种各样的历史文物，作为历史文化的载体被代代相传地保存下来。传统村落就是这样一个历史文化载体，相对于经典文献和文物，它所承载的有关中华民族文化的历史信息更具鲜活性，是中华民族文明发展史的“实证”。它比文字、文物更能真实地反映中华民族不同地域、不同族群的生产生活方式、道德伦理观念以及民族习俗风情。因此，我们有充分的理由重视传统村落，保护传统村落。<br>
这段文字意在强调：]],
    {
      [[A、保护传统村落对保护民族历史文化有着重要意义]],
      [[B、应采取多种方式和途径传承、保护民族历史文化]],
      [[C、传统村落是中华历史文化的重要载体和现实体现]],
      [[D、传统村落文化较之经典文献更能鲜活地展现历史]],
    },
    [[A]],
  },
  -- 49
  {
    [[随着智能手机的功能不断增加，手机电池有限的续航能力已不能满足待机需要，充电宝顺理成章地成为高频应用。而共享充电准入门槛低，线下布局容易，只要抓住“流量”和“刚需”，共享充电几乎是一桩可以看得见盈利的生意。随着标准的最后敲定，5G时代或在2019~2020年到来。进入5G时代，视频内容、视频电话、视频直播、高清网络游戏等都将考验手机电池的续航能力，成熟的共享充电场景或将消除这一顾虑。<br>
这段文字主要介绍了共享充电的：]],
    {
      [[A、盈利模式]],
      [[B、应用场景]],
      [[C、销售策略]],
      [[D、市场前景]],
    },
    [[D]],
  },
  -- 50
  {
    [[科学的发展总带给人类崭新的思维方式。比如，在大数据背景下，人类的许多行为都是可以被预测的。从这个角度看，人类的行为并不是互不相关的独立事件，而是相互关联的数据网络中的一个片段。在这张数据大网之中，许多事件的相关性与其发展的规律变得有迹可寻。再比如，日常生活中，我们只能感知和意识到三维世界，而超弦理论却把我们带进一个十维的宇宙世界，带来新的科学思维与方法，开拓出一个新颖刺激而富有美感的精神新领域。<br>
下列最适合做这段文字标题的是：]],
    {
      [[A、独领风骚的数据科学]],
      [[B、未来世界的无限可能]],
      [[C、科学思维无所不在]],
      [[D、科学之光点亮思维]],
    },
    [[D]],
  },
  -- 51
  {
    [[自然资源核算的对象，主要是矿产、森林、耕地和水资源等。挪威和加拿大等林业发达的国家，会更重视森林资源的核算。我国则主要强调森林、耕地和水资源的核算。这是因为矿产和化石能源固然重要，但其市场化程度也非常高。然而，森林、耕地和水资源的性质完全不同。它们向人类提供的“产品”，如粮食、木材和水产等，只是其贡献的一部分，更重要的还是其提供的生态服务，如承载生态系统、维护生物多样性等，所有这些生态服务都是不能进口的。<br>
这段文字主要说明：]],
    {
      [[A、我国为什么选择特定自然资源为主要核算对象]],
      [[B、正确选择自然资源核算对生态文明建设很重要]],
      [[C、不同国家对自然资源核算对象的选择各有偏重]],
      [[D、矿产和化石能源与其他资源在性质上存在不同]],
    },
    [[A]],
  },
  -- 52
  {
    [[①有些鸟类就因为食物缺乏、体能补充不足而夭折在迁徙途中<br>
②迁徙距离愈远，消耗脂肪愈多<br>
③因此，鸟类栖息地食物的充足就显得极为重要<br>
④飞越沙漠和大海的迁徙鸟类，由于途中无法获取食物，必须不停顿地一次完成迁徙，故而需要存储的脂肪更多一些<br>
⑤有的鸟种迁飞前脂肪积累可达体重的，有的鸟种迁飞结束时减重可达<br>
⑥鸟类迁徙期间的能量消耗完全依赖体内以脂肪形式储存的能量<br>
将以上6个句子重新排列，语序正确的是：]],
    {
      [[A、⑥②④⑤③①]],
      [[B、⑥③①②⑤④]],
      [[C、④⑤⑥②①③]],
      [[D、④②③①⑤⑥]],
    },
    [[A]],
  },
  -- 53
  {
    [[①以此来看，种植一些价廉物美的乡土草木，更易于达到上述效果，更能满足适地、适物以及“好种、好管、好活、好看”的绿化需求<br>
②绿化具有生态、经济和社会三种效益<br>
③所以在城市绿化上选择这些乡土草木资源，更能体现自己的品牌和地方特色，有助于营造有特色的园林城市风格<br>
④城市绿化是以栽种植物来改善城市环境的活动<br>
⑤乡土草木资源是长期自然选择的结果，不仅能适应本地的生态环境，而且不需要特别的投入<br>
⑥同时，各个城市都有不同的市情，有的城市还有自己的市花、市树<br>
将以上6个句子重新排列，语序正确的是：]],
    {
      [[A、②⑤⑥③①④]],
      [[B、④②①⑤⑥③]],
      [[C、②①④⑤③⑥]],
      [[D、④③⑤①⑥②]],
    },
    [[B]],
  },
  -- 54
  {
    [[绿叶蔬菜中的硝酸盐被人体摄入后，一部分不吸收而被大肠细菌利用，最终排出体外；另一部分被吸收，在几个小时当中逐渐缓慢转变成微量的亚硝酸盐。亚硝酸盐的存在时间只有几分钟，然后转变成一氧化氮，发挥扩张血管的作用。换句话说，如果需要亚硝酸盐扩张血管的作用，完全用不着吃剩菜；而且一次性大量摄入亚硝酸盐是有害的，摄入硝酸盐之后，在体内缓慢转变成亚硝酸盐，才能发挥有益作用。<br>
这段文字反驳了哪种观点？]],
    {
      [[A、人体无法避免摄入亚硝酸盐]],
      [[B、亚硝酸盐对人体有害]],
      [[C、过量食用绿叶蔬菜也有风险]],
      [[D、吃剩菜可以扩张血管]],
    },
    [[D]],
  },
  -- 55
  {
    [[进行骨髓移植的前提条件是有配型成功的捐赠者。双胞胎配型成功几率最高，兄弟姐妹也有可能。但在中国，20世纪70年代到现在，大多数都是独生子女，有兄弟姐妹且能配型成功的概率也非常低。另外，父母和子女之间骨髓配型成功的概率非常低，几乎为零。因此，绝大多数患者都必须依赖不认识的志愿者配型。非亲缘关系骨髓配型成功的几率只有几十万至几百万分之一，________。<br>
填入画横线部分最恰当的一句是：]],
    {
      [[A、即使这样，骨髓移植仍是大多数血液疾病患者的唯一希望]],
      [[B、如果冒着风险使用不完美的配型，成功率自然会大为降低]],
      [[C、骨髓库里志愿者样本的多少，直接决定着病人找到合适配型的几率]],
      [[D、志愿者捐献固然很重要，国家相关政策的落实和执行也是当务之急]],
    },
    [[C]],
  },
  -- 56
  {
    [[农村社区化建设目前尚处于探索阶段。“村改居”是城镇化发展的具体表现，也是公共服务向农村社区延伸、让农民共享改革发展成果的必然要求。长期以来，城乡二元结构导致城市与农村割裂发展，农村地区发展滞后，公共服务能力薄弱。在城镇化大潮中的“村改居”，就是要打破城乡分治的制度藩篱，因地制宜地让农民也能享受到和城里人一样的社会保障和公共服务。各地经济发展水平不一、农民对公共服务的要求各异，这就决定了“村改居”的路径、公共服务的提供种类和农村社区的保障水平等必然“因村而异”。<br>
这段文字意在强调：]],
    {
      [[A、“村改居”是农村社区化建设的有益探索]],
      [[B、“村改居”顺利推进的要领在于因地制宜]],
      [[C、城乡共享公共服务是农村发展的关键一步]],
      [[D、打破城乡二元界限才能促进城镇化的发展]],
    },
    [[B]],
  },
  -- 57
  {
    [[隐身战机目前主要依靠外形设计和材料表面涂层，来降低其可探测性，实现雷达隐身。但是，受现有技术和材料水平以及战机制造难度、机动性能，造价与后续费用、维护保障方便性等诸多限制，隐身战机不得不在上述几方面做出一定平衡，因此一般不可能实现全方位和全电磁波段的所谓全隐身，特别是它在执行特殊任务，携带或挂载暴露在机体外的非隐形配置时，隐身能力要下降很多。<br>
这段文字意在：]],
    {
      [[A、介绍制造隐身战机的困境]],
      [[B、分析隐身战机的设计缺陷]],
      [[C、探讨隐身战机的技术难点]],
      [[D、阐述隐身战机的隐身原理]],
    },
    [[B]],
  },
  -- 58
  {
    [[干扰致偏是对抗精确制导武器打击的一种有效手段。精确制导武器之所以威胁巨大，关键在于能够直击要害。高精度打击的前提是弹载制导机构必须准确锁定目标，并实时接收制导修正信号。如果制导信号被压制干扰，或修正信息不准确，制导武器就无法精确命中目标，威力大打折扣。如果说传统的伪装防护技术是利用“易容术”将目标隐藏起来，干扰致偏防护技术就是给来袭导弹戴上“磨砂镜”，让其看不清、瞄不准，使制导机构沿着错误的方向偏离目标，而且这种技术对于无法转入地下的重要阵地目标的防护更具实用价值。<br>
根据这段文字，可以将“干扰致偏”最准确地概括为：]],
    {
      [[A、伪装防护技术的“烟雾弹”]],
      [[B、导弹制导信号的“跟踪器”]],
      [[C、精确制导武器的“迷魂散”]],
      [[D、地上阵地目标的“防护伞”]],
    },
    [[C]],
  },
  -- 59
  {
    [[当我们仔细观察当今世界上的主流火箭时，就会发现它们用的发动机、燃料箱等都是上世纪的产物。比如要在2018年首飞的太空发射系统用的是改进过的航天飞机的火箭发动机，燃料箱用的是改进过的航天飞机的外挂燃料箱，两侧的固体燃料推进器用的也是改进过的航天飞机的固体燃料推进器。________。火箭是非常复杂的东西，设计并制造火箭需要考虑的因素太多，就连火箭制造商们也只能去选择一些经受过时间考验的产物，从而确保产品的可靠性。<br>
填入画横线部分最恰当的一句是：]],
    {
      [[A、这是因为新技术的推广需要一定的时间]],
      [[B、这并不意味着火箭技术没有任何新的进展]],
      [[C、事实上，制造火箭的材料并不都是前沿科技产物]],
      [[D、也就是说，在火箭这个领域内并不是最新的就是好的]],
    },
    [[D]],
  },
  -- 60
  {
    [[目前，国内的多家快递企业开始尝试拓展无人机送货业务，这样既能缓解地面交通拥堵，又能提高快递企业运营效率。但是，自无人机技术应用以来，安全事故屡屡发生。无人机在快递业的大规模应用，还可能对空管秩序造成极大冲击。特别是引入人工智能的无人机技术，逐渐摆脱了人工干预，而且还会随着“经验”的不断积累，优化自己的飞行路线。一旦对其监管落实不到位，极有可能产生不堪设想的后果。对此，我们应采取切实有效的措施，最大限度地发挥人工智能在无人机领域的优势，防止其可能产生的社会危害。<br>
这段文字意在说明：]],
    {
      [[A、无人机的广泛应用需技术和监管共同发力]],
      [[B、引入人工智能的无人机技术潜在风险更大]],
      [[C、快递企业引入无人机业务的时机尚不成熟]],
      [[D、发展人工智能需要更多地考虑其安全隐患]],
    },
    [[A]],
  },
  -- 61
  {
    [[甲商店购入400件同款夏装。7月以进价的1.6倍出售，共售出200件；8月以进价的1.3倍出售，共售出100件；9月以进价的0.7倍将剩余的100件全部售出，总共获利15000元。问这批夏装的单件进价为多少元？]],
    {
      [[A、125]],
      [[B、144]],
      [[C、100]],
      [[D、120]],
    },
    [[A]],
  },
  -- 62
  {
    [[某单位的会议室有5排共40个座位，每排座位数相同。小张和小李随机入座，则他们坐在同一排的概率：]],
    {
      [[A、不高于15%%]],
      [[B、高于15%%但低于20%%]],
      [[C、正好为20%%]],
      [[D、高于20%%]],
    },
    [[B]],
  },
  -- 63
  {
    [[企业某次培训的员工中有369名来自A部门，412名来自B部门。现分批对所有人进行培训，要求每批人数相同且批次尽可能少。如果有且仅有一批培训对象同时包含来自A和B部门的员工，那么该批中有多少人来自B部门？]],
    {
      [[A、14]],
      [[B、32]],
      [[C、57]],
      [[D、65]],
    },
    [[C]],
  },
  -- 64
  {
    [[将一块长24厘米、宽16厘米的木板分割成一个正方形和两个相同的圆形，其余部分弃去不用。在弃去不用的部分面积最小的情况下，圆的半径为多少厘米？]],
    {
      [[A、3√2]],
      [[B、2√2]],
      [[C、8]],
      [[D、4]],
    },
    [[D]],
  },
  -- 65
  {
    [[企业花费600万元升级生产线，升级后能耗费用降低了，人工成本降低了。如每天的产量不变，预计在400个工作日后收回成本。如果升级前人工成本为能耗费用的3倍，问升级后每天的人工成本比能耗费用高多少万元？]],
    {
      [[A、1.2]],
      [[B、1.5]],
      [[C、1.8]],
      [[D、2.4]],
    },
    [[C]],
  },
  -- 66
  {
    [[工程队接到一项工程，投入80台挖掘机。如连续施工30天，每天工作10小时，正好按期完成。但施工过程中遭遇大暴雨，有10天时间无法施工。工期还剩8天时，工程队增派70台挖掘机并加班施工。问工程队若想按期完成，平均每天需多工作多少个小时？]],
    {
      [[A、1.5]],
      [[B、2]],
      [[C、2.5]],
      [[D、3]],
    },
    [[B]],
  },
  -- 67
  {
    [[枣园每年产枣2500公斤，每公斤固定盈利18元。为了提高土地利用率，现决定明年在枣树下种植紫薯（产量最大为10000公斤），每公斤固定盈利3元。当紫薯产量大于400公斤时，其产量每增加n公斤将导致枣的产量下降0.2n公斤。问该枣园明年最多可能盈利多少元？]],
    {
      [[A、46176]],
      [[B、46200]],
      [[C、46260]],
      [[D、46380]],
    },
    [[B]],
  },
  -- 68
  {
    [[某企业国庆放假期间，甲、乙和丙三人被安排在10月1号到6号值班。要求每天安排且仅安排1人值班，每人值班2天，且同一人不连续值班2天。问有多少种不同的安排方式？]],
    {
      [[A、15]],
      [[B、24]],
      [[C、30]],
      [[D、36]],
    },
    [[C]],
  },
  -- 69
  {
    [[某新能源汽车企业计划在A、B、C、D四个城市建设72个充电站，其中在B市建设的充电站数量占总数的1/3，在C市建设的充电站数量比A市多6个，在D市建设的充电站数量少于其他任一城市。问至少要在C市建设多少个充电站？]],
    {
      [[A、20]],
      [[B、18]],
      [[C、22]],
      [[D、21]],
    },
    [[D]],
  },
  -- 70
  {
    [[某公司按1：3：4的比例订购了一批红色、蓝色、黑色的签字笔，实际使用时发现三种颜色的笔消耗比例为1：4：5。当某种颜色的签字笔用完时，发现另两种颜色的签字笔共剩下100盒。此时又购进三种颜色签字笔总共900盒，从而使三种颜色的签字笔可以同时用完。问新购进黑色签字笔多少盒？]],
    {
      [[A、450]],
      [[B、425]],
      [[C、500]],
      [[D、475]],
    },
    [[A]],
  },
  -- 81
  {
    [[伦理信用是指人们交往中由一定的预先约定、契约、承诺、誓言等引发的一种伦理关系，其蕴涵的合理秩序则凝结为遵守诺言、履行约定的道德准则，人们基于对信用伦理关系合理秩序的理解和规则的践行便形成了相应的道德品行。<br>
根据上述定义，下列涉及伦理信用的是：]],
    {
      [[A、陈某看到一群人在围殴邻居的孩子，他一边报警，一边跑上前去大声喝止]],
      [[B、赵某答应了丈夫的临终请求，在丈夫去世后，对丈夫前妻留下的两个孩子视如己出，将他们抚养成人]],
      [[C、王某父亲曾借给张某10万元，王父去世后，王某要求张某还钱]],
      [[D、李某家乡发生洪涝灾害，不少农民颗粒无收，父亲要求他发动其公司员工和微信圈朋友捐钱捐物]],
    },
    [[B]],
  },
  -- 82
  {
    [[定向调控指政府针对不同调控领域，制定清晰明确的调控政策，使调控更具针对性。相机调控指政府根据市场情况和各项调节措施的特点，灵活决定当前应采取哪一种或几种政策措施，重在“预调、微调”。定向调控是“做什么”，相机调控是“怎么做”。<br>
根据上述定义，下列属于相机调控的是：]],
    {
      [[A、甲国政府于年初提出了经济增长率和就业水平的“下限”、物价涨幅的“上限”等工作目标]],
      [[B、乙国政府提出“双引擎”策略：一是对小微企业、“三农”等市场主体“减负”；二是支持公共产品、公共服务建设，拉动投资。由各地制定具体措施]],
      [[C、丙国政府根据一二三四线城市房地产市场的不同特点，制定了有针对性的契税、房贷政策]],
      [[D、丁国政府实行产品和服务的生产及销售完全由自由市场的自由价格机制所引导、产权明晰的经济政策]],
    },
    [[C]],
  },
  -- 83
  {
    [[法律的当然解释是指法律虽然没有明确规定某一事项，但依规范目的，该事项应当被解释为适用这一法律规定。其解释方法有举重以明轻和举轻以明重。前者是指对于某一应当被允许的行为，举一个情节比其严重而被允许的规定，以说明其应当被允许。后者是指对于某一应当被禁止的行为，举一个情节比其轻微而被禁止的规定，以说明其应当被禁止。<br>
根据上述定义，下列判断正确的是：]],
    {
      [[A、法律规定禁止在公园采摘树叶，依据举轻以明重，在公园攀折树枝的行为应当被禁止]],
      [[B、唐律规定主人打死夜无故入人家者无罪，依据举轻以明重，主人打伤夜无故入人家者无罪]],
      [[C、法律规定禁止携带小型动物，依据举重以明轻，携带大型动物的行为应当被禁止]],
      [[D、法律规定16周岁以下的未成年人不承担刑事责任，依据举重以明轻，15周岁的未成年人不承担刑事责任]],
    },
    [[A]],
  },
  -- 84
  {
    [[系统脱敏法是一种心理治疗法，当患者面前出现引起焦虑和恐惧的刺激物时，引导患者放松，使患者逐渐消除焦虑与恐惧，不再对该刺激物产生病理性反应。它包括快速脱敏法和接触脱敏法等。前者是治疗者陪伴病人置身于令病人感到恐惧的情景，直到病人不再紧张为止。后者是通过示范，让病人逐渐与所惧怕的对象接触，最终达到克服恐惧的目的。<br>
根据上述定义，如果要治疗一名特别害怕蛇的孩子，下列治疗方法中属于接触脱敏法的是：]],
    {
      [[A、让孩子旁观别人触摸、拿起和放下蛇的过程后，再慢慢让孩子逐渐接近和触摸蛇]],
      [[B、带孩子去室内蛇类养殖场，看各种不同种类的蛇，看多了自然就不再害怕了]],
      [[C、给孩子讲有关蛇的有趣的童话故事，引发孩子开心的情绪，逐渐减少对蛇的恐惧]],
      [[D、录下孩子看见蛇后恐惧害怕的表情和动作，然后一遍又一遍地把这些视频放给孩子看]],
    },
    [[A]],
  },
  -- 85
  {
    [[独立证明法和归谬法是间接论证的两种方法，其中独立证明法是通过证明与被反驳命题相矛盾的命题为真，从而确定被反驳命题为假的方法。归谬法就是由所要反驳的命题为真，引出荒谬的结论，从而证明所要反驳的命题为假。<br>
根据上述定义，下列论证中使用了独立证明法的是：]],
    {
      [[A、甲：人类是由猿猴进化而来的。乙：不可能！有哪一个人见过，哪一只猴子变成了人？]],
      [[B、甲：天不生仲尼，万古如长夜。乙：难道仲尼以前的人都生活在黑暗之中？]],
      [[C、甲：人性本恶。乙：如果真的人性本恶，那么道德规范又从何而来呢？]],
      [[D、甲：温饱是谈道德的先决条件。乙：温饱绝不是谈道德的先决条件。古往今来，没有解决衣食之困的社会也在谈道德。]],
    },
    [[D]],
  },
  -- 86
  {
    [[符号现象是指表意上没有相关性的甲乙两事物，当我们用甲事物代表乙事物时，甲事物就可以视为乙事物的符号。<br>
根据上述定义，下列不属于符号现象的是：]],
    {
      [[A、消防车的警笛声]],
      [[B、医疗机构使用的十字标记]],
      [[C、法院大门上雕刻的天平图案]],
      [[D、体育比赛裁判员的哨声]],
    },
    [[C]],
  },
  -- 87
  {
    [[人耳对一个声音的感受性会因另一个声音的存在而发生改变。一个声音能被人耳听到的最低值会因另一声音的出现而提高，这种现象就是听觉掩蔽。<br>
根据上述定义，下列符合听觉掩蔽的是：]],
    {
      [[A、吵闹的课间，老师得大声说话，同学们才能听到]],
      [[B、长时间戴耳机听音乐，会觉得听到的音量逐渐变小]],
      [[C、人类无法听到蝙蝠等动物发出来的超声波]],
      [[D、安静的房间内，我们能够听到闹钟“滴答”的声音]],
    },
    [[A]],
  },
  -- 88
  {
    [[异质型人力资本是指某个特定历史阶段中具有边际收益递增生产力形态的人力资本，表现为拥有者所具有的独特能力，这些能力主要包括：综合协调能力、判断决策能力、学习创新能力和承担风险能力等。<br>
根据上述定义，下列不涉及异质型人力资本的是：]],
    {
      [[A、某厂长期亏损，李某担任厂长后施行了大刀阔斧的改革，很快使工厂扭亏为盈]],
      [[B、技术员陈某潜心钻研技术，他将人们认为不太可能整合的两种技术巧妙结合在一起，大大降低了生产成本]],
      [[C、某包装厂效益平平，设计师王某应聘到该厂后，由于他的设计新颖、风格清新，一下子使该厂的包装产品畅销起来]],
      [[D、某厂聘请某院士担任技术顾问，一大批风险投资公司慕名而来，一些高学历人才也陆续加盟]],
    },
    [[D]],
  },
  -- 89
  {
    [[数客互动管理是指通过先进的电子通讯和网络手段，达到企业与目标客户群之间高效、直接、自主、往复的沟通，从而满足客户的个性化需要。<br>
根据上述定义，下列属于数客互动管理的是：]],
    {
      [[A、某市政府在官网设立市长信箱，广泛收集各方面的意见，及时答复群众质询，努力改进政府工作]],
      [[B、某玩具公司建立网络交流平台，家长只要将需要的玩具类型、价格、功能等提交给平台，公司就可以及时生产出来]],
      [[C、某家具生产企业通过收集网络海量数据，进行市场需求分析，及时调整家具风格]],
      [[D、某热水器厂家根据客户提供的信息，定期与客户联系，为客户提供免费检修服务]],
    },
    [[B]],
  },
  -- 90
  {
    [[蜂鸣式营销是一种通过向潜在消费者直接提供企业产品或服务，使其获得产品或服务体验的销售方式。根据上述定义，下列不属于蜂鸣式营销的是：]],
    {
      [[A、某软件公司在网上推出一款试用版软件，用户可免费试用三个月]],
      [[B、某公司聘请演员在各大城市繁华地区扮演情侣，邀请可能成为目标客户的路人为他们拍照，借机向其宣传新款相机的功能]],
      [[C、某企业定期向用户发送邮件，寄送产品杂志，推送优惠信息，并承诺购买产品一个月内不满意可以无条件退货]],
      [[D、某饮料公司让营销人员频频出现在街道、咖啡馆、酒吧、超市等场所，请路人品尝不同口味的饮料来宣传自己的品牌]],
    },
    [[C]],
  },
  -- 91
  {
    [[法律：法盲]],
    {
      [[A、文字：文盲]],
      [[B、雪地：雪盲]],
      [[C、地图：路盲]],
      [[D、黑暗：夜盲]],
    },
    [[A]],
  },
  -- 92
  {
    [[众人拾柴：火焰高]],
    {
      [[A、多行不义：必自毙]],
      [[B、打破沙锅：问到底]],
      [[C、敬酒不吃：吃罚酒]],
      [[D、四海之内：皆兄弟]],
    },
    [[A]],
  },
  -- 93
  {
    [[羔羊跪乳：乌鸦反哺]],
    {
      [[A、昙花一现：惊鸿一瞥]],
      [[B、魂不附体：失魂落魄]],
      [[C、锋芒毕露：锐不可当]],
      [[D、朽木难雕：孺子可教]],
    },
    [[B]],
  },
  -- 94
  {
    [[花椒：麻]],
    {
      [[A、月亮：圆]],
      [[B、水泥：硬]],
      [[C、饮料：冷]],
      [[D、火焰：热]],
    },
    [[D]],
  },
  -- 95
  {
    [[蛋：卤蛋：松花蛋]],
    {
      [[A、豆：红豆：四季豆]],
      [[B、油：牛油：植物油]],
      [[C、瓜：丝瓜：白兰瓜]],
      [[D、茶：白茶：乌龙茶]],
    },
    [[D]],
  },
  -- 96
  {
    [[闪电战：战术：突袭]],
    {
      [[A、润滑油：机械：减震]],
      [[B、戈壁滩：地形：干旱]],
      [[C、防空洞：轰炸：隐蔽]],
      [[D、斑马线：标记：通过]],
    },
    [[D]],
  },
  -- 97
  {
    [[飞禽走兽：大雁：海鸥]],
    {
      [[A、珍馐美馔：山珍：海味]],
      [[B、花鸟鱼虫：鹦鹉：画眉]],
      [[C、锦衣玉食：蟒袍：霞帔]],
      [[D、卧虎藏龙：猛虎：蛟龙]],
    },
    [[C]],
  },
  -- 98
  {
    [[净水器 对于（       ）相当于（       ）对于 汽缸]],
    {
      [[A、滤芯；蒸汽机]],
      [[B、设备；元件]],
      [[C、家庭；发动机]],
      [[D、自来水；活塞]],
    },
    [[A]],
  },
  -- 99
  {
    [[日记 对于（      ）相当于（      ）对于 数据]],
    {
      [[A、纪念；查证]],
      [[B、经历；内存]],
      [[C、年鉴；计算机]],
      [[D、日期；图片]],
    },
    [[B]],
  },
  -- 100
  {
    [[原始部落 对于（              ）相当于（             ） 对于 先进科技]],
    {
      [[A、热带丛林；文明古国]],
      [[B、边远小镇；创业园区]],
      [[C、茹毛饮血；现代都市]],
      [[D、钻木取火；宇宙航行]],
    },
    [[C]],
  },
  -- 101
  {
    [[扶贫必扶智。让贫困地区的孩子们接受良好教育，是扶贫开发的重要任务，也是阻断贫困代际传递的重要途径。<br>
以上观点的前提是：]],
    {
      [[A、贫困的代际传递导致教育的落后]],
      [[B、富有阶层大都受过良好教育]],
      [[C、扶贫工作难，扶智工作更难]],
      [[D、知识改变命运，教育成就财富]],
    },
    [[D]],
  },
  -- 102
  {
    [[有调查显示，部分学生缺乏创造力。研究者认为，具有创造力的孩子在幼年时都比较淘气，而在一些家庭，小孩如果淘气就会被家长严厉呵斥，这导致他们只能乖乖听话，创造力就有所下降。<br>
这项调查最能支持的论断是：]],
    {
      [[A、幼年是创造力发展的关键时期]],
      [[B、教育方式会影响孩子创造力的发展]],
      [[C、幼年听话的孩子长大之后可能缺乏创造力]],
      [[D、有些家长对小孩淘气倾向于采取比较严厉的态度]],
    },
    [[B]],
  },
  -- 103
  {
    [[人们普遍认为，保持乐观心态会促进健康。但一项对7万名50岁左右的女性进行的长达十年的追踪研究发现，长期保持乐观心态的被试与悲观被试在死亡率上并没有差异，研究者据此认为，心态乐观与否与健康没有关系。<br>
以下哪项如果为真，最能质疑研究者的结论？]],
    {
      [[A、在这项研究的被试中悲观的人更多患有慢性疾病，虽然尚未严重到致命的程度]],
      [[B、与悲观的人相比，乐观的人患病后会更积极主动地治疗]],
      [[C、乐观的人往往对身体不会特别关注，有时一些致命性疾病无法及早发现]],
      [[D、女性更善于维持和谐的人际关系，而良好的人际关系有助于健康]],
    },
    [[A]],
  },
  -- 104
  {
    [[自上世纪50年代以来，全球每年平均爆发的大型龙卷风的次数从10次左右上升至15次。与此同时，人类活动激增，全球气候明显变暖，有人据此认为，气候变暖导致龙卷风爆发次数增加。<br>
以下哪项如果为真，不能削弱上述结论？]],
    {
      [[A、龙卷风的类型多样，全球变暖后，小型龙卷风出现的次数并没有明显的变化]],
      [[B、气候温暖是龙卷风形成的一个必要条件，几乎所有龙卷风的形成都与当地较高的温度有关]],
      [[C、尽管全球变暖，龙卷风依然最多地发生在美国的中西部地区，其他地区的龙卷风现象并不多见]],
      [[D、龙卷风是雷暴天气（即伴有雷击和闪电的局地对流性天气）的产物，只要在雷雨天气下出现极强的空气对流，就容易发生龙卷风]],
    },
    [[B]],
  },
  -- 105
  {
    [[日前，研究人员发明了一种弹性超强的新材料，这种材料可以由1英寸被拉伸到100英寸以上，同时这一材料可以自行修复且能通过电压控制动作。因此研究者认为，利用该材料可以制成人工肌肉，替代人体肌肉，从而为那些肌肉损伤后无法恢复功能的患者带来福音。<br>
以下哪项如果为真，不能支持研究者的观点？]],
    {
      [[A、该材料制成的人工肌肉在受到破坏或损伤后能立即启动修复机制，比正常肌肉的康复速度快]],
      [[B、该材料在电刺激下会发生膨胀或收缩，具有良好的柔韧性，与正常肌肉十分接近]],
      [[C、目前，该材料研制成的人工肌肉尚不能与人体神经很好的契合，无法实现精准抓取物体等动作]],
      [[D、一般材料如果被破坏，需通过溶剂修复或热修复复原，而该材料在室温下就能自行恢复]],
    },
    [[C]],
  },
}

return questions
