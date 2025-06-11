import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import Dashboard from './pages/Dashboard'
import Login from './pages/Login'
import Layout from './components/Layout'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<Dashboard />} />
            <Route path="login" element={<Login />} />
          </Route>
        </Routes>
      </Router>
    </QueryClientProvider>
  )
}

export default App


// Next Steps for Fitbit Visualizer:

// 1. Backend API Development:
//    - Implement Fitbit API data fetching in Rails controllers
//    - Create API endpoints for different Fitbit data types (steps, heart rate, sleep, etc.)
//    - Set up proper error handling and response formatting
//    - Ensure proper authentication flow is maintained

// 2. Frontend Data Integration:
//    - Set up React Query hooks for API calls
//    - Create data fetching services for each Fitbit data type
//    - Implement proper loading states and error handling
//    - Design and implement data visualization components

// 3. Data Display:
//    - Create reusable chart components (using a library like Chart.js or Recharts)
//    - Implement dashboard layout for different data types
//    - Add date range selection for historical data
//    - Design responsive data cards/grids

// 4. Testing:
//    - Test API endpoints with Postman/Insomnia
//    - Add unit tests for API controllers
//    - Test React components and data fetching
//    - Verify error handling and edge cases

// Current Status:
// - Basic React + Rails setup is complete
// - Frontend is showing loading state
// - Backend is configured as API-only
// - Need to implement actual data fetching and display

// Priority Tasks:
// 1. Start with basic Fitbit data fetching in Rails
// 2. Create corresponding API endpoints
// 3. Implement frontend data fetching
// 4. Display first set of data (e.g., daily steps)

// Additional OAuth2 Tasks to Complete:

// 1. Backend OAuth2 Completion:
//    - Create API endpoint for Fitbit data (app/controllers/api/fitbit/data_controller.rb)
//    - Update FitbitAuthController to return JSON responses instead of redirects
//    - Add proper error handling for OAuth failures
//    - Implement token refresh logic in the API

// 2. Frontend OAuth2 Integration:
//    - Update Login component to handle API responses
//    - Add proper error handling for auth failures
//    - Implement token storage and management
//    - Add auth state management

// 3. Security:
//    - Review and update CORS settings
//    - Implement proper session handling
//    - Add CSRF protection
//    - Secure token storage

// Current OAuth2 Status:
// - Basic OmniAuth setup is complete
// - Database schema for tokens is in place
// - Basic auth flow is implemented
// - Need to complete API integration