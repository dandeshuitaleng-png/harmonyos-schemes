export type RequestStatus = 'draft' | 'pending' | 'accepted' | 'done' | 'deferred' | 'cancelled';
export interface Contact { id: string; name: string; relation: string; }
export interface RequestItem {
  id: string; contactId: string; contactName: string; title: string; date: string; time: string;
  task: string; note: string; status: RequestStatus; createdAt: number; updatedAt: number;
}
export interface LocalData { version: number; contacts: Contact[]; requests: RequestItem[]; }
export interface Template { title: string; task: string; }
export const TEMPLATES: Template[] = [
  { title: '短暂休息', task: '替我在旁边陪伴家人，留意情况，有需要时联系我。' },
  { title: '外出买药', task: '我外出买药时，请在家陪伴家人半小时。' },
  { title: '处理自己的事', task: '我需要安静处理事情，请帮忙陪伴家人半小时。' }
];
export function statusLabel(status: string): string {
  switch (status) {
    case 'draft': return '草稿'; case 'pending': return '待回应'; case 'accepted': return '已接受';
    case 'done': return '已完成'; case 'deferred': return '已延期'; case 'cancelled': return '已取消';
    default: return '未知状态';
  }
}
export function pad(n: number): string { return n.toString().padStart(2, '0'); }
export function dateText(d: Date): string { return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`; }
export function timeText(d: Date): string { return `${pad(d.getHours())}:${pad(d.getMinutes())}`; }
export function startAt(item: RequestItem): number {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(item.date) || !/^\d{2}:\d{2}$/.test(item.time)) return NaN;
  const d = new Date(`${item.date}T${item.time}:00`);
  return dateText(d) === item.date && timeText(d) === item.time ? d.getTime() : NaN;
}
export function timeRange(item: RequestItem): string {
  const start = startAt(item);
  if (!Number.isFinite(start)) return '时间待补充';
  const end = new Date(start + 30 * 60 * 1000);
  return `${item.date} ${item.time} — ${dateText(end) === item.date ? '' : dateText(end) + ' '}${timeText(end)}`;
}
export function validateRequest(item: RequestItem, complete: boolean, now: number = Date.now()): string {
  if (!item.title.trim()) return '请填写请求标题';
  if (item.title.length > 40 || item.task.length > 300 || item.note.length > 300) return '输入内容过长，请缩短后保存';
  if (!complete) return '';
  if (!item.contactName.trim()) return '请选择联系人';
  if (!item.task.trim()) return '请写清楚需要对方帮忙的事项';
  if (!Number.isFinite(startAt(item))) return '请输入有效日期和时间，例如 2026-09-21、18:30';
  if (startAt(item) <= now) return '开始时间已过，请选择未来时间';
  return '';
}
export function canTransition(from: RequestStatus, to: RequestStatus): boolean {
  if (from === 'draft') return to === 'pending' || to === 'cancelled';
  if (from === 'pending') return to === 'accepted' || to === 'deferred' || to === 'cancelled';
  if (from === 'accepted') return to === 'done' || to === 'deferred' || to === 'cancelled';
  return false;
}
export function requestMessage(item: RequestItem): string {
  return `${item.contactName ? item.contactName + '，你好。' : '你好。'}\n我想请你帮忙替班30分钟：${item.title}。\n时间：${timeRange(item)}\n需要帮忙：${item.task || '待补充'}${item.note.trim() ? '\n补充：' + item.note.trim() : ''}\n只需帮忙以上事项；如果不方便也没关系，请回复告诉我。谢谢你！`;
}
export function emptyRequest(): RequestItem {
  const d = new Date(Math.ceil((Date.now() + 60 * 60 * 1000) / 60000) * 60000);
  return { id: '', contactId: '', contactName: '', title: '短暂休息', date: dateText(d), time: timeText(d), task: TEMPLATES[0].task, note: '', status: 'draft', createdAt: 0, updatedAt: 0 };
}
