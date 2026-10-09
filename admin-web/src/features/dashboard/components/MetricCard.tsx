import React from 'react'

export interface MetricCardProps {
  title: string
  value: string | number
  unit?: string
  icon: string
  iconColor: string
  subtitle: React.ReactNode
  badge: React.ReactNode
}

export const MetricCard: React.FC<MetricCardProps> = ({
  title,
  value,
  unit,
  icon,
  iconColor,
  subtitle,
  badge,
}) => {
  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-[18px] p-5 flex flex-col justify-between min-h-[132px] hover:border-[#34363b] transition-colors">
      <div className="flex items-center justify-between text-[#a7a9ae]">
        <span className="text-xs font-semibold tracking-wider uppercase">{title}</span>
        <div className={`w-8 h-8 rounded-lg bg-[#222327] border border-[#292a2f] flex items-center justify-center ${iconColor}`}>
          <span className="material-symbols-outlined text-lg">{icon}</span>
        </div>
      </div>

      <div className="my-2 flex items-baseline gap-2">
        <div className="text-[28px] leading-[34px] font-bold tracking-tight text-[#f5f5f6]">
          {value}
        </div>
        {unit && <span className="text-xs text-[#9b7bff] font-medium">{unit}</span>}
      </div>

      <div className="flex items-center justify-between text-xs pt-1 border-t border-[#292a2f]/50">
        <div className="text-[#a7a9ae]">{subtitle}</div>
        <div>{badge}</div>
      </div>
    </div>
  )
}
