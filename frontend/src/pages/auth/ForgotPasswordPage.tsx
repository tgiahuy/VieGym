import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { useState } from 'react';
import { BackButton } from '@/components/auth/BackButton';
import { toast } from 'sonner';
import { AuthVideoBackground } from '@/components/auth/AuthVideoBackground';

export default function ForgotPasswordPage() {
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    toast.loading('Đang gửi mã xác thực OTP...');
    setTimeout(() => {
      setIsLoading(false);
      toast.dismiss();
      toast.success('Đã gửi mã xác thực OTP đặt lại mật khẩu đến email của bạn.');
    }, 1500);
  };

  return (
    <div className="relative min-h-screen">
      <AuthVideoBackground />
      <div className="absolute inset-0 bg-black/70" />
      <div className="relative z-10 min-h-screen px-8 pt-24 pb-8">
        <BackButton />
        <div className="flex flex-col items-center text-center">
          <h1 className="text-3xl font-extrabold">Quên mật khẩu</h1>
          <p className="mt-4 text-muted-foreground">
            Nhập email của bạn, chúng tôi sẽ gửi một liên kết để đặt lại mật khẩu.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-10 space-y-6">
          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input id="email" type="email" placeholder="email@example.com" required />
          </div>

          <Button type="submit" className="w-full h-14" size="lg" disabled={isLoading}>
            {isLoading ? 'Đang xử lý...' : 'Gửi liên kết'}
          </Button>
        </form>
      </div>
    </div>
  );
}