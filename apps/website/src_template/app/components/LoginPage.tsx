import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import chiiLogo from 'figma:asset/dd095089ca513f2d1125400bc19c749527ae2030.png';

interface LoginPageProps {
  onLoginSuccess: (user: { username: string; email: string }) => void;
}

export function LoginPage({ onLoginSuccess }: LoginPageProps) {
  const [isLogin, setIsLogin] = useState(true);
  const [showForgotPassword, setShowForgotPassword] = useState(false);
  const [showRequestAccess, setShowRequestAccess] = useState(false);
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    username: '',
  });
  const [forgotPasswordEmail, setForgotPasswordEmail] = useState('');
  const [requestAccessData, setRequestAccessData] = useState({
    fullName: '',
    email: '',
    username: '',
    department: '',
    reason: '',
  });

  // INTEGRATION POINT: handleLogin - Called when user submits login form
  // TEST CREDENTIALS: username: "user", password: "12345"
  const handleLogin = (email: string, password: string) => {
    console.log('LOGIN ATTEMPT:', { email, password });
    
    // Test credentials
    if ((email === 'user' || email === 'user@cydonian.com') && password === '12345') {
      // Successful login
      onLoginSuccess({ 
        username: 'user',
        email: 'user@cydonian.com'
      });
      return;
    }
    
    // TODO: Connect to authentication service
    // Expected: POST /api/auth/login
    // Body: { email, password }
    // Response: { token, user }
    
    alert('Invalid credentials. Try username: "user" and password: "12345"');
  };

  // INTEGRATION POINT: handleSignup - Called when user submits signup form
  const handleSignup = (email: string, password: string, confirmPassword: string, username: string) => {
    console.log('SIGNUP ATTEMPT:', { email, password, confirmPassword, username });
    
    if (password !== confirmPassword) {
      alert('Passwords do not match');
      return;
    }
    
    // TODO: Connect to registration service
    // Expected: POST /api/auth/register
    // Body: { email, password, username }
    // Response: { success, message }
    
    alert('Account created successfully! You can now log in.');
    setIsLogin(true);
  };

  // INTEGRATION POINT: handleForgotPassword - Called when user requests password reset
  const handleForgotPassword = (email: string) => {
    console.log('PASSWORD RESET REQUEST:', { email });
    // TODO: Connect to password reset service
    // Expected: POST /api/auth/forgot-password
    // Body: { email }
    // Response: { success, message }
    
    // Mock success feedback
    alert(`Password reset link has been sent to ${email}`);
    setShowForgotPassword(false);
    setForgotPasswordEmail('');
  };

  // INTEGRATION POINT: handleRequestAccess - Called when user requests system access
  const handleRequestAccess = (data: typeof requestAccessData) => {
    console.log('ACCESS REQUEST:', data);
    // TODO: Connect to access request service
    // Expected: POST /api/auth/request-access
    // Body: { fullName, email, username, department, reason }
    // Response: { success, message, requestId }
    
    // Mock success feedback
    alert(`Access request submitted successfully! You will receive an email at ${data.email} once approved.`);
    setShowRequestAccess(false);
    setRequestAccessData({
      fullName: '',
      email: '',
      username: '',
      department: '',
      reason: '',
    });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (isLogin) {
      handleLogin(formData.email, formData.password);
    } else {
      handleSignup(formData.email, formData.password, formData.confirmPassword, formData.username);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleForgotPasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    handleForgotPassword(forgotPasswordEmail);
  };

  const handleRequestAccessSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    handleRequestAccess(requestAccessData);
  };

  const handleRequestAccessChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setRequestAccessData({ ...requestAccessData, [e.target.name]: e.target.value });
  };

  const switchToLogin = () => {
    setIsLogin(true);
  };

  const switchToSignup = () => {
    setIsLogin(false);
  };

  const openRequestAccessModal = () => {
    setShowRequestAccess(true);
  };

  const closeRequestAccessModal = () => {
    setShowRequestAccess(false);
  };

  const openForgotPasswordModal = () => {
    setShowForgotPassword(true);
  };

  const closeForgotPasswordModal = () => {
    setShowForgotPassword(false);
  };

  return (
    <div className="min-h-screen w-full bg-[#0a0e1a] relative overflow-hidden flex items-center justify-center">
      {/* Animated background grid */}
      <div className="absolute inset-0 opacity-15">
        <div className="absolute inset-0" style={{
          backgroundImage: `
            linear-gradient(rgba(0, 165, 255, 0.1) 1px, transparent 1px),
            linear-gradient(90deg, rgba(0, 165, 255, 0.1) 1px, transparent 1px)
          `,
          backgroundSize: '50px 50px',
        }} />
      </div>

      {/* Glowing orbs */}
      <motion.div
        className="absolute top-20 left-20 w-96 h-96 bg-blue-500/15 rounded-full blur-3xl"
        animate={{
          scale: [1, 1.2, 1],
          opacity: [0.2, 0.4, 0.2],
        }}
        transition={{
          duration: 8,
          repeat: Infinity,
          ease: "easeInOut"
        }}
      />
      <motion.div
        className="absolute bottom-20 right-20 w-96 h-96 bg-blue-400/15 rounded-full blur-3xl"
        animate={{
          scale: [1.2, 1, 1.2],
          opacity: [0.4, 0.2, 0.4],
        }}
        transition={{
          duration: 8,
          repeat: Infinity,
          ease: "easeInOut"
        }}
      />

      {/* Spinning Logo Badge - Bottom Left */}
      <motion.div
        className="fixed bottom-8 left-8 z-50"
        initial={{ opacity: 0, scale: 0 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.8, delay: 0.5 }}
      >
        <div className="relative w-24 h-24">
          {/* Outer spinning ring */}
          <motion.div
            className="absolute inset-0 rounded-full border-2 border-[#00a5ff]/30 border-t-[#00a5ff]"
            animate={{ rotate: 360 }}
            transition={{
              duration: 4,
              repeat: Infinity,
              ease: "linear"
            }}
          />
          
          {/* Middle spinning ring - opposite direction */}
          <motion.div
            className="absolute inset-2 rounded-full border-2 border-blue-500/20 border-b-blue-500/60"
            animate={{ rotate: -360 }}
            transition={{
              duration: 6,
              repeat: Infinity,
              ease: "linear"
            }}
          />
          
          {/* Logo container */}
          <div className="absolute inset-3 bg-[#0a0e1a]/80 backdrop-blur-sm rounded-full border border-[#00a5ff]/40 flex items-center justify-center shadow-lg shadow-blue-500/20">
            <motion.img
              src={chiiLogo}
              alt="CHII"
              className="w-12 h-12 object-contain"
              animate={{
                filter: [
                  'drop-shadow(0 0 2px rgba(0, 165, 255, 0.5))',
                  'drop-shadow(0 0 8px rgba(0, 165, 255, 0.8))',
                  'drop-shadow(0 0 2px rgba(0, 165, 255, 0.5))',
                ],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            />
          </div>
          
          {/* Pulsing glow */}
          <motion.div
            className="absolute inset-0 bg-blue-500/20 rounded-full blur-xl"
            animate={{
              scale: [1, 1.3, 1],
              opacity: [0.3, 0.6, 0.3],
            }}
            transition={{
              duration: 3,
              repeat: Infinity,
              ease: "easeInOut"
            }}
          />
        </div>
      </motion.div>

      {/* Forgot Password Modal */}
      <AnimatePresence>
        {showForgotPassword && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
              onClick={() => setShowForgotPassword(false)}
            />
            
            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="fixed inset-0 z-50 flex items-center justify-center p-6"
            >
              <div className="relative max-w-md w-full">
                {/* Modal glow */}
                <div className="absolute -inset-1 bg-gradient-to-r from-blue-500/20 to-[#00a5ff]/20 rounded-2xl blur-sm" />
                
                {/* Modal content */}
                <div className="relative bg-[#151922]/95 backdrop-blur-xl border border-[#00a5ff]/30 rounded-2xl p-8">
                  <h2 className="text-2xl font-semibold text-white mb-2">Reset Password</h2>
                  <p className="text-[#c0c5ce] text-sm mb-6">
                    Enter your email address and we'll send you a link to reset your password.
                  </p>
                  
                  <form onSubmit={handleForgotPasswordSubmit}>
                    <div className="mb-6">
                      <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                        Email Address
                      </label>
                      <div className="relative">
                        <input
                          type="email"
                          value={forgotPasswordEmail}
                          onChange={(e) => setForgotPasswordEmail(e.target.value)}
                          className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                          placeholder="user@cydonian.com"
                          required
                        />
                        <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                      </div>
                    </div>
                    
                    <div className="flex gap-3">
                      <button
                        type="button"
                        onClick={() => setShowForgotPassword(false)}
                        className="flex-1 bg-gray-800/50 text-[#c0c5ce] py-3 rounded-lg font-semibold hover:bg-gray-800/70 transition-all"
                      >
                        Cancel
                      </button>
                      <button
                        type="submit"
                        className="flex-1 bg-gradient-to-r from-[#00a5ff] to-blue-500 text-white py-3 rounded-lg font-semibold shadow-lg shadow-blue-500/30 hover:shadow-blue-500/50 transition-all"
                      >
                        Send Reset Link
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Request Access Modal */}
      <AnimatePresence>
        {showRequestAccess && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
              onClick={() => setShowRequestAccess(false)}
            />
            
            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="fixed inset-0 z-50 flex items-center justify-center p-6"
            >
              <div className="relative max-w-md w-full">
                {/* Modal glow */}
                <div className="absolute -inset-1 bg-gradient-to-r from-blue-500/20 to-[#00a5ff]/20 rounded-2xl blur-sm" />
                
                {/* Modal content */}
                <div className="relative bg-[#151922]/95 backdrop-blur-xl border border-[#00a5ff]/30 rounded-2xl p-8">
                  <h2 className="text-2xl font-semibold text-white mb-2">Request Access</h2>
                  <p className="text-[#c0c5ce] text-sm mb-6">
                    Fill out the form below to request access to the system.
                  </p>
                  
                  <form onSubmit={handleRequestAccessSubmit}>
                    <div className="mb-6">
                      <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                        Full Name
                      </label>
                      <div className="relative">
                        <input
                          type="text"
                          name="fullName"
                          value={requestAccessData.fullName}
                          onChange={handleRequestAccessChange}
                          className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                          placeholder="Enter your full name"
                          required
                        />
                        <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                      </div>
                    </div>
                    
                    <div className="mb-6">
                      <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                        Email Address
                      </label>
                      <div className="relative">
                        <input
                          type="email"
                          name="email"
                          value={requestAccessData.email}
                          onChange={handleRequestAccessChange}
                          className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                          placeholder="user@cydonian.com"
                          required
                        />
                        <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                      </div>
                    </div>
                    
                    <div className="mb-6">
                      <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                        Username
                      </label>
                      <div className="relative">
                        <input
                          type="text"
                          name="username"
                          value={requestAccessData.username}
                          onChange={handleRequestAccessChange}
                          className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                          placeholder="Enter your username"
                          required
                        />
                        <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                      </div>
                    </div>
                    
                    <div className="mb-6">
                      <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                        Department
                      </label>
                      <div className="relative">
                        <input
                          type="text"
                          name="department"
                          value={requestAccessData.department}
                          onChange={handleRequestAccessChange}
                          className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                          placeholder="Enter your department"
                          required
                        />
                        <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                      </div>
                    </div>
                    
                    <div className="mb-6">
                      <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                        Reason for Access
                      </label>
                      <div className="relative">
                        <textarea
                          name="reason"
                          value={requestAccessData.reason}
                          onChange={handleRequestAccessChange}
                          className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                          placeholder="Enter the reason for your access request"
                          required
                        />
                        <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                      </div>
                    </div>
                    
                    <div className="flex gap-3">
                      <button
                        type="button"
                        onClick={() => setShowRequestAccess(false)}
                        className="flex-1 bg-gray-800/50 text-[#c0c5ce] py-3 rounded-lg font-semibold hover:bg-gray-800/70 transition-all"
                      >
                        Cancel
                      </button>
                      <button
                        type="submit"
                        className="flex-1 bg-gradient-to-r from-[#00a5ff] to-blue-500 text-white py-3 rounded-lg font-semibold shadow-lg shadow-blue-500/30 hover:shadow-blue-500/50 transition-all"
                      >
                        Submit Request
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Main container */}
      <div className="relative z-10 w-full max-w-md px-6">
        {/* Logo and branding */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-8"
        >
          <div className="inline-block mb-2">
            <motion.div
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="relative"
            >
              <div className="absolute inset-0 bg-blue-500/30 blur-2xl scale-110" />
              <img 
                src={chiiLogo} 
                alt="CHII Logo" 
                className="relative w-64 h-auto mx-auto"
              />
            </motion.div>
          </div>
        </motion.div>

        {/* Login/Signup card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="relative"
        >
          {/* Card glow effect */}
          <div className="absolute -inset-1 bg-gradient-to-r from-blue-500/15 to-[#00a5ff]/15 rounded-2xl blur-sm" />
          
          {/* Card content */}
          <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-2xl p-8 shadow-2xl">
            {/* Tab switcher */}
            <div className="flex mb-8 bg-black/30 rounded-lg p-1">
              <button
                onClick={switchToLogin}
                className={`flex-1 py-3 rounded-md transition-all duration-300 ${
                  isLogin
                    ? 'bg-gradient-to-r from-[#00a5ff] to-blue-500 text-white shadow-lg shadow-blue-500/40'
                    : 'text-[#c0c5ce] hover:text-white'
                }`}
              >
                Login
              </button>
              <button
                onClick={switchToSignup}
                className={`flex-1 py-3 rounded-md transition-all duration-300 ${
                  !isLogin
                    ? 'bg-gradient-to-r from-[#00a5ff] to-blue-500 text-white shadow-lg shadow-blue-500/40'
                    : 'text-[#c0c5ce] hover:text-white'
                }`}
              >
                Sign Up
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-5">
              {!isLogin && (
                <motion.div
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: 'auto' }}
                  exit={{ opacity: 0, height: 0 }}
                  transition={{ duration: 0.3 }}
                >
                  <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                    Username
                  </label>
                  <div className="relative">
                    <input
                      type="text"
                      name="username"
                      value={formData.username}
                      onChange={handleChange}
                      className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      placeholder="Enter your username"
                    />
                    <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                  </div>
                </motion.div>
              )}

              <div>
                <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                  Email Address
                </label>
                <div className="relative">
                  <input
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                    placeholder="user@cydonian.com"
                    required
                  />
                  <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                </div>
              </div>

              <div>
                <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                  Password
                </label>
                <div className="relative">
                  <input
                    type="password"
                    name="password"
                    value={formData.password}
                    onChange={handleChange}
                    className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                    placeholder="Enter your password"
                    required
                  />
                  <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                </div>
              </div>

              {!isLogin && (
                <motion.div
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: 'auto' }}
                  exit={{ opacity: 0, height: 0 }}
                  transition={{ duration: 0.3 }}
                >
                  <label className="block text-[#c0c5ce] text-sm mb-2 tracking-wide">
                    Confirm Password
                  </label>
                  <div className="relative">
                    <input
                      type="password"
                      name="confirmPassword"
                      value={formData.confirmPassword}
                      onChange={handleChange}
                      className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      placeholder="Confirm your password"
                    />
                    <div className="absolute right-3 top-1/2 -translate-y-1/2 w-2 h-2 bg-[#00a5ff] rounded-full animate-pulse" />
                  </div>
                </motion.div>
              )}

              {isLogin && (
                <div className="flex justify-end">
                  <button
                    type="button"
                    onClick={openForgotPasswordModal}
                    className="text-[#00a5ff] text-sm hover:text-blue-400 transition-colors"
                  >
                    Forgot Password?
                  </button>
                </div>
              )}

              {/* Submit button */}
              <motion.button
                type="submit"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className="w-full bg-gradient-to-r from-[#00a5ff] to-blue-500 text-white py-3 rounded-lg font-semibold shadow-lg shadow-blue-500/30 hover:shadow-blue-500/50 transition-all duration-300 mt-6"
              >
                {isLogin ? 'ACCESS SYSTEM' : 'CREATE ACCOUNT'}
              </motion.button>
            </form>

            {/* Additional info */}
            <div className="mt-6 text-center">
              <p className="text-gray-500 text-xs">
                {isLogin ? "Don't have access?" : 'Already have an account?'}{' '}
                <button
                  type="button"
                  onClick={isLogin ? openRequestAccessModal : switchToLogin}
                  className="text-[#00a5ff] hover:text-blue-400 transition-colors"
                >
                  {isLogin ? 'Request Access' : 'Sign In'}
                </button>
              </p>
            </div>

            {/* Security badge */}
            <div className="mt-6 pt-6 border-t border-gray-800">
              <div className="flex items-center justify-center gap-2 text-xs text-gray-600">
                <div className="w-3 h-3 border border-[#00a5ff]/50 rounded flex items-center justify-center">
                  <div className="w-1.5 h-1.5 bg-[#00a5ff] rounded-full animate-pulse" />
                </div>
                <span>SECURE CONNECTION</span>
                <div className="w-px h-3 bg-gray-700" />
                <span>256-BIT ENCRYPTION</span>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Footer text */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="text-center mt-8 text-gray-600 text-xs"
        >
          <p>© 2026 Cydonian Heavy Industries Inc. All rights reserved.</p>
          <p className="mt-1">Unauthorized access is strictly prohibited.</p>
        </motion.div>
      </div>

      {/* Corner decorations */}
      <div className="absolute top-0 left-0 w-32 h-32 border-t-2 border-l-2 border-[#00a5ff]/20" />
      <div className="absolute top-0 right-0 w-32 h-32 border-t-2 border-r-2 border-[#00a5ff]/20" />
      <div className="absolute bottom-0 left-0 w-32 h-32 border-b-2 border-l-2 border-[#00a5ff]/20" />
      <div className="absolute bottom-0 right-0 w-32 h-32 border-b-2 border-r-2 border-[#00a5ff]/20" />
    </div>
  );
}