import { preferences } from '@kit.ArkData';

export const PRIVACY_ACCEPTED: string = 'accepted';
export const PRIVACY_DECLINED: string = 'declined';

const STORE_NAME: string = 'stillside-practice';
const COUNT_KEY: string = 'completed-count';
const PRIVACY_KEY: string = 'privacy-choice';

export class PracticeStore {
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

  async loadCount(context: Context): Promise<number> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const value = await store.get(COUNT_KEY, 0) as number;
    return Number.isFinite(value) && value >= 0 ? value : 0;
  }

  async saveCount(context: Context, count: number): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(COUNT_KEY, count);
    await store.flush();
  }

  async clearCount(context: Context): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.delete(COUNT_KEY);
    await store.flush();
  }
}
