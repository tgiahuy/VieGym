import { AppBar } from '@/components/shared/AppBar';
import { Button } from '@/components/ui/button';
import { Link } from 'react-router-dom';

export default function SettingsPage() {
  return (
    <div>
      <AppBar title="Cài đặt" showBack />
      <main className="container p-4 mx-auto mt-4">
        <p className="text-muted-foreground">Nội dung Cài đặt (MH36) sẽ được triển khai ở bước tiếp theo.</p>
        <div className="flex flex-col items-start gap-2 mt-4">
          <Button asChild variant="link" className="p-0"><Link to="/profile/settings/equipment">Tùy chọn thiết bị (MH37)</Link></Button>
          <Button asChild variant="link" className="p-0"><Link to="/profile/settings/preferences">Tùy chọn người dùng (MH38)</Link></Button>
          <Button asChild variant="link" className="p-0"><Link to="/profile/settings/security">Bảo mật tài khoản (MH53)</Link></Button>
        </div>
      </main>
    </div>
  );
}