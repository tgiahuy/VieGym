import React from 'react';
import { Outlet } from 'react-router-dom';
import { AppBar } from '@/components/shared/AppBar';

const AuthLayout: React.FC<{ title: string }> = ({ title }) => {
  return (
    <div>
      <AppBar title={title} showActions={false} showBack />
      <main className="container p-4 mx-auto mt-4">
        <Outlet />
      </main>
    </div>
  );
};

export default AuthLayout;