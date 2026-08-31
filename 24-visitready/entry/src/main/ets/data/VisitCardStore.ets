import { preferences } from '@kit.ArkData';

export interface VisitCard { id: number; placeName: string; visitTime: string; addressText?: string; companionName: string; checklist: string; needs?: string; avoids?: string; leavingPlan?: string; reminderDate?: string; }
const STORE_NAME: string = 'visitready-cards';
const CARDS_KEY: string = 'cards';

export class VisitCardStore {
  private normalize(card: VisitCard): VisitCard {
    return { id: card.id, placeName: card.placeName, visitTime: card.visitTime, addressText: card.addressText ?? '', companionName: card.companionName, checklist: card.checklist, needs: card.needs ?? '', avoids: card.avoids ?? '', leavingPlan: card.leavingPlan ?? '', reminderDate: card.reminderDate ?? '' };
  }
  async load(context: Context): Promise<VisitCard[]> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const value = await store.get(CARDS_KEY, '') as string;
    if (value.length === 0) { return []; }
    try {
      const cards = JSON.parse(value) as VisitCard[];
      return Array.isArray(cards) ? cards.map((card: VisitCard) => this.normalize(card)) : [];
    } catch { return []; }
  }
  async save(context: Context, cards: VisitCard[]): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(CARDS_KEY, JSON.stringify(cards));
    await store.flush();
  }
}
