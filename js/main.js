/* ============================================
   CBM Transport - Main JavaScript
   ============================================ */

document.addEventListener('DOMContentLoaded', () => {

    // --- Header scroll effect ---
    const header = document.getElementById('header');
    const scrollThreshold = 50;

    function handleHeaderScroll() {
        if (window.scrollY > scrollThreshold) {
            header.classList.add('header--scrolled');
        } else {
            header.classList.remove('header--scrolled');
        }
    }

    window.addEventListener('scroll', handleHeaderScroll, { passive: true });
    handleHeaderScroll();

    // --- Mobile nav toggle ---
    const navToggle = document.getElementById('navToggle');
    const navMenu = document.getElementById('navMenu');

    if (navToggle && navMenu) {
        navToggle.addEventListener('click', () => {
            navMenu.classList.toggle('open');
            navToggle.classList.toggle('active');
        });

        // Close menu on link click
        navMenu.querySelectorAll('.nav__link').forEach(link => {
            link.addEventListener('click', () => {
                navMenu.classList.remove('open');
                navToggle.classList.remove('active');
            });
        });

        // Close menu on outside click
        document.addEventListener('click', (e) => {
            if (!navMenu.contains(e.target) && !navToggle.contains(e.target)) {
                navMenu.classList.remove('open');
                navToggle.classList.remove('active');
            }
        });
    }

    // --- Animated counters ---
    function animateCounters() {
        const counters = document.querySelectorAll('.stats__number[data-target]');

        counters.forEach(counter => {
            if (counter.dataset.animated) return;

            const target = parseInt(counter.dataset.target, 10);
            const duration = 2000;
            const startTime = performance.now();

            function updateCounter(currentTime) {
                const elapsed = currentTime - startTime;
                const progress = Math.min(elapsed / duration, 1);
                const eased = 1 - Math.pow(1 - progress, 3); // ease-out cubic
                const current = Math.floor(eased * target);

                counter.textContent = current;

                if (progress < 1) {
                    requestAnimationFrame(updateCounter);
                } else {
                    counter.textContent = target;
                    counter.dataset.animated = 'true';
                }
            }

            requestAnimationFrame(updateCounter);
        });
    }

    // --- Scroll reveal animations ---
    function setupScrollReveal() {
        const reveals = document.querySelectorAll('.reveal');
        const statsSection = document.querySelector('.stats');

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');

                    // If stats section comes into view, animate counters
                    if (entry.target === statsSection || entry.target.closest('.stats')) {
                        animateCounters();
                    }
                }
            });
        }, {
            threshold: 0.15,
            rootMargin: '0px 0px -40px 0px'
        });

        reveals.forEach(el => observer.observe(el));

        // Also observe stats section directly
        if (statsSection) {
            const statsObserver = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        animateCounters();
                        statsObserver.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.3 });

            statsObserver.observe(statsSection);
        }
    }

    // Add reveal class to animatable sections
    document.querySelectorAll('.service-card, .why-us__item, .stats__item, .fleet-card, .value-card, .timeline__item, .service-detail-card').forEach((el, index) => {
        el.classList.add('reveal');
        el.style.transitionDelay = `${index % 4 * 100}ms`;
    });

    setupScrollReveal();

    // --- Active nav link highlighting ---
    function setActiveNavLink() {
        const currentPath = window.location.pathname;
        document.querySelectorAll('.nav__link').forEach(link => {
            link.classList.remove('active');
            const href = link.getAttribute('href');
            if (href === currentPath || (currentPath.endsWith('/') && href === '/') ||
                currentPath.includes(href) && href !== '/') {
                link.classList.add('active');
            }
        });
    }

    setActiveNavLink();

    // --- Smooth scroll for anchor links ---
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });

    // --- Form handling (contact page) ---
    const contactForm = document.getElementById('contactForm');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();

            const formData = new FormData(contactForm);
            const data = Object.fromEntries(formData);

            // Show success message
            const submitBtn = contactForm.querySelector('button[type="submit"]');
            const originalText = submitBtn.textContent;
            submitBtn.textContent = 'Message Sent!';
            submitBtn.style.background = 'var(--color-success)';
            submitBtn.disabled = true;

            setTimeout(() => {
                submitBtn.textContent = originalText;
                submitBtn.style.background = '';
                submitBtn.disabled = false;
                contactForm.reset();
            }, 3000);
        });
    }
});
