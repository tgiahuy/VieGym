import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { homeMockData } from '@/data/homeMockData';
import { FiPlay } from 'react-icons/fi';

export const TodayWorkoutCard = () => {
  const { todayWorkout } = homeMockData;
  return (
    <Card className="p-6 border-2 border-primary/50 bg-gradient-to-br from-primary/20 to-secondary/10">
      <CardContent className="p-0">
        <p className="font-semibold text-primary">BUỔI TẬP HÔM NAY</p>
        <h3 className="mt-2 text-3xl font-extrabold">{todayWorkout.name}</h3>
        <p className="mt-1 text-muted-foreground">
          {todayWorkout.muscleGroups.join(' • ')}
        </p>
        <div className="flex items-center gap-4 mt-4 text-sm text-muted-foreground">
          <span>{todayWorkout.exerciseCount} bài tập</span>
          <span>•</span>
          <span>{todayWorkout.durationMinutes} phút</span>
        </div>
        <Button size="lg" className="w-full mt-6 h-14">
          <FiPlay className="mr-2" />
          Bắt đầu buổi tập
        </Button>
      </CardContent>
    </Card>
  );
};