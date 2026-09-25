import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { Observation, decodeArchive, encodeArchive } from '../model/Observation';

export class ObservationStore {
  private database: preferences.Preferences;
  private committed: string = '';
  private ready: boolean = false;
  private unhealthy: boolean = false;
  private writing: boolean = false;

  constructor(context: common.UIAbilityContext) {
    this.database = preferences.getPreferencesSync(context, { name: 'nature_observations' });
  }

  load(): Observation[] {
    if (this.unhealthy || this.writing) { throw new Error('Restart required'); }
    this.ready = false;
    try {
      const value: preferences.ValueType = this.database.getSync('archive', '');
      if (typeof value !== 'string') { throw new Error('Invalid archive type'); }
      const records: Observation[] = decodeArchive(value);
      this.committed = value;
      this.ready = true;
      return records;
    } catch (error) { throw new Error('Observation read failed'); }
  }

  async save(records: Observation[]): Promise<void> {
    if (!this.ready || this.writing) { throw new Error('Storage not ready'); }
    const next: string = encodeArchive(records);
    this.writing = true;
    try {
      this.database.putSync('archive', next);
      await this.database.flush();
      this.committed = next;
    } catch (error) {
      try {
        this.database.putSync('archive', this.committed);
        await this.database.flush();
      } catch (rollbackError) {
        this.ready = false;
        this.unhealthy = true;
      }
      throw new Error('Observation write failed');
    } finally { this.writing = false; }
  }

  isReady(): boolean {
    return this.ready && !this.unhealthy;
  }
}
