'use client'

import { useParams } from 'next/navigation'
import { useEffect, useState } from 'react'
import { supabase } from '../../../../lib/supabaseClient'

interface AnimalNFT {
  id: string
  name: string
  age: number | null
  image_url: string
  status: string
  metadata?: { [key: string]: any }
}

export default function AnimalDetailsPage() {
  const params = useParams()
  const id = params.id
  const [animal, setAnimal] = useState<AnimalNFT | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!id) return
    const fetchAnimal = async () => {
      setLoading(true)
      const { data, error } = await supabase
        .from('animals')
        .select('*')
        .eq('id', id)
        .single()

      if (error) {
        console.error('Error fetching animal:', error.message)
        setAnimal(null)
      } else {
        setAnimal(data as AnimalNFT)
      }
      setLoading(false)
    }
    fetchAnimal()
  }, [id])

  if (loading) return <p className="text-center mt-10">Loading details...</p>
  if (!animal) return <p className="text-center mt-10">Animal not found.</p>

  return (
    <div className="min-h-screen bg-[#E0E0E0] px-6 py-10 text-[#1A3C34] max-w-3xl mx-auto">
      <button
        onClick={() => window.history.back()}
        className="mb-6 text-[#114232] underline"
      >
        ← Back
      </button>
      <div className="bg-white rounded-2xl shadow-md p-6 border border-[#B0BEC5]">
        <img
          src={animal.image_url}
          alt={animal.name}
          className="w-full h-64 object-cover rounded-md mb-6"
        />
        <h1 className="text-3xl font-bold mb-2">{animal.name}</h1>
        <p className="text-lg mb-1">Age: {animal.age ?? 'N/A'} years</p>
        <p className="text-lg mb-1">
          Status:{' '}
          <span
            className={`font-semibold ${
              animal.status === 'alive' ? 'text-green-700' : 'text-gray-600'
            }`}
          >
            {animal.status === 'alive' ? 'Owned' : animal.status}
          </span>
        </p>
        {animal.metadata && (
          <div className="mt-4">
            <h2 className="text-xl font-semibold mb-2">Additional Information</h2>
            <pre className="bg-gray-100 p-4 rounded text-sm overflow-x-auto">
              {JSON.stringify(animal.metadata, null, 2)}
            </pre>
          </div>
        )}
      </div>
    </div>
  )
}
