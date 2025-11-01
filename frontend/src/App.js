import React, { useState } from 'react';
import axios from 'axios';
import '@/App.css';

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

function App() {
  const [config, setConfig] = useState({
    include_basement: true,
    include_attic: true,
    include_secret_passage: true,
    scale_factor: 1.0,
    ceiling_height: 10.0,
    corridor_width: 4.0,
    prop_density: 0.5,
    light_count: 20,
    patrol_point_count: 12,
    key_spawn_count: 6,
    hiding_spot_count: 8,
    max_parts: 6000,
    dark_mode: true,
    victorian_style: true
  });

  const [preview, setPreview] = useState(null);
  const [generating, setGenerating] = useState(false);
  const [generated, setGenerated] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleConfigChange = (key, value) => {
    setConfig(prev => ({ ...prev, [key]: value }));
  };

  const fetchPreview = async () => {
    setLoading(true);
    try {
      const response = await axios.get(`${API}/manor/preview`, { params: config });
      setPreview(response.data);
    } catch (error) {
      console.error('Preview error:', error);
      alert('Failed to generate preview');
    }
    setLoading(false);
  };

  const generateManor = async () => {
    setGenerating(true);
    try {
      const response = await axios.post(`${API}/manor/generate`, config);
      setGenerated(response.data);
      alert('Manor generated successfully!');
    } catch (error) {
      console.error('Generation error:', error);
      alert('Failed to generate manor');
    }
    setGenerating(false);
  };

  const downloadFile = (url, filename) => {
    window.open(`${BACKEND_URL}${url}`, '_blank');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-black text-white">
      {/* Header */}
      <header className="bg-black/50 backdrop-blur-md border-b border-purple-500/30 sticky top-0 z-50">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center gap-4">
            <div className="text-4xl">🏰</div>
            <div>
              <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent" data-testid="manor-generator-title">
                Angry Granny Manor Generator
              </h1>
              <p className="text-gray-400 text-sm">Create Roblox-ready haunted manor maps</p>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-6 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Configuration Panel */}
          <div className="lg:col-span-1 space-y-6">
            <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-purple-500/20">
              <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
                <span>⚙️</span> Configuration
              </h2>

              {/* Room Toggles */}
              <div className="space-y-4 mb-6">
                <h3 className="font-semibold text-purple-300">🚪 Rooms</h3>
                {[
                  { key: 'include_basement', label: 'Include Basement' },
                  { key: 'include_attic', label: 'Include Attic' },
                  { key: 'include_secret_passage', label: 'Secret Passage' }
                ].map(({ key, label }) => (
                  <label key={key} className="flex items-center gap-3 cursor-pointer" data-testid={`toggle-${key}`}>
                    <input
                      type="checkbox"
                      checked={config[key]}
                      onChange={(e) => handleConfigChange(key, e.target.checked)}
                      className="w-5 h-5 rounded bg-gray-700 border-purple-500"
                    />
                    <span>{label}</span>
                  </label>
                ))}
              </div>

              {/* Sliders */}
              <div className="space-y-4">
                <h3 className="font-semibold text-purple-300">📊 Parameters</h3>
                {[
                  { key: 'scale_factor', label: 'Scale Factor', min: 0.5, max: 2.0, step: 0.1 },
                  { key: 'prop_density', label: 'Prop Density', min: 0.0, max: 1.0, step: 0.1 },
                  { key: 'patrol_point_count', label: 'Patrol Points', min: 6, max: 20, step: 1 },
                  { key: 'key_spawn_count', label: 'Key Spawns', min: 3, max: 12, step: 1 },
                  { key: 'hiding_spot_count', label: 'Hiding Spots', min: 4, max: 16, step: 1 }
                ].map(({ key, label, min, max, step }) => (
                  <div key={key} data-testid={`slider-${key}`}>
                    <div className="flex justify-between mb-2">
                      <label className="text-sm">{label}</label>
                      <span className="text-purple-400 font-mono">{config[key]}</span>
                    </div>
                    <input
                      type="range"
                      min={min}
                      max={max}
                      step={step}
                      value={config[key]}
                      onChange={(e) => handleConfigChange(key, parseFloat(e.target.value))}
                      className="w-full h-2 bg-gray-700 rounded-lg appearance-none cursor-pointer accent-purple-500"
                    />
                  </div>
                ))}
              </div>

              {/* Action Buttons */}
              <div className="mt-8 space-y-3">
                <button
                  onClick={fetchPreview}
                  disabled={loading}
                  className="w-full bg-purple-600 hover:bg-purple-700 disabled:bg-gray-600 text-white py-3 px-6 rounded-lg font-semibold transition-all transform hover:scale-105 disabled:scale-100"
                  data-testid="preview-button"
                >
                  {loading ? '⏳ Loading...' : '🔍 Preview Statistics'}
                </button>
                <button
                  onClick={generateManor}
                  disabled={generating}
                  className="w-full bg-gradient-to-r from-pink-600 to-purple-600 hover:from-pink-700 hover:to-purple-700 disabled:from-gray-600 disabled:to-gray-700 text-white py-3 px-6 rounded-lg font-semibold transition-all transform hover:scale-105 disabled:scale-100 shadow-lg"
                  data-testid="generate-button"
                >
                  {generating ? '⏳ Generating...' : '✨ Generate Manor'}
                </button>
              </div>
            </div>
          </div>

          {/* Preview/Results Panel */}
          <div className="lg:col-span-2 space-y-6">
            {/* Preview Statistics */}
            {preview && (
              <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-purple-500/20" data-testid="preview-panel">
                <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
                  <span>📊</span> Preview Statistics
                </h2>
                <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                  {Object.entries(preview.statistics).map(([key, value]) => (
                    <div key={key} className="bg-gray-900/50 rounded-lg p-4 border border-purple-500/10">
                      <div className="text-gray-400 text-sm capitalize">{key.replace('_', ' ')}</div>
                      <div className="text-2xl font-bold text-purple-400">{value}</div>
                    </div>
                  ))}
                </div>
                {!preview.valid && preview.errors.length > 0 && (
                  <div className="mt-4 bg-red-500/20 border border-red-500/50 rounded-lg p-4">
                    <h3 className="font-semibold text-red-400 mb-2">⚠️ Validation Errors:</h3>
                    <ul className="list-disc list-inside text-red-300 text-sm">
                      {preview.errors.map((err, idx) => (
                        <li key={idx}>{err}</li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            )}

            {/* Generated Manor */}
            {generated && (
              <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-purple-500/20" data-testid="generated-panel">
                <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
                  <span>✅</span> Manor Generated!
                </h2>
                <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-6">
                  {Object.entries(generated.statistics).map(([key, value]) => (
                    <div key={key} className="bg-gray-900/50 rounded-lg p-4 border border-purple-500/10">
                      <div className="text-gray-400 text-sm capitalize">{key.replace('_', ' ')}</div>
                      <div className="text-2xl font-bold text-green-400">{value}</div>
                    </div>
                  ))}
                </div>

                <div className="space-y-3">
                  <h3 className="font-semibold text-purple-300">📥 Download Files:</h3>
                  <div className="grid md:grid-cols-2 gap-3">
                    <button
                      onClick={() => downloadFile(generated.download_urls.rbxmx, 'Manor.rbxmx')}
                      className="bg-blue-600 hover:bg-blue-700 text-white py-3 px-6 rounded-lg font-semibold transition-all flex items-center justify-center gap-2"
                      data-testid="download-rbxmx-button"
                    >
                      <span>📦</span> Download RBXMX
                    </button>
                    <button
                      onClick={() => alert('Rojo export available in /output/manor_exports directory')}
                      className="bg-green-600 hover:bg-green-700 text-white py-3 px-6 rounded-lg font-semibold transition-all flex items-center justify-center gap-2"
                      data-testid="view-rojo-button"
                    >
                      <span>📁</span> View Rojo Files
                    </button>
                  </div>
                </div>

                {!generated.success && generated.errors.length > 0 && (
                  <div className="mt-4 bg-yellow-500/20 border border-yellow-500/50 rounded-lg p-4">
                    <h3 className="font-semibold text-yellow-400 mb-2">⚠️ Warnings:</h3>
                    <ul className="list-disc list-inside text-yellow-300 text-sm">
                      {generated.errors.map((err, idx) => (
                        <li key={idx}>{err}</li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            )}

            {/* Instructions */}
            {!preview && !generated && (
              <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-purple-500/20">
                <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
                  <span>📝</span> How to Use
                </h2>
                <div className="space-y-4 text-gray-300">
                  <div className="flex gap-4">
                    <div className="text-2xl">1️⃣</div>
                    <div>
                      <h3 className="font-semibold text-white mb-2">Configure Your Manor</h3>
                      <p>Adjust rooms, scale, prop density, and gameplay markers using the controls on the left.</p>
                    </div>
                  </div>
                  <div className="flex gap-4">
                    <div className="text-2xl">2️⃣</div>
                    <div>
                      <h3 className="font-semibold text-white mb-2">Preview Statistics</h3>
                      <p>Click "Preview Statistics" to see part counts and validate your configuration before generating.</p>
                    </div>
                  </div>
                  <div className="flex gap-4">
                    <div className="text-2xl">3️⃣</div>
                    <div>
                      <h3 className="font-semibold text-white mb-2">Generate & Export</h3>
                      <p>Click "Generate Manor" to create your haunted manor. Download as RBXMX for Roblox Studio or use Rojo format.</p>
                    </div>
                  </div>
                  <div className="mt-6 p-4 bg-purple-500/10 rounded-lg border border-purple-500/30">
                    <h3 className="font-semibold text-purple-300 mb-2">🎮 Game Features Included:</h3>
                    <ul className="list-disc list-inside text-sm space-y-1">
                      <li>Player spawn and Granny spawn markers</li>
                      <li>Patrol points for AI navigation</li>
                      <li>Key spawns and hiding spots</li>
                      <li>Escape exit marker</li>
                      <li>FuseBox and Generator markers</li>
                      <li>Noise zones in key areas</li>
                    </ul>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="bg-black/50 backdrop-blur-md border-t border-purple-500/30 mt-12 py-6">
        <div className="container mx-auto px-6 text-center text-gray-400">
          <p>🎃 Angry Granny Manor Generator - Built for Roblox Game Development</p>
          <p className="text-sm mt-2">Optimized for Rojo import and scripted gameplay</p>
        </div>
      </footer>
    </div>
  );
}

export default App;
