import { useRef, useState } from 'react'
import { apiClient } from '../../core/api/client'

type UploadState = 'idle' | 'uploading' | 'completing' | 'ready' | 'error'
interface InitResponse { mediaId:number; uploadUrl:string; requiredHeaders:Record<string,string> }
interface MediaResponse { id:number; fileName:string; mimeType:string; fileSizeBytes:number; status:string }

interface Props {
  ownerType: 'EXERCISE' | 'FOOD'
  ownerId?: string
  accept?: string
  onReady?: (media: MediaResponse) => void
}

export function MediaUploader({ ownerType, ownerId, accept = 'image/jpeg,image/png,image/webp,video/mp4', onReady }: Props) {
  const input = useRef<HTMLInputElement>(null)
  const [file, setFile] = useState<File | null>(null)
  const [progress, setProgress] = useState(0)
  const [status, setStatus] = useState<UploadState>('idle')
  const [error, setError] = useState<string | null>(null)

  const upload = async (selected: File) => {
    if (!ownerId || !/^\d+$/.test(ownerId)) { setError('Hãy lưu nội dung trước khi tải media.'); setStatus('error'); return }
    const isVideo = selected.type === 'video/mp4'
    const max = isVideo ? 50 * 1024 * 1024 : 5 * 1024 * 1024
    if (selected.size > max) { setError(`Tệp vượt giới hạn ${isVideo ? 50 : 5} MB.`); setStatus('error'); return }
    setFile(selected); setError(null); setProgress(0); setStatus('uploading')
    try {
      const init = await apiClient<InitResponse>('/admin/media/init-upload', { method:'POST', csrfRequired:true, body:JSON.stringify({ ownerType, ownerId:Number(ownerId), mediaType:isVideo?'VIDEO':'IMAGE', role:isVideo?'PRIMARY_VIDEO':'THUMBNAIL', sortOrder:1, fileName:selected.name, mimeType:selected.type, fileSizeBytes:selected.size }) })
      await new Promise<void>((resolve, reject) => {
        const xhr = new XMLHttpRequest(); xhr.open('PUT', init.uploadUrl)
        Object.entries(init.requiredHeaders).forEach(([key,value]) => xhr.setRequestHeader(key,value))
        xhr.upload.onprogress = (event) => event.lengthComputable && setProgress(Math.round(event.loaded / event.total * 100))
        xhr.onload = () => xhr.status >= 200 && xhr.status < 300 ? resolve() : reject(new Error(`Upload HTTP ${xhr.status}`))
        xhr.onerror = () => reject(new Error('Mất kết nối khi tải tệp')); xhr.send(selected)
      })
      setStatus('completing')
      const media = await apiClient<MediaResponse>(`/admin/media/${init.mediaId}/complete`, { method:'POST', csrfRequired:true })
      setProgress(100); setStatus('ready'); onReady?.(media)
    } catch (reason) { setStatus('error'); setError(reason instanceof Error ? reason.message : 'Không thể tải tệp') }
  }

  return <div className="rounded-xl border border-dashed border-[#4d8dff]/50 bg-[#4d8dff]/5 p-4">
    <input ref={input} className="sr-only" type="file" accept={accept} onChange={(event) => { const selected=event.target.files?.[0]; if(selected) void upload(selected) }} />
    <div className="flex items-center justify-between gap-3">
      <div><p className="text-sm font-semibold text-[#f5f5f6]">{file?.name ?? 'Ảnh hoặc video minh họa'}</p><p className="mt-1 text-xs text-[#8a8d93]">JPG/PNG/WebP tối đa 5 MB · MP4 tối đa 50 MB</p></div>
      <button type="button" onClick={() => input.current?.click()} className="h-10 rounded-lg bg-[#222327] px-3 text-xs font-semibold text-[#f5f5f6]">{status === 'error' ? 'Thử lại' : 'Chọn tệp'}</button>
    </div>
    {status !== 'idle' && <div className="mt-3"><div className="h-1.5 overflow-hidden rounded bg-[#292a2f]"><div className="h-full bg-[#4d8dff] transition-all" style={{width:`${progress}%`}} /></div><p className={`mt-1 text-xs ${error?'text-[#ff5a5f]':'text-[#a7a9ae]'}`}>{error ?? (status==='ready'?'Đã xác minh và sẵn sàng':status==='completing'?'Đang xác minh MIME và object…':`Đang tải ${progress}%`)}</p></div>}
  </div>
}
