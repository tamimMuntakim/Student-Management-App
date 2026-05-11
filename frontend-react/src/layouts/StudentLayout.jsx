import React from 'react'
import { Outlet, useNavigate } from 'react-router'
import Swal from 'sweetalert2'

export default function StudentLayout(){
  const navigate = useNavigate()
  const student = (() => {
    try {
      return JSON.parse(localStorage.getItem('studentUser') || 'null')
    } catch {
      return null
    }
  })()

  const logout = () => {
    Swal.fire({
      title: 'Logging out...',
      text: 'Are you sure you want to log out?',
      icon: 'question',
      showCancelButton: true,
      confirmButtonColor: '#0f766e',
      cancelButtonColor: '#d33',
      confirmButtonText: 'Yes, log out!'
    }).then((result) => {
      if (result.isConfirmed) {
        localStorage.removeItem('studentUser')
        navigate('/login', { replace: true })
      }
    })
  }

  return (
    <div className="min-h-screen flex flex-col bg-linear-to-br from-teal-50 via-white to-amber-50">
      <header className="bg-teal-700 text-white shadow-md">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-extrabold tracking-tight">Student Dashboard</h1>
            <p className="text-teal-100 text-sm">Welcome back{student?.name ? `, ${student.name}` : ''}</p>
          </div>
          <button onClick={logout} className="bg-red-500 hover:bg-red-600 border-2 border-red-600 px-4 py-1.5 rounded transition shadow-sm font-semibold">
            Logout
          </button>
        </div>
      </header>

      <main className="flex-1 container mx-auto px-4 py-8">
        <Outlet />
      </main>
    </div>
  )
}