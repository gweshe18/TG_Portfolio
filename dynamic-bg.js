<script>
    // Dynamic gradient background — shared include
    (() => {
    // Ensure the canvas exists (create if missing)
    let bg = document.getElementById('bg-canvas');
    if (!bg) {
        bg = document.createElement('div');
        bg.id = 'bg-canvas';
        bg.setAttribute('aria-hidden', 'true');
        document.body.prepend(bg);
    }

    const root = document.documentElement;
    const clamp = (n, min, max) => Math.max(min, Math.min(n, max));
    let pulse = 0, ticking = false;

    const apply = () => {
        const y = window.scrollY || 0;
        const h = Math.max(document.body.scrollHeight - window.innerHeight, 1);
        const progress = clamp(y / h, 0, 1);
        root.style.setProperty('--scroll', (progress * 100).toFixed(2));
        root.style.setProperty('--pulse', pulse.toFixed(2));
        ticking = false;
    };

    window.addEventListener('scroll', () => {
        if (!ticking) {
        ticking = true;
        requestAnimationFrame(apply);
        }
    }, { passive: true });

    window.addEventListener('mousemove', (e) => {
        const mx = (e.clientX / window.innerWidth) * 100;
        const my = (e.clientY / window.innerHeight) * 100;
        root.style.setProperty('--mx', mx.toFixed(2));
        root.style.setProperty('--my', my.toFixed(2));
    }, { passive: true });

    window.addEventListener('click', () => {
        pulse = 1;
        root.style.setProperty('--pulse', '1');
        const t0 = performance.now();
        const fade = () => {
        const dt = (performance.now() - t0) / 800;
        pulse = Math.max(0, 1 - dt);
        root.style.setProperty('--pulse', pulse.toFixed(3));
        if (pulse > 0) requestAnimationFrame(fade);
        };
        requestAnimationFrame(fade);
    });

    // Defaults
    root.style.setProperty('--mx', '50');
    root.style.setProperty('--my', '50');
    root.style.setProperty('--scroll', '0');
    root.style.setProperty('--pulse', '0');
    apply();
    })();
</script>
