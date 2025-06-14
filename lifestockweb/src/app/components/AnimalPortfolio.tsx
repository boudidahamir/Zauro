 'use client'

import { useEffect, useState } from 'react'
import { supabase } from '../../../lib/supabaseClient'

interface AnimalNFT {
  id: string
  name: string
  age: number | null
  image_url: string | null
  status: 'alive' | 'sold'
  owner_id: string
  created_at: string
}

export default function AnimalPortfolio() {
  const [animals, setAnimals] = useState<AnimalNFT[]>([])
  const [loading, setLoading] = useState(true)
  const [userId, setUserId] = useState<string | null>(null)
  const [fetchError, setFetchError] = useState<string | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [newAnimal, setNewAnimal] = useState({ name: '', age: '', image: null as File | null })
  const [addError, setAddError] = useState<string | null>(null)

  useEffect(() => {
    const getUser = async () => {
      try {
        const { data, error } = await supabase.auth.getUser()
        if (error || !data.user) {
          setFetchError('Please log in to view your portfolio.')
          setLoading(false)
          return
        }
        setUserId(data.user.id)
        fetchAnimals(data.user.id)
      } catch {
        setFetchError('Failed to authenticate user.')
        setLoading(false)
      }
    }
    getUser()
  }, [])

  const fetchAnimals = async (uid: string) => {
    if (!uid) {
      setFetchError('No user ID provided.')
      setLoading(false)
      return
    }
    setLoading(true)
    setFetchError(null)
    try {
      const { data, error } = await supabase
        .from('animals')
        .select('*')
        .eq('owner_id', uid)
        .order('created_at', { ascending: false })

      if (error) throw error

      setAnimals(data as AnimalNFT[])
    } catch (error: any) {
      setFetchError(`Failed to load animals: ${error.message}`)
      setAnimals([])
    }
    setLoading(false)
  }

  const handleAddAnimal = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!userId) {
      setAddError('You must be logged in to add an animal.')
      return
    }
    if (!newAnimal.name.trim()) {
      setAddError('Animal name is required.')
      return
    }

    setAddError(null)
    try {
      let imageUrl = '/assets/cow.png' // Default image
      if (newAnimal.image) {
        const fileName = `${userId}/${Date.now()}_${newAnimal.image.name}`
        const { error: uploadError } = await supabase.storage
          .from('animal-images')
          .upload(fileName, newAnimal.image)
        if (uploadError) throw uploadError

        const { data: publicUrlData } = supabase.storage
          .from('animal-images')
          .getPublicUrl(fileName)
        imageUrl = publicUrlData.publicUrl
      }

      const { error } = await supabase.from('animals').insert({
        owner_id: userId,
        name: newAnimal.name,
        age: newAnimal.age ? parseInt(newAnimal.age) : null,
        image_url: imageUrl,
        status: 'alive',
        created_at: new Date().toISOString(),
      })

      if (error) throw error

      setIsModalOpen(false)
      setNewAnimal({ name: '', age: '', image: null })
      fetchAnimals(userId)
    } catch (error: any) {
      setAddError(`Failed to add animal: ${error.message}`)
    }
  }

  const activeAnimals = animals.filter((a) => a.status === 'alive')
  const pastAnimals = animals.filter((a) => a.status === 'sold')

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#E0E0E0] via-[#F5F5F5] to-[#C8D5C1] py-10 px-6">
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-10">
          <h2 className="text-3xl font-extrabold text-[#114232] text-center flex-1">
            🐄 Your Livestock Portfolio
          </h2>
          <button
            onClick={() => setIsModalOpen(true)}
            className="bg-[#114232] text-white px-4 py-2 rounded-lg hover:bg-[#1A3C34] transition"
          >
            Add Animal
          </button>
        </div>

        {loading ? (
          <div className="flex justify-center items-center text-[#114232] text-lg">
            Loading animals...
          </div>
        ) : fetchError ? (
          <p className="text-center text-red-600">{fetchError}</p>
        ) : (
          <>
            <section className="mb-10">
              <h3 className="text-xl font-semibold text-[#1A3C34] mb-4">🟢 Currently Owned</h3>
              {activeAnimals.length === 0 ? (
                <p className="text-sm text-gray-600">No active animals found.</p>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
                  {activeAnimals.map((animal) => (
                    <AnimalCard key={animal.id} animal={animal} />
                  ))}
                </div>
              )}
            </section>

            <section>
              <h3 className="text-xl font-semibold text-[#1A3C34] mb-4">⚪ Previously Owned</h3>
              {pastAnimals.length === 0 ? (
                <p className="text-sm text-gray-600">No previous animals found.</p>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
                  {pastAnimals.map((animal) => (
                    <AnimalCard key={animal.id} animal={animal} />
                  ))}
                </div>
              )}
            </section>
          </>
        )}
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 flex items-center justify-center z-50 bg-black bg-opacity-50 backdrop-blur-sm">
          <div className="bg-white rounded-2xl p-6 w-full max-w-md mx-4">
            <h3 className="text-xl font-bold text-[#114232] mb-4">Add New Animal</h3>
            <form onSubmit={handleAddAnimal}>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700">Name</label>
                <input
                  type="text"
                  value={newAnimal.name}
                  onChange={(e) => setNewAnimal({ ...newAnimal, name: e.target.value })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-[#114232] focus:ring-[#114232]"
                  required
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700">Age (years)</label>
                <input
                  type="number"
                  value={newAnimal.age}
                  onChange={(e) => setNewAnimal({ ...newAnimal, age: e.target.value })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-[#114232] focus:ring-[#114232]"
                  min="0"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700">Image (optional)</label>
                <input
                  type="file"
                  accept="image/*"
                  onChange={(e) => setNewAnimal({ ...newAnimal, image: e.target.files?.[0] || null })}
                  className="mt-1 block w-full text-sm text-gray-500"
                />
              </div>
              {addError && <p className="text-red-600 text-sm mb-4">{addError}</p>}
              <div className="flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => {
                    setIsModalOpen(false)
                    setAddError(null)
                    setNewAnimal({ name: '', age: '', image: null })
                  }}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#114232] text-white rounded-lg hover:bg-[#1A3C34]"
                >
                  Add Animal
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

function AnimalCard({ animal }: { animal: AnimalNFT }) {
  const defaultImage = '/assets/cow.png'

  const imageSrc =
    animal.image_url && animal.image_url.trim() !== '' && !animal.image_url.startsWith('blob:')
      ? animal.image_url
      : defaultImage

  return (
    <div className="bg-white border border-[#B0BEC5] rounded-2xl shadow-lg p-4 transition-transform hover:scale-105 hover:shadow-xl">
      <img
        src={imageSrc}
        alt={animal.name}
        className="w-full h-40 object-cover rounded-xl mb-4"
      />
      <h4 className="text-lg font-bold text-[#114232]">{animal.name}</h4>
      <p className="text-sm text-gray-700">
        Age: {animal.age !== null ? animal.age : 'N/A'} years
      </p>
      <span
        className={`inline-block mt-2 px-3 py-1 text-xs font-medium rounded-full ${
          animal.status === 'alive' ? 'bg-green-100 text-green-800' : 'bg-gray-200 text-gray-600'
        }`}
      >
        {animal.status === 'alive' ? 'Owned' : 'Sold'}
      </span>
    </div>
  )
}