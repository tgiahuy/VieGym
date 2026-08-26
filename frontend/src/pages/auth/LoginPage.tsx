import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Link } from 'react-router-dom';
import { useState } from 'react';
import { FaDumbbell, FaGoogle, FaFacebook } from 'react-icons/fa';
import { BackButton } from '@/components/auth/BackButton';
import { PasswordInput } from '@/components/auth/PasswordInput';
import { SocialButton } from '@/components/auth/SocialButton';
import { DividerWithText } from '@/components/auth/DividerWithText';
import { AuthVideoBackground } from '@/components/auth/AuthVideoBackground';

export default function LoginPage() {
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    // Mock API call
    setTimeout(() => setIsLoading(false), 1500);
  };

  return (
    <div className="relative min-h-screen">
      <AuthVideoBackground />
      <div className="absolute inset-0 bg-black/70" />
      <div className="relative z-10 min-h-screen px-8 pt-24 pb-8">
        <BackButton />
        <div className="flex flex-col items-center">
          <FaDumbbell className="text-5xl text-primary" />
          <h1 className="mt-6 text-3xl font-extrabold">Đăng nhập</h1>
        </div>

        <form onSubmit={handleSubmit} className="mt-10 space-y-6">
          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input id="email" type="email" placeholder="email@example.com" required />
          </div>
          <div className="space-y-2">
            <Label htmlFor="password">Mật khẩu</Label>
            <PasswordInput id="password" required />
          </div>

          <Button type="submit" className="w-full h-14" size="lg" disabled={isLoading}>
            {isLoading ? 'Đang xử lý...' : 'Đăng nhập'}
          </Button>

          <div className="text-center">
            <Button asChild variant="link" className="p-0 h-auto text-base">
              <Link to="/forgot-password">Quên mật khẩu?</Link>
            </Button>
          </div>
        </form>

        <DividerWithText text="Hoặc" />

        <div className="space-y-4">
          <SocialButton provider="Facebook" icon={<FaFacebook />} />
          <SocialButton provider="Google" icon={<FaGoogle />} />
        </div>
      </div>
    </div>
  );
}