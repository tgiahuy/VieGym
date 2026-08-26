import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import { Toaster } from "./components/ui/sonner";

// Layouts
import MainLayout from "./layouts/MainLayout";

// Main Pages
import DashboardPage from "./pages/dashboard/DashboardPage";
import WorkoutTabPage from "./pages/workout/WorkoutTabPage";
import MealTabPage from "./pages/meal/MealTabPage";
import AiTabPage from "./pages/ai/AiTabPage";
import ProfileTabPage from "./pages/profile/ProfileTabPage";

// Standalone Pages (No Nav)
import WelcomePage from "./pages/auth/WelcomePage";
import LoginPage from "./pages/auth/LoginPage";
import RegisterPage from "./pages/auth/RegisterPage";
import ForgotPasswordPage from "./pages/auth/ForgotPasswordPage";
import OtpPage from "./pages/auth/OtpPage";
import HealthProfileOnboardingPage from "./pages/onboarding/HealthProfileOnboardingPage";
import EquipmentOnboardingPage from "./pages/onboarding/EquipmentOnboardingPage";
import WorkoutSessionPage from "./pages/workout/WorkoutSessionPage";
import WorkoutSummaryPage from "./pages/workout/WorkoutSummaryPage";
import ExerciseDetailPage from "./pages/workout/ExerciseDetailPage";

// Sub Pages (With Nav)
import ExerciseLibraryPage from "./pages/workout/ExerciseLibraryPage";
import SettingsPage from "./pages/profile/SettingsPage";

// Other
import NotFound from "./pages/NotFound";


function App() {
  return (
    <Router>
      <div className="relative min-h-screen bg-background">
        <main className="pb-24">
          <Routes>
            {/* Standalone Routes (No BottomNav) */}
            <Route path="/welcome" element={<WelcomePage />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} />
            <Route path="/forgot-password" element={<ForgotPasswordPage />} />
            <Route path="/otp" element={<OtpPage />} />
            <Route path="/onboarding/health-profile" element={<HealthProfileOnboardingPage />} />
            <Route path="/onboarding/equipment" element={<EquipmentOnboardingPage />} />
            <Route path="/workout/session/:id" element={<WorkoutSessionPage />} />
            <Route path="/workout/summary/:id" element={<WorkoutSummaryPage />} />
            <Route path="/exercise/:id" element={<ExerciseDetailPage />} />

            {/* Main Layout Routes (With BottomNav) */}
            <Route element={<MainLayout />}>
              <Route path="/" element={<DashboardPage />} />

              <Route path="/workout" element={<WorkoutTabPage />} />
              <Route path="/workout/library" element={<ExerciseLibraryPage />} />

              <Route path="/meal" element={<MealTabPage />} />
              <Route path="/ai" element={<AiTabPage />} />

              <Route path="/profile" element={<ProfileTabPage />} />
              <Route path="/profile/settings" element={<SettingsPage />} />
              {/* Add other sub-pages with nav here */}
            </Route>

            {/* Fallback Route */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </main>
        <Toaster position="top-center" richColors />
      </div>
    </Router>
  );
}

export default App;