import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { FiCheckCircle } from 'react-icons/fi';

export default function WorkoutSummaryPage() {
  const navigate = useNavigate();

  return (
    <div className="container p-4 mx-auto mt-10 text-center">
      <FiCheckCircle className="w-16 h-16 mx-auto text-primary" />
      <h1 className="mt-4 text-4xl font-extrabold">Hoàn thành!</h1>
      <p className="mt-2 text-muted-foreground">Bạn đã hoàn thành buổi tập Upper Body A.</p>

      <Card className="mt-8 text-left">
        <CardHeader><CardTitle>Tóm tắt buổi tập</CardTitle></CardHeader>
        <CardContent className="grid grid-cols-2 gap-4">
          <div><p className="text-sm text-muted-foreground">Thời gian</p><p className="font-bold">58:32</p></div>
          <div><p className="text-sm text-muted-foreground">Tổng khối lượng</p><p className="font-bold">3,240 kg</p></div>
          <div><p className="text-sm text-muted-foreground">Số hiệp</p><p className="font-bold">12</p></div>
          <div><p className="text-sm text-muted-foreground">PR mới</p><p className="font-bold">1</p></div>
        </CardContent>
      </Card>

      <Button size="lg" className="w-full mt-8 h-14" onClick={() => navigate('/workout')}>
        Xong
      </Button>
    </div>
  );
}