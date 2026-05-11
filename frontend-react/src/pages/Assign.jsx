import React, {useEffect, useState} from 'react'
import Swal from 'sweetalert2'
import { students as studentsAPI, subjects as subjectsAPI, assignments } from '../api'

export default function Assign(){
  const [studentsList, setStudentsList] = useState([])
  const [subjectsList, setSubjectsList] = useState([])
  const [studentId, setStudentId] = useState('')
  const [subjectId, setSubjectId] = useState('')
  const [loading, setLoading] = useState(false)
  const [formLoading, setFormLoading] = useState(false)

  useEffect(()=>{ 
    fetchStudents()
    fetchSubjects()
  },[])

  async function fetchStudents(){ 
    setLoading(true)
    try{ 
      const data = await studentsAPI.list()
      setStudentsList(data || [])
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to fetch students','error')
    }finally{
      setLoading(false)
    }
  }

  async function fetchSubjects(){ 
    try{ 
      const data = await subjectsAPI.list()
      setSubjectsList(data || [])
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to fetch subjects','error')
    }
  }

  async function handleAssign(e){
    e.preventDefault()
    if(!studentId || !subjectId) return Swal.fire({icon:'warning', title:'Missing Selection', text:'Please select both student and subject'})
    
    setFormLoading(true)
    try{
      await assignments.assign(studentId, subjectId)
      setStudentId(''); 
      setSubjectId(''); 
      await fetchStudents()
      Swal.fire({icon:'success', title:'Success', text:'Subject assigned successfully!', timer:1500, showConfirmButton:false}) 
    }catch(e){
      console.error(e)
      Swal.fire({icon:'error', title:'Error', text:'Failed to assign subject. Please try again.'})
    }finally{
      setFormLoading(false)
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <section className="card md:w-1/2 lg:w-1/3">
        <h2 className="text-lg font-bold text-gray-700 mb-4 border-b pb-2">Assign Subject</h2>
        <form onSubmit={handleAssign} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Student</label>
            <select required value={studentId} onChange={e=>setStudentId(e.target.value)} disabled={formLoading || loading} className="select-field disabled:opacity-50">
              <option value="">-- Select Student --</option>
              {studentsList.map(s=> <option key={s.id} value={s.id}>{s.name} - ({s.email})</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Subject</label>
            <select required value={subjectId} onChange={e=>setSubjectId(e.target.value)} disabled={formLoading} className="select-field disabled:opacity-50">
              <option value="">-- Select Subject --</option>
              {subjectsList.map(s=> <option key={s.id} value={s.id}>{s.name} - {s.code}</option>)}
            </select>
          </div>
          <button type="submit" disabled={formLoading} className="btn-primary w-full disabled:opacity-50 disabled:cursor-not-allowed">{formLoading ? 'Assigning...' : 'Assign'}</button>
        </form>
      </section>

      <section className="card overflow-hidden">
        <div className="card-header">
          <h2 className="text-lg font-bold text-gray-700">Assigned Subjects Log</h2>
        </div>
        <div className="overflow-x-auto">
          {loading ? (
            <div className="px-6 py-8 text-center text-gray-400">Loading assignments...</div>
          ) : studentsList.flatMap(s=> (s.subjects||[]).map(sub=> ({id:`${s.id}-${sub.id}`, studentName:s.name, subjectName:sub.name, subjectCode:sub.code}))).length === 0 ? (
            <div className="px-6 py-8 text-center text-gray-400 italic">No assignments found</div>
          ) : (
            <table className="min-w-full text-left table-auto">
              <thead className="bg-white text-gray-500 text-xs uppercase tracking-wider border-b">
                <tr>
                  <th className="px-6 py-3 font-medium">Student Name</th>
                  <th className="px-6 py-3 font-medium">Subject Name</th>
                  <th className="px-6 py-3 font-medium">Subject Code</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                {studentsList.flatMap(s=> (s.subjects||[]).map(sub=> ({id:`${s.id}-${sub.id}`, studentName:s.name, subjectName:sub.name, subjectCode:sub.code}))).map(row=> (
                  <tr key={row.id} className="table-row-hover">
                    <td className="px-6 py-3 whitespace-nowrap">{row.studentName}</td>
                    <td className="px-6 py-3 whitespace-nowrap font-semibold">{row.subjectName}</td>
                    <td className="px-6 py-3 whitespace-nowrap"><span className="badge">{row.subjectCode}</span></td>
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
