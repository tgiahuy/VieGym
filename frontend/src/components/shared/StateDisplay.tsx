import React from 'react';
import { Skeleton } from '@/components/ui/skeleton';
import { FiAlertTriangle, FiInbox } from 'react-icons/fi';

type StateType = 'loading' | 'empty' | 'error';

interface StateDisplayProps {
  type: StateType;
  title?: string;
  message?: string;
  children?: React.ReactNode;
}

const stateConfig = {
  loading: {
    icon: null,
    defaultTitle: 'Đang tải...',
    defaultMessage: 'Vui lòng chờ trong giây lát.',
  },
  empty: {
    icon: FiInbox,
    defaultTitle: 'Không có dữ liệu',
    defaultMessage: 'Hiện tại chưa có gì ở đây cả.',
  },
  error: {
    icon: FiAlertTriangle,
    defaultTitle: 'Đã xảy ra lỗi',
    defaultMessage: 'Chúng tôi không thể tải dữ liệu. Vui lòng thử lại.',
  },
};

export const StateDisplay: React.FC<StateDisplayProps> = ({ type, title, message, children }) => {
  if (type === 'loading') {
    return (
      <div className="w-full p-4 space-y-4">
        <Skeleton className="w-3/4 h-8" />
        <Skeleton className="w-full h-4" />
        <Skeleton className="w-full h-4" />
        <Skeleton className="w-1/2 h-4" />
      </div>
    );
  }

  const config = stateConfig[type];
  const Icon = config.icon;

  return (
    <div className="flex flex-col items-center justify-center p-8 text-center rounded-lg bg-card">
      {Icon && <Icon className="w-16 h-16 mb-4 text-muted-foreground" />}
      <h3 className="text-lg font-semibold text-foreground">
        {title || config.defaultTitle}
      </h3>
      <p className="mt-1 text-sm text-muted-foreground">
        {message || config.defaultMessage}
      </p>
      {children && <div className="mt-6">{children}</div>}
    </div>
  );
};