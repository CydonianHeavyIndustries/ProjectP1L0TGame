import { motion } from 'motion/react';
import { Rocket, Shield, Zap, Globe } from 'lucide-react';
import chiiLogo from 'figma:asset/dd095089ca513f2d1125400bc19c749527ae2030.png';

export function HomePage() {
  return (
    <div className="max-w-7xl mx-auto px-6 py-12">
      {/* Hero Section */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="text-center mb-16"
      >
        <div className="relative inline-block mb-6">
          <motion.div
            className="absolute inset-0 bg-[#00a5ff]/20 blur-3xl"
            animate={{
              scale: [1, 1.2, 1],
              opacity: [0.3, 0.6, 0.3],
            }}
            transition={{
              duration: 4,
              repeat: Infinity,
              ease: "easeInOut"
            }}
          />
          <img src={chiiLogo} alt="CHII Logo" className="relative w-64 h-auto mx-auto" />
        </div>
        
        <h1 className="text-5xl font-bold text-white mb-4 tracking-wide">
          Welcome to <span className="bg-gradient-to-r from-[#00a5ff] to-blue-400 bg-clip-text text-transparent">CHII</span>
        </h1>
        <p className="text-xl text-[#c0c5ce] max-w-3xl mx-auto">
          Cydonian Heavy Industries Inc. - Pioneering the future of interactive entertainment and advanced technology solutions
        </p>
      </motion.div>

      {/* Features Grid */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.2 }}
        className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16"
      >
        {[
          { icon: Rocket, title: 'Innovation', desc: 'Pushing boundaries in game development' },
          { icon: Shield, title: 'Reliability', desc: 'Enterprise-grade security and stability' },
          { icon: Zap, title: 'Performance', desc: 'Optimized for maximum efficiency' },
          { icon: Globe, title: 'Global Reach', desc: 'Serving creators worldwide' },
        ].map((feature, index) => (
          <motion.div
            key={feature.title}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3 + index * 0.1 }}
            className="relative group"
          >
            <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/30 to-blue-500/30 rounded-xl blur opacity-0 group-hover:opacity-100 transition-opacity" />
            <div className="relative bg-[#151922]/80 backdrop-blur-xl border border-[#00a5ff]/20 rounded-xl p-6 hover:border-[#00a5ff]/40 transition-all">
              <div className="w-12 h-12 bg-[#00a5ff]/10 rounded-lg flex items-center justify-center mb-4 border border-[#00a5ff]/30">
                <feature.icon className="w-6 h-6 text-[#00a5ff]" />
              </div>
              <h3 className="text-white font-semibold mb-2">{feature.title}</h3>
              <p className="text-[#c0c5ce] text-sm">{feature.desc}</p>
            </div>
          </motion.div>
        ))}
      </motion.div>

      {/* About Section */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.6 }}
        className="relative mb-16"
      >
        <div className="absolute -inset-1 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-2xl blur-sm" />
        <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-2xl p-8">
          <h2 className="text-3xl font-bold text-white mb-4">About CHII</h2>
          <div className="space-y-4 text-[#c0c5ce]">
            <p>
              Cydonian Heavy Industries Inc. (CHII) is at the forefront of interactive entertainment development,
              combining cutting-edge technology with innovative gameplay mechanics to create unforgettable experiences.
            </p>
            <p>
              Our mission is to push the boundaries of what's possible in gaming, delivering high-quality products
              that challenge conventions and inspire players worldwide.
            </p>
            <p>
              From independent projects to collaborative ventures, CHII maintains a commitment to excellence,
              creativity, and technical innovation in every endeavor.
            </p>
          </div>
        </div>
      </motion.div>

      {/* Projects Showcase */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.8 }}
        className="relative"
      >
        <div className="absolute -inset-1 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-2xl blur-sm" />
        <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-2xl p-8">
          <h2 className="text-3xl font-bold text-white mb-6">Featured Projects</h2>
          <div className="grid md:grid-cols-2 gap-6">
            <div className="relative group overflow-hidden rounded-xl border border-[#00a5ff]/30 hover:border-[#00a5ff]/60 transition-all">
              <div className="bg-gradient-to-br from-[#00a5ff]/20 to-blue-500/20 p-8">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-3 h-3 bg-[#00a5ff] rounded-full animate-pulse" />
                  <span className="text-xs text-[#00a5ff] font-semibold tracking-wider">IN DEVELOPMENT</span>
                </div>
                <h3 className="text-2xl font-bold text-white mb-3">Project-P1L0T</h3>
                <p className="text-[#c0c5ce] mb-4">
                  Our flagship work-in-progress game combining innovative mechanics with stunning visuals.
                  Join the development journey and be part of something extraordinary.
                </p>
                <div className="flex gap-3">
                  <button className="px-4 py-2 bg-[#00a5ff]/20 text-[#00a5ff] border border-[#00a5ff]/40 rounded-lg hover:bg-[#00a5ff]/30 transition-all text-sm font-semibold">
                    Learn More →
                  </button>
                </div>
              </div>
            </div>

            <div className="relative group overflow-hidden rounded-xl border border-gray-700/30 hover:border-gray-600/60 transition-all">
              <div className="bg-gradient-to-br from-gray-800/20 to-gray-700/20 p-8">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-3 h-3 bg-gray-500 rounded-full" />
                  <span className="text-xs text-gray-500 font-semibold tracking-wider">COMING SOON</span>
                </div>
                <h3 className="text-2xl font-bold text-white mb-3">Future Projects</h3>
                <p className="text-[#c0c5ce] mb-4">
                  Multiple exciting projects are in the pipeline. Stay tuned for announcements
                  and join our community to get early access and exclusive updates.
                </p>
                <div className="flex gap-3">
                  <button className="px-4 py-2 bg-gray-700/20 text-gray-400 border border-gray-700/40 rounded-lg text-sm font-semibold cursor-not-allowed">
                    Coming Soon
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </motion.div>

      {/* Stats Section */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 1.0 }}
        className="mt-16 grid grid-cols-3 gap-6"
      >
        {[
          { value: '2026', label: 'Established' },
          { value: '1+', label: 'Active Projects' },
          { value: '∞', label: 'Possibilities' },
        ].map((stat, index) => (
          <div key={stat.label} className="text-center">
            <div className="relative inline-block">
              <motion.div
                className="absolute inset-0 bg-[#00a5ff]/20 blur-xl"
                animate={{
                  scale: [1, 1.2, 1],
                  opacity: [0.3, 0.6, 0.3],
                }}
                transition={{
                  duration: 3,
                  repeat: Infinity,
                  ease: "easeInOut",
                  delay: index * 0.3,
                }}
              />
              <h3 className="relative text-4xl font-bold text-[#00a5ff] mb-2">{stat.value}</h3>
            </div>
            <p className="text-[#c0c5ce] text-sm">{stat.label}</p>
          </div>
        ))}
      </motion.div>
    </div>
  );
}
