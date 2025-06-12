import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { SleepChart } from '../SleepChart';
import { useSleep } from '../../hooks/useFitbitData';
import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the useSleep hook
vi.mock('../../hooks/useFitbitData', () => ({
  useSleep: vi.fn(),
}));

const mockUseSleep = useSleep as ReturnType<typeof vi.fn>;

type SleepData = {
  data: {
    sleep: Array<{
      startTime: string;
      endTime: string;
      duration: number;
      efficiency: number;
      levels: {
        summary: {
          deep: { minutes: number };
          light: { minutes: number };
          rem: { minutes: number };
          wake: { minutes: number };
        };
      };
    }>;
  } | null;
};

type QueryResult = {
  data: SleepData | undefined;
  isLoading: boolean;
  error: Error | null;
};

describe('SleepChart', () => {
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
    mockUseSleep.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    } as QueryResult);

    render(<SleepChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('Loading sleep data...')).toBeInTheDocument();
  });

  it('renders error state', () => {
    const errorMessage = 'Failed to fetch data';
    mockUseSleep.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error(errorMessage),
    } as QueryResult);

    render(<SleepChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText(`Error loading sleep data: ${errorMessage}`)).toBeInTheDocument();
  });

  it('renders no data state', () => {
    mockUseSleep.mockReturnValue({
      data: { data: null },
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<SleepChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('No sleep data available')).toBeInTheDocument();
  });

  it('renders chart with data', async () => {
    const mockData = {
      data: {
        sleep: [
          {
            startTime: '2024-03-12T22:00:00.000',
            endTime: '2024-03-13T06:00:00.000',
            duration: 28800000,
            efficiency: 95,
            levels: {
              summary: {
                deep: { minutes: 60 },
                light: { minutes: 240 },
                rem: { minutes: 90 },
                wake: { minutes: 30 },
              },
            },
          },
        ],
      },
    };

    mockUseSleep.mockReturnValue({
      data: mockData,
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<SleepChart date="2024-03-12" />, { wrapper });

    await waitFor(() => {
      expect(screen.getByText('Sleep Analysis for 2024-03-12')).toBeInTheDocument();
      expect(screen.getByText('Total Sleep Duration: 480 minutes')).toBeInTheDocument();
      expect(screen.getByText('Sleep Efficiency: 95%')).toBeInTheDocument();
    });
  });

  it('handles missing sleep data', () => {
    const mockData = {
      data: {
        sleep: [],
      },
    };

    mockUseSleep.mockReturnValue({
      data: mockData,
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<SleepChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('No sleep data available')).toBeInTheDocument();
  });

  it('handles invalid data format', () => {
    const mockData = {
      data: {
        sleep: [
          {
            startTime: '2024-03-12T22:00:00.000',
            endTime: '2024-03-13T06:00:00.000',
            duration: 'invalid' as unknown as number,
            efficiency: 'invalid' as unknown as number,
            levels: {
              summary: {
                deep: { minutes: 'invalid' as unknown as number },
                light: { minutes: 'invalid' as unknown as number },
                rem: { minutes: 'invalid' as unknown as number },
                wake: { minutes: 'invalid' as unknown as number },
              },
            },
          },
        ],
      },
    };

    mockUseSleep.mockReturnValue({
      data: mockData,
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<SleepChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('Sleep Analysis for 2024-03-12')).toBeInTheDocument();
  });
}); 