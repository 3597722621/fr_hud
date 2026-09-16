/* ========== PLAYER HUD ========== */
window.addEventListener('message', function (event) {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === 'updatePlayer' || (data.action === 'update' && data.data)) {
        const hud = document.getElementById('hud');
        if (!hud) return;
        hud.style.display = 'flex';

        const d = data.data;
        if (!d) return;

        document.getElementById('health-fill').style.width = d.health + '%';
        document.getElementById('armor-fill').style.width = d.armor + '%';
        document.getElementById('hunger-fill').style.width = d.hunger + '%';
        document.getElementById('thirst-fill').style.width = d.thirst + '%';

        document.getElementById('hunger-icon').style.color = d.hunger < 20 ? 'red' : 'rgba(255,255,255,0.7)';
        document.getElementById('thirst-icon').style.color = d.thirst < 20 ? 'red' : 'rgba(255,255,255,0.7)';

        if (d.stamina < 100) {
            document.getElementById('stamina-container').style.display = 'flex';
            document.getElementById('stamina-fill').style.width = d.stamina + '%';
            document.getElementById('stamina-icon').style.color = d.stamina < 20 ? 'red' : 'white';
        } else {
            document.getElementById('stamina-container').style.display = 'none';
        }

        if (d.isUnderwater) {
            document.getElementById('oxygen-container').style.display = 'flex';
            document.getElementById('oxygen-fill').style.width = d.oxygen + '%';
            document.getElementById('oxygen-icon').style.color = d.oxygen < 20 ? 'red' : 'white';
        } else {
            document.getElementById('oxygen-container').style.display = 'none';
        }

        const mic = document.getElementById('mic-bg');
        const micIcon = document.getElementById('mic-icon');
        let fill = 0;
        if (d.voice <= 1) fill = 33;
        else if (d.voice == 2) fill = 66;
        else if (d.voice >= 3) fill = 100;

        if (d.isTalking) {
            micIcon.style.color = '#b026ff';
            mic.style.background = `linear-gradient(to top, rgba(176, 38, 255, 0.4) ${fill}%, rgba(15, 15, 15, 0.85) ${fill}%)`;
        } else {
            micIcon.style.color = 'white';
            mic.style.background = `linear-gradient(to top, rgba(255, 255, 255, 0.2) ${fill}%, rgba(15, 15, 15, 0.85) ${fill}%)`;
        }

        const stressBg = document.getElementById('stress-bg');
        const stressIcon = document.getElementById('stress-icon');
        if (d.stress > 0) {
            stressBg.style.display = 'flex';
            stressBg.style.background = `linear-gradient(to top, rgba(231, 76, 60, 0.4) ${d.stress}%, rgba(15, 15, 15, 0.85) ${d.stress}%)`;
            stressIcon.style.color = d.stress > 50 ? '#e74c3c' : 'white';
        } else {
            stressBg.style.display = 'none';
        }

        document.getElementById('bleed-container').style.display = d.bleed ? 'flex' : 'none';
        document.getElementById('bone-container').style.display = d.bone ? 'flex' : 'none';
        document.getElementById('devmode-container').style.display = d.devmode ? 'flex' : 'none';
        document.getElementById('status-separator').style.display =
            (d.stress > 0 || d.bleed || d.bone || d.devmode) ? 'block' : 'none';

        document.getElementById('crosshair').style.display = d.isAiming ? 'block' : 'none';

        if (d.hasWeapon) {
            document.getElementById('weapon-container').style.display = 'flex';
            document.getElementById('ammo-clip').innerText = d.ammoClip;
            document.getElementById('ammo-total').innerText = d.ammoTotal;
        } else {
            document.getElementById('weapon-container').style.display = 'none';
        }
    } else if (data.action === 'hidePlayer' || (data.action === 'hide' && !('pulse' in data))) {
        // only hide player when not a pulse hide
        if (data.action === 'hidePlayer' || data.action === 'hide') {
            const hud = document.getElementById('hud');
            if (hud) hud.style.display = 'none';
            const stamina = document.getElementById('stamina-container');
            const oxygen = document.getElementById('oxygen-container');
            const weapon = document.getElementById('weapon-container');
            const crosshair = document.getElementById('crosshair');
            if (stamina) stamina.style.display = 'none';
            if (oxygen) oxygen.style.display = 'none';
            if (weapon) weapon.style.display = 'none';
            if (crosshair) crosshair.style.display = 'none';
        }
    } else if (data.action === 'cinematicBars') {
        const on = !!data.state;
        document.getElementById('cinematic-top').style.height = on ? '12vh' : '0';
        document.getElementById('cinematic-bottom').style.height = on ? '12vh' : '0';
    }
});

