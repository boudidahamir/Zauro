'use client'

import { useEffect, useState } from 'react'
import { supabase } from '../../../../lib/supabaseClient'

interface UserProfile {
  email: string | null
}

export default function ProfilePage() {
  const [profile, setProfile] = useState<UserProfile>({  email: null })
  const [animalCount, setAnimalCount] = useState<number>(0)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadProfileAndCount() {
      setLoading(true)

      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser()

      if (authError || !user) {
        console.error('User not authenticated:', authError)
        setLoading(false)
        return
      }

      // Récupérer les données du profil
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('full_name, email')
        .eq('id', user.id)
        .single()

      if (profileError) {
        console.error('Error fetching profile:', profileError)
        setProfile({  email: user.email ?? null })
      } else {
        setProfile({
         
          email: profileData?.email ?? null,
        })
      }

      // Compter les animaux
      const { count, error: countError } = await supabase
        .from('animals')
        .select('*', { count: 'exact', head: true })
        .eq('owner_id', user.id)

      if (countError) {
        console.error('Error counting animals:', countError)
      } else {
        setAnimalCount(count ?? 0)
      }

      setLoading(false)
    }

    loadProfileAndCount()
  }, [])

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#E0E0E0] text-[#114232] text-lg font-medium">
        Loading profile...
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#E0E0E0] via-[#C8D5C1] to-[#114232] p-6">
      <div className="bg-white rounded-3xl shadow-xl w-full max-w-md p-8 border border-[#B0BEC5]">
        <h1 className="text-3xl font-extrabold text-center text-[#114232] mb-6">
          User Profile
        </h1>
        <div className="mb-4">
          <label className="block text-sm font-semibold text-[#1A3C34] mb-1">Email</label>
          <p className="text-[#4B4B4B]">{profile.email ?? 'No email available'}</p>
        </div>

        <div>
          <label className="block text-sm font-semibold text-[#1A3C34] mb-1">Number of Animals Owned</label>
          <p className="text-[#4B4B4B]">{animalCount}</p>
        </div>
      </div>
    </div>
  )
}
