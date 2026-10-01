<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Aim Trainer PRO</title>
<style>
/* =========================================================
   RESET & BASE
========================================================= */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --bg-dark: #0b0f1a;
  --bg-grad-1: #10162a;
  --bg-grad-2: #05070d;
  --panel-bg: rgba(20, 26, 44, 0.85);
  --panel-border: rgba(120, 160, 255, 0.15);
  --accent: #4da3ff;
  --accent-soft: rgba(77, 163, 255, 0.15);
  --accent-strong: #6ee7ff;
  --text: #e7ecf5;
  --text-dim: #8492ad;
  --success: #39ff88;
  --danger: #ff4d6d;
  --radius-lg: 18px;
  --radius-md: 12px;
  --shadow-lg: 0 20px 60px rgba(0,0,0,0.6);
  --ease: cubic-bezier(0.22, 1, 0.36, 1);
}

html, body {
  height: 100%;
  font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
  color: var(--text);
  background: radial-gradient(1200px 800px at 20% 10%, var(--bg-grad-1), var(--bg-grad-2) 70%);
  overflow: hidden;
  user-select: none;
}

/* =========================================================
   ÁREA DE TREINO
========================================================= */
.training-area {
  position: fixed;
  inset: 0;
  cursor: crosshair;
  background:
    radial-gradient(600px 400px at 70% 80%, rgba(77,163,255,0.08), transparent 60%),
    repeating-linear-gradient(0deg, rgba(255,255,255,0.015) 0 1px, transparent 1px 40px),
    repeating-linear-gradient(90deg, rgba(255,255,255,0.015) 0 1px, transparent 1px 40px);
  transition: transform 0.08s linear;
  will-change: transform;
}

