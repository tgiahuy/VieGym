import { Button } from '@/components/ui/button';
import { Link } from 'react-router-dom';
import { FaDumbbell } from 'react-icons/fa';
import { AuthVideoBackground } from '@/components/auth/AuthVideoBackground';

export default function WelcomePage() {
  return (
    <div className="relative flex flex-col min-h-screen text-white">
      <AuthVideoBackground />
      <div className="absolute inset-0 bg-black/60" />
      <div className="relative z-10 flex flex-col flex-1 p-8">

        {/* Logo ở trung tâm */}
        <div className="flex-1 flex items-center justify-center">
          <FaDumbbell className="text-8xl text-primary opacity-90" />
        </div>

        {/* Nội dung ở dưới */}
        <div className="w-full">
          <h2 className="font-display text-4xl font-bold italic tracking-wider text-white">
            VIEGYM
          </h2>
          <h1 className="mt-1 text-3xl font-extrabold tracking-tighter md:text-4xl">
            Tập thông minh.<br/>
            Sống khoẻ mạnh.
          </h1>
          <div className="flex flex-col w-full gap-4 mt-6">
            <Button asChild size="lg" className="h-14"><Link to="/register">Bắt đầu ngay!</Link></Button>
            <Button asChild size="lg" variant="secondary" className="h-14"><Link to="/login">Bạn đã có tài khoản?</Link></Button>
          </div>
        </div>
      </div>
    </div>
  );
}