import { Button } from '@/components/ui/button';
import React from 'react';

interface SocialButtonProps {
  icon: React.ReactNode;
  provider: string;
}

export const SocialButton: React.FC<SocialButtonProps> = ({ icon, provider }) => {
  return (
    <Button variant="secondary" size="lg" className="w-full bg-foreground text-background hover:bg-gray-200">
      <div className="flex items-center justify-center w-full">
        <span className="mr-3 text-xl">{icon}</span>
        Đăng nhập với {provider}
      </div>
    </Button>
  );
};