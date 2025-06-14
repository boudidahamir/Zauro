'use client'

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import {
  FaWallet, FaChartPie, FaStore, FaSignOutAlt, FaBell, FaHorse, FaUser
} from "react-icons/fa";
import { supabase } from '../../lib/supabaseClient';
import PortfolioPage from './portfolio/page';
import Marketplace from './marketplace/page';
import ProfilePage from './auth/profile/page';

interface Notification {
  id: string;
  text: string;
  type: 'warning' | 'info' | 'success';
}

interface Livestock {
  id: string;
  breed: string;
  healthScore: number;
  marketValue: number;
  owned: boolean;
}

export default function Home() {
  const router = useRouter();
  const [userName, setUserName] = useState<string>('User');
  const [walletAddress, setWalletAddress] = useState<string>('0x3FaB...9e1D');
  const [showWalletCard, setShowWalletCard] = useState<boolean>(false);
  const [activeTab, setActiveTab] = useState<'home' | 'portfolio' | 'marketplace' | 'profile'>('home');

  const totalNFTs = 2;
  const marketValue = 1350;

  const notifications: Notification[] = [
    { id: '1', text: '⚠️ New disease alert in your region', type: 'warning' },
    { id: '2', text: '💰 Loan offer available: up to $5,000', type: 'info' },
    { id: '3', text: '🛒 3 new animals listed on marketplace', type: 'success' },
  ];

  const livestock: Livestock[] = [
    { id: '1', breed: 'Zebu', healthScore: 87, marketValue: 2500, owned: true },
    { id: '2', breed: 'Barbary Sheep', healthScore: 91, marketValue: 1700, owned: true },
    { id: '3', breed: 'Arouss', healthScore: 75, marketValue: 2100, owned: true },
  ];

  useEffect(() => {
    const checkUser = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        router.push('/auth/login');
      } else {
        setUserName(user.email ?? 'User');
      }
    };
    checkUser();
  }, [router]);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    router.push('/auth/login');
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 text-gray-900 font-sans relative">
      {/* Header */}
      <header className="bg-white/95 backdrop-blur-sm shadow-md py-4 px-6 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-3">
            <img src="/assets/logo.png" alt="Zauro Logo" className="h-10 w-10 object-contain" />
            <h1 className="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-emerald-600 to-teal-500">
              Zauro
            </h1>
          </div>
          <nav className="flex items-center gap-10">
            <button
              onClick={() => setActiveTab('home')}
              className={`text-lg transition font-medium ${
                activeTab === 'home' ? 'text-emerald-700 font-bold' : 'text-gray-600 hover:text-emerald-600'
              }`}
            >
              Home
            </button>
            <button
              onClick={() => setActiveTab('portfolio')}
              className={`text-lg transition font-medium ${
                activeTab === 'portfolio' ? 'text-emerald-700 font-bold' : 'text-gray-600 hover:text-emerald-600'
              }`}
            >
              Portfolio
            </button>
            <button
              onClick={() => setActiveTab('marketplace')}
              className={`text-lg transition font-medium ${
                activeTab === 'marketplace' ? 'text-emerald-700 font-bold' : 'text-gray-600 hover:text-emerald-600'
              }`}
            >
              Marketplace
            </button>
            <button
              onClick={() => setActiveTab('profile')}
              className={`text-lg transition font-medium ${
                activeTab === 'profile' ? 'text-emerald-700 font-bold' : 'text-gray-600 hover:text-emerald-600'
              }`}
            >
              Profile
            </button>

            <button
              onClick={() => setShowWalletCard(!showWalletCard)}
              className="flex items-center gap-2 bg-emerald-100 text-emerald-700 px-5 py-2 rounded-full hover:bg-emerald-200 transition"
            >
              <FaWallet size={20} />
              <span className="font-mono text-sm">{walletAddress}</span>
            </button>
            <button onClick={handleLogout} className="flex items-center gap-2 text-rose-600 hover:text-rose-700 transition">
              <FaSignOutAlt size={20} /> Logout
            </button>
          </nav>
        </div>
      </header>

      {/* Main Content */}
      <main className={`max-w-7xl mx-auto p-8 space-y-16 relative ${showWalletCard ? 'filter blur-sm brightness-90' : ''}`}>
        {activeTab === 'home' && (
          <>
            {/* Welcome */}
            <section className="bg-white rounded-2xl shadow-lg p-8 border border-gray-100/50">
              <h2 className="text-3xl font-bold text-emerald-800 mb-4">Welcome back, {userName} 👋</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="bg-emerald-50 p-6 rounded-xl">
                  <p className="text-5xl font-bold text-emerald-700">{totalNFTs}</p>
                  <p className="text-sm text-gray-500 uppercase tracking-wider mt-2">Livestock NFTs</p>
                </div>
                <div className="bg-emerald-50 p-6 rounded-xl">
                  <p className="text-5xl font-bold text-emerald-700">${marketValue.toLocaleString()}</p>
                  <p className="text-sm text-gray-500 uppercase tracking-wider mt-2">Market Value</p>
                </div>
              </div>
            </section>

            {/* Notifications */}
            <section className="space-y-6">
              <h3 className="text-2xl font-semibold text-emerald-800">Notifications</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {notifications.map((note) => (
                  <div
                    key={note.id}
                    className={`p-5 rounded-xl shadow-sm border transform transition hover:-translate-y-1 ${
                      note.type === 'warning'
                        ? 'border-rose-200 bg-rose-50'
                        : note.type === 'info'
                        ? 'border-teal-200 bg-teal-50'
                        : 'border-emerald-100 bg-emerald-50'
                    }`}
                  >
                    <div className="flex items-center gap-4">
                      <FaBell
                        className={`text-xl ${
                          note.type === 'warning' ? 'text-rose-600' : note.type === 'info' ? 'text-teal-600' : 'text-emerald-600'
                        }`}
                      />
                      <span className="text-gray-800 text-lg">{note.text}</span>
                    </div>
                  </div>
                ))}
              </div>
            </section>

            {/* Quick Actions */}
            <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              <div onClick={() => setActiveTab('portfolio')}>
                <ActionBtn icon={<FaChartPie size={24} />} label="Portfolio" color="bg-emerald-600" />
              </div>
              <div onClick={() => setActiveTab('marketplace')}>
                <ActionBtn icon={<FaStore size={24} />} label="Marketplace" color="bg-emerald-600" />
              </div>
              <div onClick={() => setActiveTab('profile')}>
                <ActionBtn icon={<FaUser size={24} />} label="Profile" color="bg-emerald-600" />
              </div>
            </section>

            {/* Livestock */}
            <section>
              <h3 className="text-2xl font-semibold text-emerald-800 mb-8">Your Livestock</h3>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                {livestock.map((animal) => (
                  <div
                    key={animal.id}
                    className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100/50 hover:shadow-xl transition-transform hover:-translate-y-2"
                  >
                    <div className="flex justify-center mb-6">
                      <FaHorse className="text-6xl text-emerald-500" />
                    </div>
                    <h4 className="text-xl font-semibold text-emerald-900 text-center mb-4">{animal.breed}</h4>
                    <p className="text-gray-600 mb-2">Health: <span className="text-emerald-600 font-semibold">{animal.healthScore}%</span></p>
                    <p className="text-gray-600 mb-2">Value: <span className="text-emerald-600 font-semibold">${animal.marketValue.toLocaleString()}</span></p>
                    <p className={`font-semibold ${animal.owned ? 'text-emerald-600' : 'text-rose-600'}`}>
                      Status: {animal.owned ? 'Owned' : 'Not Owned'}
                    </p>
                  </div>
                ))}
              </div>
            </section>
          </>
        )}

        {activeTab === 'portfolio' && <PortfolioPage />}

        {activeTab === 'marketplace' && <Marketplace />}

        {activeTab === 'profile' && <ProfilePage />}
      </main>

      {/* Wallet Popup Modal */}
      {showWalletCard && (
        <div
          onClick={() => setShowWalletCard(false)}
          className="fixed inset-0 z-50 flex items-center justify-center"
        >
          {/* Note : Overlay noir supprimé pour ne pas assombrir */}
          {/* Modal content */}
          <section
            onClick={(e) => e.stopPropagation()}
            className="relative bg-white rounded-2xl shadow-xl p-8 max-w-md w-full z-10"
          >
            <h3 className="text-2xl font-semibold text-emerald-800 mb-4 flex items-center gap-2">
              <FaWallet className="text-emerald-600" /> My Wallet
            </h3>
            <div className="space-y-3">
              <p className="text-gray-800 text-lg flex items-center gap-2">
                <span className="font-semibold">Address:</span>
                <span className="font-mono bg-gray-100/50 px-2 py-1 rounded">{walletAddress}</span>
              </p>
              <p className="text-gray-800 text-lg">
                <span className="font-semibold">Total NFTs:</span>
                <span className="text-emerald-700 font-semibold ml-2">{totalNFTs}</span>
              </p>
              <p className="text-gray-800 text-lg">
                <span className="font-semibold">Estimated Value:</span>
                <span className="text-emerald-700 font-semibold ml-2">${marketValue.toLocaleString()}</span>
              </p>
            </div>
            <button
              onClick={() => setShowWalletCard(false)}
              className="mt-4 text-rose-600 hover:text-rose-700 transition flex items-center gap-2"
            >
              <FaSignOutAlt size={16} /> Close
            </button>
          </section>
        </div>
      )}
    </div>
  );
}

// Action Button Component
function ActionBtn({ icon, label, color }: { icon: React.ReactNode; label: string; color: string }) {
  return (
    <div
      className={`${color} text-white py-4 px-8 rounded-xl hover:bg-emerald-700 transition-all font-semibold flex items-center justify-center gap-3 transform hover:-translate-y-1 shadow-md cursor-pointer`}
    >
      {icon}
      <span className="text-lg">{label}</span>
    </div>
  );
}
