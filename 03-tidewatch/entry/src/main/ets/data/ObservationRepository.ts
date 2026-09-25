import { ObservationDraft, decodeRecords, encodeRecords } from './Observation';

export interface SnapshotIO {
  read(): Promise<string>;
  write(value: string): Promise<void>;
}

// One writer per page; a failed load never grants permission to overwrite stored evidence.
export class ObservationRepository {
  private io: SnapshotIO;
  private ready: boolean = false;
  private busy: boolean = false;
  constructor(io: SnapshotIO) { this.io = io; }

  async load(): Promise<ObservationDraft[]> {
    if (this.busy) throw new Error('本机存储正在处理');
    this.busy = true;
    this.ready = false;
    try {
      const records = decodeRecords(await this.io.read());
      this.ready = true;
      return records;
    } finally { this.busy = false; }
  }

  async save(records: ObservationDraft[]): Promise<void> {
    if (!this.ready || this.busy) throw new Error('请先完成读取，或等待当前保存结束');
    const raw = encodeRecords(records);
    this.busy = true;
    try { await this.io.write(raw); }
    catch (error) {
      // A flush failure has an uncertain outcome; require reloading before the next mutation.
      this.ready = false;
      throw error;
    } finally { this.busy = false; }
  }
}
