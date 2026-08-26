import { Card, CardContent } from '@/components/ui/card';
import { homeMockData } from '@/data/homeMockData';
import { FiZap } from 'react-icons/fi';

export const AIInsightCard = () => {
  const { aiInsight } = homeMockData;
  return (
    <Card className="p-6 bg-secondary/50">
      <CardContent className="p-0">
        <div className="flex items-center gap-2 mb-3">
          <FiZap className="text-primary" />
          <h3 className="font-bold">{aiInsight.title}</h3>
        </div>
        <p className="text-sm text-muted-foreground">{aiInsight.message}</p>
      </CardContent>
    </Card>
  );
};