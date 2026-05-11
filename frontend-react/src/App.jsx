import React from 'react'
import { Navigate, createBrowserRouter } from 'react-router'
import Login from './pages/Login'
import AdminLayout from './layouts/AdminLayout'
import StudentLayout from './layouts/StudentLayout'
import Students from './pages/Students'
import Subjects from './pages/Subjects'
import Assign from './pages/Assign'
import Analytics from './pages/Analytics'
import StudentDashboard from './pages/StudentDashboard'

function getCurrentUser() {
  try {
    return JSON.parse(localStorage.getItem('studentUser') || 'null')
  } catch {
    return null
  }
}

function RequireAuth({ children, role }) {
  const user = getCurrentUser()

  if (!user) {
    return <Navigate to="/login" replace />
  }

  if (role && user.role !== role) {
    return <Navigate to={user.role === 'ADMIN' ? '/admin/students' : '/student/dashboard'} replace />
  }

  return children
}

function RootRedirect() {
  const user = getCurrentUser()

  if (!user) {
    return <Navigate to="/login" replace />
  }

  return <Navigate to={user.role === 'ADMIN' ? '/admin/students' : '/student/dashboard'} replace />
}

function LoginRedirect() {
  const user = getCurrentUser()

  if (!user) {
    return <Navigate to="/login" replace />
  }

  return <Navigate to={user.role === 'ADMIN' ? '/admin/students' : '/student/dashboard'} replace />
}

export const router = createBrowserRouter([
  {
    path: '/',
    element: <RootRedirect />,
  },
  {
    path: '/login',
    element: <Login />,
  },
  {
    path: '/admin',
    element: <RequireAuth role="ADMIN"><AdminLayout /></RequireAuth>,
    children: [
      { index: true, element: <Navigate to="students" replace /> },
      { path: 'students', element: <Students /> },
      { path: 'subjects', element: <Subjects /> },
      { path: 'assign', element: <Assign /> },
      { path: 'analytics', element: <Analytics /> },
    ],
  },
  {
    path: '/student',
    element: <RequireAuth role="STUDENT"><StudentLayout /></RequireAuth>,
    children: [
      { index: true, element: <Navigate to="dashboard" replace /> },
      { path: 'dashboard', element: <StudentDashboard /> },
    ],
  },
  {
    path: '*',
    element: <LoginRedirect />,
  },
])

export default function App() {
  return null
}