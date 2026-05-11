import React, {useEffect, useState} from 'react'
import Swal from 'sweetalert2'
import { students as studentsAPI } from '../api'

export default function Students(){
  const [studentsList, setStudentsList] = useState([])
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [formLoading, setFormLoading] = useState(false)

  useEffect(()=>{ fetchStudents() },[])

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

  async function handleAdd(e){
    e.preventDefault()
    if(!name || !email) return Swal.fire('Missing','Please fill all fields','warning')
    
    setFormLoading(true)
    try{
      await studentsAPI.create({name, email})
      setName(''); 
      setEmail(''); 
      await fetchStudents()
      Swal.fire({icon:'success', title:'Success', text:'Student added successfully!', timer:1500, showConfirmButton:false}) 
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to add student. Please try again.','error')
    }finally{
      setFormLoading(false)
    }
  }

  async function handleDelete(id){
    const result = await Swal.fire({title:'Are you sure?', text:"You won't be able to revert this!", icon:'warning', showCancelButton:true, confirmButtonColor:'#d33', cancelButtonColor:'#3085d6', confirmButtonText:'Yes, delete it!'})
    if(!result.isConfirmed) return
    try{ 
      await studentsAPI.delete(id)
      await fetchStudents()
      Swal.fire({icon:'success', title:'Deleted!', text:'Student has been deleted.', timer:1500, showConfirmButton:false})
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to delete student','error')
    }
  }

  async function handleEdit(id, oldName, oldEmail){
    const { value: newName } = await Swal.fire({title:'Edit Student', input:'text', inputValue:oldName, showCancelButton:true})
    if(!newName) return
    const { value: newEmail } = await Swal.fire({title:'Edit Email', input:'email', inputValue:oldEmail, showCancelButton:true})
    if(!newEmail) return
    try{
      await studentsAPI.update(id, {name:newName, email:newEmail})
      await fetchStudents()
      Swal.fire({icon:'success', title:'Updated!', text:'Student updated successfully.', timer:1500, showConfirmButton:false})
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to update student','error')
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <section className="card md:w-1/2 lg:w-1/3">
        <h2 className="text-lg font-bold text-gray-700 mb-4 border-b pb-2">Add Student</h2>
        <form onSubmit={handleAdd} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Name</label>
            <input required type="text" value={name} onChange={e=>setName(e.target.value)} disabled={formLoading} className="input-field" placeholder="Enter student name" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Email</label>
            <input required type="email" value={email} onChange={e=>setEmail(e.target.value)} disabled={formLoading} className="input-field" placeholder="Enter email" />
          </div>
          <button type="submit" disabled={formLoading} className="btn-primary w-full disabled:opacity-50 disabled:cursor-not-allowed">{formLoading ? 'Saving...' : 'Save Student'}</button>
        </form>
      </section>

      <section className="card overflow-hidden">
        <div className="card-header flex justify-between items-center">
          <h2 className="text-lg font-bold text-gray-700">Students List</h2>
        </div>
        <div className="overflow-x-auto">
          {loading ? (
            <div className="px-6 py-8 text-center text-gray-400">Loading students...</div>
          ) : studentsList.length === 0 ? (
            <div className="px-6 py-8 text-center text-gray-400 italic">No students found</div>
          ) : (
            <table className="min-w-full text-left table-auto">
              <thead className="bg-white text-gray-500 text-xs uppercase tracking-wider border-b">
                <tr>
                  <th className="px-6 py-3 font-medium">Name</th>
                  <th className="px-6 py-3 font-medium">Email</th>
                  <th className="px-6 py-3 font-medium">Subjects</th>
                  <th className="px-6 py-3 font-medium text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                {studentsList.map(s=> (
                  <tr key={s.id} className="table-row-hover">
                    <td className="px-6 py-4 whitespace-nowrap font-medium">{s.name}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-gray-500">{s.email}</td>
                    <td className="px-6 py-4">{s.subjects?.length > 0 ? s.subjects.map(x=> <span key={x.id} className="badge-teal">{x.name}</span>) : <span className="text-gray-400 italic">None</span>}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                      <button onClick={()=>handleEdit(s.id, s.name, s.email)} className="text-blue-600 hover:text-blue-900 font-semibold">Edit</button>
                      <button onClick={()=>handleDelete(s.id)} className="text-red-600 hover:text-red-900 font-semibold">Delete</button>
                    </td>
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
