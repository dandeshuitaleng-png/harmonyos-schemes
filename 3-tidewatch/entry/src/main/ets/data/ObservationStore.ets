import { preferences } from '@kit.ArkData';

export interface ObservationDraft { id: number; source: string; collectedAt: string; expiresAt: string; status: string; }

export const PRIVACY_ACCEPTED: string = 'accepted';
export const PRIVACY_DECLINED: string = 'declined';

const STORE_NAME: string = 'tidewatch-observation-drafts';
const DRAFTS_KEY: string = 'drafts';
const PRIVACY_KEY: string = 'privacy-choice';

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

  async clear(context: Context): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.delete(DRAFTS_KEY);
    await store.flush();
  }

  async load(context: Context): Promise<ObservationDraft[]> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const raw = await store.get(DRAFTS_KEY, '') as string;
    if (raw.length === 0) return [];
    try {
      const parsed = JSON.parse(raw) as ObservationDraft[];
      if (Array.isArray(parsed)) {
        const valid: ObservationDraft[] = [];
        for (let index = 0; index < parsed.length; index += 1) {
          const item = parsed[index];
          if (typeof item.id === 'number' && typeof item.source === 'string' && typeof item.collectedAt === 'string'
            && typeof item.expiresAt === 'string' && typeof item.status === 'string') {
            valid.push(item);
          }
        }
        return valid;
      }
    } catch {}
    const drafts: ObservationDraft[] = [];
    const lines = raw.split('\n');
    for (let index = 0; index < lines.length; index += 1) {
      const parts = lines[index].split('|');
      const id = Number(parts[0]);
      if (parts.length === 5 && Number.isFinite(id) && parts[1].length > 0 && parts[2].length > 0 && parts[3].length > 0 && parts[4].length > 0) {
        drafts.push({ id, source: parts[1], collectedAt: parts[2], expiresAt: parts[3], status: parts[4] });
      }
    }
    return drafts;
  }

  async save(context: Context, drafts: ObservationDraft[]): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(DRAFTS_KEY, JSON.stringify(drafts));
    await store.flush();
  }
}
