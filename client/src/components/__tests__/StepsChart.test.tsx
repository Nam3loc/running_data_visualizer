import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { StepsChart } from '../StepsChart';
import { useSteps } from '../../hooks/useFitbitData';
import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the useSteps hook
vi.mock('../../hooks/useFitbitData', () => ({
  useSteps: vi.fn(),
}));

const mockUseSteps = useSteps as ReturnType<typeof vi.fn>;

type StepsData = {
  data: {
    'activities-steps-intraday': {
      dataset: Array<{ time: string; value: string }>;
    };
  } | null;
};

type QueryResult = {
  data: StepsData | undefined;
  isLoading: boolean;
  error: Error | null;
};

describe('StepsChart', () => {
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
    mockUseSteps.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    } as QueryResult);

    render(<StepsChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('Loading steps data...')).toBeInTheDocument();
  });

  it('renders error state', () => {
    const errorMessage = 'Failed to fetch data';
    mockUseSteps.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error(errorMessage),
    } as QueryResult);

    render(<StepsChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText(`Error loading steps data: ${errorMessage}`)).toBeInTheDocument();
  });

  it('renders no data state', () => {
    mockUseSteps.mockReturnValue({
      data: { data: null },
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<StepsChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('No steps data available')).toBeInTheDocument();
  });

  it('renders chart with data', async () => {
    const mockData = {
      data: {
        'activities-steps-intraday': {
          dataset: [
            { time: '00:00', value: '100' },
            { time: '01:00', value: '200' },
          ],
        },
      },
    };

    mockUseSteps.mockReturnValue({
      data: mockData,
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<StepsChart date="2024-03-12" />, { wrapper });

    await waitFor(() => {
      expect(screen.getByText('Steps for 2024-03-12')).toBeInTheDocument();
    });
  });

  it('handles empty dataset', () => {
    const mockData = {
      data: {
        'activities-steps-intraday': {
          dataset: [],
        },
      },
    };

    mockUseSteps.mockReturnValue({
      data: mockData,
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<StepsChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('Steps for 2024-03-12')).toBeInTheDocument();
  });

  it('handles invalid data format', () => {
    const mockData = {
      data: {
        'activities-steps-intraday': {
          dataset: [
            { time: '00:00', value: 'invalid' },
          ],
        },
      },
    };

    mockUseSteps.mockReturnValue({
      data: mockData,
      isLoading: false,
      error: null,
    } as QueryResult);

    render(<StepsChart date="2024-03-12" />, { wrapper });
    expect(screen.getByText('Steps for 2024-03-12')).toBeInTheDocument();
  });
}); 