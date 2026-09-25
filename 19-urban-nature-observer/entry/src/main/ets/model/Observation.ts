export const TASKS: string[] = ['叶缘', '叶脉', '花果', '树皮'];
export const PLACES: string[] = ['公园', '街边', '校园', '社区'];
export const UNCLEAR: string = '暂时看不清';
export const ABSENT: string = '未见花果';
export const MAX_RECORDS: number = 10;
// Application budget for ten small records, independent of the platform's larger value limit.
export const MAX_ARCHIVE_BYTES: number = 8192;

function checkArchiveSize(raw: string): void {
  if (raw.length > MAX_ARCHIVE_BYTES) { throw new Error('Observation archive too large'); }
  let bytes: number = 0;
  for (let i = 0; i < raw.length; i++) {
    const code: number = raw.charCodeAt(i);
    if (code < 0x80) { bytes += 1; }
    else if (code < 0x800) { bytes += 2; }
    else if (code >= 0xD800 && code <= 0xDBFF && i + 1 < raw.length &&
      raw.charCodeAt(i + 1) >= 0xDC00 && raw.charCodeAt(i + 1) <= 0xDFFF) {
      bytes += 4;
      i++;
    } else { bytes += 3; }
    if (bytes > MAX_ARCHIVE_BYTES) { throw new Error('Observation archive too large'); }
  }
}

export interface Observation {
  id: string;
  createdAt: number;
  task: string;
  place: string;
  features: string[];
}

interface Archive {
  version: number;
  records: Observation[];
}

export function optionsFor(task: string): string[] {
  if (task === '叶缘') { return ['边缘看起来平滑', '边缘有明显锯齿', '边缘有分裂或裂片', UNCLEAR]; }
  if (task === '叶脉') { return ['可见一条主脉', '可见多条分叉脉', '可见大致平行的脉', UNCLEAR]; }
  if (task === '花果') { return ['看到花或花苞', '看到果实或种子结构', ABSENT, UNCLEAR]; }
  if (task === '树皮') { return ['表面较平滑', '表面粗糙有纹理', '有片状脱落或裂纹', UNCLEAR]; }
  return [];
}

export function guidanceFor(task: string): string {
  if (task === '叶缘') { return '看叶片外缘的轮廓，可比较同一株上的几片叶子；不摘取叶片。'; }
  if (task === '叶脉') { return '在自然光下看叶片表面的线条，看不清时记录不确定即可。'; }
  if (task === '花果') { return '从原地观察是否有花、花苞或果实结构；不采摘、不品尝。'; }
  if (task === '树皮') { return '看树干表面的纹理与裂隙；不剥皮，也无需触摸。'; }
  return '从身边一株植物开始，选择一个观察任务。';
}

export function toggleFeature(task: string, selected: string[], option: string): string[] {
  if (optionsFor(task).indexOf(option) < 0) { return selected.slice(); }
  if (selected.indexOf(option) >= 0) { return selected.filter((item: string) => item !== option); }
  if (option === UNCLEAR || option === ABSENT) { return [option]; }
  const next: string[] = selected.filter((item: string) => item !== UNCLEAR && item !== ABSENT);
  next.push(option);
  return next;
}

export function validSelection(task: string, place: string, features: string[]): boolean {
  if (TASKS.indexOf(task) < 0 || PLACES.indexOf(place) < 0 || !Array.isArray(features)) { return false; }
  const options: string[] = optionsFor(task);
  if (features.length === 0 || features.length > options.length) { return false; }
  for (let i = 0; i < features.length; i++) {
    if (options.indexOf(features[i]) < 0 || features.indexOf(features[i]) !== i) { return false; }
  }
  return !((features.indexOf(UNCLEAR) >= 0 || features.indexOf(ABSENT) >= 0) && features.length > 1);
}

export function decodeArchive(raw: string): Observation[] {
  if (raw === '') { return []; }
  checkArchiveSize(raw);
  const archive: Archive = JSON.parse(raw) as Archive;
  if (!archive || archive.version !== 1 || !Array.isArray(archive.records) || archive.records.length > MAX_RECORDS) {
    throw new Error('Unsupported observation archive');
  }
  const ids: string[] = [];
  const records: Observation[] = [];
  for (const record of archive.records) {
    if (!record || typeof record.id !== 'string' || record.id.length === 0 || record.id.length > 80 || record.id === 'all' ||
      ids.indexOf(record.id) >= 0 || !Number.isSafeInteger(record.createdAt) || record.createdAt <= 0 ||
      record.createdAt > 8640000000000000 || !validSelection(record.task, record.place, record.features)) {
      throw new Error('Invalid observation record');
    }
    ids.push(record.id);
    records.push({ id: record.id, createdAt: record.createdAt, task: record.task, place: record.place, features: record.features.slice() });
  }
  return records;
}

export function encodeArchive(records: Observation[]): string {
  const archive: Archive = { version: 1, records: records };
  const raw: string = JSON.stringify(archive);
  const normalized: Archive = { version: 1, records: decodeArchive(raw) };
  return JSON.stringify(normalized);
}
