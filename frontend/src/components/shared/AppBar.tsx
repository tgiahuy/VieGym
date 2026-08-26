import React from 'react';
import { FiMoreHorizontal, FiArrowLeft } from 'react-icons/fi';
import { useNavigate } from 'react-router-dom';

interface AppBarProps {
  title: string;
  showActions?: boolean;
  showBack?: boolean;
}

export const AppBar: React.FC<AppBarProps> = ({ title, showActions = true, showBack = false }) => {
  const navigate = useNavigate();

  return (
    <header className="sticky top-0 z-40 w-full bg-background/80 backdrop-blur-sm">
      <div className="container flex items-center justify-between h-20 px-4 mx-auto">
        <div className="flex items-center gap-2">
          {showBack && (
            <button onClick={() => navigate(-1)} className="p-3 -ml-3 text-2xl rounded-full text-muted-foreground hover:text-foreground hover:bg-secondary">
              <FiArrowLeft />
            </button>
          )}
          <h1 className="text-3xl font-extrabold tracking-tight">{title}</h1>
        </div>
        {showActions && (
          <div className="flex items-center gap-2">
            <button className="p-3 text-xl rounded-full text-muted-foreground hover:text-foreground hover:bg-secondary">
              <FiMoreHorizontal />
            </button>
          </div>
        )}
      </div>
    </header>
  );
};