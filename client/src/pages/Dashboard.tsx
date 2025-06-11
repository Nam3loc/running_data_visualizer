import { useQuery } from '@tanstack/react-query'
import axios from 'axios'

interface FitbitData {
  steps: number
  heartRate: number
  sleep: {
    duration: number
    startTime: string
    endTime: string
  }
}

const fetchFitbitData = async (): Promise<FitbitData> => {
  const { data } = await axios.get('/api/fitbit/data')
  return data
}

const Dashboard = () => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['fitbitData'],
    queryFn: fetchFitbitData
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="text-xl text-gray-600">Loading your Fitbit data...</div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="text-xl text-red-600">Error loading Fitbit data</div>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      {/* Steps Card */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold mb-4">Steps</h2>
        <p className="text-4xl font-bold text-blue-600">
          {data?.steps.toLocaleString()}
        </p>
      </div>

      {/* Heart Rate Card */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold mb-4">Heart Rate</h2>
        <p className="text-4xl font-bold text-red-600">
          {data?.heartRate} bpm
        </p>
      </div>

      {/* Sleep Card */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold mb-4">Sleep</h2>
        <p className="text-4xl font-bold text-purple-600">
          {data?.sleep.duration.toFixed(1)} hrs
        </p>
        <p className="text-gray-600 mt-2">
          {data?.sleep.startTime && new Date(data.sleep.startTime).toLocaleTimeString()} - 
          {data?.sleep.endTime && new Date(data.sleep.endTime).toLocaleTimeString()}
        </p>
      </div>
    </div>
  )
}

export default Dashboard 