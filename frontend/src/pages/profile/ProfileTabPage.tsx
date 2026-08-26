import { AppBar } from '@/components/shared/AppBar';
import { Button } from '@/components/ui/button';
import { Link } from 'react-router-dom';

export default function ProfileTabPage() {
  return (
    <div>
      <AppBar title="Hồ sơ" />
      <main className="container p-4 mx-auto mt-4 space-y-4">
        <p className="text-muted-foreground">Giao diện Tab Hồ sơ (MH33) sẽ được triển khai ở bước tiếp theo.</p>
        <div className="flex flex-col items-start gap-2">
            <Button asChild variant="link" className="p-0"><Link to="/profile/settings">Cài đặt (MH36)</Link></Button>
        </div>
      </main>
    </div>
  );
}