import { useNavigate, useParams } from 'react-router-dom';
import { workoutPlan } from '@/data/workoutMockData';
import { Button } from '@/components/ui/button';
import { SetRow } from '@/components/session/SetRow';
import { RestTimerOverlay } from '@/components/session/RestTimerOverlay';
import { WorkoutSessionProvider } from '@/contexts/WorkoutSessionContext';
import { FiX } from 'react-icons/fi';

const WorkoutSessionContent = () => {
  const navigate = useNavigate();
  const currentExercise = workoutPlan.exercises[0]; // Mock: always show the first exercise

  return (
    <div className="relative min-h-screen">
      <header className="container p-4 mx-auto flex justify-between items-center h-20">
        <p className="font-bold">1 / {workoutPlan.exercises.length}</p>
        <p className="font-bold">00:15:32</p>
        <Button variant="ghost" size="icon" onClick={() => navigate('/workout')}>
          <FiX className="w-6 h-6" />
        </Button>
      </header>

      <main className="container p-4 mx-auto">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-extrabold">{currentExercise.name}</h1>
          <p className="text-muted-foreground">{workoutPlan.muscleGroups.join(' • ')}</p>
        </div>

        {/* Set Table Header */}
        <div className="grid grid-cols-5 items-center gap-2 px-2 mb-2 text-xs font-bold text-muted-foreground">
          <div className="text-center">HIỆP</div>
          <div className="text-center">TRƯỚC</div>
          <div className="text-center">KG</div>
          <div className="text-center">REPS</div>
          <div className="text-center">✓</div>
        </div>

        {/* Set Rows */}
        <div className="space-y-2">
          {[...Array(currentExercise.sets)].map((_, i) => (
            <SetRow key={i} exerciseId={currentExercise.id} setNumber={i + 1} previousData="40x10" />
          ))}
        </div>

        <Button variant="secondary" className="w-full mt-6">+ Thêm hiệp</Button>
      </main>

      <div className="fixed bottom-0 left-0 right-0 p-4 bg-background/80 backdrop-blur-sm border-t border-border">
        <Button size="lg" className="w-full h-14" onClick={() => navigate(`/workout/summary/${workoutPlan.id}`)}>
          Hoàn thành buổi tập
        </Button>
      </div>

      <RestTimerOverlay />
    </div>
  );
};

export default function WorkoutSessionPage() {
  return (
    <WorkoutSessionProvider>
      <WorkoutSessionContent />
    </WorkoutSessionProvider>
  );
}