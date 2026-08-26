import React from 'react';
import { Checkbox } from '@/components/ui/checkbox';

interface EquipmentListItemProps {
  icon: React.ReactNode;
  name: string;
  description: string;
  isSelected: boolean;
  onToggle: () => void;
}

export const EquipmentListItem: React.FC<EquipmentListItemProps> = ({
  icon,
  name,
  description,
  isSelected,
  onToggle,
}) => {
  return (
    <div
      onClick={onToggle}
      className="flex items-center p-3 rounded-xl cursor-pointer hover:bg-secondary/50"
      role="button"
      aria-pressed={isSelected}
    >
      <div className="flex items-center justify-center w-14 h-14 mr-4 rounded-lg bg-secondary">
        <span className="text-3xl text-muted-foreground">{icon}</span>
      </div>
      <div className="flex-1">
        <h3 className="font-bold text-base">{name}</h3>
        <p className="text-sm text-muted-foreground">{description}</p>
      </div>
      <Checkbox checked={isSelected} className="w-6 h-6 rounded-md" />
    </div>
  );
};