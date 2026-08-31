import { preferences } from '@kit.ArkData';

export type DrillKind = 'sos' | 'shelter' | 'roadblock' | 'supplies';

export const DRILL_KINDS: DrillKind[] = ['sos', 'shelter', 'roadblock', 'supplies'];

export function drillKindLabel(kind: DrillKind): string {
  switch (kind) {
    case 'shelter':
      return '避险点';
    case 'roadblock':
      return '道路障碍';
    case 'supplies':
      return '物资点';
    default:
      return 'SOS 演练';
  }
}

function toDrillKind(value: string, label: string): DrillKind {
  if (value === 'sos' || value === 'shelter' || value === 'roadblock' || value === 'supplies') {
    return value;
  }
  if (label.indexOf('避险') >= 0) {
    return 'shelter';
  }
  if (label.indexOf('道路') >= 0) {
    return 'roadblock';
  }
  if (label.indexOf('物资') >= 0) {
    return 'supplies';
  }
  return 'sos';
}

export interface DrillRecord {
  id: number;
  createdAt: string;
  kind: DrillKind;
  label: string;
  sourceVersionId: string;
  receivedAt: string;
  conflictGroupId: string;
  conflictStatus: string;
  drillPackId: string;
  drillPackTitle: string;
  locationPrecision: string;
  source: string;
  reviewStatus: string;
}

export interface DrillPack {
  id: string;
  title: string;
  description: string;
}

// 这些是应用内置的演练提示，不是下载的地图、政府预警或真实救援资料。
export const LOCAL_DRILL_PACKS: DrillPack[] = [
  {
    id: 'community-basics',
    title: '社区基础演练包',
    description: '用于练习记录 SOS、避险点、道路障碍和物资点；不含地图。'
  },
  {
    id: 'family-preparedness',
    title: '家庭预案演练包',
    description: '用于练习家庭场景下的本机事件记录；不含联系人通知或位置。'
  }
];

export const PRIVACY_ACCEPTED: string = 'accepted';
export const PRIVACY_DECLINED: string = 'declined';

const PREFERENCES_NAME: string = 'beidou-neighboraid-drill-records';
const RECORDS_KEY: string = 'records';
const PRIVACY_KEY: string = 'privacy-choice';
const DRILL_PACK_KEY: string = 'selected-drill-pack';

export class DrillRecordStore {
  async loadPrivacyChoice(context: Context): Promise<string> {
    const store = await preferences.getPreferences(context, PREFERENCES_NAME);
    const value = await store.get(PRIVACY_KEY, '') as string;
    return typeof value === 'string' ? value : '';
  }

  async savePrivacyChoice(context: Context, choice: string): Promise<void> {
    const store = await preferences.getPreferences(context, PREFERENCES_NAME);
    await store.put(PRIVACY_KEY, choice);
    await store.flush();
  }

  async loadSelectedDrillPackId(context: Context): Promise<string> {
    const store = await preferences.getPreferences(context, PREFERENCES_NAME);
    const value = await store.get(DRILL_PACK_KEY, '') as string;
    return typeof value === 'string' ? value : '';
  }

  async saveSelectedDrillPackId(context: Context, drillPackId: string): Promise<void> {
    const store = await preferences.getPreferences(context, PREFERENCES_NAME);
    await store.put(DRILL_PACK_KEY, drillPackId);
    await store.flush();
  }

  async load(context: Context): Promise<DrillRecord[]> {
    const store = await preferences.getPreferences(context, PREFERENCES_NAME);
    const storedValue = await store.get(RECORDS_KEY, '') as string;
    return this.decode(storedValue);
  }

  async save(context: Context, records: DrillRecord[]): Promise<void> {
    const store = await preferences.getPreferences(context, PREFERENCES_NAME);
    await store.put(RECORDS_KEY, JSON.stringify(records));
    await store.flush();
  }

  async clear(context: Context): Promise<void> {
    const store = await preferences.getPreferences(context, PREFERENCES_NAME);
    await store.delete(RECORDS_KEY);
    await store.flush();
  }

  private decode(value: string): DrillRecord[] {
    if (value.length === 0) {
      return [];
    }

    try {
      const parsed = JSON.parse(value) as DrillRecord[];
      if (Array.isArray(parsed)) {
        return this.keepValid(parsed);
      }
    } catch {
      // 兼容本轮之前的分隔符存档。
    }

    const records: DrillRecord[] = [];
    const lines = value.split('\n');
    for (let index = 0; index < lines.length; index += 1) {
      const parts = lines[index].split('|');
      const id = Number(parts[0]);
      if (parts.length === 3 && Number.isFinite(id) && parts[1].length > 0 && parts[2].length > 0) {
        const kind = toDrillKind('', parts[2]);
        records.push({
          id,
          createdAt: parts[1],
          kind,
          label: parts[2],
          sourceVersionId: `legacy-${id}`,
          receivedAt: parts[1],
          conflictGroupId: '',
          conflictStatus: '当前无冲突版本',
          drillPackId: '',
          drillPackTitle: '未启用本机演练包',
          locationPrecision: '未添加位置',
          source: '本机演练',
          reviewStatus: '未提交'
        });
      }
    }
    return records;
  }

  private keepValid(items: DrillRecord[]): DrillRecord[] {
    const records: DrillRecord[] = [];
    for (let index = 0; index < items.length; index += 1) {
      const item = items[index];
      if (typeof item.id === 'number' && Number.isFinite(item.id) &&
        typeof item.createdAt === 'string' && item.createdAt.length > 0 &&
        typeof item.label === 'string' && item.label.length > 0) {
        records.push({
          id: item.id,
          createdAt: item.createdAt,
          kind: toDrillKind(item.kind, item.label),
          label: item.label,
          sourceVersionId: typeof item.sourceVersionId === 'string' && item.sourceVersionId.length > 0
            ? item.sourceVersionId
            : `local-${item.id}`,
          receivedAt: typeof item.receivedAt === 'string' && item.receivedAt.length > 0
            ? item.receivedAt
            : item.createdAt,
          conflictGroupId: typeof item.conflictGroupId === 'string' ? item.conflictGroupId : '',
          conflictStatus: typeof item.conflictStatus === 'string' && item.conflictStatus.length > 0
            ? item.conflictStatus
            : '当前无冲突版本',
          drillPackId: typeof item.drillPackId === 'string' ? item.drillPackId : '',
          drillPackTitle: typeof item.drillPackTitle === 'string' && item.drillPackTitle.length > 0
            ? item.drillPackTitle
            : '未启用本机演练包',
          locationPrecision: typeof item.locationPrecision === 'string' && item.locationPrecision.length > 0
            ? item.locationPrecision
            : '未添加位置',
          source: typeof item.source === 'string' && item.source.length > 0 ? item.source : '本机演练',
          reviewStatus: typeof item.reviewStatus === 'string' && item.reviewStatus.length > 0
            ? item.reviewStatus
            : '未提交'
        });
      }
    }
    return records;
  }
}
