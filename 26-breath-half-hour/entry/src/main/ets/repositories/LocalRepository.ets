import { fileIo as fs } from '@kit.CoreFileKit';
import { LocalData } from '../models/RequestDomain';

export class LocalRepository {
  private path: string = '';
  private ready: boolean = false;
  load(filesDir: string): LocalData {
    this.ready = false;
    this.path = filesDir + '/breath-data-v1.json';
    if (!fs.accessSync(this.path)) {
      this.ready = true;
      return { version: 1, contacts: [], requests: [] };
    }
    const data = JSON.parse(fs.readTextSync(this.path)) as LocalData;
    if (data.version !== 1 || !Array.isArray(data.contacts) || !Array.isArray(data.requests)) throw new Error('Invalid local data');
    for (const contact of data.contacts) {
      if (typeof contact.id !== 'string' || typeof contact.name !== 'string' || typeof contact.relation !== 'string') throw new Error('Invalid contact');
    }
    for (const item of data.requests) {
      if (typeof item.id !== 'string' || typeof item.title !== 'string' || typeof item.contactName !== 'string' ||
        typeof item.contactId !== 'string' || typeof item.date !== 'string' || typeof item.time !== 'string' ||
        typeof item.task !== 'string' || typeof item.note !== 'string' || !Number.isFinite(item.createdAt) ||
        !Number.isFinite(item.updatedAt) || !['draft', 'pending', 'accepted', 'done', 'deferred', 'cancelled'].includes(item.status)) throw new Error('Invalid request');
    }
    this.ready = true;
    return data;
  }
  // Flush a complete temporary snapshot before atomically replacing the saved file.
  save(data: LocalData): void {
    if (!this.ready) throw new Error('Storage is not ready');
    const temp = this.path + '.tmp';
    const file = fs.openSync(temp, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
    try { fs.writeSync(file.fd, JSON.stringify(data)); fs.fsyncSync(file.fd); }
    finally { fs.closeSync(file); }
    fs.renameSync(temp, this.path);
  }
}
