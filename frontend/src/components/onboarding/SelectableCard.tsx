import { cn } from '@/lib/utils';
import { Card } from '@/components/ui/card';
import React from 'react';

interface SelectableCardProps {
  icon?: React.ReactNode;
  title: string;
  description?: string;
  isSelected: boolean;
  onClick: () => void;
}

export const SelectableCard: React.FC<SelectableCardProps> = ({ icon, title, description, isSelected, onClick }) => {
  return (
    <Card
      onClick={onClick}
      className={cn(
        "p-6 text-center transition-all border-2 cursor-pointer rounded-2xl",
        isSelected
          ? "border-primary bg-secondary shadow-lg"
          : "border-transparent bg-white/5 hover:bg-white/10"
      )}
    >
      {icon && <div className="mb-4 text-5xl text-primary flex justify-center">{icon}</div>}
      <h3 className="text-lg font-bold">{title}</h3>
      {description && <p className="mt-1 text-sm text-muted-foreground">{description}</p>}
    </Card>
  );
};