import { Checkbox } from '@/components/ui/checkbox';
import { Input } from '@/components/ui/input';
import { useWorkoutSession } from '@/contexts/WorkoutSessionContext';
import { cn } from '@/lib/utils';

interface SetRowProps {
  exerciseId: string;
  setNumber: number;
  previousData: string;
}

export const SetRow: React.FC<SetRowProps> = ({ exerciseId, setNumber, previousData }) => {
  const { sessionState, updateSet, startRest } = useWorkoutSession();
  const setId = `set-${setNumber}`;
  const setData = sessionState[exerciseId]?.[setId] || { kg: '', reps: '', isCompleted: false };

  const handleComplete = () => {
    const newCompletedState = !setData.isCompleted;
    updateSet(exerciseId, setId, { isCompleted: newCompletedState });
    if (newCompletedState) {
      startRest();
    }
  };

  return (
    <div className={cn("grid grid-cols-5 items-center gap-2 p-2 rounded-lg", setData.isCompleted && "bg-secondary/50")}>
      <div className="text-center font-bold">{setNumber}</div>
      <div className="text-center text-sm text-muted-foreground">{previousData}</div>
      <Input
        type="number"
        placeholder="-"
        className="h-12 text-center text-base font-bold bg-input"
        value={setData.kg}
        onChange={(e) => updateSet(exerciseId, setId, { kg: e.target.value })}
      />
      <Input
        type="number"
        placeholder="-"
        className="h-12 text-center text-base font-bold bg-input"
        value={setData.reps}
        onChange={(e) => updateSet(exerciseId, setId, { reps: e.target.value })}
      />
      <div className="flex justify-center">
        <Checkbox
          checked={setData.isCompleted}
          onCheckedChange={handleComplete}
          className="w-8 h-8 rounded-full"
        />
      </div>
    </div>
  );
};