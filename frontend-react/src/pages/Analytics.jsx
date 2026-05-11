import React, {useEffect, useState} from 'react'
import Swal from 'sweetalert2'
import { students as studentsAPI } from '../api'

export default function Analytics(){
  const [students, setStudents] = useState([])
  const [loading, setLoading] = useState(false)

  useEffect(()=>{ fetchAnalytics() },[])

  async function fetchAnalytics(){
    setLoading(true)
    try{ 
      const data = await studentsAPI.list()
      setStudents(data || [])
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to fetch analytics data','error')
    }finally{
      setLoading(false)
    }
  }

  const courses = (()=>{
    const map = {}
    students.forEach(s=> (s.subjects||[]).forEach(sub=>{ map[sub.code] = map[sub.code] || {course:sub, students:[]}; map[sub.code].students.push(s.name)}))
    return Object.values(map)
  })()

  if(loading) return <div className="text-center py-12 text-gray-400">Loading analytics...</div>

  return (
    <div className="flex flex-col gap-8">
      <section className="card overflow-hidden">
        <div className="card-header">
          <h2 className="text-lg font-bold text-gray-700">Students and their Courses</h2>
        </div>
        <div className="overflow-x-auto">
          {students.length === 0 ? (
            <div className="px-6 py-8 text-center text-gray-400 italic">No students found</div>
          ) : (
            <table className="min-w-full text-left table-auto">
              <thead className="bg-white text-gray-500 text-xs uppercase tracking-wider border-b">
                <tr>
                  <th className="px-6 py-4 font-medium">Student Name</th>
                  <th className="px-6 py-4 font-medium">Email</th>
                  <th className="px-6 py-4 font-medium">Enrolled Courses</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                {students.map(s=> (
                  <tr key={s.id} className="hover:bg-gray-50 transition">
                    <td className="px-6 py-4 whitespace-nowrap font-medium text-gray-900">{s.name}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-gray-500">{s.email}</td>
                    <td className="px-6 py-4 text-gray-500">{(s.subjects||[]).length>0 ? (s.subjects.map(sub=> <span key={sub.id} className="badge-teal">{sub.name}</span>)) : <span className="text-gray-400 italic">None</span>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </section>

      <section className="card overflow-hidden">
        <div className="card-header">
          <h2 className="text-lg font-bold text-gray-700">Courses and Enrolled Students</h2>
        </div>
        <div className="overflow-x-auto">
          {courses.length===0 ? (
            <div className="px-6 py-8 text-center text-gray-400 italic">No courses with enrolled students found.</div>
          ) : (
            <table className="min-w-full text-left table-auto">
              <thead className="bg-white text-gray-500 text-xs uppercase tracking-wider border-b">
                <tr>
                  <th className="px-6 py-4 font-medium">Course Code</th>
                  <th className="px-6 py-4 font-medium">Course Name</th>
                  <th className="px-6 py-4 font-medium">Enrolled Students</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                {courses.map(c=> (
                  <tr key={c.course.code} className="hover:bg-gray-50 transition">
                    <td className="px-6 py-4 whitespace-nowrap font-mono text-xs font-bold text-teal-700"><span className="bg-teal-50 px-2 py-1 rounded border border-teal-100">{c.course.code}</span></td>
                    <td className="px-6 py-4 whitespace-nowrap font-medium text-gray-900">{c.course.name}</td>
                    <td className="px-6 py-4 text-gray-500">{c.students.join(', ')}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </section>
    </div>
  )
}
