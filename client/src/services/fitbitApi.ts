import axios from 'axios';

const API_BASE_URL = '/api/fitbit';

export interface StepsData {
  'activities-steps-intraday': {
    dataset: Array<{
      time: string;
      value: string;
    }>;
  };
}

export interface HeartRateData {
  'activities-heart-intraday': {
    dataset: Array<{
      time: string;
      value: number;
    }>;
  };
}

export interface SleepData {
  sleep: Array<{
    startTime: string;
    endTime: string;
    duration: number;
    efficiency: number;
    levels: {
      summary: {
        deep: number;
        light: number;
        rem: number;
        wake: number;
      };
    };
  }>;
}

export interface FitbitResponse<T> {
  data: T;
}

export const fitbitApi = {
  getSteps: async (date: string): Promise<FitbitResponse<StepsData>> => {
    const response = await axios.get(`${API_BASE_URL}/data/steps`, {
      params: { date }
    });
    return response.data;
  },

  getHeartRate: async (date: string): Promise<FitbitResponse<HeartRateData>> => {
    const response = await axios.get(`${API_BASE_URL}/data/heart_rate`, {
      params: { date }
    });
    return response.data;
  },

  getSleep: async (date: string): Promise<FitbitResponse<SleepData>> => {
    const response = await axios.get(`${API_BASE_URL}/data/sleep`, {
      params: { date }
    });
    return response.data;
  }
}; 