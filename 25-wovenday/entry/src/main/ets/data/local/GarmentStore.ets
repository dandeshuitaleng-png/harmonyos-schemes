import { preferences } from '@kit.ArkData';

export interface CareNote { id: number; text: string; }
export interface CareEvent { id: number; eventType: string; occurredAt: string; note: string; }
export interface ShareDraft { garmentId: number; includedFields: string[]; }
export interface Garment { id: number; name: string; category: string; statusText: string; nextActionDate: string; careAgreement: string; repairPrep: string; events?: CareEvent[]; }

const STORE_NAME: string = 'wovenday-garments';
const GARMENTS_KEY: string = 'garments';

export class GarmentStore {
  private normalize(garment: Garment): Garment {
    return { id: garment.id, name: garment.name, category: garment.category, statusText: garment.statusText, nextActionDate: garment.nextActionDate, careAgreement: garment.careAgreement, repairPrep: garment.repairPrep, events: garment.events ?? [] };
  }
  async load(context: Context): Promise<Garment[]> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const value = await store.get(GARMENTS_KEY, '') as string;
    if (value.length === 0) { return []; }
    try { const garments = JSON.parse(value) as Garment[]; return Array.isArray(garments) ? garments.map((garment: Garment) => this.normalize(garment)) : []; }
    catch { return []; }
  }
  async save(context: Context, garments: Garment[]): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(GARMENTS_KEY, JSON.stringify(garments)); await store.flush();
  }
}
