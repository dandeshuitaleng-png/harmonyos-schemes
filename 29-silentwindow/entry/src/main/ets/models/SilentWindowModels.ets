export class SilentWindowScenario {
  id: string = ''
  title: string = ''
  description: string = ''
}

export class PhraseTemplate {
  id: string = ''
  scenario: string = ''
  speaker: string = 'user'
  text: string = ''
  priority: number = 0
}

export class CommunicationSession {
  id: string = ''
  scenario: string = ''
  createdAt: string = ''
  selectedPhrases: string[] = []
  nextStep: string = ''
  materials: string[] = []
  note: string = ''
  status: string = 'draft'
}