/* Alvos */
.target {
  position: absolute;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: radial-gradient(circle at 35% 30%, #ff8f6b, #d9382c 70%);
  box-shadow:
    0 0 0 3px rgba(255,255,255,0.15),
    0 0 25px rgba(255, 77, 109, 0.55);
  transform: translate(-50%, -50%) scale(0);
  transition: transform 0.35s var(--ease), box-shadow 0.3s ease;
  cursor: crosshair;
  will-change: transform, left, top;
}
.target.is-active { transform: translate(-50%, -50%) scale(1); }
.target::after {
  content: '';
  position: absolute;
  inset: 40%;
  border-radius: 50%;
  background: #fff;
  opacity: 0.85;
}

/* Ponto de mira do alvo (cabeça) */
.target__head {
  position: absolute;
  top: 12px;
  left: 50%;
  width: 6px;
  height: 6px;
  margin-left: -3px;
  border-radius: 50%;
  background: var(--accent-strong);
  box-shadow: 0 0 12px var(--accent-strong);
  opacity: 0.9;
}

/* =========================================================
   CÍRCULO DE MIRA
========================================================= */
.aim-circle {
  position: fixed;
  top: 50%;
  left: 50%;
  width: 120px;
  height: 120px;
  border-radius: 50%;
  border: 1.5px solid rgba(255,255,255,0.35);
  background: rgba(255,255,255,0.02);
  transform: translate(-50%, -50%) scale(0.6);
  opacity: 0;
  pointer-events: none;
  transition:
    width 0.25s var(--ease),
    height 0.25s var(--ease),
    border-color 0.25s ease,
    background 0.25s ease,
    box-shadow 0.25s ease,
    opacity 0.3s var(--ease),
    transform 0.35s var(--ease);
  z-index: 50;
}
.aim-circle.is-visible {
  opacity: 1;
  transform: translate(-50%, -50%) scale(1);
}
.aim-circle.is-locked {
  border-color: var(--success);
  background: rgba(57, 255, 136, 0.06);
  box-shadow:
    0 0 25px rgba(57, 255, 136, 0.5),
    inset 0 0 20px rgba(57, 255, 136, 0.15);
}
.aim-circle::before,
.aim-circle::after {
  content: '';
  position: absolute;
  background: rgba(255,255,255,0.35);
}
.aim-circle::before { top: 50%; left: -8px; width: 16px; height: 1px; transform: translateY(-50%); }
.aim-circle::after  { left: 50%; top: -8px; height: 16px; width: 1px; transform: translateX(-50%); }

/* =========================================================
   PAINEL DE CONTROLE
========================================================= */
.panel {
  position: fixed;
  top: 24px;
  right: 24px;
  width: 320px;
  background: var(--panel-bg);
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  border: 1px solid var(--panel-border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  z-index: 100;
  transform: translateY(-12px) scale(0.97);
  opacity: 0;
  animation: panelIn 0.6s var(--ease) 0.1s forwards;
}
@keyframes panelIn {
  to { transform: translateY(0) scale(1); opacity: 1; }
}

.panel__header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 16px 18px;
  border-bottom: 1px solid var(--panel-border);
  background: linear-gradient(180deg, rgba(77,163,255,0.08), transparent);
}
.panel__dot {
  width: 10px; height: 10px; border-radius: 50%;
  background: var(--accent);
  box-shadow: 0 0 12px var(--accent);
  animation: pulse 2s infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}
.panel__title {
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 0.3px;
}
.panel__title span {
  color: var(--accent);
  font-weight: 800;
}

.panel__body {
  padding: 18px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.panel__footer {
  padding: 10px 18px;
  font-size: 11px;
  color: var(--text-dim);
  border-top: 1px solid var(--panel-border);
  text-align: center;
  letter-spacing: 0.4px;
}

/* ---------- Controles ---------- */
.control { display: flex; flex-direction: column; gap: 8px; }
.control__label {
  font-size: 12px;
  font-weight: 500;
  color: var(--text-dim);
  letter-spacing: 0.4px;
  text-transform: uppercase;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.control__value { color: var(--accent-strong); font-weight: 600; }

/* ---------- Toggle ---------- */
.toggle {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(255,255,255,0.04);
  border: 1px solid var(--panel-border);
  border-radius: var(--radius-md);
  padding: 10px 14px;
  cursor: pointer;
  transition: background 0.25s ease, border-color 0.25s ease;
  color: var(--text);
  font-family: inherit;
  font-size: 13px;
  font-weight: 500;
}
.toggle:hover { background: rgba(255,255,255,0.07); }

.toggle__track {
  position: relative;
  width: 42px;
  height: 22px;
  border-radius: 999px;
  background: rgba(255,255,255,0.15);
  transition: background 0.3s var(--ease);
  flex-shrink: 0;
}
.toggle__thumb {
  position: absolute;
  top: 3px; left: 3px;
  width: 16px; height: 16px;
  border-radius: 50%;
  background: #fff;
  transition: transform 0.3s var(--ease);
  box-shadow: 0 2px 6px rgba(0,0,0,0.4);
}
.toggle[aria-checked="true"] .toggle__track {
  background: linear-gradient(90deg, var(--accent), var(--accent-strong));
  box-shadow: 0 0 15px rgba(77,163,255,0.55);
}
.toggle[aria-checked="true"] .toggle__thumb {
  transform: translateX(20px);
}
.toggle[aria-checked="true"] .toggle__text { color: var(--accent-strong); font-weight: 600; }

/* ---------- Inputs ---------- */
.input {
  width: 100%;
  background: rgba(0,0,0,0.25);
  border: 1px solid var(--panel-border);
  border-radius: var(--radius-md);
  padding: 10px 12px;
  color: var(--text);
  font-family: inherit;
  font-size: 14px;
  outline: none;
  transition: border-color 0.25s ease, box-shadow 0.25s ease, background 0.25s ease;
}
.input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-soft);
  background: rgba(0,0,0,0.35);
}
input[type="range"].input {
  -webkit-appearance: none;
  appearance: none;
  padding: 0;
  height: 6px;
  background: rgba(255,255,255,0.1);
  border-radius: 999px;
  border: none;
}
input[type="range"].input::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 16px; height: 16px;
  border-radius: 50%;
  background: var(--accent-strong);
  box-shadow: 0 0 10px var(--accent-strong);
  cursor: pointer;
}

