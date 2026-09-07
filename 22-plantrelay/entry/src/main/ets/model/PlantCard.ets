export interface PlantCard {
  id: number;
  name: string;
  room: string;
  task: string;
  carer: string;
  confirmed?: boolean;
  completed?: boolean;
  completedAt?: string;
  completionNote?: string;
  palette?: number;
}

export function normalizeCard(card: PlantCard): PlantCard {
  if (!card || typeof card.id !== 'number' || !Number.isFinite(card.id) || card.id <= 0 ||
    typeof card.name !== 'string' || typeof card.room !== 'string' ||
    typeof card.task !== 'string' || typeof card.carer !== 'string') {
    throw new Error('Invalid plant card');
  }
  return {
    id: card.id, name: card.name, room: card.room, task: card.task, carer: card.carer,
    confirmed: card.confirmed === true || card.completed === true,
    completed: card.completed === true,
    completedAt: typeof card.completedAt === 'string' ? card.completedAt : '',
    completionNote: typeof card.completionNote === 'string' ? card.completionNote : '',
    palette: card.palette === 1 || card.palette === 2 ? card.palette : 0
  };
}

export function parseCards(serialized: string): PlantCard[] {
  if (serialized.length === 0) { return []; }
  const raw = JSON.parse(serialized) as PlantCard[];
  if (!Array.isArray(raw)) { throw new Error('Invalid plant collection'); }
  const result: PlantCard[] = [];
  raw.forEach((card: PlantCard) => {
    const next = normalizeCard(card);
    if (result.some((item: PlantCard) => item.id === next.id)) {
      throw new Error('Duplicate plant card');
    }
    result.push(next);
  });
  return result;
}

export function taskStatus(card: PlantCard): string {
  if (card.completed === true) { return '已完成'; }
  return card.confirmed === true ? '待完成' : '待接手';
}

export function acceptCard(card: PlantCard): PlantCard {
  const next = normalizeCard(card);
  next.confirmed = true;
  return next;
}

export function finishCard(card: PlantCard, time: string, note: string): PlantCard {
  if (card.confirmed !== true || card.completed === true || time.trim().length === 0) {
    throw new Error('Task must be accepted and have a completion time');
  }
  const next = normalizeCard(card);
  next.completed = true;
  next.completedAt = time.trim();
  next.completionNote = note.trim();
  return next;
}

export function recolorCard(card: PlantCard, palette: number): PlantCard {
  const next = normalizeCard(card);
  next.palette = palette === 1 || palette === 2 ? palette : 0;
  return next;
}
