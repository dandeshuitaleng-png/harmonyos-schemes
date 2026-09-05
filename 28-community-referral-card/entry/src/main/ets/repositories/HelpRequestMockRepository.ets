import { HelpRequest } from '../models/HelpRequestModels';

export class HelpRequestMockRepository {
  static list(): HelpRequest[] {
    return [
      {
        id: 'HR-20260901-001',
        alias: '朝阳里 03',
        category: '养老照护',
        description: '家属来电，希望记录独居老人近期买药和陪诊诉求。',
        status: 'followed',
        createdAt: '2026-09-01 09:20',
        dueAt: '今日 16:00',
        urgency: '普通'
      },
      {
        id: 'HR-20260901-002',
        alias: '春晖苑 A12',
        category: '残障支持',
        description: '窗口咨询轮椅维修渠道，需要转给社区助残员核实。',
        status: 'referred',
        createdAt: '2026-09-01 10:05',
        dueAt: '明日 10:00',
        urgency: '较急'
      },
      {
        id: 'HR-20260831-018',
        alias: '民安巷 7 号',
        category: '困难家庭',
        description: '网格员代记临时生活物资咨询，需补充联系方式。',
        status: 'draft',
        createdAt: '2026-08-31 17:40',
        urgency: '普通'
      },
      {
        id: 'HR-20260831-015',
        alias: '松柏楼 2 单元',
        category: '养老照护',
        description: '已记录上门探访需求，等待确认下一步转介对象。',
        status: 'registered',
        createdAt: '2026-08-31 15:10',
        dueAt: '9 月 2 日',
        urgency: '普通'
      },
      {
        id: 'HR-20260830-011',
        alias: '河畔社区 06',
        category: '就业咨询',
        description: '困难家庭成员咨询公益岗位信息，已安排电话回访。',
        status: 'followed',
        createdAt: '2026-08-30 11:35',
        dueAt: '今日 18:00',
        urgency: '普通'
      },
      {
        id: 'HR-20260829-009',
        alias: '安康院 5 栋',
        category: '残障支持',
        description: '已完成情况回访，记录结果仅用于社区交接。',
        status: 'closed',
        createdAt: '2026-08-29 14:15',
        urgency: '普通'
      }
    ];
  }
}
