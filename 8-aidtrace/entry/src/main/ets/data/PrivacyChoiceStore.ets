import { preferences } from '@kit.ArkData';

export const PRIVACY_ACCEPTED: string = 'accepted';

const STORE_NAME: string = 'app-privacy-choice';
const PRIVACY_KEY: string = 'choice';

export class PrivacyChoiceStore {
  async load(context: Context): Promise<string> {
    try {
      const store = await preferences.getPreferences(context, STORE_NAME);
      const value = await store.get(PRIVACY_KEY, '') as string;
      return typeof value === 'string' ? value : '';
    } catch {
      throw new Error('Unable to load local privacy choice');
    }
  }

  async saveAccepted(context: Context): Promise<void> {
    try {
      const store = await preferences.getPreferences(context, STORE_NAME);
      await store.put(PRIVACY_KEY, PRIVACY_ACCEPTED);
      await store.flush();
    } catch {
      throw new Error('Unable to save local privacy choice');
    }
  }
}
