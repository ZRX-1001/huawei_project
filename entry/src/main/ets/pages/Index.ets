interface ChatMessage {
  role: string
  content: string
  meta: string
}

interface AgentTool {
  icon: string
  name: string
  description: string
}

@Entry
@Component
struct Index {
  @State inputText: string = ''
  @State activeTool: string = '通用助理'
  @State activeChat: string = '秋招冲刺计划'
  @State thinking: boolean = false
  @State isPanelVisible: boolean = true
  @State workspaceExpanded: boolean = true
  @State recentsExpanded: boolean = true
  @State taskProgress: number = 1
  @State messages: ChatMessage[] = [
    { role: 'agent', content: '我已阅读你的秋招目标。我们先把简历打磨到可投递水平，再用模拟面试验证表达。', meta: '刚刚 · 已使用项目记忆' },
    { role: 'agent', content: '你可以上传简历，或直接告诉我目标岗位和一段最有代表性的项目经历。', meta: '等待你的信息' }
  ]

  private readonly tools: AgentTool[] = [
    { icon: '✦', name: '通用助理', description: '规划、总结与协作' },
    { icon: '◫', name: '求职实验室', description: '简历与模拟面试' },
    { icon: '✓', name: '智能日程', description: '课程与多任务安排' },
    { icon: '¥', name: '消费洞察', description: '记账与预算分析' },
    { icon: '♡', name: '健康计划', description: '饮食与运动陪伴' },
    { icon: '☀', name: '天气穿搭', description: '出行与穿搭建议' }
  ]
  private readonly chats: string[] = ['秋招冲刺计划', '本周学习规划', '9 月消费复盘']

  private sendPrompt(prompt: string): void {
    if (this.thinking || prompt.trim().length === 0) {
      return
    }
    this.messages = [...this.messages, { role: 'user', content: prompt, meta: '现在' }]
    this.inputText = ''
    this.thinking = true
    setTimeout(() => {
      this.messages = [...this.messages, { role: 'agent', content: this.replyFor(prompt), meta: '任务已更新 · 现在' }]
      this.thinking = false
    }, 580)
  }

  private replyFor(prompt: string): string {
    if (this.activeTool === '消费洞察') {
      return '我已创建本月账本。你可以直接输入“午餐 18 元”，我会自动分类、更新预算，并在消费异常时主动提醒你。'
    }
    if (this.activeTool === '智能日程') {
      return '我会按截止日期、精力和课程空档排序。先把本周的作业、考试与约定发给我，我将生成一份可勾选的行动日程。'
    }
    if (this.activeTool === '健康计划') {
      return '先从低负担的计划开始。告诉我你的作息、运动基础和饮食偏好，我会给出一周可调整方案并在每日复盘时更新。'
    }
    if (this.activeTool === '天气穿搭') {
      return '天气工具已进入待调用队列。接入定位与天气服务后，我会结合降雨、温度和出行时间给出穿搭与出行提醒。'
    }
    if (this.activeTool === '求职实验室' || this.activeChat === '秋招冲刺计划') {
      return '收到。我会先提炼岗位关键词和你的项目证据，再给出可直接修改的简历建议。完成后，我们进入限时模拟面试，并根据回答持续调整训练重点。'
    }
    return `已记录「${prompt}」。我会把它拆为结果、约束与下一步行动；需要查询或生成内容时会先展示工具调用状态。`
  }

  private chooseTool(tool: AgentTool): void {
    this.activeTool = tool.name
    this.activeChat = tool.name
    this.taskProgress = 1
    this.messages = [{ role: 'agent', content: `已切换到${tool.name}。${tool.description}工作流已准备好，你想从哪里开始？`, meta: '新工作区 · 现在' }]
  }

  private startNewChat(): void {
    this.activeTool = '通用助理'
    this.activeChat = '新对话'
    this.taskProgress = 1
    this.messages = [{ role: 'agent', content: '新的任务空间已创建。告诉我你希望达成的结果，我会先澄清目标，再推进下一步。', meta: '现在' }]
  }

  private advanceTask(): void {
    if (this.thinking) {
      return
    }
    this.thinking = true
    setTimeout(() => {
      if (this.taskProgress < 3) {
        this.taskProgress += 1
      }
      const text = this.taskProgress === 2
        ? '简历诊断已完成：我提取了 6 个岗位关键词，并发现 2 条项目描述可以补充量化成果。已生成一份优化清单。'
        : '模拟面试已创建。第一轮将从 60 秒自我介绍开始，回答后我会追问项目细节并给出针对性反馈。'
      this.messages = [...this.messages, { role: 'agent', content: text, meta: '工具调用完成 · 现在' }]
      this.thinking = false
    }, 700)
  }

