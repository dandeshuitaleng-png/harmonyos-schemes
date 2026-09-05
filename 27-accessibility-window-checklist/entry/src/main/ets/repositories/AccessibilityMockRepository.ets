import { BarrierSeverity, PlaceCheck, ReviewStatus } from '../models/AccessibilityModels';

export class AccessibilityMockRepository {
  getPlaceChecks(): PlaceCheck[] {
    return [
      {
        id: 'place-001',
        placeName: '市民服务中心',
        serviceWindow: '社保综合窗口',
        address: '一层东侧 A 区',
        lastCheckedAt: '2026-08-29 09:30',
        status: ReviewStatus.PENDING,
        nextStep: '下次带身份证复印件，先找导办台确认低位窗口。',
        note: '排队区较窄，轮椅转身困难。',
        template: {
          id: 'template-government',
          name: '政务窗口基础检查',
          items: [
            { id: 'barrier-001', title: '低位服务窗口', description: '现场是否有可坐姿沟通的低位窗口。', severity: BarrierSeverity.HIGH, checked: true },
            { id: 'barrier-002', title: '排队通道宽度', description: '通道是否允许轮椅或助行器通过。', severity: BarrierSeverity.HIGH, checked: false },
            { id: 'barrier-003', title: '取号机高度', description: '取号机屏幕和按钮是否可触达。', severity: BarrierSeverity.MEDIUM, checked: false },
            { id: 'barrier-004', title: '导办人员协助', description: '入口是否能快速找到工作人员协助。', severity: BarrierSeverity.MEDIUM, checked: true }
          ]
        }
      },
      {
        id: 'place-002',
        placeName: '人民医院门诊楼',
        serviceWindow: '缴费窗口',
        address: '门诊二层西侧',
        lastCheckedAt: '2026-08-29 11:10',
        status: ReviewStatus.DONE,
        nextStep: '已记录可通行路线，复诊时直接从北门电梯进入。',
        note: '北门电梯更近，窗口旁有临时座椅。',
        template: {
          id: 'template-hospital',
          name: '医院窗口基础检查',
          items: [
            { id: 'barrier-005', title: '无障碍电梯路线', description: '入口到窗口是否有连续可通行路线。', severity: BarrierSeverity.HIGH, checked: true },
            { id: 'barrier-006', title: '叫号屏可见', description: '坐姿位置是否能看清叫号屏。', severity: BarrierSeverity.MEDIUM, checked: true },
            { id: 'barrier-007', title: '现金/扫码可达', description: '支付设备是否放在可触达高度。', severity: BarrierSeverity.MEDIUM, checked: true }
          ]
        }
      },
      {
        id: 'place-003',
        placeName: '建设银行社区支行',
        serviceWindow: '个人业务窗口',
        address: '大厅入口右侧',
        lastCheckedAt: '2026-08-29 14:20',
        status: ReviewStatus.DEFERRED,
        nextStep: '避开午后高峰，提前电话确认是否有工作人员协助。',
        note: '门口坡道可用，但自助机触控区域偏高。',
        template: {
          id: 'template-bank',
          name: '银行窗口基础检查',
          items: [
            { id: 'barrier-008', title: '入口坡道', description: '入口坡道是否可独立通过。', severity: BarrierSeverity.HIGH, checked: true },
            { id: 'barrier-009', title: '自助机高度', description: '自助终端是否可坐姿操作。', severity: BarrierSeverity.HIGH, checked: false },
            { id: 'barrier-010', title: '等候座位', description: '等候区是否留有助行设备空间。', severity: BarrierSeverity.LOW, checked: true }
          ]
        }
      },
      {
        id: 'place-004',
        placeName: '社区卫生服务站',
        serviceWindow: '登记窗口',
        address: '一层大厅',
        lastCheckedAt: '2026-08-29 16:45',
        status: ReviewStatus.DRAFT,
        nextStep: '补充登记窗口照片后再保存。',
        note: '入口台阶旁有活动坡板，需要工作人员取出。',
        template: {
          id: 'template-community-health',
          name: '社区服务窗口检查',
          items: [
            { id: 'barrier-011', title: '活动坡板可用', description: '坡板是否容易取得并能固定。', severity: BarrierSeverity.HIGH, checked: false },
            { id: 'barrier-012', title: '窗口沟通高度', description: '登记窗口是否能清楚听见和看见。', severity: BarrierSeverity.MEDIUM, checked: false },
            { id: 'barrier-013', title: '本地记录提醒', description: '是否写下下一步和联系人。', severity: BarrierSeverity.LOW, checked: true }
          ]
        }
      }
    ];
  }
}
