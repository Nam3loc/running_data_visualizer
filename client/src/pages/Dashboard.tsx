import { useState } from 'react';
import { StepsChart } from '../components/StepsChart';
import { HeartRateChart } from '../components/HeartRateChart';
import { SleepChart } from '../components/SleepChart';
import { DateRangeSelector } from '../components/DateRangeSelector';

const Dashboard = () => {
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Fitbit Dashboard</h1>
      
      <div className="mb-8">
        <DateRangeSelector
          selectedDate={selectedDate}
          onDateChange={setSelectedDate}
        />
      </div>

      <div className="grid grid-cols-1 gap-8">
        <div className="bg-white p-6 rounded-lg shadow">
          <StepsChart date={selectedDate} />
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <HeartRateChart date={selectedDate} />
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <SleepChart date={selectedDate} />
        </div>
      </div>
    </div>
  );
};

export default Dashboard; 