/* ========== CAR HUD ========== */
let lastEngineHealth = 1000;
let engineShowTimer = null;

window.addEventListener('message', function (e) {
    const data = e.data;
    if (!data) return;

    if (data.action === 'updateCarHud') {
        document.getElementById('vehicle-hud').style.display = 'flex';
        const d = data;

        const fuelTypeIcon = document.getElementById('fuel-type-icon');
        const rpmPath = document.getElementById('rpm-path');

        if (d.isElectric) {
            rpmPath.style.stroke = 'url(#elec-grad)';
            fuelTypeIcon.className = 'fa-solid fa-plug';
        } else {
            rpmPath.style.stroke = 'url(#gas-grad)';
            fuelTypeIcon.className = 'fa-solid fa-gas-pump';
        }

        rpmPath.style.strokeDashoffset = 100 - (d.rpm * 100);

        const speedStr = d.speed.toString().padStart(3, '0');
        let speedHtml = '';
        let foundNonZero = false;
        for (let i = 0; i < speedStr.length; i++) {
            if (speedStr[i] === '0' && !foundNonZero && i < speedStr.length - 1) {
                speedHtml += '<span class="faded-zero">0</span>';
            } else {
                foundNonZero = true;
                speedHtml += speedStr[i];
            }
        }
        document.getElementById('veh-speed').innerHTML = speedHtml;
        document.getElementById('veh-gear').innerText = d.gear;

        const fuelPath = document.getElementById('fuel-path');
        fuelPath.style.strokeDashoffset = 100 - d.fuel;
        fuelPath.style.stroke = d.fuel <= 20 ? '#e74c3c' : '#ffffff';

        const lightsIcon = document.getElementById('icon-lights');
        lightsIcon.classList.toggle('active-lights', !!d.lights);

        const fuelIcon = document.getElementById('icon-fuel');
        fuelIcon.classList.toggle('active-fuel', d.fuel < 15);

        const seatbeltIcon = document.getElementById('icon-seatbelt');
        if (d.seatbelt) {
            seatbeltIcon.classList.remove('active-seatbelt');
            seatbeltIcon.classList.add('seatbelt-on');
            seatbeltIcon.innerHTML = '<i class="fa-solid fa-user-check"></i>';
        } else {
            seatbeltIcon.classList.remove('seatbelt-on');
            seatbeltIcon.classList.add('active-seatbelt');
            seatbeltIcon.innerHTML = '<i class="fa-solid fa-user-slash"></i>';
        }

        const lockIcon = document.getElementById('icon-lock');
        if (d.locked) {
            lockIcon.classList.remove('unlocked');
            lockIcon.classList.add('locked');
            lockIcon.innerHTML = '<i class="fa-solid fa-lock"></i>';
        } else {
            lockIcon.classList.remove('locked');
            lockIcon.classList.add('unlocked');
            lockIcon.innerHTML = '<i class="fa-solid fa-unlock"></i>';
        }

        let isDamagedNow = false;
        if (d.engine < lastEngineHealth && d.engine < 995) isDamagedNow = true;
        lastEngineHealth = d.engine;

        if (d.engine < 995) {
            const enginePct = Math.max(0, Math.min(100, (d.engine / 1000) * 100));
            document.getElementById('engine-fill').style.width = enginePct + '%';
            document.getElementById('engine-icon').style.color = enginePct <= 10 ? '#e74c3c' : 'white';

            if (enginePct <= 10) {
                document.getElementById('engine-container').style.display = 'flex';
                if (engineShowTimer) clearTimeout(engineShowTimer);
            } else if (isDamagedNow) {
                document.getElementById('engine-container').style.display = 'flex';
                if (engineShowTimer) clearTimeout(engineShowTimer);
                engineShowTimer = setTimeout(() => {
                    if (lastEngineHealth > 100) {
                        document.getElementById('engine-container').style.display = 'none';
                    }
                }, 3000);
            }
        } else {
            document.getElementById('engine-container').style.display = 'none';
            if (engineShowTimer) clearTimeout(engineShowTimer);
        }
    } else if (data.action === 'hideCarHud') {
        document.getElementById('vehicle-hud').style.display = 'none';
        document.getElementById('engine-container').style.display = 'none';
        lastEngineHealth = 1000;
    }
});

