import { preferences } from '@kit.ArkData';

export interface HabitState {
  day: string;
  selectedIds: string[];
  completedIds: string[];
  skippedIds: string[];
}

export const PRIVACY_ACCEPTED: string = 'accepted';
export const PRIVACY_DECLINED: string = 'declined';

const STORE_NAME: string = 'gentlesteps-habits';
const STATE_KEY: string = 'daily-state';
const PRIVACY_KEY: string = 'privacy-choice';

export class HabitStore {
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

  async load(context: Context, day: string): Promise<HabitState> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const raw = await store.get(STATE_KEY, '') as string;
    if (raw.length === 0) {
      return { day, selectedIds: [], completedIds: [], skippedIds: [] };
    }
    try {
      const parsed = JSON.parse(raw) as HabitState;
      if (parsed.day === day && Array.isArray(parsed.selectedIds) &&
        Array.isArray(parsed.completedIds) && Array.isArray(parsed.skippedIds)) {
        return parsed;
      }
    } catch {
      // 跨日或损坏记录不展示为当天任务。
    }
    return { day, selectedIds: [], completedIds: [], skippedIds: [] };
  }

  async save(context: Context, state: HabitState): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(STATE_KEY, JSON.stringify(state));
    await store.flush();
  }

  async clear(context: Context): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.delete(STATE_KEY);
    await store.flush();
  }
}
