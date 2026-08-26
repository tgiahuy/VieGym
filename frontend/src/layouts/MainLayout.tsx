import React from 'react';
import { Outlet } from 'react-router-dom';
import { BottomNav } from '@/components/shared/BottomNav';

const MainLayout: React.FC = () => {
  return (
    <>
      <Outlet />
      <BottomNav />
    </>
  );
};

export default MainLayout;