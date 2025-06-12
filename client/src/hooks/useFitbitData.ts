import { useQuery } from '@tanstack/react-query';
import { fitbitApi } from '../services/fitbitApi';

export const useSteps = (date: string) => {
  return useQuery({
    queryKey: ['steps', date],
    queryFn: () => fitbitApi.getSteps(date),
    enabled: !!date,
  });
};

export const useHeartRate = (date: string) => {
  return useQuery({
    queryKey: ['heartRate', date],
    queryFn: () => fitbitApi.getHeartRate(date),
    enabled: !!date,
  });
};

export const useSleep = (date: string) => {
  return useQuery({
    queryKey: ['sleep', date],
    queryFn: () => fitbitApi.getSleep(date),
    enabled: !!date,
  });
}; 