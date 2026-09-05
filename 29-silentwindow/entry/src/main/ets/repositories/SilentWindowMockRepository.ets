import { CommunicationSession, PhraseTemplate, SilentWindowScenario } from '../models/SilentWindowModels'

function scenario(id: string, title: string, description: string): SilentWindowScenario {
  const item = new SilentWindowScenario()
  item.id = id
  item.title = title
  item.description = description
  return item
}

function phrase(id: string, scenarioId: string, speaker: string, text: string, priority: number): PhraseTemplate {
  const item = new PhraseTemplate()
  item.id = id
  item.scenario = scenarioId
  item.speaker = speaker
  item.text = text
  item.priority = priority
  return item
}

function session(id: string, scenarioId: string, createdAt: string, selectedPhrases: string[], nextStep: string, status: string): CommunicationSession {
  const item = new CommunicationSession()
  item.id = id
  item.scenario = scenarioId
  item.createdAt = createdAt
  item.selectedPhrases = selectedPhrases
  item.nextStep = nextStep
  item.status = status
  return item
}

export class SilentWindowMockRepository {
  private scenarios: SilentWindowScenario[] = [
    scenario('hospital', '医院', '挂号、候诊、检查、缴费'),
    scenario('bank', '银行', '取号、业务确认、材料核对'),
    scenario('government', '政务', '办事窗口、材料补正、下一步'),
    scenario('general', '通用', '任何需要大字沟通的窗口')
  ]

  private phrases: PhraseTemplate[] = [
    phrase('hospital_user_01', 'hospital', 'user', '我听不清，请用文字或点选回复。', 1),
    phrase('hospital_user_02', 'hospital', 'user', '请告诉我下一步要去哪里。', 2),
    phrase('hospital_user_03', 'hospital', 'user', '请帮我确认材料是否齐全。', 3),
    phrase('hospital_user_04', 'hospital', 'user', '我需要知道检查地点和时间。', 4),
    phrase('hospital_staff_01', 'hospital', 'staff', '请先取号，再等待叫号。', 5),
    phrase('hospital_staff_02', 'hospital', 'staff', '请到缴费窗口办理。', 6),
    phrase('hospital_staff_03', 'hospital', 'staff', '材料齐全，可以继续办理。', 7),
    phrase('hospital_staff_04', 'hospital', 'staff', '还需要补充身份证或就诊卡。', 8),
    phrase('bank_user_01', 'bank', 'user', '我听不清，请用文字或点选回复。', 1),
    phrase('bank_user_02', 'bank', 'user', '请告诉我要办理哪一步。', 2),
    phrase('bank_user_03', 'bank', 'user', '请确认我需要签名的位置。', 3),
    phrase('bank_user_04', 'bank', 'user', '请写下需要补充的材料。', 4),
    phrase('bank_staff_01', 'bank', 'staff', '请先取号并等待叫号。', 5),
    phrase('bank_staff_02', 'bank', 'staff', '请出示身份证和银行卡。', 6),
    phrase('bank_staff_03', 'bank', 'staff', '请确认金额和姓名。', 7),
    phrase('bank_staff_04', 'bank', 'staff', '业务已受理，请保留凭条。', 8),
    phrase('government_user_01', 'government', 'user', '我听不清，请用文字或点选回复。', 1),
    phrase('government_user_02', 'government', 'user', '请告诉我下一步要做什么。', 2),
    phrase('government_user_03', 'government', 'user', '请确认材料是否齐全。', 3),
    phrase('government_user_04', 'government', 'user', '请写下缺少的材料名称。', 4),
    phrase('government_user_05', 'government', 'user', '请告诉我应该去哪个窗口。', 5),
    phrase('government_staff_01', 'government', 'staff', '材料齐全，可以提交。', 6),
    phrase('government_staff_02', 'government', 'staff', '需要补材料后再办理。', 7),
    phrase('government_staff_03', 'government', 'staff', '请到下一窗口继续办理。', 8),
    phrase('government_staff_04', 'government', 'staff', '请等待短信或电话通知。', 9),
    phrase('government_staff_05', 'government', 'staff', '请在这里签字确认。', 10),
    phrase('general_user_01', 'general', 'user', '我听不清，请用文字或点选回复。', 1),
    phrase('general_user_02', 'general', 'user', '请说慢一点，或写给我看。', 2),
    phrase('general_user_03', 'general', 'user', '请告诉我下一步要做什么。', 3),
    phrase('general_user_04', 'general', 'user', '请确认我是否理解正确。', 4),
    phrase('general_staff_01', 'general', 'staff', '材料齐全。', 5),
    phrase('general_staff_02', 'general', 'staff', '需要补充材料。', 6),
    phrase('general_staff_03', 'general', 'staff', '请到下一窗口。', 7),
    phrase('general_staff_04', 'general', 'staff', '请等待叫号。', 8)
  ]

  private recentSessions: CommunicationSession[] = [
    session('mock_session_01', 'hospital', '今天 09:20', ['hospital_user_01', 'hospital_staff_03'], '到二楼检验科', 'confirmed'),
    session('mock_session_02', 'bank', '昨天 15:40', ['bank_user_02', 'bank_staff_02'], '补充银行卡原件', 'confirmed'),
    session('mock_session_03', 'government', '8月29日 10:12', ['government_user_03', 'government_staff_01'], '等待短信通知', 'confirmed'),
    session('mock_session_04', 'general', '草稿', ['general_user_01'], '稍后继续确认', 'draft')
  ]

  getScenarios(): SilentWindowScenario[] {
    return this.scenarios.map((item: SilentWindowScenario) => this.cloneScenario(item))
  }

  getRecentSessions(): CommunicationSession[] {
    return this.recentSessions.map((item: CommunicationSession) => this.cloneSession(item))
  }

  getScenarioTitle(scenarioId: string): string {
    const item = this.scenarios.find((value: SilentWindowScenario) => value.id === scenarioId)
    return item ? item.title : '通用'
  }

  getPhrases(scenarioId: string): PhraseTemplate[] {
    const matched = this.phrases.filter((item: PhraseTemplate) => item.scenario === scenarioId)
    const source = matched.length > 0 ? matched : this.phrases.filter((item: PhraseTemplate) => item.scenario === 'general')
    return source.sort((a: PhraseTemplate, b: PhraseTemplate) => a.priority - b.priority)
      .map((item: PhraseTemplate) => this.clonePhrase(item))
  }

  private cloneScenario(source: SilentWindowScenario): SilentWindowScenario {
    return scenario(source.id, source.title, source.description)
  }

  private clonePhrase(source: PhraseTemplate): PhraseTemplate {
    return phrase(source.id, source.scenario, source.speaker, source.text, source.priority)
  }

  private cloneSession(source: CommunicationSession): CommunicationSession {
    return session(source.id, source.scenario, source.createdAt, [...source.selectedPhrases], source.nextStep, source.status)
  }
}
