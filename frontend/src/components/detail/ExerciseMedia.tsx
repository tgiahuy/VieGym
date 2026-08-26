interface ExerciseMediaProps {
  videoUrl: string;
  exerciseName: string;
}

export const ExerciseMedia: React.FC<ExerciseMediaProps> = ({ videoUrl, exerciseName }) => {
  return (
    <div className="w-full aspect-square bg-secondary rounded-lg overflow-hidden">
      <video
        className="w-full h-full object-cover"
        src={videoUrl}
        title={exerciseName}
        autoPlay
        loop
        muted
        playsInline
      />
    </div>
  );
};