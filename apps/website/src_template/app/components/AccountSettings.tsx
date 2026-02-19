import { useState } from 'react';
import { motion } from 'motion/react';
import { User, Mail, Lock, Phone, Edit, Globe, Activity, Image as ImageIcon, Save, X } from 'lucide-react';

interface AccountSettingsProps {
  user: { username: string; email: string };
}

export function AccountSettings({ user }: AccountSettingsProps) {
  const [activeSection, setActiveSection] = useState<'profile' | 'security' | 'socials'>('profile');
  const [profileData, setProfileData] = useState({
    username: user.username,
    email: user.email,
    phone: '',
    bio: '',
    status: 'online' as 'online' | 'away' | 'busy' | 'offline',
    profilePicture: '',
  });

  const [securityData, setSecurityData] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
    newEmail: '',
  });

  const [socialsData, setSocialsData] = useState({
    twitter: '',
    github: '',
    discord: '',
    website: '',
  });

  const [isEditingBio, setIsEditingBio] = useState(false);
  const [tempBio, setTempBio] = useState(profileData.bio);

  const handleProfilePictureChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        setProfileData({ ...profileData, profilePicture: event.target?.result as string });
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSaveProfile = () => {
    // TODO: Connect to backend API to save profile data
    console.log('Saving profile:', profileData);
    alert('Profile updated successfully!');
  };

  const handleChangePassword = () => {
    if (securityData.newPassword !== securityData.confirmPassword) {
      alert('New passwords do not match!');
      return;
    }
    // TODO: Connect to backend API to change password
    console.log('Changing password');
    alert('Password changed successfully!');
    setSecurityData({
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      newEmail: '',
    });
  };

  const handleChangeEmail = () => {
    // TODO: Connect to backend API to change email
    console.log('Changing email to:', securityData.newEmail);
    alert('Email change request sent! Please check your inbox to verify.');
    setSecurityData({ ...securityData, newEmail: '' });
  };

  const handleSaveSocials = () => {
    // TODO: Connect to backend API to save social links
    console.log('Saving socials:', socialsData);
    alert('Social links updated successfully!');
  };

  const handleSaveBio = () => {
    setProfileData({ ...profileData, bio: tempBio });
    setIsEditingBio(false);
    alert('Bio updated successfully!');
  };

  const statusColors = {
    online: 'bg-green-500',
    away: 'bg-yellow-500',
    busy: 'bg-red-500',
    offline: 'bg-gray-500',
  };

  return (
    <div className="max-w-7xl mx-auto px-6 py-12">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="mb-8"
      >
        <h1 className="text-4xl font-bold text-white mb-2">Account Settings</h1>
        <p className="text-[#c0c5ce]">Manage your profile, security, and preferences</p>
      </motion.div>

      <div className="grid lg:grid-cols-4 gap-6">
        {/* Sidebar Navigation */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="lg:col-span-1"
        >
          <div className="relative">
            <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-xl blur-sm" />
            <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-xl p-4 space-y-2">
              <button
                onClick={() => setActiveSection('profile')}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${
                  activeSection === 'profile'
                    ? 'bg-[#00a5ff]/20 text-[#00a5ff] border border-[#00a5ff]/40'
                    : 'text-[#c0c5ce] hover:bg-[#00a5ff]/10 hover:text-white'
                }`}
              >
                <User className="w-5 h-5" />
                <span className="font-medium">Profile</span>
              </button>
              <button
                onClick={() => setActiveSection('security')}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${
                  activeSection === 'security'
                    ? 'bg-[#00a5ff]/20 text-[#00a5ff] border border-[#00a5ff]/40'
                    : 'text-[#c0c5ce] hover:bg-[#00a5ff]/10 hover:text-white'
                }`}
              >
                <Lock className="w-5 h-5" />
                <span className="font-medium">Security</span>
              </button>
              <button
                onClick={() => setActiveSection('socials')}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${
                  activeSection === 'socials'
                    ? 'bg-[#00a5ff]/20 text-[#00a5ff] border border-[#00a5ff]/40'
                    : 'text-[#c0c5ce] hover:bg-[#00a5ff]/10 hover:text-white'
                }`}
              >
                <Globe className="w-5 h-5" />
                <span className="font-medium">Socials</span>
              </button>
            </div>
          </div>
        </motion.div>

        {/* Main Content */}
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="lg:col-span-3"
        >
          {/* Profile Section */}
          {activeSection === 'profile' && (
            <div className="space-y-6">
              {/* Profile Picture */}
              <div className="relative">
                <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-xl blur-sm" />
                <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-xl p-6">
                  <h2 className="text-2xl font-bold text-white mb-4 flex items-center gap-2">
                    <ImageIcon className="w-6 h-6 text-[#00a5ff]" />
                    Profile Picture
                  </h2>
                  <div className="flex items-center gap-6">
                    <div className="relative">
                      <div className="w-24 h-24 rounded-full bg-[#00a5ff]/10 border-2 border-[#00a5ff]/40 flex items-center justify-center overflow-hidden">
                        {profileData.profilePicture ? (
                          <img src={profileData.profilePicture} alt="Profile" className="w-full h-full object-cover" />
                        ) : (
                          <User className="w-12 h-12 text-[#00a5ff]" />
                        )}
                      </div>
                      <div className={`absolute bottom-0 right-0 w-5 h-5 ${statusColors[profileData.status]} rounded-full border-2 border-[#151922]`} />
                    </div>
                    <div>
                      <label className="px-4 py-2 bg-[#00a5ff]/20 text-[#00a5ff] border border-[#00a5ff]/40 rounded-lg hover:bg-[#00a5ff]/30 transition-all cursor-pointer inline-block">
                        Upload New Picture
                        <input
                          type="file"
                          accept="image/*"
                          onChange={handleProfilePictureChange}
                          className="hidden"
                        />
                      </label>
                      <p className="text-[#c0c5ce] text-sm mt-2">JPG, PNG or GIF. Max size 5MB.</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Basic Info */}
              <div className="relative">
                <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-xl blur-sm" />
                <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-xl p-6">
                  <h2 className="text-2xl font-bold text-white mb-4 flex items-center gap-2">
                    <Edit className="w-6 h-6 text-[#00a5ff]" />
                    Basic Information
                  </h2>
                  <div className="space-y-4">
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">Username</label>
                      <input
                        type="text"
                        value={profileData.username}
                        onChange={(e) => setProfileData({ ...profileData, username: e.target.value })}
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      />
                    </div>
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">Email (Display Only)</label>
                      <input
                        type="email"
                        value={profileData.email}
                        disabled
                        className="w-full bg-black/20 border border-[#00a5ff]/15 rounded-lg px-4 py-3 text-[#e8ebf0]/50 cursor-not-allowed"
                      />
                      <p className="text-xs text-[#c0c5ce] mt-1">Change email in Security section</p>
                    </div>
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">Phone Number</label>
                      <div className="relative">
                        <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#00a5ff]/50" />
                        <input
                          type="tel"
                          value={profileData.phone}
                          onChange={(e) => setProfileData({ ...profileData, phone: e.target.value })}
                          placeholder="+1 (555) 000-0000"
                          className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg pl-11 pr-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Bio */}
              <div className="relative">
                <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-xl blur-sm" />
                <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-xl p-6">
                  <div className="flex items-center justify-between mb-4">
                    <h2 className="text-2xl font-bold text-white flex items-center gap-2">
                      <Edit className="w-6 h-6 text-[#00a5ff]" />
                      Bio
                    </h2>
                    {!isEditingBio && (
                      <button
                        onClick={() => {
                          setIsEditingBio(true);
                          setTempBio(profileData.bio);
                        }}
                        className="px-3 py-1 text-sm bg-[#00a5ff]/20 text-[#00a5ff] border border-[#00a5ff]/40 rounded-lg hover:bg-[#00a5ff]/30 transition-all"
                      >
                        Edit
                      </button>
                    )}
                  </div>
                  {isEditingBio ? (
                    <div className="space-y-3">
                      <textarea
                        value={tempBio}
                        onChange={(e) => setTempBio(e.target.value)}
                        placeholder="Tell us about yourself..."
                        rows={4}
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all resize-none"
                      />
                      <div className="flex gap-2">
                        <button
                          onClick={handleSaveBio}
                          className="flex items-center gap-2 px-4 py-2 bg-[#00a5ff] text-white rounded-lg hover:bg-[#0090e0] transition-all"
                        >
                          <Save className="w-4 h-4" />
                          Save
                        </button>
                        <button
                          onClick={() => setIsEditingBio(false)}
                          className="flex items-center gap-2 px-4 py-2 bg-gray-700/50 text-[#c0c5ce] rounded-lg hover:bg-gray-700/70 transition-all"
                        >
                          <X className="w-4 h-4" />
                          Cancel
                        </button>
                      </div>
                    </div>
                  ) : (
                    <p className="text-[#c0c5ce]">
                      {profileData.bio || 'No bio yet. Click edit to add one.'}
                    </p>
                  )}
                </div>
              </div>

              {/* Status */}
              <div className="relative">
                <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-xl blur-sm" />
                <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-xl p-6">
                  <h2 className="text-2xl font-bold text-white mb-4 flex items-center gap-2">
                    <Activity className="w-6 h-6 text-[#00a5ff]" />
                    Live Status
                  </h2>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                    {(['online', 'away', 'busy', 'offline'] as const).map((status) => (
                      <button
                        key={status}
                        onClick={() => setProfileData({ ...profileData, status })}
                        className={`flex items-center gap-2 px-4 py-3 rounded-lg border transition-all ${
                          profileData.status === status
                            ? 'bg-[#00a5ff]/20 border-[#00a5ff]/40 text-white'
                            : 'bg-black/20 border-[#00a5ff]/15 text-[#c0c5ce] hover:border-[#00a5ff]/30'
                        }`}
                      >
                        <div className={`w-3 h-3 ${statusColors[status]} rounded-full`} />
                        <span className="capitalize">{status}</span>
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Save Button */}
              <button
                onClick={handleSaveProfile}
                className="w-full px-6 py-3 bg-gradient-to-r from-[#00a5ff] to-blue-500 text-white rounded-lg font-semibold shadow-lg shadow-[#00a5ff]/30 hover:shadow-[#00a5ff]/50 transition-all"
              >
                Save Profile Changes
              </button>
            </div>
          )}

          {/* Security Section */}
          {activeSection === 'security' && (
            <div className="space-y-6">
              {/* Change Password */}
              <div className="relative">
                <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-xl blur-sm" />
                <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-xl p-6">
                  <h2 className="text-2xl font-bold text-white mb-4 flex items-center gap-2">
                    <Lock className="w-6 h-6 text-[#00a5ff]" />
                    Change Password
                  </h2>
                  <div className="space-y-4">
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">Current Password</label>
                      <input
                        type="password"
                        value={securityData.currentPassword}
                        onChange={(e) => setSecurityData({ ...securityData, currentPassword: e.target.value })}
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      />
                    </div>
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">New Password</label>
                      <input
                        type="password"
                        value={securityData.newPassword}
                        onChange={(e) => setSecurityData({ ...securityData, newPassword: e.target.value })}
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      />
                    </div>
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">Confirm New Password</label>
                      <input
                        type="password"
                        value={securityData.confirmPassword}
                        onChange={(e) => setSecurityData({ ...securityData, confirmPassword: e.target.value })}
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      />
                    </div>
                    <button
                      onClick={handleChangePassword}
                      className="w-full px-6 py-3 bg-gradient-to-r from-[#00a5ff] to-blue-500 text-white rounded-lg font-semibold shadow-lg shadow-[#00a5ff]/30 hover:shadow-[#00a5ff]/50 transition-all"
                    >
                      Update Password
                    </button>
                  </div>
                </div>
              </div>

              {/* Change Email */}
              <div className="relative">
                <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-xl blur-sm" />
                <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-xl p-6">
                  <h2 className="text-2xl font-bold text-white mb-4 flex items-center gap-2">
                    <Mail className="w-6 h-6 text-[#00a5ff]" />
                    Change Email Address
                  </h2>
                  <div className="space-y-4">
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">Current Email</label>
                      <input
                        type="email"
                        value={user.email}
                        disabled
                        className="w-full bg-black/20 border border-[#00a5ff]/15 rounded-lg px-4 py-3 text-[#e8ebf0]/50 cursor-not-allowed"
                      />
                    </div>
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">New Email Address</label>
                      <input
                        type="email"
                        value={securityData.newEmail}
                        onChange={(e) => setSecurityData({ ...securityData, newEmail: e.target.value })}
                        placeholder="new.email@example.com"
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      />
                    </div>
                    <button
                      onClick={handleChangeEmail}
                      className="w-full px-6 py-3 bg-gradient-to-r from-[#00a5ff] to-blue-500 text-white rounded-lg font-semibold shadow-lg shadow-[#00a5ff]/30 hover:shadow-[#00a5ff]/50 transition-all"
                    >
                      Send Verification Email
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Socials Section */}
          {activeSection === 'socials' && (
            <div className="space-y-6">
              <div className="relative">
                <div className="absolute -inset-0.5 bg-gradient-to-r from-[#00a5ff]/10 to-blue-500/10 rounded-xl blur-sm" />
                <div className="relative bg-[#151922]/60 backdrop-blur-xl border border-[#00a5ff]/25 rounded-xl p-6">
                  <h2 className="text-2xl font-bold text-white mb-4 flex items-center gap-2">
                    <Globe className="w-6 h-6 text-[#00a5ff]" />
                    Social Links
                  </h2>
                  <div className="space-y-4">
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">Twitter / X</label>
                      <input
                        type="text"
                        value={socialsData.twitter}
                        onChange={(e) => setSocialsData({ ...socialsData, twitter: e.target.value })}
                        placeholder="https://twitter.com/username"
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      />
                    </div>
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">GitHub</label>
                      <input
                        type="text"
                        value={socialsData.github}
                        onChange={(e) => setSocialsData({ ...socialsData, github: e.target.value })}
                        placeholder="https://github.com/username"
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      />
                    </div>
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">Discord</label>
                      <input
                        type="text"
                        value={socialsData.discord}
                        onChange={(e) => setSocialsData({ ...socialsData, discord: e.target.value })}
                        placeholder="username#0000"
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      />
                    </div>
                    <div>
                      <label className="block text-[#c0c5ce] text-sm mb-2">Website</label>
                      <input
                        type="text"
                        value={socialsData.website}
                        onChange={(e) => setSocialsData({ ...socialsData, website: e.target.value })}
                        placeholder="https://yourwebsite.com"
                        className="w-full bg-black/40 border border-[#00a5ff]/25 rounded-lg px-4 py-3 text-[#e8ebf0] placeholder-gray-600 focus:outline-none focus:border-[#00a5ff] focus:ring-2 focus:ring-[#00a5ff]/20 transition-all"
                      />
                    </div>
                    <button
                      onClick={handleSaveSocials}
                      className="w-full px-6 py-3 bg-gradient-to-r from-[#00a5ff] to-blue-500 text-white rounded-lg font-semibold shadow-lg shadow-[#00a5ff]/30 hover:shadow-[#00a5ff]/50 transition-all"
                    >
                      Save Social Links
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}
        </motion.div>
      </div>
    </div>
  );
}
