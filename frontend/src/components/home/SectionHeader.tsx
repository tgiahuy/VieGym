import React from 'react';
import { Link } from 'react-router-dom';

interface SectionHeaderProps {
  title: string;
  actionText?: string;
  actionLink?: string;
}

export const SectionHeader: React.FC<SectionHeaderProps> = ({ title, actionText, actionLink }) => {
  return (
    <div className="flex items-center justify-between mb-4">
      <h2 className="text-xl font-bold">{title}</h2>
      {actionText && actionLink && (
        <Link to={actionLink} className="text-sm font-bold text-primary">
          {actionText}
        </Link>
      )}
    </div>
  );
};