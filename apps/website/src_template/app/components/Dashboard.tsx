import { useState } from 'react';
import { motion } from 'motion/react';
import { Home, Gamepad2, Mail, Users, User, LogOut } from 'lucide-react';
import chiiLogo from 'figma:asset/dd095089ca513f2d1125400bc19c749527ae2030.png';
import { HomePage } from './HomePage';
import { ProjectP1L0T } from './ProjectP1L0T';
import { AccountSettings } from './AccountSettings';

interface DashboardProps {
  user: { username: string; email: string };
  onLogout: () => void;
}

export function Dashboard({ user, onLogout }: DashboardProps) {
  const [activeTab, setActiveTab] = useState<'home' | 'project' | 'account'>('home');

  const handleContactUs = () => {
    window.location.href = 'mailto:Cydonianheavyindustries@gmail.com';
  };

  const handleJoinCommunity = () => {
    window.open('https://discord.gg/SJGXsUXWGS', '_blank');
  };

  return (
    <div className="min-h-screen w-full bg-[#0a0e1a] relative overflow-hidden">
      {/* Animated background grid */}
      <div className="fixed inset-0 opacity-10 pointer-events-none">
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
        className="fixed top-20 right-20 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl pointer-events-none"
        animate={{
          scale: [1, 1.2, 1],
          opacity: [0.1, 0.3, 0.1],
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
        transition={{ duration: 0.8, delay: 0.3 }}
      >
        <div className="relative w-20 h-20">
          <motion.div
            className="absolute inset-0 rounded-full border-2 border-[#00a5ff]/30 border-t-[#00a5ff]"
            animate={{ rotate: 360 }}
            transition={{
              duration: 4,
              repeat: Infinity,
              ease: "linear"
            }}
          />
          <motion.div
            className="absolute inset-2 rounded-full border-2 border-blue-500/20 border-b-blue-500/60"
            animate={{ rotate: -360 }}
            transition={{
              duration: 6,
              repeat: Infinity,
              ease: "linear"
            }}
          />
          <div className="absolute inset-3 bg-[#0a0e1a]/80 backdrop-blur-sm rounded-full border border-[#00a5ff]/40 flex items-center justify-center shadow-lg shadow-blue-500/20">
            <motion.img
              src={chiiLogo}
              alt="CHII"
              className="w-10 h-10 object-contain"
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

      {/* Top Navigation Bar */}
      <motion.div
        initial={{ y: -100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.6 }}
        className="relative z-10"
      >
        <div className="border-b border-[#00a5ff]/20 bg-[#151922]/80 backdrop-blur-xl">
          <div className="max-w-7xl mx-auto px-6">
            <div className="flex items-center justify-between h-20">
              {/* Logo */}
              <div className="flex items-center gap-4">
                <img src={chiiLogo} alt="CHII" className="w-12 h-12" />
                <div>
                  <h1 className="text-white font-semibold tracking-wide">CHII</h1>
                  <p className="text-xs text-[#00a5ff]/80 tracking-wider">CYDONIAN HEAVY INDUSTRIES</p>
                </div>
              </div>

              {/* Navigation */}
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setActiveTab('home')}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${
                    activeTab === 'home'
                      ? 'bg-[#00a5ff]/20 text-[#00a5ff] border border-[#00a5ff]/40'
                      : 'text-[#c0c5ce] hover:bg-[#00a5ff]/10 hover:text-white'
                  }`}
                >
                  <Home className="w-4 h-4" />
                  <span className="text-sm">Home</span>
                </button>
                <button
                  onClick={() => setActiveTab('project')}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${
                    activeTab === 'project'
                      ? 'bg-[#00a5ff]/20 text-[#00a5ff] border border-[#00a5ff]/40'
                      : 'text-[#c0c5ce] hover:bg-[#00a5ff]/10 hover:text-white'
                  }`}
                >
                  <Gamepad2 className="w-4 h-4" />
                  <span className="text-sm">Project-P1L0T</span>
                </button>
                <button
                  onClick={handleContactUs}
                  className="flex items-center gap-2 px-4 py-2 rounded-lg text-[#c0c5ce] hover:bg-[#00a5ff]/10 hover:text-white transition-all"
                >
                  <Mail className="w-4 h-4" />
                  <span className="text-sm">Contact Us</span>
                </button>
                <button
                  onClick={handleJoinCommunity}
                  className="flex items-center gap-2 px-4 py-2 rounded-lg bg-[#5865F2]/20 text-[#5865F2] border border-[#5865F2]/40 hover:bg-[#5865F2]/30 transition-all"
                >
                  <Users className="w-4 h-4" />
                  <span className="text-sm">Join Community</span>
                </button>
              </div>

              {/* User Menu */}
              <div className="flex items-center gap-3">
                <button
                  onClick={() => setActiveTab('account')}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${
                    activeTab === 'account'
                      ? 'bg-[#00a5ff]/20 text-[#00a5ff] border border-[#00a5ff]/40'
                      : 'text-[#c0c5ce] hover:bg-[#00a5ff]/10 hover:text-white'
                  }`}
                >
                  <User className="w-4 h-4" />
                  <span className="text-sm">{user.username}</span>
                </button>
                <button
                  onClick={onLogout}
                  className="flex items-center gap-2 px-4 py-2 rounded-lg text-red-400 hover:bg-red-500/10 hover:text-red-300 transition-all border border-red-500/30"
                >
                  <LogOut className="w-4 h-4" />
                  <span className="text-sm">Logout</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </motion.div>

      {/* Main Content */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.6, delay: 0.2 }}
        className="relative z-0"
      >
        {activeTab === 'home' && <HomePage />}
        {activeTab === 'project' && <ProjectP1L0T />}
        {activeTab === 'account' && <AccountSettings user={user} />}
      </motion.div>

      {/* Corner decorations */}
      <div className="fixed top-0 left-0 w-32 h-32 border-t-2 border-l-2 border-[#00a5ff]/10 pointer-events-none" />
      <div className="fixed top-0 right-0 w-32 h-32 border-t-2 border-r-2 border-[#00a5ff]/10 pointer-events-none" />
      <div className="fixed bottom-0 left-0 w-32 h-32 border-b-2 border-l-2 border-[#00a5ff]/10 pointer-events-none" />
      <div className="fixed bottom-0 right-0 w-32 h-32 border-b-2 border-r-2 border-[#00a5ff]/10 pointer-events-none" />
    </div>
  );
}
