import { FiArrowLeft } from 'react-icons/fi';
import { useNavigate } from 'react-router-dom';

export const BackButton = () => {
  const navigate = useNavigate();
  return (
    <button
      onClick={() => navigate(-1)}
      className="absolute top-16 left-4 z-10 flex items-center justify-center w-10 h-10 rounded-full bg-secondary/50 hover:bg-secondary"
      aria-label="Quay lại"
    >
      <FiArrowLeft className="w-5 h-5" />
    </button>
  );
};