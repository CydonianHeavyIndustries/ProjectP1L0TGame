import { motion } from 'motion/react';
import { Github, Download, ExternalLink, Gamepad2, Users, Code } from 'lucide-react';

export function ProjectP1L0T() {
  const handleGithub = () => {
    // Replace with actual GitHub URL when available
    window.open('https://github.com/cydonianheavyindustries/project-p1l0t', '_blank');
  };

  const handleDownload = () => {
    // Replace with actual download URL when available
    alert('Download link will be available soon! Check back later or join our Discord for updates.');
  };

  return (
    <div className="max-w-7xl mx-auto px-6 py-12">
      {/* Hero Section */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="relative mb-16 overflow-hidden rounded-2xl"
      >
        <div className="absolute -inset-1 bg-gradient-to-r from-[#00a5ff]/20 to-blue-500/20 blur-xl" />
        <div className="relative bg-gradient-to-br from-[#151922]/90 to-[#0a0e1a]/90 backdrop-blur-xl border border-[#00a5ff]/30 rounded-2xl p-12">
          <div className="flex items-center gap-4 mb-6">
            <div className="w-4 h-4 bg-[#00a5ff] rounded-full animate-pulse" />
            <span className="text-sm text-[#00a5ff] font-semibold tracking-wider">WORK IN PROGRESS</span>
          </div>
          
          <h1 className="text-6xl font-bold mb-4">
            <span className="text-white">Project-</span>
            <span className="bg-gradient-to-r from-[#00a5ff] to-blue-400 bg-clip-text text-transparent">P1L0T</span>
          </h1>
          
          <p className="text-xl text-[#c0c5ce] max-w-3xl mb-8">
            An innovative gaming experience that pushes the boundaries of interactive storytelling and gameplay mechanics.
            Join us on this development journey and be part of creating something extraordinary.
          </p>

          <div className="flex gap-4">
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={handleGithub}
              className="flex items-center gap-2 px-6 py-3 bg-[#00a5ff] text-white rounded-lg font-semibold shadow-lg shadow-[#00a5ff]/30 hover:shadow-[#00a5ff]/50 transition-all"
            >
              <Github className="w-5 h-5" />
              View on GitHub
            </motion.button>
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={handleDownload}
              className="flex items-center gap-2 px-6 py-3 bg-[#151922] text-[#00a5ff] border border-[#00a5ff]/40 rounded-lg font-semibold hover:bg-[#00a5ff]/10 transition-all"
            >
              <Download className="w-5 h-5" />
              Download Latest Build
            </motion.button>
          </div>
        </div>
      </motion.div>

      {/* Features Grid */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.2 }}
        className="grid md:grid-cols-3 gap-6 mb-16"
      >
        {[
          {
            icon: Gamepad2,
            title: 'Innovative Gameplay',
            desc: 'Unique mechanics that challenge traditional gaming conventions',
          },
          {
            icon: Users,
            title: 'Community Driven',
            desc: 'Built with feedback from our passionate community of testers',
          },
          {
            icon: Code,
            title: 'Open Development',
            desc: 'Follow our progress and contribute to the development',
          },
        ].map((feature, index) => (
          <motion.div
            key={feature.title}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3 + index * 0.1 }}
            className="relative group"
          >
            <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/20 to-blue-500/20 rounded-xl blur opacity-0 group-hover:opacity-100 transition-opacity" />
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

      {/* Development Status */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.6 }}
        className="relative mb-16"
      >
        <div className="absolute -inset-1 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-2xl blur-sm" />
        <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-2xl p-8">
          <h2 className="text-3xl font-bold text-white mb-6">Development Status</h2>
          <div className="space-y-4">
            {[
              { phase: 'Concept & Design', progress: 100, status: 'Complete' },
              { phase: 'Core Mechanics', progress: 75, status: 'In Progress' },
              { phase: 'Asset Creation', progress: 60, status: 'In Progress' },
              { phase: 'Testing & Polish', progress: 30, status: 'Ongoing' },
              { phase: 'Release', progress: 0, status: 'Planned' },
            ].map((item) => (
              <div key={item.phase} className="space-y-2">
                <div className="flex justify-between items-center">
                  <span className="text-white font-medium">{item.phase}</span>
                  <span className="text-sm text-[#00a5ff]">{item.status}</span>
                </div>
                <div className="h-2 bg-[#0a0e1a] rounded-full overflow-hidden border border-[#00a5ff]/20">
                  <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${item.progress}%` }}
                    transition={{ duration: 1, delay: 0.8 }}
                    className="h-full bg-gradient-to-r from-[#00a5ff] to-blue-500 rounded-full"
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      </motion.div>

      {/* Links Section */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.8 }}
        className="grid md:grid-cols-2 gap-6"
      >
        <div className="relative group">
          <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/20 to-blue-500/20 rounded-xl blur opacity-0 group-hover:opacity-100 transition-opacity" />
          <div className="relative bg-[#151922]/80 backdrop-blur-xl border border-[#00a5ff]/20 rounded-xl p-6 hover:border-[#00a5ff]/40 transition-all">
            <div className="flex items-center gap-3 mb-4">
              <Github className="w-8 h-8 text-[#00a5ff]" />
              <h3 className="text-xl font-bold text-white">GitHub Repository</h3>
            </div>
            <p className="text-[#c0c5ce] mb-4">
              Access the source code, report issues, and contribute to the project development.
            </p>
            <button
              onClick={handleGithub}
              className="flex items-center gap-2 text-[#00a5ff] hover:text-blue-400 transition-colors font-semibold"
            >
              Visit Repository
              <ExternalLink className="w-4 h-4" />
            </button>
          </div>
        </div>

        <div className="relative group">
          <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/20 to-blue-500/20 rounded-xl blur opacity-0 group-hover:opacity-100 transition-opacity" />
          <div className="relative bg-[#151922]/80 backdrop-blur-xl border border-[#00a5ff]/20 rounded-xl p-6 hover:border-[#00a5ff]/40 transition-all">
            <div className="flex items-center gap-3 mb-4">
              <Download className="w-8 h-8 text-[#00a5ff]" />
              <h3 className="text-xl font-bold text-white">Download Builds</h3>
            </div>
            <p className="text-[#c0c5ce] mb-4">
              Try the latest development builds and provide feedback to help shape the game.
            </p>
            <button
              onClick={handleDownload}
              className="flex items-center gap-2 text-[#00a5ff] hover:text-blue-400 transition-colors font-semibold"
            >
              Get Latest Build
              <ExternalLink className="w-4 h-4" />
            </button>
          </div>
        </div>
      </motion.div>

      {/* Call to Action */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 1.0 }}
        className="mt-16 text-center"
      >
        <div className="relative inline-block">
          <div className="absolute -inset-2 bg-gradient-to-r from-[#00a5ff]/30 to-blue-500/30 rounded-2xl blur-xl" />
          <div className="relative bg-[#151922]/90 backdrop-blur-xl border border-[#00a5ff]/30 rounded-2xl p-8">
            <h2 className="text-2xl font-bold text-white mb-4">Join the Development Journey</h2>
            <p className="text-[#c0c5ce] mb-6 max-w-2xl mx-auto">
              Be part of our community and help shape Project-P1L0T. Share your ideas, report bugs,
              and get exclusive early access to new features.
            </p>
            <button
              onClick={() => window.open('https://discord.gg/SJGXsUXWGS', '_blank')}
              className="px-8 py-3 bg-[#5865F2] text-white rounded-lg font-semibold shadow-lg shadow-[#5865F2]/30 hover:shadow-[#5865F2]/50 hover:bg-[#4752C4] transition-all"
            >
              Join Our Discord Community
            </button>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
