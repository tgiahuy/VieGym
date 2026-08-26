import { useParams } from 'react-router-dom';
import { AppBar } from '@/components/shared/AppBar';
import { findExerciseById } from '@/data/exercisesMockData';
import { ExerciseMedia } from '@/components/detail/ExerciseMedia';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';

export default function ExerciseDetailPage() {
  const { id } = useParams<{ id: string }>();
  const exercise = id ? findExerciseById(id) : undefined;

  if (!exercise) {
    return (
      <div>
        <AppBar title="Không tìm thấy" showBack />
        <main className="container p-4 mx-auto mt-4">
          <p>Không tìm thấy thông tin cho bài tập này.</p>
        </main>
      </div>
    );
  }

  return (
    <div>
      <AppBar title="" showBack showActions={true} />
      <main className="container p-4 mx-auto mt-4 pb-24">
        <ExerciseMedia videoUrl={exercise.videoUrl} exerciseName={exercise.name} />
        <div className="mt-6">
          <h1 className="text-3xl font-extrabold">{exercise.name}</h1>
          <div className="flex gap-2 mt-2">
            <Badge variant="secondary">{exercise.primaryMuscle}</Badge>
            <Badge variant="secondary">{exercise.equipment}</Badge>
          </div>
        </div>

        <div className="mt-8">
          <h2 className="text-xl font-bold mb-2">Hướng dẫn</h2>
          <ul className="space-y-3 list-decimal list-inside text-muted-foreground">
            {exercise.instructions.map((step, index) => (
              <li key={index}>{step}</li>
            ))}
          </ul>
        </div>
      </main>
      <div className="fixed bottom-0 left-0 right-0 z-10 p-4 bg-background/80 backdrop-blur-sm border-t border-border">
        <Button size="lg" className="w-full h-14">Thêm vào buổi tập</Button>
      </div>
    </div>
  );
}