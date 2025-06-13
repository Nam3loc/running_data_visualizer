import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { HeartRateChart } from '../HeartRateChart';
import { useHeartRate } from '../../hooks/useFitbitData';
import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the useHeartRate hook
vi.mock('../../hooks/useFitbitData', () => ({
  useHeartRate: vi.fn(),
}));

const mockUseHeartRate = useHeartRate as ReturnType<typeof vi.fn>;

type HeartRateData = {
  data: {
    'activities-heart-intraday': {
      dataset: Array<{ time: string; value: number }>;
    };
  } | null;
};

type QueryResult = {
  data: HeartRateData | undefined;
  isLoading: boolean;
  error: Error | null;
};

describe('HeartRateChart', () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
    },
  });

  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders loading state', () => {
    mockUseHeartRate.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    } as QueryResult);

    render(<HeartRateChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('Loading heart rate data...')).toBeInTheDocument();
  });

  it('renders error state', () => {
    const errorMessage = 'Failed to fetch data';
    mockUseHeartRate.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error(errorMessage),
    } as QueryResult);

    render(<HeartRateChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText(`Error loading heart rate data: ${errorMessage}`)).toBeInTheDocument();
  });

  it('renders no data state', () => {
    mockUseHeartRate.mockReturnValue({
      data: { data: null },
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<HeartRateChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('No heart rate data available')).toBeInTheDocument();
  });

  it('renders chart with data', async () => {
    const mockData = {
      data: {
        'activities-heart-intraday': {
          dataset: [
            { time: '00:00', value: 65 },
            { time: '01:00', value: 70 },
          ],
        },
      },
    };

    mockUseHeartRate.mockReturnValue({
      data: mockData,
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<HeartRateChart date="2024-03-12" />, { wrapper });

    await waitFor(() => {
      expect(screen.getByText(/Heart Rate for 2024-03-12/)).toBeInTheDocument();
    });
  });

  it('handles empty dataset', () => {
    const mockData = {
      data: {
        'activities-heart-intraday': {
          dataset: [],
        },
      },
    };

    mockUseHeartRate.mockReturnValue({
      data: mockData,
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<HeartRateChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('No heart rate data available')).toBeInTheDocument();
  });

  it('handles invalid data format', () => {
    const mockData = {
      data: {
        'activities-heart-intraday': {
          dataset: [
            { time: '00:00', value: 'invalid' as unknown as number },
          ],
        },
      },
    };
  
    mockUseHeartRate.mockReturnValue({
      data: mockData,
      isLoading: false,
      error: new Error('Invalid heart rate data: invalid'),
    } as QueryResult);
  
    render(<HeartRateChart date="2024-03-12" />, { wrapper });
  
    expect(screen.getByText('Error loading heart rate data: Invalid heart rate data: invalid')).toBeInTheDocument();
  });
}); 