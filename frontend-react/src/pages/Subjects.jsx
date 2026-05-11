import React, {useEffect, useState} from 'react'
import Swal from 'sweetalert2'
import { subjects as subjectsAPI } from '../api'

export default function Subjects(){
  const [subjectsList, setSubjectsList] = useState([])
  const [name, setName] = useState('')
  const [code, setCode] = useState('')
  const [loading, setLoading] = useState(false)
  const [formLoading, setFormLoading] = useState(false)

  useEffect(()=>{ fetchSubjects() },[])

  async function fetchSubjects(){
    setLoading(true)
    try{ 
      const data = await subjectsAPI.list()
      setSubjectsList(data || [])
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to fetch subjects','error')
    }finally{
      setLoading(false)
    }
  }

  async function handleAdd(e){
    e.preventDefault()
    if(!name || !code) return Swal.fire('Missing','Please fill all fields','warning')
    setFormLoading(true)
    try{
      await subjectsAPI.create({name, code})
      setName(''); 
      setCode(''); 
      await fetchSubjects()
      Swal.fire({icon:'success', title:'Success', text:'Subject added successfully!', timer:1500, showConfirmButton:false}) 
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to add subject. Please try again.','error')
    }finally{
      setFormLoading(false)
    }
  }

  async function handleDelete(id){
    const result = await Swal.fire({title:'Are you sure?', text:"You won't be able to revert this!", icon:'warning', showCancelButton:true, confirmButtonColor:'#d33', cancelButtonColor:'#3085d6', confirmButtonText:'Yes, delete it!'})
    if(!result.isConfirmed) return
    try{ 
      await subjectsAPI.delete(id)
      await fetchSubjects()
      Swal.fire({icon:'success', title:'Deleted!', text:'Subject has been deleted.', timer:1500, showConfirmButton:false})
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to delete subject','error')
    }
  }

  async function handleEdit(id, oldName, oldCode){
    const { value: newName } = await Swal.fire({title:'Edit Subject Name', input:'text', inputValue:oldName, showCancelButton:true})
    if(!newName) return
    const { value: newCode } = await Swal.fire({title:'Edit Subject Code', input:'text', inputValue:oldCode, showCancelButton:true})
    if(!newCode) return
    try{
      await subjectsAPI.update(id, {name:newName, code:newCode})
      await fetchSubjects()
      Swal.fire({icon:'success', title:'Updated!', text:'Subject updated successfully.', timer:1500, showConfirmButton:false})
    }catch(e){
      console.error(e)
      Swal.fire('Error','Failed to update subject','error')
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <section className="card md:w-1/2 lg:w-1/3">
        <h2 className="text-lg font-bold text-gray-700 mb-4 border-b pb-2">Add Subject</h2>
        <form onSubmit={handleAdd} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Subject Name</label>
            <input required type="text" value={name} onChange={e=>setName(e.target.value)} disabled={formLoading} className="input-field" placeholder="Enter subject name" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Subject Code</label>
            <input required type="text" value={code} onChange={e=>setCode(e.target.value)} disabled={formLoading} className="input-field" placeholder="Enter subject code" />
          </div>
          <button type="submit" disabled={formLoading} className="btn-primary w-full disabled:opacity-50 disabled:cursor-not-allowed">{formLoading ? 'Saving...' : 'Save Subject'}</button>
        </form>
      </section>

      <section className="card overflow-hidden">
        <div className="card-header">
          <h2 className="text-lg font-bold text-gray-700">Subjects List</h2>
        </div>
        <div className="overflow-x-auto">
          {loading ? (
            <div className="px-6 py-8 text-center text-gray-400">Loading subjects...</div>
          ) : subjectsList.length === 0 ? (
            <div className="px-6 py-8 text-center text-gray-400 italic">No subjects found</div>
          ) : (
            <table className="min-w-full text-left table-auto">
              <thead className="bg-white text-gray-500 text-xs uppercase tracking-wider border-b">
                <tr>
                  <th className="px-6 py-3 font-medium">ID</th>
                  <th className="px-6 py-3 font-medium">Name</th>
                  <th className="px-6 py-3 font-medium">Code</th>
                  <th className="px-6 py-3 font-medium text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                {subjectsList.map(s=> (
                  <tr key={s.id} className="table-row-hover">
                    <td className="px-6 py-4 whitespace-nowrap text-gray-500 text-xs">{s.id}</td>
                    <td className="px-6 py-4 whitespace-nowrap font-semibold">{s.name}</td>
                    <td className="px-6 py-4 whitespace-nowrap"><span className="badge">{s.code}</span></td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                      <button onClick={()=>handleEdit(s.id, s.name, s.code)} className="text-blue-600 hover:text-blue-900 font-semibold">Edit</button>
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