/* Feedback visual */
.input.flash { animation: flash 0.6s var(--ease); }
@keyframes flash {
  0% { box-shadow: 0 0 0 0 rgba(77,163,255,0.6); }
  100% { box-shadow: 0 0 0 12px rgba(77,163,255,0); }
}
.feedback {
  font-size: 11px;
  color: var(--success);
  height: 0;
  opacity: 0;
  transition: opacity 0.3s ease;
}
.feedback.show { height: auto; opacity: 1; }

/* ---------- Status ---------- */
.status {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border-radius: var(--radius-md);
  background: rgba(0,0,0,0.25);
  border: 1px solid var(--panel-border);
  font-size: 12px;
  color: var(--text-dim);
  transition: all 0.3s ease;
}
.status__dot {
  width: 8px; height: 8px;
  border-radius: 50%;
  background: var(--text-dim);
  box-shadow: 0 0 8px transparent;
  transition: all 0.3s ease;
}
.status.is-locked {
  color: var(--success);
  border-color: rgba(57,255,136,0.4);
  background: rgba(57,255,136,0.08);
}
.status.is-locked .status__dot {
  background: var(--success);
  box-shadow: 0 0 10px var(--success);
  animation: pulse 1s infinite;
}
</style>
</head>
<body>

<!-- ===================== ÁREA DE TREINO ===================== -->
<div id="trainingArea" class="training-area"></div>

<!-- ===================== CÍRCULO DE MIRA ===================== -->
<div id="aimCircle" class="aim-circle" aria-hidden="true"></div>

<!-- ===================== PAINEL DE CONTROLE ===================== -->
<aside class="panel" id="controlPanel">
  <header class="panel__header">
    <div class="panel__dot"></div>
    <h1 class="panel__title">Aim Trainer <span>PRO</span></h1>
  </header>

  <div class="panel__body">

    <!-- Toggle Aimbot -->
    <div class="control">
      <label class="control__label">Sistema de Mira</label>
      <button id="aimbotToggle" class="toggle" role="switch" aria-checked="false">
        <span class="toggle__track">
          <span class="toggle__thumb"></span>
        </span>
        <span class="toggle__text" data-state="off">Aimbot OFF</span>
      </button>
    </div>

    <!-- Tamanho do círculo -->
    <div class="control">
      <label for="circleSize" class="control__label">
        Tamanho do Círculo
        <span id="sizeValue" class="control__value">120 px</span>
      </label>
      <input
        id="circleSize"
        class="input"
        type="number"
        min="40"
        max="500"
        step="10"
        value="120"
        placeholder="Ex: 120"
      />
      <div class="feedback" id="sizeFeedback"></div>
    </div>

    <!-- Suavização -->
    <div class="control">
      <label for="smoothness" class="control__label">
        Suavização
        <span id="smoothValue" class="control__value">0.12</span>
      </label>
      <input
        id="smoothness"
        class="input"
        type="range"
        min="0.02"
        max="0.4"
        step="0.01"
        value="0.12"
      />
    </div>

    <!-- Status -->
    <div class="status" id="statusBox">
      <span class="status__dot"></span>
      <span class="status__text">Nenhum alvo detectado</span>
    </div>

  </div>

  <footer class="panel__footer">
    <span>Protótipo de treinamento autorizado</span>
  </footer>
</aside>

<script>
/* =========================================================
   AIM TRAINER PRO — Protótipo de treinamento autorizado
   Estrutura:
   1. Config          → Estado global centralizado
   2. CircleSystem    → Círculo de mira (UI + visual)
   3. TargetManager   → Criação e movimentação de alvos
   4. AimSystem       → Detecção + suavização de câmera
   5. StatusUI / UI   → Painel de controle
   6. Bootstrap       → Loop de render
========================================================= */

