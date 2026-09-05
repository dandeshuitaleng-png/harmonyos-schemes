export type RequestStatus = 'draft' | 'registered' | 'referred' | 'followed' | 'closed';

export interface HelpRequest {
  id: string;
  alias: string;
  category: string;
  description: string;
  status: RequestStatus;
  createdAt: string;
  dueAt?: string;
  urgency: string;
}

export interface Referral {
  id: string;
  requestId: string;
  target: string;
  note: string;
  dueAt: string;
}

export interface FollowUp {
  id: string;
  requestId: string;
  result: string;
  nextAction?: string;
}

export function statusLabel(status: RequestStatus): string {
  const labels: Record<RequestStatus, string> = {
    draft: '草稿',
    registered: '已登记',
    referred: '已转介',
    followed: '待回访',
    closed: '已关闭'
  };
  return labels[status];
}
