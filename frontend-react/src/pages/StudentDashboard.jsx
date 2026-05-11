import React from 'react'

export default function StudentDashboard(){
  const student = (() => {
    try {
      return JSON.parse(localStorage.getItem('studentUser') || 'null')
    } catch {
      return null
    }
  })()

  const subjects = student?.subjects || []

  return (
    <div className="space-y-6">
      <section className="card">
        <h2 className="text-lg font-bold text-gray-700 mb-2">My Profile</h2>
        <p className="text-gray-600"><span className="font-semibold">Name:</span> {student?.name || 'Student'}</p>
        <p className="text-gray-600"><span className="font-semibold">Email:</span> {student?.email || 'N/A'}</p>
        <p className="text-gray-600"><span className="font-semibold">Role:</span> {student?.role || 'STUDENT'}</p>
      </section>

      <section className="card overflow-hidden">
        <div className="card-header">
          <h2 className="text-lg font-bold text-gray-700">My Subjects</h2>
        </div>
        <div className="overflow-x-auto">
          {subjects.length === 0 ? (
            <div className="px-6 py-8 text-center text-gray-400 italic">No subjects assigned yet</div>
          ) : (
            <table className="min-w-full text-left table-auto">
              <thead className="bg-white text-gray-500 text-xs uppercase tracking-wider border-b">
                <tr>
                  <th className="px-6 py-4 font-medium">Subject Name</th>
                  <th className="px-6 py-4 font-medium">Code</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                {subjects.map((subject) => (
                  <tr key={subject.id} className="hover:bg-gray-50 transition">
                    <td className="px-6 py-4 whitespace-nowrap font-medium text-gray-900">{subject.name}</td>
                    <td className="px-6 py-4 whitespace-nowrap"><span className="badge">{subject.code}</span></td>
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