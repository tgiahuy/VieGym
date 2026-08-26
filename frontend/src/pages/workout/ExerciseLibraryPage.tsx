import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { AppBar } from '@/components/shared/AppBar';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { FiSearch, FiFilter } from 'react-icons/fi';
import { exercises } from '@/data/exercisesMockData';
import { ExerciseListRow } from '@/components/library/ExerciseListRow';
import { StickyButton } from '@/components/workout/StickyButton';

export default function ExerciseLibraryPage() {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedExercises, setSelectedExercises] = useState<string[]>([]);

  const handleToggleSelect = (id: string) => {
    setSelectedExercises(prev =>
      prev.includes(id) ? prev.filter(exId => exId !== id) : [...prev, id]
    );
  };

  const filteredExercises = exercises.filter(ex =>
    ex.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div>
      <AppBar title="Thêm bài tập" showBack />
      <main className="container p-4 mx-auto mt-4 pb-32">
        <div className="relative">
          <FiSearch className="absolute text-xl left-4 top-1/2 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Tìm bài tập"
            className="pl-12 h-12 rounded-full bg-secondary/50 border-secondary"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div className="flex gap-2 mt-4">
          <Button variant="outline" className="rounded-full"><FiFilter className="mr-2" /> Nhóm cơ</Button>
          <Button variant="outline" className="rounded-full"><FiFilter className="mr-2" /> Thiết bị</Button>
        </div>
        <div className="mt-6 space-y-2">
          {filteredExercises.length > 0 ? (
            filteredExercises.map(ex => (
              <ExerciseListRow
                key={ex.id}
                {...ex}
                isSelected={selectedExercises.includes(ex.id)}
                onToggleSelect={() => handleToggleSelect(ex.id)}
              />
            ))
          ) : (
            <p className="text-center text-muted-foreground mt-10">Không tìm thấy bài tập phù hợp.</p>
          )}
        </div>
      </main>
      {selectedExercises.length > 0 && (
        <StickyButton onClick={() => navigate(-1)}>
          Thêm {selectedExercises.length} bài tập
        </StickyButton>
      )}
    </div>
  );
}