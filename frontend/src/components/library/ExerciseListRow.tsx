import { Checkbox } from '@/components/ui/checkbox';
import { Link } from 'react-router-dom';

interface ExerciseListRowProps {
  id: string;
  name: string;
  primaryMuscle: string;
  equipment: string;
  thumbnailUrl: string;
  isSelected: boolean;
  onToggleSelect: () => void;
}

export const ExerciseListRow: React.FC<ExerciseListRowProps> = ({
  id, name, primaryMuscle, equipment, thumbnailUrl, isSelected, onToggleSelect
}) => {
  return (
    <div className="flex items-center p-2 rounded-xl hover:bg-secondary/50">
      <img src={thumbnailUrl} alt={name} className="w-14 h-14 mr-4 rounded-lg object-cover" />
      <div className="flex-1" onClick={onToggleSelect}>
        <h3 className="font-bold text-base leading-tight">{name}</h3>
        <p className="text-sm text-muted-foreground">
          {primaryMuscle} • {equipment}
        </p>
      </div>
      <div className="pl-4" onClick={onToggleSelect}>
        <Checkbox checked={isSelected} className="w-6 h-6 rounded-md" />
      </div>
    </div>
  );
};