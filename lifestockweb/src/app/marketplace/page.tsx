'use client'

import { useState } from 'react'
import { FaHorse, FaMapMarkerAlt, FaHeartbeat, FaCoins } from 'react-icons/fa'

interface Animal {
  id: string
  breed: string
  age: number
  healthScore: number
  region: string
  price: number
  imageUrl: string
}

const dummyData: Animal[] = [
  { id: '1', breed: 'Zebu', age: 2, healthScore: 88, region: 'Dakkar', price: 2300, imageUrl: '/assets/cow.png' },
  { id: '2', breed: 'Arouss', age: 3, healthScore: 92, region: 'Niger', price: 2500, imageUrl: '/assets/cow.png' },
  { id: '3', breed: 'Barbary Sheep', age: 1, healthScore: 79, region: 'senegal', price: 1800, imageUrl: '/assets/cow.png' },
]

export default function Marketplace() {
  const [filters, setFilters] = useState({ region: '', breed: '', minScore: 0 })

  const filteredAnimals = dummyData.filter(a =>
    (filters.region === '' || a.region === filters.region) &&
    (filters.breed === '' || a.breed === filters.breed) &&
    a.healthScore >= filters.minScore
  )

  return (
    <div className="min-h-screen bg-gray-50 text-gray-800 p-8">
      <h1 className="text-4xl font-bold text-[#114232] mb-8 text-center">🐮 Livestock Marketplace</h1>

      {/* Filtres */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 mb-10 max-w-5xl mx-auto">
        <div>
          <label htmlFor="filter-region" className="block mb-1 font-semibold text-gray-700">🌍 Region</label>
          <select
            id="filter-region"
            value={filters.region}
            onChange={(e) => setFilters(prev => ({ ...prev, region: e.target.value }))}
            className="border border-gray-300 p-2 rounded-xl w-full"
          >
            <option value="">All Regions</option>
            <option value="Sénégal">Sénégal</option>
            <option value="Niger">Niger</option>
            <option value="Dakkar">Dakkar</option>
          </select>
        </div>

        <div>
          <label htmlFor="filter-breed" className="block mb-1 font-semibold text-gray-700">🐐 Breed</label>
          <select
            id="filter-breed"
            value={filters.breed}
            onChange={(e) => setFilters(prev => ({ ...prev, breed: e.target.value }))}
            className="border border-gray-300 p-2 rounded-xl w-full"
          >
            <option value="">All Breeds</option>
            <option value="Zebu">Zebu</option>
            <option value="Arouss">Arouss</option>
            <option value="Barbary Sheep">Barbary Sheep</option>
          </select>
        </div>

        <div>
          <label htmlFor="filter-minScore" className="block mb-1 font-semibold text-gray-700">❤️ Health Score ≥</label>
          <input
            id="filter-minScore"
            type="number"
            min={0}
            max={100}
            value={filters.minScore}
            onChange={(e) => setFilters(prev => ({ ...prev, minScore: parseInt(e.target.value) || 0 }))}
            placeholder="0"
            className="border border-gray-300 p-2 rounded-xl w-full"
          />
        </div>
      </div>

      {/* Liste des animaux */}
      {filteredAnimals.length === 0 ? (
        <p className="text-center text-gray-500 mt-20 text-lg">
          No animals found matching your filters.
        </p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8 max-w-7xl mx-auto">
          {filteredAnimals.map(animal => (
            <div
              key={animal.id}
              className="bg-white rounded-2xl shadow-lg p-6 border border-gray-200 hover:shadow-xl transition-all"
            >
              <img
                src={animal.imageUrl}
                alt={animal.breed}
                className="w-full h-44 object-cover rounded-lg mb-4"
              />
              <h3 className="text-xl font-bold text-[#114232]">{animal.breed}</h3>
              <p className="text-gray-600 flex items-center gap-2"><FaMapMarkerAlt /> {animal.region}</p>
              <p className="text-gray-600 flex items-center gap-2"><FaHorse /> Age: {animal.age} years</p>
              <p className="text-gray-600 flex items-center gap-2"><FaHeartbeat /> Health Score: {animal.healthScore}%</p>
              <p className="text-[#0288D1] text-lg mt-3 font-bold flex items-center gap-2"><FaCoins /> {animal.price} HBAR</p>

              <button
                onClick={() => alert(`🔐 Smart Contract Triggered for ${animal.breed}`)}
                className="mt-4 bg-[#114232] hover:bg-[#0c2e26] text-white py-2 px-4 rounded-full w-full font-semibold"
              >
                Buy Now
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
