export const SOURCE: string = '现场巡查员本地记录';
export const PRIVATE_STATUS: string = '待审核 · 不公开';
export const MAX_RECORDS: number = 200;
export const KINDS: string[] = ['潮位异常', '道路积水', '避险物资', '未分类'];
export const RISKS: string[] = ['未评估', '低', '中', '高'];
export const HOURS: number[] = [1, 2, 6, 12, 24];

export interface ObservationDraft {
  id: number;
  source: string;
  collectedAt: string;
  expiresAt: string;
  status: string;
  title: string;
  place: string;
  description: string;
  kind: string;
  risk: string;
  updatedAt: string;
}
export interface ObservationInput {
  title: string;
  place: string;
  description: string;
  kind: string;
  risk: string;
}
interface LegacyDraft {
  id: number;
  source: string;
  collectedAt: string;
  expiresAt: string;
  status: string;
}
interface Snapshot {
  version: number;
  records: ObservationDraft[];
}

export function validateInput(input: ObservationInput): string {
  if (typeof input.title !== 'string' || input.title.trim().length < 2 || input.title.trim().length > 40) return '标题需为2–40字';
  if (typeof input.place !== 'string' || input.place.trim().length < 2 || input.place.trim().length > 80) return '地点概述需为2–80字';
  if (typeof input.description !== 'string' || input.description.trim().length < 5 || input.description.trim().length > 500) return '现场描述需为5–500字';
  if (KINDS.indexOf(input.kind) < 0 || RISKS.indexOf(input.risk) < 0) return '请选择有效的类型与风险等级';
  return '';
}
function validTime(value: string): boolean {
  return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/.test(value) &&
    Number.isFinite(Date.parse(value)) && new Date(value).toISOString() === value;
}
function validLegacy(item: LegacyDraft): boolean {
  return item !== null && typeof item === 'object' && Number.isSafeInteger(item.id) && item.id > 0 &&
    item.source === SOURCE && item.status === PRIVATE_STATUS && validTime(item.collectedAt) &&
    validTime(item.expiresAt) && Date.parse(item.expiresAt) > Date.parse(item.collectedAt);
}
function migrate(item: LegacyDraft): ObservationDraft {
  if (!validLegacy(item)) throw new Error('旧记录字段无效，请保留原始数据并修复');
  return { id: item.id, source: item.source, collectedAt: item.collectedAt, expiresAt: item.expiresAt,
    status: PRIVATE_STATUS, title: '历史观察草稿', place: '尚未补充', description: '旧版草稿未记录现场描述。',
    kind: '未分类', risk: '未评估', updatedAt: item.collectedAt };
}
export function isExpired(item: ObservationDraft, now: number): boolean {
  return Date.parse(item.expiresAt) <= now;
}
export function validateRecords(records: ObservationDraft[]): void {
  if (!Array.isArray(records) || records.length > MAX_RECORDS) throw new Error('记录数量或格式无效');
  const ids: number[] = [];
  for (let i = 0; i < records.length; i += 1) {
    const item = records[i];
    if (!validLegacy(item) || validateInput(item).length > 0 || !validTime(item.updatedAt) ||
      Date.parse(item.updatedAt) < Date.parse(item.collectedAt) || ids.indexOf(item.id) >= 0) {
      throw new Error('发现损坏或重复的记录，已停止写入以保护原数据');
    }
    ids.push(item.id);
  }
}
export function decodeRecords(raw: string): ObservationDraft[] {
  if (raw === '') return [];
  let records: ObservationDraft[] = [];
  const text = raw.trim();
  if (text.startsWith('[')) {
    const legacy = JSON.parse(text) as LegacyDraft[];
    for (let i = 0; i < legacy.length; i += 1) records.push(migrate(legacy[i]));
  } else if (text.startsWith('{')) {
    const snapshot = JSON.parse(text) as Snapshot;
    if (snapshot.version !== 2) throw new Error('不支持此数据版本，请勿覆盖');
    records = snapshot.records;
  } else {
    const lines = text.split('\n');
    for (let i = 0; i < lines.length; i += 1) {
      const parts = lines[i].split('|');
      if (parts.length !== 5 || !/^\d+$/.test(parts[0])) throw new Error('旧格式数据损坏');
      records.push(migrate({ id: Number(parts[0]), source: parts[1], collectedAt: parts[2], expiresAt: parts[3], status: parts[4] }));
    }
  }
  validateRecords(records);
  return records;
}
export function encodeRecords(records: ObservationDraft[]): string {
  validateRecords(records);
  const snapshot: Snapshot = { version: 2, records: records };
  return JSON.stringify(snapshot);
}
export function createObservation(input: ObservationInput, hours: number, now: number, existing: ObservationDraft[]): ObservationDraft {
  const error = validateInput(input);
  if (error.length > 0) throw new Error(error);
  if (HOURS.indexOf(hours) < 0 || !Number.isSafeInteger(now) || now <= 0) throw new Error('有效期或时间无效');
  if (existing.length >= MAX_RECORDS) throw new Error('本机最多保存200条，请先整理历史记录');
  let id = now;
  while (existing.some((item: ObservationDraft) => item.id === id)) id += 1;
  return { id: id, source: SOURCE, collectedAt: new Date(now).toISOString(), expiresAt: new Date(now + hours * 3600000).toISOString(),
    status: PRIVATE_STATUS, title: input.title.trim(), place: input.place.trim(), description: input.description.trim(),
    kind: input.kind, risk: input.risk, updatedAt: new Date(now).toISOString() };
}
export function editObservation(item: ObservationDraft, input: ObservationInput, now: number): ObservationDraft {
  const error = validateInput(input);
  if (error.length > 0) throw new Error(error);
  if (!Number.isSafeInteger(now) || now < Date.parse(item.collectedAt)) throw new Error('系统时间早于采集时间，请检查时间设置');
  if (isExpired(item, now)) throw new Error('记录已过期，请创建新的现场观察');
  return { id: item.id, source: item.source, collectedAt: item.collectedAt, expiresAt: item.expiresAt, status: PRIVATE_STATUS,
    title: input.title.trim(), place: input.place.trim(), description: input.description.trim(), kind: input.kind, risk: input.risk,
    updatedAt: new Date(now).toISOString() };
}
export function filterObservations(records: ObservationDraft[], query: string, filter: string, now: number): ObservationDraft[] {
  const term = query.trim().toLowerCase();
  return records.filter((item: ObservationDraft) => {
    const expired = isExpired(item, now);
    return (filter === '全部' || (filter === '有效期内' && !expired) || (filter === '已过期' && expired)) &&
      `${item.title} ${item.place} ${item.description} ${item.kind}`.toLowerCase().indexOf(term) >= 0;
  });
}
