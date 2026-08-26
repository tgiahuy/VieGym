import { useNavigate } from 'react-router-dom';
import { AppBar } from '@/components/shared/AppBar';
import { Button } from '@/components/ui/button';
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from '@/components/ui/sheet';
import { workoutPlan } from '@/data/workoutMockData';
import { ExerciseListItem } from '@/components/workout/ExerciseListItem';
import { StickyButton } from '@/components/workout/StickyButton';
import { FiPlus, FiClock, FiRepeat } from 'react-icons/fi';

export default function WorkoutTabPage() {
  const navigate = useNavigate();

  return (
    <div>
      <AppBar title="Kế hoạch của tôi" />
      <main className="container p-4 mx-auto mt-4 pb-32">
        {/* Workout Header */}
        <div className="text-center">
          <h1 className="text-4xl font-extrabold">{workoutPlan.name}</h1>
          <p className="mt-1 text-muted-foreground">
            {workoutPlan.muscleGroups.join(' • ')}
          </p>
        </div>

        {/* Workout Controls */}
        <div className="flex justify-center gap-2 my-6">
          <Sheet>
            <SheetTrigger asChild>
              <Button variant="outline" className="rounded-full">
                <FiClock className="mr-2" /> {workoutPlan.durationMinutes} phút
              </Button>
            </SheetTrigger>
            <SheetContent side="bottom">
              <SheetHeader><SheetTitle>Chọn thời lượng</SheetTitle></SheetHeader>
              <p className="p-4">Các lựa chọn thời lượng sẽ ở đây.</p>
            </SheetContent>
          </Sheet>
          <Button variant="outline" className="rounded-full">
            <FiRepeat className="mr-2" /> Đổi buổi tập
          </Button>
        </div>

        {/* Exercise List */}
        <div className="space-y-2">
          {workoutPlan.exercises.map((exercise) => (
            <ExerciseListItem key={exercise.id} {...exercise} />
          ))}
        </div>

        {/* Add Exercise Button */}
        <Button variant="secondary" className="w-full mt-6" onClick={() => navigate('/workout/library')}>
          <FiPlus className="mr-2" /> Thêm bài tập
        </Button>
      </main>

      {/* Sticky Start Button */}
      <StickyButton onClick={() => navigate(`/workout/session/${workoutPlan.id}`)}>
        Bắt đầu tập
      </StickyButton>
    </div>
  );
}