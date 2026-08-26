import React from 'react';
import { Button } from '@/components/ui/button';

interface StickyButtonProps {
  children: React.ReactNode;
  onClick: () => void;
}

export const StickyButton: React.FC<StickyButtonProps> = ({ children, onClick }) => {
  return (
    <div className="fixed bottom-24 left-0 right-0 z-10 px-4 pb-2" style={{ paddingBottom: 'calc(0.5rem + env(safe-area-inset-bottom))' }}>
      <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-background to-transparent" />
      <Button onClick={onClick} size="lg" className="relative w-full h-14">
        {children}
      </Button>
    </div>
  );
};