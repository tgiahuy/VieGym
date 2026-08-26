import { Button } from '@/components/ui/button';
import { InputOTP, InputOTPGroup, InputOTPSlot } from '@/components/ui/input-otp';
import { useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { AuthVideoBackground } from '@/components/auth/AuthVideoBackground';
import { BackButton } from '@/components/auth/BackButton';

export default function OtpPage() {
  const navigate = useNavigate();

  const handleComplete = (value: string) => {
    toast.loading('Đang xác thực...');
    setTimeout(() => {
      toast.dismiss();
      if (value === "123456") { // Mock OTP
        toast.success('Xác thực thành công!');
        navigate('/onboarding/health-profile');
      } else {
        toast.error('Mã OTP không hợp lệ.');
      }
    }, 1000);
  };

  return (
    <div className="relative min-h-screen">
      <AuthVideoBackground />
      <div className="absolute inset-0 bg-black/70" />
      <div className="relative z-10 flex flex-col min-h-screen px-8 pt-24 pb-8">
        <BackButton />
        <div className="flex flex-col items-center text-center">
          <h1 className="text-3xl font-extrabold">Xác thực tài khoản</h1>
          <p className="mt-4 text-muted-foreground">
            Chúng tôi đã gửi một mã gồm 6 chữ số đến email của bạn. Vui lòng nhập mã vào bên dưới.
          </p>
        </div>

        <div className="flex flex-col items-center justify-center flex-1">
          <InputOTP maxLength={6} onComplete={handleComplete}>
            <InputOTPGroup className="gap-2 md:gap-3">
              <InputOTPSlot className="w-12 h-14 text-2xl border-border bg-input rounded-md" index={0} />
              <InputOTPSlot className="w-12 h-14 text-2xl border-border bg-input rounded-md" index={1} />
              <InputOTPSlot className="w-12 h-14 text-2xl border-border bg-input rounded-md" index={2} />
              <InputOTPSlot className="w-12 h-14 text-2xl border-border bg-input rounded-md" index={3} />
              <InputOTPSlot className="w-12 h-14 text-2xl border-border bg-input rounded-md" index={4} />
              <InputOTPSlot className="w-12 h-14 text-2xl border-border bg-input rounded-md" index={5} />
            </InputOTPGroup>
          </InputOTP>
        </div>

        <div className="text-center">
          <Button variant="link">Chưa nhận được mã? Gửi lại</Button>
        </div>
      </div>
    </div>
  );
}