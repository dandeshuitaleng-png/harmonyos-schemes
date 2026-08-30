import { preferences } from '@kit.ArkData';

export type ObservationType = '暴雨云团' | '台风外雨带' | '山洪水迹' | '潮汐变化';

export const SOURCE_PUBLIC_LEAD: string = '未核验公众线索';
export const PRIVACY_ACCEPTED: string = 'accepted';
export const PRIVACY_DECLINED: string = 'declined';

export interface ObservationRecord {
  id: string;
  kind: ObservationType;
  sourceLevel: string;
  place: string;
  note: string;
  observedAt: number;
  createdAt: number;
}

const STORE_NAME: string = 'naturalcollect-observations';
const RECORDS_KEY: string = 'records';
const PRIVACY_KEY: string = 'privacy-choice';
const VALID_KINDS: ObservationType[] = ['暴雨云团', '台风外雨带', '山洪水迹', '潮汐变化'];

export class ObservationStore {
  async loadPrivacyChoice(context: Context): Promise<string> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const value = await store.get(PRIVACY_KEY, '') as string;
    return typeof value === 'string' ? value : '';
  }

  async savePrivacyChoice(context: Context, choice: string): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(PRIVACY_KEY, choice);
    await store.flush();
  }

  async load(context: Context): Promise<ObservationRecord[]> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const raw = await store.get(RECORDS_KEY, '') as string;
    if (raw.length === 0) {
      return [];
    }
    try {
      const parsed = JSON.parse(raw) as ObservationRecord[];
      if (!Array.isArray(parsed)) {
        return [];
      }
      return this.keepValid(parsed);
    } catch {
      return [];
    }
  }

  async save(context: Context, records: ObservationRecord[]): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(RECORDS_KEY, JSON.stringify(records));
    await store.flush();
  }

  async clear(context: Context): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.delete(RECORDS_KEY);
    await store.flush();
  }

  create(kind: ObservationType, place: string, note: string): ObservationRecord {
    const now: number = Date.now();
    const record: ObservationRecord = {
      id: `observation-${now}`,
      kind,
      sourceLevel: SOURCE_PUBLIC_LEAD,
      place: place.trim(),
      note: note.trim(),
      observedAt: now,
      createdAt: now
    };
    return record;
  }

  private keepValid(items: ObservationRecord[]): ObservationRecord[] {
    const records: ObservationRecord[] = [];
    for (let index = 0; index < items.length; index += 1) {
      const item = items[index];
      if (typeof item.id === 'string' && item.id.length > 0 &&
        this.isKind(item.kind) &&
        typeof item.sourceLevel === 'string' && item.sourceLevel.length > 0 &&
        typeof item.place === 'string' && typeof item.note === 'string' &&
        typeof item.observedAt === 'number' && Number.isFinite(item.observedAt) &&
        typeof item.createdAt === 'number' && Number.isFinite(item.createdAt)) {
        records.push(item);
      }
    }
    return records;
  }

  private isKind(value: string): boolean {
    for (let index = 0; index < VALID_KINDS.length; index += 1) {
      if (VALID_KINDS[index] === value) {
        return true;
      }
    }
    return false;
  }
}
