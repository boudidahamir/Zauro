'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { supabase } from '../../../../lib/supabaseClient'

export default function SignupPage() {
  const router = useRouter()
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    password: '',
    confirmPassword: ''
  })
  const [agreeToTerms, setAgreeToTerms] = useState(false)
  const [error, setError] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: value
    }))
  }

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setIsLoading(true)

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

    if (!formData.fullName.trim()) {
      setError('Full name is required')
      setIsLoading(false)
      return
    }

    if (!formData.email.trim() || !emailRegex.test(formData.email)) {
      setError('Please enter a valid email address')
      setIsLoading(false)
      return
    }

    if (!formData.password) {
      setError('Password is required')
      setIsLoading(false)
      return
    }

    if (formData.password.length < 6) {
      setError('Password must be at least 6 characters long')
      setIsLoading(false)
      return
    }

    if (formData.password !== formData.confirmPassword) {
      setError("Passwords don't match")
      setIsLoading(false)
      return
    }

    if (!agreeToTerms) {
      setError("You must agree to the Terms of Service and Privacy Policy")
      setIsLoading(false)
      return
    }

    try {
      const { data, error: signupError } = await supabase.auth.signUp({
        email: formData.email,
        password: formData.password,
        options: {
          data: {
            full_name: formData.fullName
          }
        }
      })

      if (signupError) {
        setError(signupError.message)
        setIsLoading(false)
        return
      }

      router.push('/')
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err)
      setError(message || 'Signup failed. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#E0E0E0] via-[#B0BEC5] to-[#114232] relative overflow-hidden px-4">
      <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md p-10 border border-[#B0BEC5] relative overflow-hidden">

        {/* Illustration décorative */}
        <div className="absolute top-[-30px] left-[-30px] w-32 h-32 bg-[url('/leaf-icon.svg')] bg-contain bg-no-repeat opacity-10 pointer-events-none" />

        {/* Logo */}
        <div className="flex justify-center mb-4">
          <img src="/assets/logo.png" alt="Zauro Logo" className="h-16" />
        </div>

        <h2 className="text-3xl font-extrabold text-[#114232] text-center mb-6">
          Create Your Account
        </h2>

        <p className="text-center text-sm text-[#1A3C34] mb-6">
          Join Zauro and secure your livestock traceability.
        </p>

        {error && (
          <div className="mb-4 p-3 bg-red-100 text-red-700 rounded-md text-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSignup} className="flex flex-col gap-4">

          <input
            type="text"
            name="fullName"
            placeholder="Full Name"
            value={formData.fullName}
            onChange={handleChange}
            className="p-3 rounded-md border border-[#B0BEC5] focus:outline-none focus:ring-2 focus:ring-[#114232] text-[#1A3C34] placeholder:text-[#B0BEC5] w-full"
            required
          />

          <input
            type="email"
            name="email"
            placeholder="Email"
            value={formData.email}
            onChange={handleChange}
            className="p-3 rounded-md border border-[#B0BEC5] focus:outline-none focus:ring-2 focus:ring-[#114232] text-[#1A3C34] placeholder:text-[#B0BEC5] w-full"
            required
          />

          <input
            type="password"
            name="password"
            placeholder="Password (min 6 characters)"
            value={formData.password}
            onChange={handleChange}
            className="p-3 rounded-md border border-[#B0BEC5] focus:outline-none focus:ring-2 focus:ring-[#114232] text-[#1A3C34] placeholder:text-[#B0BEC5] w-full"
            minLength={6}
            required
          />

          <input
            type="password"
            name="confirmPassword"
            placeholder="Confirm Password"
            value={formData.confirmPassword}
            onChange={handleChange}
            className="p-3 rounded-md border border-[#B0BEC5] focus:outline-none focus:ring-2 focus:ring-[#114232] text-[#1A3C34] placeholder:text-[#B0BEC5] w-full"
            required
          />

          <label className="flex items-center text-sm text-[#1A3C34]">
            <input
              type="checkbox"
              checked={agreeToTerms}
              onChange={(e) => setAgreeToTerms(e.target.checked)}
              className="w-4 h-4 rounded border-gray-300 focus:ring-2 focus:ring-[#114232]"
              required
            />
            <span className="ml-2">
              I agree to the{' '}
              <Link href="/terms" className="text-[#114232] hover:underline">
                Terms of Service
              </Link>{' '}
              and{' '}
              <Link href="/privacy" className="text-[#114232] hover:underline">
                Privacy Policy
              </Link>
            </span>
          </label>

          <button
            type="submit"
            disabled={isLoading}
            className={`bg-[#114232] text-white py-3 rounded-md hover:bg-[#1A3C34] transition-colors font-semibold ${isLoading ? 'opacity-70 cursor-not-allowed' : ''}`}
          >
            {isLoading ? 'Creating account...' : 'Create Account'}
          </button>
        </form>

        <p className="mt-6 text-center text-sm text-[#1A3C34]">
          Already have an account?{' '}
          <Link href="/auth/login" className="text-[#114232] font-medium hover:underline">
            Sign In
          </Link>
        </p>
      </div>
    </div>
  )
}
