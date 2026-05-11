import React, {useState} from 'react'
import { useNavigate } from 'react-router'
import Swal from 'sweetalert2'
import { auth } from '../api'

export default function Login(){
  const [mode,setMode] = useState('login')
  const navigate = useNavigate()

  const submit = async (e)=>{
    e.preventDefault()
    const form = e.target
    const email = mode === 'login' ? form.email.value : form.registerEmail.value
    const password = mode === 'login' ? form.password.value : form.registerPassword.value

    if(!email || !password){
      return Swal.fire('Missing','Please provide all fields','warning')
    }

    try {
      if (mode === 'login') {
        const user = await auth.login({ email, password })
        localStorage.setItem('studentUser', JSON.stringify(user))

        const destination = user.role === 'ADMIN' ? '/admin/students' : '/student/dashboard'
        Swal.fire({ icon: 'success', title: 'Login successful', timer: 1200, showConfirmButton: false })
          .then(() => navigate(destination, { replace: true }))
      } else {
        const name = form.registerName.value
        const user = await auth.register({ name, email, password })
        localStorage.setItem('studentUser', JSON.stringify(user))

        const destination = user.role === 'ADMIN' ? '/admin/students' : '/student/dashboard'
        Swal.fire({ icon: 'success', title: 'Registration successful', timer: 1200, showConfirmButton: false })
          .then(() => navigate(destination, { replace: true }))
      }
    } catch (error) {
      console.error(error)
      Swal.fire('Error', 'Invalid credentials or server error', 'error')
    }
  }

  return (
    <div className="flex items-center justify-center min-h-screen text-gray-800 bg-gray-50">
      <div className="bg-white p-8 rounded-xl shadow-xl w-full max-w-md border border-gray-200">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-extrabold text-teal-700">StudentApp</h1>
          <p className="text-gray-500 mt-2 font-medium">Manage your education</p>
        </div>

        {mode==='login' ? (
          <form id="login-form" onSubmit={submit} className="space-y-4">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
              <input name="email" type="email" required placeholder="your@email.com" className="input-field" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Password</label>
              <input name="password" type="password" required placeholder="••••••••" className="input-field" />
            </div>
            <button type="submit" className="btn-primary w-full mt-6 text-base">Login</button>
          </form>
        ) : (
          <form id="register-form" onSubmit={submit} className="space-y-4">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Full Name</label>
              <input name="registerName" type="text" required placeholder="Your Name" className="input-field" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
              <input name="registerEmail" type="email" required placeholder="your@email.com" className="input-field" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Password</label>
              <input name="registerPassword" type="password" required placeholder="••••••••" className="input-field" />
            </div>
            <button type="submit" className="btn-primary w-full mt-6 text-base">Register</button>
          </form>
        )}

        <div className="mt-6 pt-6 border-t border-gray-200 text-center">
          <p className="text-sm text-gray-600">{
            mode==='login'
              ? <><span>Don't have an account? </span><button type="button" onClick={()=>setMode('register')} className="text-teal-600 font-semibold hover:text-teal-700 hover:underline">Register here</button></>
              : <><span>Already have an account? </span><button type="button" onClick={()=>setMode('login')} className="text-teal-600 font-semibold hover:text-teal-700 hover:underline">Login here</button></>
          }</p>
        </div>
      </div>
    </div>
  )
}
