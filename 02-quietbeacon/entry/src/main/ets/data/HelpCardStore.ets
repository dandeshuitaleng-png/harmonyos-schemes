import { preferences } from '@kit.ArkData';

export interface HelpCard { templateId: string; message: string; createdAt: string; }

export const PRIVACY_ACCEPTED: string = 'accepted';
export const PRIVACY_DECLINED: string = 'declined';

const STORE_NAME: string = 'quietbeacon-help-card';
const CARD_KEY: string = 'active-card';
const PRIVACY_KEY: string = 'privacy-choice';

export class HelpCardStore {
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

  async load(context: Context): Promise<HelpCard | undefined> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const raw = await store.get(CARD_KEY, '') as string;
    if (raw.length === 0) return undefined;
    try {
      const parsed = JSON.parse(raw) as HelpCard;
      if (typeof parsed.templateId === 'string' && typeof parsed.message === 'string' && typeof parsed.createdAt === 'string'
        && parsed.templateId.length > 0 && parsed.message.length > 0 && parsed.createdAt.length > 0) {
        return parsed;
      }
    } catch {}
    const parts = raw.split('|');
    if (parts.length === 3 && parts[0].length > 0 && parts[1].length > 0 && parts[2].length > 0) {
      return { templateId: parts[0], message: parts[1], createdAt: parts[2] };
    }
    return undefined;
  }

  async save(context: Context, card: HelpCard): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(CARD_KEY, JSON.stringify(card));
    await store.flush();
  }

  async clear(context: Context): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.delete(CARD_KEY);
    await store.flush();
  }
}
