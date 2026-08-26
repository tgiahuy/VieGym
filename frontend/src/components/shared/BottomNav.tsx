import React, { useState, useEffect, useRef } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { FiGrid, FiZap, FiUser, FiHeart } from 'react-icons/fi';
import { FaDumbbell } from 'react-icons/fa';
import { cn } from '@/lib/utils';

const navItems = [
  { to: "/", icon: FiGrid, label: "Dashboard" },
  { to: "/workout", icon: FaDumbbell, label: "Tập luyện" },
  { to: "/meal", icon: FiHeart, label: "Bữa ăn" },
  { to: "/ai", icon: FiZap, label: "AI Coach" },
  { to: "/profile", icon: FiUser, label: "Hồ sơ" },
];

const ICON_SIZE = 24;
const NAV_HEIGHT = 68; // Chiều cao thanh nav
const ACTIVE_CIRCLE_SIZE = 56; // Kích thước vòng tròn active

// Component cho đường cong SVG
const LiquidNotch = ({ pathD }: { pathD: string }) => (
  <svg
    className="absolute top-0 left-0 w-full h-full"
    fill="hsl(var(--card) / 0.7)"
    viewBox="0 0 312 68" // Chiều rộng và chiều cao cố định để dễ tính toán path
    preserveAspectRatio="none"
  >
    <path d={pathD} className="transition-all duration-500 ease-[cubic-bezier(0.65,0,0.35,1)]" />
  </svg>
);

export const BottomNav: React.FC = () => {
  const location = useLocation();
  const navRef = useRef<HTMLElement>(null);
  const [activeIndex, setActiveIndex] = useState(0);
  const [pathD, setPathD] = useState('');
  const [indicatorStyle, setIndicatorStyle] = useState({});

  useEffect(() => {
    const { pathname } = location;
    const currentActiveIndex = [...navItems]
      .reverse()
      .find(item => pathname.startsWith(item.to))
      ? navItems.findIndex(item => pathname.startsWith(item.to) && item.to !== '/')
      : navItems.findIndex(item => item.to === pathname);

    const finalActiveIndex = currentActiveIndex === -1 ? 0 : currentActiveIndex;
    setActiveIndex(finalActiveIndex);

    if (navRef.current) {
      const navWidth = navRef.current.offsetWidth;
      const itemCount = navItems.length;
      const itemWidth = navWidth / itemCount;
      const indicatorCenterX = itemWidth * finalActiveIndex + itemWidth / 2;

      // Cập nhật vị trí cho vòng tròn active
      setIndicatorStyle({
        transform: `translateX(${indicatorCenterX - ACTIVE_CIRCLE_SIZE / 2}px)`,
      });

      // Tạo path SVG cho notch
      const notchRadius = ACTIVE_CIRCLE_SIZE / 2 + 4; // Bán kính của notch
      const startX = indicatorCenterX - notchRadius;
      const endX = indicatorCenterX + notchRadius;

      const newPathD = `
        M 0 20
        C 10 0, 20 0, 30 0
        H ${startX - 10}
        C ${startX} 0, ${startX} 20, ${indicatorCenterX} 20
        C ${endX} 20, ${endX} 0, ${endX + 10} 0
        H ${navWidth - 30}
        C ${navWidth - 20} 0, ${navWidth - 10} 0, ${navWidth} 20
        V ${NAV_HEIGHT}
        H 0
        Z
      `;
      // Sử dụng viewBox width thay vì navWidth
      const viewBoxWidth = 312;
      const scale = viewBoxWidth / navWidth;
      const scaledIndicatorCenterX = indicatorCenterX * scale;
      const scaledNotchRadius = notchRadius * scale;
      const scaledStartX = scaledIndicatorCenterX - scaledNotchRadius;
      const scaledEndX = scaledIndicatorCenterX + scaledNotchRadius;

      const finalPathD = `
        M 0 ${20 * scale}
        C ${10 * scale} 0, ${20 * scale} 0, ${30 * scale} 0
        H ${scaledStartX - 10 * scale}
        C ${scaledStartX} 0, ${scaledStartX} ${20 * scale}, ${scaledIndicatorCenterX} ${20 * scale}
        C ${scaledEndX} ${20 * scale}, ${scaledEndX} 0, ${scaledEndX + 10 * scale} 0
        H ${viewBoxWidth - 30 * scale}
        C ${viewBoxWidth - 20 * scale} 0, ${viewBoxWidth - 10 * scale} 0, ${viewBoxWidth} ${20 * scale}
        V ${NAV_HEIGHT}
        H 0
        Z
      `;
      setPathD(finalPathD);
    }
  }, [location.pathname]);

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50" style={{ paddingBottom: 'env(safe-area-inset-bottom)' }}>
      <nav
        ref={navRef}
        className="relative mx-auto w-[calc(100%-2rem)] max-w-sm"
        style={{ height: `${NAV_HEIGHT}px` }}
      >
        {/* SVG Background với Notch */}
        <div className="absolute bottom-0 w-full h-full backdrop-blur-xl" style={{ maskImage: `url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 312 68"><path d="${pathD}"/></svg>')`, WebkitMaskImage: `url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 312 68"><path d="${pathD}"/></svg>')` }}>
          <div className="w-full h-full bg-card/70"></div>
        </div>

        {/* Vòng tròn Active */}
        <div
          className="absolute top-[-12px] flex items-center justify-center bg-primary rounded-full shadow-lg transition-transform duration-500 ease-[cubic-bezier(0.65,0,0.35,1)]"
          style={{ ...indicatorStyle, width: `${ACTIVE_CIRCLE_SIZE}px`, height: `${ACTIVE_CIRCLE_SIZE}px` }}
        >
          {React.createElement(navItems[activeIndex].icon, { size: ICON_SIZE, className: "text-primary-foreground" })}
        </div>

        {/* Các mục Nav */}
        <div className="flex items-center justify-around h-full">
          {navItems.map((item, index) => {
            const isActive = index === activeIndex;
            return (
              <NavLink
                key={item.to}
                to={item.to}
                aria-current={isActive ? "page" : undefined}
                className="relative z-10 flex flex-col items-center justify-center w-full h-full gap-1 text-xs font-medium transition-colors"
              >
                <div className={cn(
                  "transition-all duration-300",
                  isActive ? 'opacity-0 -translate-y-2' : 'opacity-100 translate-y-0'
                )}>
                  {React.createElement(item.icon, { size: ICON_SIZE, className: "text-muted-foreground" })}
                </div>
                <span className={cn(
                  "absolute bottom-1 text-[10px] font-bold text-muted-foreground transition-opacity duration-300",
                  isActive ? 'opacity-100' : 'opacity-0'
                )}>
                  {item.label}
                </span>
              </NavLink>
            );
          })}
        </div>
      </nav>
    </div>
  );
};