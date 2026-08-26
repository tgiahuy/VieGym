import { homeMockData } from '@/data/homeMockData';
import { TodayWorkoutCard } from '@/components/home/TodayWorkoutCard';
import { NutritionSummaryCard } from '@/components/home/NutritionSummaryCard';
import { AIInsightCard } from '@/components/home/AIInsightCard';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';

const HomeHeader = () => {
  const { user } = homeMockData;
  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  };

  return (
    <div className="flex items-center justify-between">
      <div>
        <p className="text-muted-foreground">{getGreeting()},</p>
        <h1 className="text-3xl font-extrabold">{user.name}</h1>
      </div>
      <Avatar className="w-12 h-12">
        <AvatarImage src={user.avatarUrl} alt={user.name} />
        <AvatarFallback>{user.name.charAt(0)}</AvatarFallback>
      </Avatar>
    </div>
  );
};

export default function DashboardPage() {
  return (
    <div className="container p-4 mx-auto mt-4 space-y-8">
      <HomeHeader />
      <TodayWorkoutCard />
      <AIInsightCard />
      <NutritionSummaryCard />
    </div>
  );
}