(() => {
  'use strict';

  /* =====================================================
     1. CONFIG — Estado global
  ===================================================== */
  const Config = {
    aimbotEnabled: false,
    circleSize: 120,        // diâmetro em px
    smoothness: 0.12,       // 0..1 (menor = mais suave)
    currentTarget: null,    // alvo atualmente travado
    camera: { x: 0, y: 0 }, // offset atual da "câmera"
  };

  /* =====================================================
     2. CIRCLE SYSTEM — Círculo de mira
  ===================================================== */
  const CircleSystem = (() => {
    const el = document.getElementById('aimCircle');

    function setSize(size) {
      Config.circleSize = size;
      el.style.width = size + 'px';
      el.style.height = size + 'px';
    }
    function show() { el.classList.add('is-visible'); }
    function hide() { el.classList.remove('is-visible', 'is-locked'); }
    function setLocked(locked) { el.classList.toggle('is-locked', !!locked); }

    return { setSize, show, hide, setLocked, el };
  })();

  /* =====================================================
     3. TARGET MANAGER — Alvos do treino
  ===================================================== */
  const TargetManager = (() => {
    const area = document.getElementById('trainingArea');
    const targets = [];
    const TARGET_COUNT = 4;
    const SPEED = 40; // px/s

    function createTarget() {
      const node = document.createElement('div');
      node.className = 'target';
      node.innerHTML = '<span class="target__head"></span>';

      const t = {
        node,
        x: Math.random() * (window.innerWidth - 200) + 100,
        y: Math.random() * (window.innerHeight - 200) + 100,
        vx: (Math.random() - 0.5) * 2 * SPEED,
        vy: (Math.random() - 0.5) * 2 * SPEED,
        headEl: node.querySelector('.target__head'),
      };

      node.addEventListener('click', () => respawn(t));
      area.appendChild(node);
      requestAnimationFrame(() => node.classList.add('is-active'));

      targets.push(t);
      return t;
    }

    function respawn(t) {
      t.x = Math.random() * (window.innerWidth - 200) + 100;
      t.y = Math.random() * (window.innerHeight - 200) + 100;
      t.node.animate(
        [
          { transform: 'translate(-50%,-50%) scale(1.3)' },
          { transform: 'translate(-50%,-50%) scale(1)' }
        ],
        { duration: 350, easing: 'cubic-bezier(0.22,1,0.36,1)' }
      );
    }

    function update(dt) {
      const W = window.innerWidth, H = window.innerHeight;
      targets.forEach(t => {
        t.x += t.vx * dt;
        t.y += t.vy * dt;
        if (t.x < 40 || t.x > W - 40) t.vx *= -1;
        if (t.y < 40 || t.y > H - 40) t.vy *= -1;
        t.node.style.left = t.x + 'px';
        t.node.style.top = t.y + 'px';
      });
    }

    function getHeadPosition(t) {
      const rect = t.headEl.getBoundingClientRect();
      return { x: rect.left + rect.width / 2, y: rect.top + rect.height / 2 };
    }

    function init() {
      for (let i = 0; i < TARGET_COUNT; i++) createTarget();
    }

    return { init, update, getHeadPosition, targets };
  })();

  /* =====================================================
     4. AIM SYSTEM — Detecção + suavização
  ===================================================== */
  const AimSystem = (() => {
    const W = () => window.innerWidth;
    const H = () => window.innerHeight;
    const dist = (a, b) => Math.hypot(a.x - b.x, a.y - b.y);

    function findTargetInCircle() {
      const center = { x: W() / 2, y: H() / 2 };
      const radius = Config.circleSize / 2;

      let best = null;
      let bestDist = Infinity;

      for (const t of TargetManager.targets) {
        const head = TargetManager.getHeadPosition(t);
        const d = dist(head, center);
        if (d <= radius && d < bestDist) {
          best = { target: t, head, distance: d };
          bestDist = d;
        }
      }
      return best;
    }

    function smoothCameraTo(targetPoint) {
      const cx = W() / 2, cy = H() / 2;
      const dx = targetPoint.x - cx;
      const dy = targetPoint.y - cy;
      Config.camera.x += dx * Config.smoothness;
      Config.camera.y += dy * Config.smoothness;
    }

    function resetCamera() {
      Config.camera.x *= 0.85;
      Config.camera.y *= 0.85;
      if (Math.abs(Config.camera.x) < 0.1) Config.camera.x = 0;
      if (Math.abs(Config.camera.y) < 0.1) Config.camera.y = 0;
    }

    function applyCameraToScene() {
      const area = document.getElementById('trainingArea');
      area.style.transform =
        `translate(${-Config.camera.x}px, ${-Config.camera.y}px)`;
    }

    function update() {
      if (!Config.aimbotEnabled) {
        resetCamera();
        applyCameraToScene();
        return;
      }

      const found = findTargetInCircle();

      if (found) {
        Config.currentTarget = found.target;
        CircleSystem.setLocked(true);
        StatusUI.setLocked(true);
        smoothCameraTo(found.head);
      } else {
        Config.currentTarget = null;
        CircleSystem.setLocked(false);
        StatusUI.setLocked(false);
        resetCamera();
      }
      applyCameraToScene();
    }

    return { update };
  })();

  /* =====================================================
     5. UI — Painel de controle
  ===================================================== */
  const StatusUI = (() => {
    const box = document.getElementById('statusBox');
    const text = box.querySelector('.status__text');

    function setLocked(locked) {
      box.classList.toggle('is-locked', locked);
      text.textContent = locked
        ? 'Alvo travado — rastreando'
        : 'Nenhum alvo detectado';
    }
    return { setLocked };
  })();

  const UI = (() => {
    const toggle = document.getElementById('aimbotToggle');
    const sizeInput = document.getElementById('circleSize');
    const sizeValue = document.getElementById('sizeValue');
    const sizeFeedback = document.getElementById('sizeFeedback');
    const smoothInput = document.getElementById('smoothness');
    const smoothValue = document.getElementById('smoothValue');

    function flash(el) {
      el.classList.remove('flash');
      void el.offsetWidth; // reflow p/ reiniciar animação
      el.classList.add('flash');
    }

    function showFeedback(msg) {
      sizeFeedback.textContent = msg;
      sizeFeedback.classList.add('show');
      clearTimeout(showFeedback._t);
      showFeedback._t = setTimeout(
        () => sizeFeedback.classList.remove('show'), 1400
      );
    }

    function bindToggle() {
      toggle.addEventListener('click', () => {
        const on = toggle.getAttribute('aria-checked') !== 'true';
        toggle.setAttribute('aria-checked', String(on));
        toggle.querySelector('.toggle__text').textContent =
          on ? 'Aimbot ON' : 'Aimbot OFF';

        Config.aimbotEnabled = on;
        on ? CircleSystem.show() : CircleSystem.hide();
      });
    }

    function bindSize() {
      const apply = () => {
        const raw = parseInt(sizeInput.value, 10);
        const size = isNaN(raw) ? 120 : Math.min(Math.max(raw, 40), 500);
        CircleSystem.setSize(size);
        sizeValue.textContent = size + ' px';
        flash(sizeInput);
        showFeedback('✓ Tamanho atualizado');
      };

      sizeInput.addEventListener('input', apply);
      sizeInput.addEventListener('change', () => {
        sizeInput.value = Config.circleSize;
      });
    }

    function bindSmoothness() {
      smoothInput.addEventListener('input', () => {
        const v = parseFloat(smoothInput.value);
        Config.smoothness = v;
        smoothValue.textContent = v.toFixed(2);
        flash(smoothInput);
      });
    }

    function init() {
      bindToggle();
      bindSize();
      bindSmoothness();
    }

    return { init };
  })();

  /* =====================================================
     6. BOOTSTRAP — Inicialização + loop de render
  ===================================================== */
  let lastTime = performance.now();

  function loop(now) {
    const dt = Math.min((now - lastTime) / 1000, 0.05);
    lastTime = now;

    TargetManager.update(dt);
    AimSystem.update();

    requestAnimationFrame(loop);
  }

  function boot() {
    TargetManager.init();
    CircleSystem.setSize(Config.circleSize);
    UI.init();
    requestAnimationFrame(loop);
  }

  window.addEventListener('DOMContentLoaded', boot);
})();
</script>
</body>
</html>
