import { Input } from '@/components/ui/input';
import { useState } from 'react';
import { FiEye, FiEyeOff } from 'react-icons/fi';

type PasswordInputProps = React.InputHTMLAttributes<HTMLInputElement>;

export const PasswordInput = (props: PasswordInputProps) => {
  const [showPassword, setShowPassword] = useState(false);
  return (
    <div className="relative">
      <Input type={showPassword ? 'text' : 'password'} {...props} className="pr-10" />
      <button
        type="button"
        onClick={() => setShowPassword(!showPassword)}
        className="absolute inset-y-0 right-0 flex items-center justify-center w-10 h-full text-muted-foreground"
        aria-label={showPassword ? 'Ẩn mật khẩu' : 'Hiện mật khẩu'}
      >
        {showPassword ? <FiEyeOff /> : <FiEye />}
      </button>
    </div>
  );
};
