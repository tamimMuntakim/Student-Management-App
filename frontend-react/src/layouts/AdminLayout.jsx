import React from 'react'
import { Outlet, NavLink, useNavigate } from 'react-router'
import Swal from 'sweetalert2'

function Header(){
  const navigate = useNavigate()
  const logout = ()=>{
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
    <header className="bg-teal-700 text-white shadow-md z-10 relative">
      <div className="container mx-auto px-4 py-4 flex justify-between items-center">
        <h1 className="text-2xl font-extrabold tracking-tight">Admin Dashboard</h1>
        <nav className="flex items-center">
          <button onClick={logout} className="bg-red-500 hover:bg-red-600 border-2 border-red-600 px-4 py-1.5 rounded transition shadow-sm font-semibold">
            Logout
          </button>
        </nav>
      </div>
    </header>
  )
}

function Sidebar(){
  const items = [
    {to:'/admin/students', label:'Students'},
    {to:'/admin/subjects', label:'Subjects'},
    {to:'/admin/assign', label:'Assign Subjects'},
    {to:'/admin/analytics', label:'Analytics'}
  ]
  return (
    <aside className="w-64 bg-white border-r border-gray-200 overflow-y-auto hidden md:block">
      <div className="p-6">
        <nav className="space-y-1">
          {items.map(i=> (
            <NavLink key={i.to} to={i.to} className={({isActive})=>isActive ? 'nav-item nav-active' : 'nav-item'}>
              {i.label}
            </NavLink>
          ))}
        </nav>
      </div>
    </aside>
  )
}

export default function AdminLayout() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-100">
      <Header />
      <div className="flex flex-1 overflow-hidden">
        <Sidebar />
        <main className="flex-1 overflow-y-auto p-4 md:p-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
