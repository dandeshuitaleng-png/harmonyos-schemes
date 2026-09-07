// Original procedural artwork. These colors describe material lighting, not UI semantics.
interface PotMaterial { light: string; middle: string; shade: string; rim: string; }
class ClayArt {
  static pots: PotMaterial[] = [
    { light: '#FFE2BC', middle: '#ECA578', shade: '#B96747', rim: '#FFD6AB' },
    { light: '#E0EAC2', middle: '#A9BE86', shade: '#687E51', rim: '#ECF3D3' },
    { light: '#EADDFB', middle: '#B8A0D5', shade: '#80669E', rim: '#EEE3FF' }
  ];
  static leafLight: string = '#CEE99A';
  static leafMiddle: string = '#76AB54';
  static leafShade: string = '#326147';
  static stem: string = '#547C44';
  static eyes: string = '#354332';
  static blush: string = '#D77F68';
  static shine: string = '#FFFFFF';
  static soil: string = '#65503C';
  static shadow: string = 'rgba(45,71,38,0.20)';
  static shadowClear: string = 'rgba(45,71,38,0)';
  static star: string = '#E4BA5E';
}

@Component
export struct ClayPlant {
  @Prop @Watch('render') palette: number = 0;
  @Prop @Watch('render') happy: boolean = false;
  @Prop @Watch('motionChanged') motionEnabled: boolean = true;
  @Prop compact: boolean = false;
  @Prop @Watch('celebrate') pulse: number = 0;
  onPlay: () => void = (): void => {};
  @State private angle: number = 0;
  @State private orbitAngle: number = 0;
  @State private zoom: number = 1;
  private wink: boolean = false;
  private ready: boolean = false;
  private timer: number = -1;
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  aboutToDisappear(): void { if (this.timer !== -1) { clearTimeout(this.timer); } this.ready = false; }
  private motionChanged(): void {
    if (!this.motionEnabled) {
      if (this.timer !== -1) { clearTimeout(this.timer); this.timer = -1; }
      this.angle = 0; this.orbitAngle = 0; this.zoom = 1;
    }
  }
  private celebrate(): void { if (this.ready && this.pulse > 0) { this.respond(); } }
  private respond(): void {
    this.wink = !this.wink;
    this.render();
    if (!this.motionEnabled || this.compact) { return; }
    if (this.timer !== -1) { clearTimeout(this.timer); }
    this.getUIContext().animateTo({ duration: 130, curve: Curve.EaseOut }, () => { this.angle = -5; this.zoom = 1.035; });
    this.timer = setTimeout(() => {
      this.getUIContext().animateTo({ duration: 170, curve: Curve.EaseOut }, () => { this.angle = 0; this.orbitAngle = 0; this.zoom = 1; });
      this.timer = -1;
    }, 130);
  }
  private ellipse(x: number, y: number, rx: number, ry: number, color: string): void {
    const c = this.context;
    c.beginPath(); c.ellipse(x, y, rx, ry, 0, 0, Math.PI * 2); c.fillStyle = color; c.fill();
  }
  private leaf(x: number, y: number, rotation: number, size: number): void {
    const c = this.context;
    c.save(); c.translate(x, y); c.rotate(rotation); c.scale(size, size);
    // A curved, inflated leaf with directional light and a fine central vein.
    c.beginPath(); c.moveTo(0, 0);
    c.bezierCurveTo(-38, -1, -53, -29, -42, -54);
    c.bezierCurveTo(-13, -55, 7, -34, 0, 0);
    const shade = c.createLinearGradient(-47, -46, 5, 0);
    shade.addColorStop(0, ClayArt.leafLight); shade.addColorStop(0.42, ClayArt.leafMiddle); shade.addColorStop(1, ClayArt.leafShade);
    c.fillStyle = shade; c.shadowColor = ClayArt.shadow; c.shadowBlur = 8; c.shadowOffsetY = 4; c.fill();
    c.shadowBlur = 0; c.shadowOffsetY = 0;
    c.beginPath(); c.moveTo(-3, -5); c.quadraticCurveTo(-25, -28, -34, -43);
    c.lineWidth = 1.3; c.strokeStyle = 'rgba(228,247,182,0.48)'; c.stroke();
    c.beginPath(); c.ellipse(-30, -37, 5, 13, -0.55, 0, Math.PI * 2);
    c.fillStyle = 'rgba(247,255,218,0.23)'; c.fill();
    c.restore();
  }
  private star(x: number, y: number, size: number): void {
    const c = this.context;
    c.save(); c.translate(x, y); c.beginPath(); c.moveTo(0, -size);
    c.quadraticCurveTo(size * 0.2, -size * 0.2, size, 0);
    c.quadraticCurveTo(size * 0.2, size * 0.2, 0, size);
    c.quadraticCurveTo(-size * 0.2, size * 0.2, -size, 0);
    c.quadraticCurveTo(-size * 0.2, -size * 0.2, 0, -size);
    c.fillStyle = ClayArt.star; c.fill(); c.restore();
  }
  private render(): void {
    if (!this.ready) { return; }
    const c = this.context;
    const w = c.width; const h = c.height;
    if (w <= 0 || h <= 0) { return; }
    const material = ClayArt.pots[this.palette === 1 || this.palette === 2 ? this.palette : 0];
    c.resetTransform(); c.clearRect(0, 0, w, h);
    const scale = Math.min(w / 320, h / 240);
    c.translate((w - 320 * scale) / 2, (h - 240 * scale) / 2); c.scale(scale, scale);
    // Soft ground contact and raised island.
    const shadow = c.createRadialGradient(160, 218, 3, 160, 218, 94);
    shadow.addColorStop(0, ClayArt.shadow); shadow.addColorStop(1, ClayArt.shadowClear);
    c.save(); c.translate(160, 224); c.scale(1, 0.24); c.translate(-160, -218);
    c.fillStyle = shadow; c.fillRect(60, 120, 200, 200); c.restore();
    this.ellipse(160, 218, 76, 13, 'rgba(251,250,228,0.62)');
    this.ellipse(162, 220, 59, 9, 'rgba(62,82,42,0.10)');
    // Pot wall, rounded base, thick lip and inset soil.
    c.beginPath(); c.moveTo(101, 147); c.lineTo(113, 205);
    c.bezierCurveTo(119, 231, 202, 231, 209, 205); c.lineTo(221, 147); c.closePath();
    const pot = c.createLinearGradient(104, 158, 224, 209);
    pot.addColorStop(0, material.light); pot.addColorStop(0.40, material.middle); pot.addColorStop(1, material.shade);
    c.fillStyle = pot; c.fill();
    this.ellipse(161, 148, 61, 19, material.shade);
    this.ellipse(160, 143, 62, 19, material.rim);
    this.ellipse(160, 143, 50, 12, ClayArt.soil);
    this.ellipse(160, 141, 49, 10, '#776048');
    this.ellipse(127, 141, 3, 1.6, '#B69B73'); this.ellipse(186, 146, 4, 1.6, '#AC8D68');
    c.beginPath(); c.moveTo(120, 165); c.quadraticCurveTo(119, 188, 129, 205);
    c.strokeStyle = 'rgba(255,255,239,0.30)'; c.lineWidth = 5; c.lineCap = 'round'; c.stroke();
    // Stem rises from the soil; leaves overlap with soft material shading.
    c.beginPath(); c.moveTo(161, 142); c.bezierCurveTo(159, 112, 163, 80, 154, 46);
    c.lineWidth = 7; c.strokeStyle = ClayArt.stem; c.stroke();
    c.beginPath(); c.moveTo(160, 116); c.quadraticCurveTo(145, 105, 130, 101);
    c.moveTo(159, 102); c.quadraticCurveTo(181, 94, 193, 86);
    c.lineWidth = 4; c.stroke();
    this.leaf(161, 127, -0.70, 0.96);
    this.leaf(161, 112, 1.36, 1.03);
    this.leaf(159, 89, -0.45, 0.88);
    this.leaf(158, 80, 1.13, 0.86);
    this.leaf(155, 59, 0.45, 0.73);
    // Friendly eyes live on the pot, never encode plant health.
    if (this.happy || this.wink) {
      c.beginPath(); c.moveTo(137, 180); c.quadraticCurveTo(142, 174, 147, 180);
      c.moveTo(173, 180); c.quadraticCurveTo(178, 174, 183, 180);
      c.strokeStyle = ClayArt.eyes; c.lineWidth = 3.5; c.stroke();
    } else {
      this.ellipse(142, 180, 3.6, 4.8, ClayArt.eyes); this.ellipse(178, 180, 3.6, 4.8, ClayArt.eyes);
      this.ellipse(141, 178.5, 1, 1.2, ClayArt.shine); this.ellipse(177, 178.5, 1, 1.2, ClayArt.shine);
    }
    this.ellipse(131, 189, 7, 3, 'rgba(208,103,89,0.28)'); this.ellipse(189, 189, 7, 3, 'rgba(208,103,89,0.28)');
    c.beginPath(); c.moveTo(154, 189); c.quadraticCurveTo(160, 196, 166, 189);
    c.lineWidth = 2.6; c.strokeStyle = ClayArt.eyes; c.stroke();
    if (!this.compact) {
      this.star(80, 82, this.wink || this.happy ? 9 : 6);
      this.star(246, 123, this.wink || this.happy ? 8 : 5);
      this.ellipse(234, 57, 4, 4, 'rgba(255,255,234,0.85)');
      this.ellipse(82, 162, 3, 3, 'rgba(255,255,234,0.85)');
      if (this.happy) { this.star(221, 36, 7); this.star(104, 32, 5); }
    }
    c.resetTransform();
  }