/* ========== MINIMAP / COMPASS ========== */
window.addEventListener('message', function (event) {
    const data = event.data;
    if (!data) return;

    if (data.action === 'updateCompass') {
        document.getElementById('compass-container').style.display = 'flex';
        document.getElementById('degree').innerText = data.heading;
        document.getElementById('street').innerText = data.street;
        document.getElementById('zone').innerText = data.zone;

        if (data.waypoint) {
            document.getElementById('waypoint-box').style.display = 'flex';
            document.getElementById('waypoint-dist').innerText = data.waypoint;
            let arrowClass = 'fa-arrow-up';
            if (data.waypointDir === 'left') arrowClass = 'fa-arrow-left';
            else if (data.waypointDir === 'right') arrowClass = 'fa-arrow-right';
            else if (data.waypointDir === 'down') arrowClass = 'fa-arrow-down';
            document.querySelector('#waypoint-box i').className = 'fa-solid ' + arrowClass;
        } else {
            document.getElementById('waypoint-box').style.display = 'none';
        }

        document.getElementById('compass-letters').style.transform = `rotate(${-data.heading}deg)`;
        document.querySelectorAll('.letter').forEach((letter) => {
            letter.style.transform = `translate(-50%, -50%) rotate(${data.heading}deg)`;
        });
    } else if (data.action === 'hideCompass') {
        document.getElementById('compass-container').style.display = 'none';
    } else if (data.action === 'showSafezoneWarning') {
        document.getElementById('safezone-warning').style.display = 'flex';
    } else if (data.action === 'hideSafezoneWarning') {
        document.getElementById('safezone-warning').style.display = 'none';
    }
});

/* ========== PULSE HUD ========== */
function polarToCartesian(centerX, centerY, radius, angleInDegrees) {
    const angleInRadians = (angleInDegrees - 90) * Math.PI / 180.0;
    return {
        x: centerX + (radius * Math.cos(angleInRadians)),
        y: centerY + (radius * Math.sin(angleInRadians))
    };
}

function describeArcSegment(x, y, radiusIn, radiusOut, startAngle, endAngle) {
    const startIn = polarToCartesian(x, y, radiusIn, endAngle);
    const endIn = polarToCartesian(x, y, radiusIn, startAngle);
    const startOut = polarToCartesian(x, y, radiusOut, endAngle);
    const endOut = polarToCartesian(x, y, radiusOut, startAngle);
    const largeArcFlag = endAngle - startAngle <= 180 ? '0' : '1';
    return [
        'M', startOut.x, startOut.y,
        'A', radiusOut, radiusOut, 0, largeArcFlag, 0, endOut.x, endOut.y,
        'L', endIn.x, endIn.y,
        'A', radiusIn, radiusIn, 0, largeArcFlag, 1, startIn.x, startIn.y,
        'Z'
    ].join(' ');
}

const pulseSvg = document.getElementById('pulse-svg');
const pulseAngles = [
    { start: 160, end: 212 },
    { start: 218, end: 270 },
    { start: 276, end: 328 },
    { start: 334, end: 386 },
    { start: 392, end: 444 }
];
const pulseSegments = [];
if (pulseSvg) {
    pulseAngles.forEach((angle, index) => {
        const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        path.setAttribute('d', describeArcSegment(50, 50, 28, 46, angle.start, angle.end));
        path.setAttribute('class', 'segment');
        path.setAttribute('id', 'seg-' + index);
        pulseSvg.appendChild(path);
        pulseSegments.push(path);
    });
}

window.addEventListener('message', function (event) {
    const data = event.data;
    if (!data) return;

    if (data.action === 'updatePulse') {
        const box = document.getElementById('pulse-hud');
        box.classList.remove('hidden');
        const pulse = data.pulse;
        document.getElementById('pulse-value').innerText = Math.round(pulse);

        const wrapper = document.querySelector('.pulse-wrapper');
        if (pulse >= 100) {
            wrapper.classList.remove('color-cyan');
            wrapper.classList.add('color-red', 'beating');
        } else {
            wrapper.classList.remove('color-red', 'beating');
            wrapper.classList.add('color-cyan');
        }

        let fillCount = 1;
        if (pulse < 80) fillCount = 1;
        else if (pulse < 95) fillCount = 2;
        else if (pulse < 110) fillCount = 3;
        else if (pulse < 125) fillCount = 4;
        else fillCount = 5;

        pulseSegments.forEach((seg, i) => {
            seg.classList.toggle('filled', i < fillCount);
        });
    } else if (data.action === 'hidePulse') {
        document.getElementById('pulse-hud').classList.add('hidden');
    }
});
