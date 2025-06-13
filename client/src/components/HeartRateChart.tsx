import React from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { useHeartRate } from '../hooks/useFitbitData';

interface HeartRateChartProps {
  date: string;
}

interface ChartDataPoint {
  time: string;
  heartRate: number;
}

export const HeartRateChart: React.FC<HeartRateChartProps> = ({ date }) => {
  const { data, isLoading, error } = useHeartRate(date);

  if (isLoading) {
    return <div>Loading heart rate data...</div>;
  }

  if (error) {
    return <div>Error loading heart rate data: {(error as Error).message}</div>;
  }

  //If no heartRate data is given or is the heartRate data is empty
  if (!data?.data || !data.data['activities-heart-intraday']?.dataset?.length) {
    return <div>No heart rate data available</div>;
  }

  const rawDataset = data.data['activities-heart-intraday']?.dataset || [];

  const cleanedDataset: ChartDataPoint[] = rawDataset.map((data) => {
    if (typeof data.value !== 'number' || isNaN(data.value)) {
      throw new Error(`Invalid heart rate data: ${data.value}`);
    }
  
    return {
      time: data.time,
      heartRate: data.value,
    };
  });
  
  const chartData: ChartDataPoint[] = cleanedDataset;

  return (
    <div style={{ width: '100%', height: 300 }}>
      <h3>Heart Rate for {date}</h3>
      <ResponsiveContainer width="100%" height={200}>
        <LineChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="time" />
          <YAxis domain={['auto', 'auto']} />
          <Tooltip />
          <Line 
            type="monotone" 
            dataKey="heartRate" 
            stroke="#ff6b6b" 
            name="Heart Rate (bpm)"
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}; 