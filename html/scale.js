(function () {
    const BASE_W = 1920;
    const BASE_H = 1080;
    let lastSafe = 1;

    function applyUiScale(resX, resY, safeZone) {
        const w = Number(resX) || window.innerWidth || BASE_W;
        const h = Number(resY) || window.innerHeight || BASE_H;
        lastSafe = safeZone;

        let scale = Math.min(w / BASE_W, h / BASE_H);
        scale = Math.max(0.7, Math.min(scale, 1.35));
        document.documentElement.style.setProperty('--hud-scale', scale.toFixed(4));
        document.documentElement.style.setProperty('--hud-final-scale', scale.toFixed(4));

        const safe = Math.min(1, Math.max(0.9, Number(safeZone) || 1));
        const insetX = ((1 - safe) * 0.5) * w;
        const insetY = ((1 - safe) * 0.5) * h;
        document.documentElement.style.setProperty('--safe-x', insetX.toFixed(1) + 'px');
        document.documentElement.style.setProperty('--safe-y', insetY.toFixed(1) + 'px');
    }

    window.applyUiScale = applyUiScale;

    window.addEventListener('message', function (event) {
        const data = event.data;
        if (!data) return;
        if (data.action === 'setUiScale') {
            applyUiScale(data.resX, data.resY, data.safeZone);
        }
    });

    window.addEventListener('resize', function () {
        applyUiScale(window.innerWidth, window.innerHeight, lastSafe || 1);
    });

    applyUiScale(window.innerWidth, window.innerHeight, 1);
})();
