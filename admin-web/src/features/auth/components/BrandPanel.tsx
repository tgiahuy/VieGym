import React from 'react'

export const BrandPanel: React.FC = () => {
  return (
    <section className="relative w-full lg:w-[44%] min-h-[380px] lg:min-h-screen bg-gradient-to-b from-[#0b0c0e] via-[#0d0e10] to-[#17181b] flex flex-col justify-between p-6 sm:p-10 md:p-12 lg:p-16 border-b lg:border-b-0 lg:border-r border-[#292a2f] overflow-hidden select-none">
      {/* Background Technical Geometric Lines & Telemetry Grid */}
      <div className="absolute inset-0 telemetry-grid opacity-35 pointer-events-none" />

      {/* Subtle Ambient Glow Rings */}
      <div className="absolute -top-24 -left-24 w-96 h-96 rounded-full bg-[rgba(242,48,90,0.12)] blur-3xl pointer-events-none" />
      <div className="absolute top-1/2 -right-32 w-80 h-80 rounded-full bg-[#9b7bff]/10 blur-3xl pointer-events-none" />

      {/* Header: Platform Brand Identification */}
      <div className="relative z-10">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-[#222327] border border-[#34363b] flex items-center justify-center shadow-inner">
            <span className="material-symbols-outlined text-[#f2305a] text-[24px]">fitness_center</span>
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="text-[20px] font-bold tracking-tight text-[#f5f5f6]">VIEGYM ADMIN</span>
              <span className="px-2 py-0.5 rounded-full bg-[rgba(242,48,90,0.12)] border border-[#f2305a]/30 text-[#f2305a] text-[10px] font-semibold uppercase">
                Enterprise
              </span>
            </div>
            <p className="text-[12px] text-[#8a8d93]">Enterprise Console</p>
          </div>
        </div>
      </div>

      {/* Center: Operational Technical Showcase & Vector Geometry */}
      <div className="relative z-10 my-8 lg:my-auto max-w-lg">
        {/* Live Telemetry Vector Graphic (ECG / Workout Curve / AI Tensor Nodes) */}
        <div className="mb-8 p-4 rounded-xl bg-[#17181b]/80 border border-[#292a2f] backdrop-blur-sm relative overflow-hidden">
          <div className="flex items-center justify-between pb-3 mb-3 border-b border-[#292a2f]">
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-[#35c76f] animate-pulse" />
              <span className="text-[12px] font-semibold text-[#a7a9ae]">SYSTEM TELEMETRY ENGINE</span>
            </div>
            <div className="flex items-center gap-3">
              <span className="text-[12px] font-semibold text-[#9b7bff] flex items-center gap-1">
                <span className="material-symbols-outlined text-[14px]">smart_toy</span> AI v3.4
              </span>
              <span className="text-[12px] font-semibold text-[#2cc7b5] flex items-center gap-1">
                <span className="material-symbols-outlined text-[14px]">bolt</span> 99.98%
              </span>
            </div>
          </div>

          {/* Abstract SVG Graph & Data Streams */}
          <svg className="w-full h-24 overflow-visible" fill="none" viewBox="0 0 400 90" xmlns="http://www.w3.org/2000/svg">
            <line stroke="#292a2f" strokeDasharray="3 3" x1="0" x2="400" y1="20" y2="20" />
            <line stroke="#292a2f" strokeDasharray="3 3" x1="0" x2="400" y1="45" y2="45" />
            <line stroke="#292a2f" strokeDasharray="3 3" x1="0" x2="400" y1="70" y2="70" />
            <path
              d="M0 65 Q 45 60, 90 40 T 180 30 T 270 50 T 360 25 L 400 20"
              fill="none"
              opacity="0.85"
              stroke="#9b7bff"
              strokeLinecap="round"
              strokeWidth="2"
            />
            <path
              d="M0 75 L 70 75 L 85 82 L 105 15 L 125 80 L 140 75 L 210 75 L 225 60 L 240 85 L 255 35 L 270 78 L 330 75 L 345 55 L 360 80 L 400 75"
              fill="none"
              stroke="#f2305a"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2.5"
            />
            <circle className="animate-ping" cx="105" cy="15" fill="#f2305a" r="3.5" style={{ animationDuration: '2s', transformOrigin: '105px 15px' }} />
            <circle cx="105" cy="15" fill="#f2305a" r="3" />
            <circle cx="255" cy="35" fill="#f2305a" r="3" />
            <circle cx="360" cy="25" fill="#9b7bff" r="3.5" />
          </svg>

          {/* Metric micro-badges below vector */}
          <div className="grid grid-cols-3 gap-2 mt-3 pt-2 border-t border-[#292a2f]/60 text-[11px] font-mono">
            <div className="flex flex-col">
              <span className="text-[#8a8d93]">ĐỘ TRỄ TẬP TRUNG</span>
              <span className="text-[#f5f5f6] font-bold">12ms · Real-time</span>
            </div>
            <div className="flex flex-col">
              <span className="text-[#8a8d93]">CHỈ SỐ DINH DƯỠNG</span>
              <span className="text-[#2cc7b5] font-bold">4.2M Calo Sync</span>
            </div>
            <div className="flex flex-col">
              <span className="text-[#8a8d93]">KHU VỰC VẬN HÀNH</span>
              <span className="text-[#f5f5f6] font-bold">VN-South (HCM)</span>
            </div>
          </div>
        </div>

        {/* Main Operational Headline & Mission */}
        <h1 className="text-[28px] sm:text-[32px] leading-tight font-bold text-[#f5f5f6] tracking-tight mb-3">
          Vận hành khỏe hơn.<br />
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#f2305a] via-[#ffb2b8] to-[#9b7bff]">
            Dữ liệu chính xác.
          </span>
        </h1>
        <p className="text-[14px] leading-relaxed text-[#a7a9ae] mb-6">
          Hệ thống quản trị tập trung dữ liệu bài tập, dinh dưỡng và mô hình AI huấn luyện.
        </p>

        {/* Key Domain Semantics Badges */}
        <div className="flex flex-wrap gap-2">
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#222327] border border-[#292a2f] text-[#a7a9ae] text-[11px] font-semibold">
            <span className="material-symbols-outlined text-[#f2305a] text-[14px]">fitness_center</span>
            1000+ Bài tập
          </span>
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#222327] border border-[#292a2f] text-[#a7a9ae] text-[11px] font-semibold">
            <span className="material-symbols-outlined text-[#35c76f] text-[14px]">restaurant</span>
            Dinh dưỡng đa lượng
          </span>
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#222327] border border-[#292a2f] text-[#a7a9ae] text-[11px] font-semibold">
            <span className="material-symbols-outlined text-[#9b7bff] text-[14px]">smart_toy</span>
            AI Vision Pose Pipeline
          </span>
        </div>
      </div>

      {/* Footer: Environment & Security Stamp */}
      <div className="relative z-10 pt-4 border-t border-[#292a2f] flex items-center justify-between text-[12px] text-[#8a8d93]">
        <div className="flex items-center gap-2">
          <span className="material-symbols-outlined text-[#35c76f] text-[16px]">verified_user</span>
          <span>v1.0 · Secure Admin Console</span>
        </div>
        <div className="flex items-center gap-2 font-mono text-[11px]">
          <span className="inline-block w-1.5 h-1.5 rounded-full bg-[#f2305a]" />
          <span>TLS 1.3 · AES-256</span>
        </div>
      </div>
    </section>
  )
}
