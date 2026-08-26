import { FiMoreVertical } from 'react-icons/fi';
import { Link } from 'react-router-dom';

interface ExerciseListItemProps {
  id: string;
  name: string;
  sets: number;
  reps: number;
  weightKg: number;
  isMain?: boolean;
  thumbnailUrl: string;
}

export const ExerciseListItem: React.FC<ExerciseListItemProps> = ({
  id,
  name,
  sets,
  reps,
  weightKg,
  isMain,
  thumbnailUrl,
}) => {
  return (
    <div className="flex items-center py-3">
      <img src={thumbnailUrl} alt={name} className="w-16 h-16 mr-4 rounded-lg object-cover" />
      <div className="flex-1">
        {isMain && <p className="text-xs font-bold text-primary uppercase tracking-wider">Bài chính</p>}
        <h3 className="font-bold text-base leading-tight">{name}</h3>
        <p className="text-sm text-muted-foreground">
          {sets} hiệp • {reps} reps • {weightKg} kg
        </p>
      </div>
      <Link to={`/exercise/${id}`} className="p-3 text-xl rounded-full text-muted-foreground hover:bg-secondary">
        <FiMoreVertical />
      </Link>
    </div>
  );
};