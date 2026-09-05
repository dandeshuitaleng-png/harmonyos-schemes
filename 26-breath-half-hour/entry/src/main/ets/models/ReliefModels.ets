export type ResponseStatus = 'draft' | 'saved' | 'pending' | 'done' | 'deferred';

export interface TrustedContact {
  id: string;
  name: string;
  relation: string;
  reachableTime: string;
}

export interface RequestTemplate {
  id: string;
  title: string;
  message: string;
}

export interface ReliefRequest {
  id: string;
  title: string;
  timeWindow: string;
  contactName: string;
  task: string;
  note: string;
  status: ResponseStatus;
}
