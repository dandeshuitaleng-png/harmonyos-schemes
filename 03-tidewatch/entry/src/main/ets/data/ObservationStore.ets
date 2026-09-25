import { preferences } from '@kit.ArkData';
import { RdbSnapshotIO } from './RdbSnapshotIO';
import { ObservationDraft } from './Observation';
import { ObservationRepository } from './ObservationRepository';

export const PRIVACY_ACCEPTED: string = 'accepted';
export const PRIVACY_DECLINED: string = 'declined';
const STORE_NAME: string = 'tidewatch-observation-drafts';
const PRIVACY_KEY: string = 'privacy-choice';

export class ObservationStore {
  private repository: ObservationRepository | undefined = undefined;
  private getRepository(context: Context): ObservationRepository {
    if (this.repository === undefined) this.repository = new ObservationRepository(new RdbSnapshotIO(context));
    return this.repository;
  }
  async loadPrivacyChoice(context: Context): Promise<string> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const value = await store.get(PRIVACY_KEY, '');
    return value === PRIVACY_ACCEPTED || value === PRIVACY_DECLINED ? value : '';
  }
  async savePrivacyChoice(context: Context, choice: string): Promise<void> {
    if (choice !== PRIVACY_ACCEPTED && choice !== PRIVACY_DECLINED) throw new Error('隐私选择无效');
    const store = await preferences.getPreferences(context, STORE_NAME);
    const previous = await store.get(PRIVACY_KEY, '');
    try {
      await store.put(PRIVACY_KEY, choice);
      await store.flush();
    } catch (error) {
      await store.put(PRIVACY_KEY, previous);
      await store.flush();
      throw new Error((error as Error).message);
    }
  }
  async load(context: Context): Promise<ObservationDraft[]> { return this.getRepository(context).load(); }
  async save(context: Context, drafts: ObservationDraft[]): Promise<void> { await this.getRepository(context).save(drafts); }
}
