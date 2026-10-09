import React, { useState } from 'react'
import { StorageSettings } from '../types'

interface StorageSettingsTabProps {
  data: StorageSettings
  onChange: (fields: Partial<StorageSettings>) => void
  onTestConnection: (serviceName: string) => void
}

export const StorageSettingsTab: React.FC<StorageSettingsTabProps> = ({
  data,
  onChange,
  onTestConnection,
}) => {
  const [showKey, setShowKey] = useState(false)

  return (
    <div className="space-y-6">
      {/* CDN & Object Storage */}
      <div className="p-6 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-5">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#292a2f]">
          <div>
            <h3 className="text-base font-bold text-[#f5f5f6]">Mạng phân phối CDN &amp; Object Storage (S3)</h3>
            <p className="text-xs text-[#8a8d93] mt-0.5">Lưu trữ video bài tập, hình ảnh thực phẩm và tối ưu phân phối toàn cầu</p>
          </div>
          <button
            type="button"
            onClick={() => onTestConnection('CDN / S3 Bucket')}
            className="px-3.5 py-1.5 rounded-xl bg-[#222327] hover:bg-[#292a2f] text-xs font-semibold text-[#f5f5f6] border border-[#34363b] flex items-center gap-1.5 transition-colors cursor-pointer self-start sm:self-auto"
          >
            <span className="material-symbols-outlined text-sm text-[#35c76f]">sync</span>
            <span>Kiểm tra kết nối S3</span>
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Nhà cung cấp CDN</label>
            <select
              value={data.cdnProvider}
              onChange={(e) => onChange({ cdnProvider: e.target.value as StorageSettings['cdnProvider'] })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d] cursor-pointer"
            >
              <option value="Cloudflare">Cloudflare CDN (Default)</option>
              <option value="AWS S3">AWS CloudFront / S3</option>
              <option value="Cloudinary">Cloudinary Media API</option>
              <option value="MinIO">MinIO Self-Hosted Storage</option>
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">CDN Base URL</label>
            <input
              type="url"
              value={data.cdnUrl}
              onChange={(e) => onChange({ cdnUrl: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="https://cdn.viegym.vn"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">S3 Bucket Name</label>
            <input
              type="text"
              value={data.s3BucketName}
              onChange={(e) => onChange({ s3BucketName: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="viegym-media-prod"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">AWS / S3 Region</label>
            <input
              type="text"
              value={data.s3Region}
              onChange={(e) => onChange({ s3Region: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="ap-southeast-1 (Singapore)"
            />
          </div>

          <div className="space-y-1.5 md:col-span-2">
            <div className="flex items-center justify-between">
              <label className="text-xs font-semibold text-[#f5f5f6]">Access Key ID &amp; Secret</label>
              <button
                type="button"
                onClick={() => setShowKey(!showKey)}
                className="text-[11px] text-[#ff506d] hover:underline cursor-pointer flex items-center gap-1"
              >
                <span className="material-symbols-outlined text-xs">
                  {showKey ? 'visibility_off' : 'visibility'}
                </span>
                <span>{showKey ? 'Ẩn khóa bảo mật' : 'Hiển thị khóa bảo mật'}</span>
              </button>
            </div>
            <input
              type={showKey ? 'text' : 'password'}
              value={data.accessKeyMasked}
              onChange={(e) => onChange({ accessKeyMasked: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
          </div>
        </div>
      </div>

      {/* Upload Limits & Format Constraints */}
      <div className="p-6 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-5">
        <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
          <div>
            <h3 className="text-base font-bold text-[#f5f5f6]">Giới hạn Tải lên &amp; Tối ưu hóa Media</h3>
            <p className="text-xs text-[#8a8d93] mt-0.5">Kiểm soát kích thước tập tin tối đa và tự động nén dung lượng</p>
          </div>
          <span className="material-symbols-outlined text-[#9b7bff] text-2xl">cloud_upload</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Dung lượng Video tối đa (MB)</label>
            <input
              type="number"
              min={10}
              max={500}
              value={data.maxVideoUploadSizeMb}
              onChange={(e) => onChange({ maxVideoUploadSizeMb: Number(e.target.value) || 10 })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
            <p className="text-[11px] text-[#8a8d93]">Định dạng hỗ trợ: {data.allowedVideoFormats}</p>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Dung lượng Ảnh tối đa (MB)</label>
            <input
              type="number"
              min={1}
              max={50}
              value={data.maxImageUploadSizeMb}
              onChange={(e) => onChange({ maxImageUploadSizeMb: Number(e.target.value) || 1 })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
            <p className="text-[11px] text-[#8a8d93]">Định dạng hỗ trợ: {data.allowedImageFormats}</p>
          </div>
        </div>

        {/* Auto Optimize Toggle */}
        <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-between">
          <div className="space-y-0.5 pr-3">
            <span className="text-sm font-semibold text-[#f5f5f6]">Tự động chuyển đổi sang WebP / MP4 Web-Ready</span>
            <p className="text-xs text-[#8a8d93]">Giúp tiết kiệm tới 65% băng thông và tăng tốc độ tải ứng dụng trên di động</p>
          </div>
          <label className="relative inline-flex items-center cursor-pointer shrink-0">
            <input
              type="checkbox"
              checked={data.autoOptimizeMedia}
              onChange={(e) => onChange({ autoOptimizeMedia: e.target.checked })}
              className="sr-only peer"
            />
            <div className="w-11 h-6 bg-[#17181b] border border-[#34363b] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-[#8a8d93] peer-checked:after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#35c76f]" />
          </label>
        </div>
      </div>
    </div>
  )
}
