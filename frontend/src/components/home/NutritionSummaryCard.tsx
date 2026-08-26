import { Card, CardContent } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
import { homeMockData } from '@/data/homeMockData';
import { SectionHeader } from './SectionHeader';

const MacroItem = ({ label, consumed, target, unit }: { label: string, consumed: number, target: number, unit: string }) => (
  <div>
    <div className="flex justify-between mb-1 text-sm">
      <span className="font-semibold">{label}</span>
      <span className="text-muted-foreground">{consumed}{unit}</span>
    </div>
    <Progress value={(consumed / target) * 100} />
  </div>
);

export const NutritionSummaryCard = () => {
  const { nutrition } = homeMockData;
  const calProgress = (nutrition.calories.consumed / nutrition.calories.target) * 100;

  return (
    <Card className="p-6">
      <SectionHeader title="Dinh dưỡng hôm nay" actionText="Chi tiết" actionLink="/meal" />
      <CardContent className="p-0">
        <div className="flex items-baseline justify-between">
          <span className="text-3xl font-extrabold">{nutrition.calories.consumed}</span>
          <span className="text-lg font-semibold text-muted-foreground">/ {nutrition.calories.target} kcal</span>
        </div>
        <Progress value={calProgress} className="mt-2 h-2" />
        <div className="grid grid-cols-3 gap-4 mt-6">
          <MacroItem label="Protein" consumed={nutrition.protein.consumed} target={nutrition.protein.target} unit="g" />
          <MacroItem label="Carbs" consumed={nutrition.carbs.consumed} target={nutrition.carbs.target} unit="g" />
          <MacroItem label="Fat" consumed={nutrition.fat.consumed} target={nutrition.fat.target} unit="g" />
        </div>
      </CardContent>
    </Card>
  );
};