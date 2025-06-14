'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '../../../../lib/supabaseClient'
import { FaSignInAlt } from 'react-icons/fa'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [formErrors, setFormErrors] = useState({ email: '', password: '' })

  const validateForm = () => {
    let valid = true
    const newErrors = { email: '', password: '' }

    if (!email) {
      newErrors.email = 'Email is required'
      valid = false
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      newErrors.email = 'Email is invalid'
      valid = false
    }

    if (!password) {
      newErrors.password = 'Password is required'
      valid = false
    } else if (password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters'
      valid = false
    }

    setFormErrors(newErrors)
    return valid
  }

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    if (!validateForm()) return

    try {
      const { data, error: supabaseError } = await supabase.auth.signInWithPassword({
        email,
        password
      })

      if (supabaseError) {
        setError(supabaseError.message || 'Login failed. Please try again.')
      } else {
        router.push('/')
      }
    } catch {
      setError('An unexpected error occurred. Please try again.')
    }
  }

  return (
<div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#E0E0E0] via-[#B0BEC5] to-[#114232] relative overflow-hidden px-4">
      
      {/* Background Texture Layer */}
      <div className="absolute inset-0 bg-[url('/assets/leaf-pattern.svg')] bg-contain bg-no-repeat opacity-5 pointer-events-none" />

      {/* Glass Card */}
      <div className="relative z-10 backdrop-blur-xl bg-white/70 border border-white/30 shadow-xl rounded-3xl w-full max-w-md p-10 animate-fade-in">

        {/* Logo & Heading */}
        <div className="flex flex-col items-center gap-2 mb-6">
          <img src="/assets/logo.png" alt="Zauro Logo" className="h-14 object-contain" />
          <h2 className="text-3xl font-extrabold text-[#114232] text-center drop-shadow-sm">
            Welcome back to Zauro
          </h2>
          <p className="text-sm text-[#1A3C34] text-center">
            Secure traceability of your livestock, always.
          </p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-100 border border-red-300 text-red-700 rounded-md text-sm">
            {error}
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleLogin} className="space-y-5">
          <div>
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={e => {
                setEmail(e.target.value)
                if (formErrors.email) setFormErrors({ ...formErrors, email: '' })
              }}
              className={`w-full px-4 py-3 rounded-xl border ${
                formErrors.email ? 'border-red-500' : 'border-[#B0BEC5]'
              } focus:ring-2 focus:ring-[#0288D1] outline-none text-[#1A3C34] placeholder-[#90A4AE] bg-white/80 backdrop-blur-sm`}
            />
            {formErrors.email && <p className="mt-1 text-xs text-red-600">{formErrors.email}</p>}
          </div>

          <div>
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={e => {
                setPassword(e.target.value)
                if (formErrors.password) setFormErrors({ ...formErrors, password: '' })
              }}
              className={`w-full px-4 py-3 rounded-xl border ${
                formErrors.password ? 'border-red-500' : 'border-[#B0BEC5]'
              } focus:ring-2 focus:ring-[#0288D1] outline-none text-[#1A3C34] placeholder-[#90A4AE] bg-white/80 backdrop-blur-sm`}
            />
            {formErrors.password && (
              <p className="mt-1 text-xs text-red-600">{formErrors.password}</p>
            )}
          </div>

          <button
            type="submit"
            className="w-full bg-[#114232] text-white py-3 rounded-xl flex items-center justify-center gap-2 hover:bg-[#1A3C34] transition-all shadow-md"
          >
            <FaSignInAlt />
            Login to Zauro
          </button>

          <div className="text-center text-sm text-[#1A3C34]">
            Don’t have an account?{' '}
            <a href="/auth/signup" className="text-[#114232] font-medium hover:underline">
              Sign up
            </a>
          </div>

          <div className="text-center text-sm mt-1">
            <a href="/auth/forgot-password" className="text-[#114232] hover:underline">
              Forgot your password?
            </a>
          </div>
        </form>
      </div>
    </div>
  )
}