  build() {
    Button({ type: ButtonType.Normal }) {
      Canvas(this.context).width('100%').height('100%')
        .onReady(() => { this.ready = true; this.render(); })
        .onAreaChange(() => this.render())
        .rotate({ angle: this.angle, centerX: '50%', centerY: '85%' })
        .scale({ x: this.zoom, y: this.zoom, centerX: '50%', centerY: '85%' })
        .accessibilityLevel('no')
    }.width('100%').height('100%').padding(0).backgroundColor(Color.Transparent)
      .stateEffect(false).borderRadius(24).hitTestBehavior(this.compact ? HitTestMode.None : HitTestMode.Default)
      .rotate({ x: 0, y: 1, z: 0, angle: this.orbitAngle, centerX: '50%', centerY: '70%', perspective: 500 })
      .accessibilityText('轻碰盆栽打招呼，左右轻拖有倾转反馈，不改变照护状态')
      .accessibilityLevel(this.compact ? 'no' : 'yes')
      .onClick(() => { if (!this.compact) { this.respond(); this.onPlay(); } })
      .gesture(PanGesture({ direction: PanDirection.Horizontal, distance: 8 })
        .onActionUpdate((event: GestureEvent) => {
          if (!this.compact && this.motionEnabled) { this.orbitAngle = Math.max(-18, Math.min(18, event.offsetX / 4)); }
        })
        .onActionEnd(() => {
          if (!this.compact) {
            this.getUIContext().animateTo({ duration: this.motionEnabled ? 220 : 0, curve: Curve.EaseOut }, () => { this.orbitAngle = 0; });
          }
        })
        .onActionCancel(() => { this.orbitAngle = 0; }))
  }
}
