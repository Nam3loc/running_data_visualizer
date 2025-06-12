const Login = () => {
  const handleFitbitLogin = () => {
    window.location.href = '/auth/fitbit'
  }

  return (
    <div className="min-h-[80vh] flex items-center justify-center">
      <div className="max-w-md w-full space-y-8 p-8 bg-white rounded-lg shadow">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Connect your Fitbit account
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Visualize your fitness data and track your progress
          </p>
        </div>
        <div>
          <button
            onClick={handleFitbitLogin}
            className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            Connect with Fitbit
          </button>
        </div>
      </div>
    </div>
  )
}

export default Login 