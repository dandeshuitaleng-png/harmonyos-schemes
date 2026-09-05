import { ReliefRequest, RequestTemplate, TrustedContact } from '../models/ReliefModels';

export class ReliefMockRepository {
  getTrustedContacts(): TrustedContact[] {
    return [
      { id: 'c1', name: '小林', relation: '邻居', reachableTime: '今天 18:30 后' },
      { id: 'c2', name: '二姐', relation: '家人', reachableTime: '午休或晚饭后' },
      { id: 'c3', name: '陈叔', relation: '熟人', reachableTime: '周末下午' }
    ];
  }

  getRequestTemplates(): RequestTemplate[] {
    return [
      { id: 't1', title: '买药窗口', message: '我需要离开 30 分钟去买药，可以帮忙在家看一下吗？不方便也没关系。' },
      { id: 't2', title: '短暂休息', message: '我想安静休息 30 分钟，可以替我留意一下情况吗？只需要在旁边看着。' },
      { id: 't3', title: '接电话处理事', message: '我有一通必须处理的电话，需要 30 分钟不被打断。可以帮我照看一下吗？' }
    ];
  }

  getRecentRequests(): ReliefRequest[] {
    return [
      { id: 'r1', title: '买药窗口', timeWindow: '今天 18:30-19:00', contactName: '小林', task: '在客厅留意老人状态', note: '药店来回大约 20 分钟。', status: 'pending' },
      { id: 'r2', title: '短暂休息', timeWindow: '昨天 15:00-15:30', contactName: '二姐', task: '替班 30 分钟', note: '已当面感谢。', status: 'done' },
      { id: 'r3', title: '接电话处理事', timeWindow: '周六下午', contactName: '陈叔', task: '必要时帮忙倒水', note: '对方建议改到周日。', status: 'deferred' },
      { id: 'r4', title: '草稿：晚饭后喘口气', timeWindow: '今晚待定', contactName: '未选择', task: '陪伴 30 分钟', note: '先记录，稍后补联系人。', status: 'draft' }
    ];
  }
}
