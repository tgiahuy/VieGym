import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { useWorkoutSession } from '@/contexts/WorkoutSessionContext';

const REST_DURATION = 60; // 60 seconds

export const RestTimerOverlay = () => {
  const { isResting, stopRest } = useWorkoutSession();
  const [timeLeft, setTimeLeft] = useState(REST_DURATION);

  useEffect(() => {
    if (isResting) {
      setTimeLeft(REST_DURATION);
      const timer = setInterval(() => {
        setTimeLeft(prev => {
          if (prev <= 1) {
            clearInterval(timer);
            stopRest();
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
      return () => clearInterval(timer);
    }
  }, [isResting, stopRest]);

  if (!isResting) return null;

  const minutes = Math.floor(timeLeft / 60).toString().padStart(2, '0');
  const seconds = (timeLeft % 60).toString().padStart(2, '0');

  return (
    <div className="fixed inset-0 z-50 flex flex-col justify-end bg-black/80 backdrop-blur-sm">
      <div className="p-6 text-center">
        <p className="text-lg font-bold text-muted-foreground">NGHỈ</p>
        <h1 className="text-8xl font-extrabold my-4">{minutes}:{seconds}</h1>
        <div className="flex justify-center gap-4">
          <Button variant="secondary" onClick={() => setTimeLeft(t => Math.max(0, t - 15))}>-15s</Button>
          <Button variant="secondary" onClick={() => setTimeLeft(t => t + 15)}>+15s</Button>
        </div>
        <Button variant="ghost" className="mt-6" onClick={stopRest}>Bỏ qua</Button>
      </div>
    </div>
  );
};