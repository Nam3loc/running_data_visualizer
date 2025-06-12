import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { useSleep } from '../hooks/useFitbitData';

interface SleepChartProps {
  date: string;
}

interface SleepStageData {
  name: string;
  deep: number;
  light: number;
  rem: number;
  wake: number;
}

export const SleepChart: React.FC<SleepChartProps> = ({ date }) => {
  const { data, isLoading, error } = useSleep(date);

  if (isLoading) {
    return <div>Loading sleep data...</div>;
  }

  if (error) {
    return <div>Error loading sleep data: {(error as Error).message}</div>;
  }

  if (!data?.data?.sleep?.[0]) {
    return <div>No sleep data available</div>;
  }

  const sleepData = data.data.sleep[0];
  const chartData: SleepStageData[] = [{
    name: 'Sleep Stages',
    deep: sleepData.levels.summary.deep,
    light: sleepData.levels.summary.light,
    rem: sleepData.levels.summary.rem,
    wake: sleepData.levels.summary.wake,
  }];

  return (
    <div style={{ width: '100%', height: 300 }}>
      <h3>Sleep Analysis for {date}</h3>
      <div className="mb-2">
        <p>Total Sleep Duration: {Math.round(sleepData.duration / 60000)} minutes</p>
        <p>Sleep Efficiency: {sleepData.efficiency}%</p>
      </div>
      <ResponsiveContainer width="100%" height={200}>
        <BarChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis label={{ value: 'Minutes', angle: -90, position: 'insideLeft' }} />
          <Tooltip />
          <Legend />
          <Bar dataKey="deep" name="Deep Sleep" fill="#4a90e2" stackId="a" />
          <Bar dataKey="light" name="Light Sleep" fill="#50e3c2" stackId="a" />
          <Bar dataKey="rem" name="REM Sleep" fill="#f5a623" stackId="a" />
          <Bar dataKey="wake" name="Awake" fill="#d0021b" stackId="a" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}; 