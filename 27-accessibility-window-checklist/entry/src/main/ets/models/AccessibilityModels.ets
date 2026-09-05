export enum ReviewStatus {
  DRAFT = 'draft',
  SAVED = 'saved',
  PENDING = 'pending',
  DONE = 'done',
  DEFERRED = 'deferred',
  DELETED = 'deleted'
}

export enum BarrierSeverity {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high'
}

export interface BarrierItem {
  id: string;
  title: string;
  description: string;
  severity: BarrierSeverity;
  checked: boolean;
}

export interface CheckTemplate {
  id: string;
  name: string;
  items: BarrierItem[];
}

export interface PlaceCheck {
  id: string;
  placeName: string;
  serviceWindow: string;
  address: string;
  lastCheckedAt: string;
  status: ReviewStatus;
  nextStep: string;
  note: string;
  template: CheckTemplate;
}
