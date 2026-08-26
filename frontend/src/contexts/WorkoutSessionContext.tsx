import React, { createContext, useContext, useState, ReactNode } from 'react';
import { workoutPlan } from '@/data/workoutMockData'; // Assuming this is the plan we start

// Define types for our state
interface SetData {
  kg: string;
  reps: string;
  isCompleted: boolean;
}

interface ExerciseState {
  [setId: string]: SetData;
}

interface WorkoutSessionState {
  [exerciseId: string]: ExerciseState;
}

interface WorkoutContextType {
  sessionState: WorkoutSessionState;
  updateSet: (exerciseId: string, setId: string, data: Partial<SetData>) => void;
  isResting: boolean;
  startRest: () => void;
  stopRest: () => void;
}

const WorkoutSessionContext = createContext<WorkoutContextType | undefined>(undefined);

export const WorkoutSessionProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [sessionState, setSessionState] = useState<WorkoutSessionState>({});
  const [isResting, setIsResting] = useState(false);

  const updateSet = (exerciseId: string, setId: string, data: Partial<SetData>) => {
    setSessionState(prev => ({
      ...prev,
      [exerciseId]: {
        ...prev[exerciseId],
        [setId]: {
          ...prev[exerciseId]?.[setId],
          kg: prev[exerciseId]?.[setId]?.kg || '',
          reps: prev[exerciseId]?.[setId]?.reps || '',
          isCompleted: prev[exerciseId]?.[setId]?.isCompleted || false,
          ...data,
        },
      },
    }));
  };

  const startRest = () => setIsResting(true);
  const stopRest = () => setIsResting(false);

  return (
    <WorkoutSessionContext.Provider value={{ sessionState, updateSet, isResting, startRest, stopRest }}>
      {children}
    </WorkoutSessionContext.Provider>
  );
};

export const useWorkoutSession = () => {
  const context = useContext(WorkoutSessionContext);
  if (!context) {
    throw new Error('useWorkoutSession must be used within a WorkoutSessionProvider');
  }
  return context;
};