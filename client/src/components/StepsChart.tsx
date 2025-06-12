import React from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { useSteps } from '../hooks/useFitbitData';

interface StepsChartProps {
  date: string;
}

interface ChartDataPoint {
  time: string;
  steps: number;
}

export const StepsChart: React.FC<StepsChartProps> = ({ date }) => {
  const { data, isLoading, error } = useSteps(date);

  if (isLoading) {
    return <div>Loading steps data...</div>;
  }

  if (error) {
    return <div>Error loading steps data: {(error as Error).message}</div>;
  }

  if (!data?.data) {
    return <div>No steps data available</div>;
  }

  // Transform the data for the chart
  const chartData: ChartDataPoint[] = data.data['activities-steps-intraday']?.dataset.map((item) => ({
    time: item.time,
    steps: parseInt(item.value, 10),
  })) || [];

  return (
    <div style={{ width: '100%', height: 300 }}>
      <h3>Steps for {date}</h3>
      <ResponsiveContainer width="100%" height={200}>
        <LineChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="time" />
          <YAxis />
          <Tooltip />
          <Line type="monotone" dataKey="steps" stroke="#8884d8" />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}; 