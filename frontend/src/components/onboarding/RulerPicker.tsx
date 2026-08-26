import React, { useRef, useEffect, useMemo } from 'react';
import { cn } from '@/lib/utils';

interface RulerPickerProps {
  min: number;
  max: number;
  unit: string;
  value: number;
  onChange: (value: number) => void;
}

const RulerPicker: React.FC<RulerPickerProps> = ({ min, max, unit, value, onChange }) => {
  const rulerRef = useRef<HTMLDivElement>(null);
  const itemWidth = 12; // Chiều rộng của mỗi vạch
  const scrollTimeout = useRef<number | null>(null);

  const ticks = useMemo(() => Array.from({ length: (max - min) + 1 }, (_, i) => min + i), [max, min]);

  const scrollToValue = (val: number, behavior: ScrollBehavior = 'auto') => {
    if (rulerRef.current) {
      const index = val - min;
      const targetScroll = index * itemWidth - rulerRef.current.offsetWidth / 2 + itemWidth / 2;
      rulerRef.current.scrollTo({ left: targetScroll, behavior });
    }
  };

  useEffect(() => {
    scrollToValue(value);
  }, []);

  const handleScroll = () => {
    if (rulerRef.current) {
      if (scrollTimeout.current) clearTimeout(scrollTimeout.current);

      const scrollLeft = rulerRef.current.scrollLeft;
      const centerOffset = rulerRef.current.offsetWidth / 2;
      const centerIndex = Math.round((scrollLeft + centerOffset - itemWidth / 2) / itemWidth);
      const newValue = min + centerIndex;

      if (newValue >= min && newValue <= max) {
        onChange(newValue);
      }

      scrollTimeout.current = window.setTimeout(() => {
        scrollToValue(newValue, 'smooth');
      }, 200);
    }
  };

  return (
    <div className="flex flex-col items-center w-full">
      <div className="text-center mb-4">
        <span className="text-5xl font-extrabold text-white">{value}</span>
        <span className="ml-2 text-lg font-semibold text-muted-foreground">{unit}</span>
      </div>
      <div className="relative w-full h-24">
        <div className="absolute top-0 z-10 w-1 h-12 -translate-x-1/2 bg-primary left-1/2 rounded-full" />
        <div
          ref={rulerRef}
          className="absolute top-0 left-0 flex w-full h-full overflow-x-scroll no-scrollbar"
          onScroll={handleScroll}
        >
          <div style={{ width: '50%' }} />
          {ticks.map((tickValue) => {
            const isMajorTick = tickValue % 5 === 0;
            return (
              <div key={tickValue} className="flex flex-col items-center justify-start flex-shrink-0" style={{ width: `${itemWidth}px` }}>
                <div className={cn('bg-muted-foreground rounded-full', isMajorTick ? 'w-0.5 h-8' : 'w-px h-5')} />
                {isMajorTick && <span className="mt-2 text-xs text-muted-foreground">{tickValue}</span>}
              </div>
            );
          })}
          <div style={{ width: '50%' }} />
        </div>
      </div>
    </div>
  );
};

export default RulerPicker;