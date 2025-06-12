import React from 'react';

interface DateRangeSelectorProps {
  selectedDate: string;
  onDateChange: (date: string) => void;
}

export const DateRangeSelector: React.FC<DateRangeSelectorProps> = ({
  selectedDate,
  onDateChange,
}) => {
  const today = new Date().toISOString().split('T')[0];
  const maxDate = today;
  const minDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]; // 30 days ago

  return (
    <div className="mb-4">
      <label htmlFor="date-selector" className="block text-sm font-medium text-gray-700 mb-1">
        Select Date
      </label>
      <input
        type="date"
        id="date-selector"
        value={selectedDate}
        onChange={(e) => onDateChange(e.target.value)}
        min={minDate}
        max={maxDate}
        className="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
      />
    </div>
  );
}; 