  build() {
    Row() {
      Column() {
        Row({ space: 9 }) {
          Text('C').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#151614').width(32).height(32).textAlign(TextAlign.Center).padding({ top: 6 }).backgroundColor('#D4F56A').borderRadius(9)
          Text('CampusPilot').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#F5F5F0')
        }.width('100%').margin({ bottom: 23 })

        Button({ type: ButtonType.Normal }) {
          Row({ space: 8 }) {
            Text('＋').fontSize(19).fontColor('#151614')
            Text('新建对话').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#151614')
          }.width('100%').justifyContent(FlexAlign.Center)
        }.width('100%').height(42).backgroundColor('#D4F56A').borderRadius(10).onClick(() => this.startNewChat())

        Row({ space: 7 }) {
          Text('⌕').fontSize(17).fontColor('#AFB0AB')
          Text('搜索对话和记忆').fontSize(12).fontColor('#8B8C88')
        }.width('100%').height(38).padding({ left: 10 }).margin({ top: 12, bottom: 19 }).backgroundColor('#292A27').borderRadius(9)

        Scroll() {
          Column() {
            Row() {
              Text('工作区').fontSize(11).fontWeight(FontWeight.Medium).fontColor('#80817D')
              Blank()
              Text(this.workspaceExpanded ? '⌃' : '⌄').fontSize(13).fontColor('#9B9C96')
            }.width('100%').height(28).padding({ left: 2, right: 7 }).onClick(() => this.workspaceExpanded = !this.workspaceExpanded)
            if (this.workspaceExpanded) {
              ForEach(this.tools, (tool: AgentTool) => {
                Row({ space: 10 }) {
                  Text(tool.icon).fontSize(16).fontColor(this.activeTool === tool.name ? '#D4F56A' : '#A5A6A1').width(20).textAlign(TextAlign.Center)
                  Text(tool.name).fontSize(13).fontColor(this.activeTool === tool.name ? '#F5F5F0' : '#C7C8C3').fontWeight(this.activeTool === tool.name ? FontWeight.Medium : FontWeight.Regular).layoutWeight(1)
                }.width('100%').height(40).padding({ left: 8, right: 6 }).margin({ bottom: 2 })
                .backgroundColor(this.activeTool === tool.name ? '#30312D' : '#1D1E1B').borderRadius(8)
                .onClick(() => this.chooseTool(tool))
              }, (tool: AgentTool) => tool.name)
            }

            Row() {
              Text('最近对话').fontSize(11).fontWeight(FontWeight.Medium).fontColor('#80817D')
              Blank()
              Text(this.recentsExpanded ? '⌃' : '⌄').fontSize(13).fontColor('#9B9C96')
            }.width('100%').height(28).padding({ left: 2, right: 7 }).margin({ top: 14 }).onClick(() => this.recentsExpanded = !this.recentsExpanded)
            if (this.recentsExpanded) {
              ForEach(this.chats, (chat: string) => {
                Text(chat).fontSize(12).fontColor(this.activeChat === chat ? '#F0F0E9' : '#A6A7A2')
                  .width('100%').height(33).padding({ left: 9, top: 8 }).margin({ bottom: 1 })
                  .backgroundColor(this.activeChat === chat ? '#292A27' : '#1D1E1B').borderRadius(7)
                  .onClick(() => this.activeChat = chat)
              }, (chat: string) => chat)
            }
          }.width('100%').justifyContent(FlexAlign.Start)
        }.layoutWeight(1).width('100%').align(Alignment.TopStart).scrollBar(BarState.Auto)

        Row({ space: 8 }) {
          Text('●').fontSize(10).fontColor('#D4F56A')
          Text('本地演示 · 数据未上传').fontSize(11).fontColor('#8B8C88')
        }.width('100%').padding({ top: 10, bottom: 4 })
      }.width(216).height('100%').padding(14).backgroundColor('#1D1E1B')

      Column() {
        Row() {
          Column({ space: 3 }) {
            Row({ space: 7 }) {
              Text(this.activeChat).fontSize(18).fontWeight(FontWeight.Medium).fontColor('#242521')
              Text('项目').fontSize(10).fontColor('#356B58').padding({ left: 7, right: 7, top: 3, bottom: 3 }).backgroundColor('#E4F1E8').borderRadius(8)
            }
            Text('目标：完成产品经理秋招准备 · 记忆已关联').fontSize(11).fontColor('#85867E')
          }.alignItems(HorizontalAlign.Start)
          Blank()
          Text('＋ 上下文').fontSize(12).fontColor('#575951').padding({ left: 10, right: 10, top: 8, bottom: 8 }).backgroundColor('#EFEFEA').borderRadius(8)
          Text(this.isPanelVisible ? '☷' : '☰').fontSize(18).fontColor('#55564F').margin({ left: 12 }).padding(7).onClick(() => this.isPanelVisible = !this.isPanelVisible)
        }.width('100%').height(70).padding({ left: 26, right: 20 }).backgroundColor('#FBFBF8').border({ width: { bottom: 1 }, color: '#E5E5DF' })

        Scroll() {
          Column({ space: 15 }) {
            Row({ space: 8 }) {
              Text('✦').fontSize(13).fontColor('#356B58')
              Text('Agent 已载入项目记忆：目标岗位、简历版本和练习记录').fontSize(12).fontColor('#596159')
            }.width('100%').padding(11).backgroundColor('#EFF6F0').borderRadius(10)

            ForEach(this.messages, (message: ChatMessage, index: number) => {
              Row() {
                if (message.role === 'agent') {
                  Text('C').fontSize(12).fontWeight(FontWeight.Bold).fontColor('#151614').width(27).height(27).textAlign(TextAlign.Center).padding({ top: 5 }).backgroundColor('#D4F56A').borderRadius(8).margin({ right: 9 })
                }
                Column({ space: 5 }) {
                  Text(message.role === 'agent' ? 'CampusPilot' : '你').fontSize(11).fontColor('#82837C')
                  Text(message.content).fontSize(15).fontColor('#292A27').lineHeight(23)
                  Text(message.meta).fontSize(10).fontColor('#9A9B94')
                }.alignItems(HorizontalAlign.Start).width('80%').padding(13)
                .backgroundColor(message.role === 'agent' ? '#FFFFFF' : '#E9F3EB').borderRadius(13)
              }.width('100%').justifyContent(message.role === 'agent' ? FlexAlign.Start : FlexAlign.End)
            }, (message: ChatMessage, index: number) => `${message.role}-${index}`)

            if (this.thinking) {
              Row({ space: 9 }) {
                Text('C').fontSize(12).fontWeight(FontWeight.Bold).fontColor('#151614').width(27).height(27).textAlign(TextAlign.Center).padding({ top: 5 }).backgroundColor('#D4F56A').borderRadius(8)
                Text('正在检索项目记忆并规划下一步…').fontSize(13).fontColor('#666861')
              }
            }

            Row({ space: 7 }) {
              Text('帮我优化简历').fontSize(12).fontColor('#4C5049').padding(9).backgroundColor('#ECEDE8').borderRadius(9).onClick(() => this.sendPrompt('帮我优化简历，并列出优先修改项。'))
              Text('开始模拟面试').fontSize(12).fontColor('#4C5049').padding(9).backgroundColor('#ECEDE8').borderRadius(9).onClick(() => this.sendPrompt('开始一轮产品经理模拟面试。'))
            }.width('100%').margin({ top: 3 })
          }.width('100%').padding({ left: 26, right: 26, top: 20, bottom: 20 })
        }.layoutWeight(1).width('100%').scrollBar(BarState.Off)

        Column({ space: 8 }) {
          Row({ space: 10 }) {
            Text('＋').fontSize(19).fontColor('#4F514B').width(27).textAlign(TextAlign.Center).onClick(() => this.sendPrompt('我想添加一份简历作为项目上下文。'))
            Text('◉').fontSize(15).fontColor('#4F514B').width(22).textAlign(TextAlign.Center).onClick(() => this.sendPrompt('请开始语音任务。'))
            TextInput({ text: this.inputText, placeholder: '向 CampusPilot 描述你的下一步…' })
              .layoutWeight(1).height(44).fontSize(14).backgroundColor('#F2F2ED').borderRadius(10)
              .padding({ left: 12, right: 8 }).onChange((value: string) => this.inputText = value)
              .onSubmit(() => this.sendPrompt(this.inputText))
            Button('↑').fontSize(19).fontColor('#F9FAF6').width(42).height(42).backgroundColor('#356B58').borderRadius(10).onClick(() => this.sendPrompt(this.inputText))
          }.width('100%').padding(8).backgroundColor('#FFFFFF').borderRadius(14).border({ width: 1, color: '#E2E3DC' })
          Text('Agent 会在需要时调用工具；涉及上传或外部操作前将征求你的确认。').fontSize(10).fontColor('#92938D').width('100%').textAlign(TextAlign.Center)
        }.width('100%').padding({ left: 26, right: 26, top: 10, bottom: 14 }).backgroundColor('#FBFBF8')
      }.layoutWeight(1).height('100%').backgroundColor('#FBFBF8')

      if (this.isPanelVisible) {
        Divider().vertical(true).color('#E4E5DE').strokeWidth(1)
        Column({ space: 15 }) {
          Row() {
            Text('任务面板').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#272824')
            Blank()
            Text('•••').fontSize(18).fontColor('#787A73')
          }.width('100%')

          Column({ space: 7 }) {
            Row() {
              Text('秋招准备进度').fontSize(13).fontWeight(FontWeight.Medium).fontColor('#363833')
              Blank()
              Text(`${this.taskProgress}/3`).fontSize(12).fontColor('#356B58')
            }.width('100%')
            Row() {
              Row().width(this.taskProgress === 1 ? '33%' : this.taskProgress === 2 ? '66%' : '100%').height(5).backgroundColor('#356B58').borderRadius(4)
              Blank().height(5).backgroundColor('#E1E3DD').borderRadius(4)
            }.width('100%').height(5).backgroundColor('#E1E3DD').borderRadius(4)
            Text('Agent 将在每一步完成后自动保存结果。').fontSize(11).fontColor('#85877F')
          }.width('100%').padding(13).backgroundColor('#EFF6F0').borderRadius(12)

          Text('正在推进').fontSize(11).fontWeight(FontWeight.Medium).fontColor('#82837C').width('100%')
          Column({ space: 12 }) {
            Row({ space: 9 }) {
              Text(this.taskProgress >= 1 ? '✓' : '○').fontSize(14).fontColor(this.taskProgress >= 1 ? '#356B58' : '#A1A39B')
              Column({ space: 2 }) {
                Text('明确岗位与目标').fontSize(13).fontColor('#3D3F39')
                Text('产品经理 · 2027 届').fontSize(10).fontColor('#8E9088')
              }.alignItems(HorizontalAlign.Start)
            }
            Row({ space: 9 }) {
              Text(this.taskProgress >= 2 ? '✓' : '○').fontSize(14).fontColor(this.taskProgress >= 2 ? '#356B58' : '#A1A39B')
              Column({ space: 2 }) {
                Text('简历诊断与优化').fontSize(13).fontColor('#3D3F39')
                Text(this.taskProgress >= 2 ? '已生成优化清单' : '等待调用简历工具').fontSize(10).fontColor('#8E9088')
              }.alignItems(HorizontalAlign.Start)
            }
            Row({ space: 9 }) {
              Text(this.taskProgress >= 3 ? '✓' : '○').fontSize(14).fontColor(this.taskProgress >= 3 ? '#356B58' : '#A1A39B')
              Column({ space: 2 }) {
                Text('限时模拟面试').fontSize(13).fontColor('#3D3F39')
                Text(this.taskProgress >= 3 ? '第一轮已创建' : '将在简历优化后开启').fontSize(10).fontColor('#8E9088')
              }.alignItems(HorizontalAlign.Start)
            }
          }.width('100%').padding(13).backgroundColor('#FFFFFF').borderRadius(12)

          Button(this.taskProgress >= 3 ? '开始第一轮面试' : '推进下一步')
            .width('100%').height(40).fontSize(13).fontColor('#F7F8F3').backgroundColor('#356B58').borderRadius(9).onClick(() => this.advanceTask())

          Text('本次产物').fontSize(11).fontWeight(FontWeight.Medium).fontColor('#82837C').width('100%').margin({ top: 3 })
          Column({ space: 6 }) {
            Row({ space: 9 }) {
              Text('▤').fontSize(16).fontColor('#B46A39')
              Column({ space: 2 }) {
                Text('简历优化清单').fontSize(13).fontColor('#3D3F39')
                Text('待生成 · 可编辑可导出').fontSize(10).fontColor('#8E9088')
              }.alignItems(HorizontalAlign.Start)
            }.width('100%').padding(11).backgroundColor('#FFF8F1').borderRadius(10)
            Row({ space: 9 }) {
              Text('▱').fontSize(16).fontColor('#5C6FBB')
              Column({ space: 2 }) {
                Text('面试复盘报告').fontSize(13).fontColor('#3D3F39')
                Text('将在练习后自动沉淀').fontSize(10).fontColor('#8E9088')
              }.alignItems(HorizontalAlign.Start)
            }.width('100%').padding(11).backgroundColor('#F2F4FC').borderRadius(10)
          }.width('100%')
        }.width(274).height('100%').padding(16).backgroundColor('#F6F7F2')
      }
    }.width('100%').height('100%').backgroundColor('#FBFBF8')
  }
}
