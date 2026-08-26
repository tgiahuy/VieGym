import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { FiSearch } from 'react-icons/fi';
import { AppBar } from '@/components/shared/AppBar';
import { AuthVideoBackground } from '@/components/auth/AuthVideoBackground';
import { EquipmentListItem } from '@/components/onboarding/EquipmentListItem';
import { FaDumbbell, FaWeightHanging, FaDotCircle, FaWater, FaChair, FaShoePrints } from 'react-icons/fa';

const equipmentData = [
  {
    category: 'Tạ nhỏ',
    items: [
      { id: 'db', name: 'Tạ đơn', description: '1.0, 2.5, 5.0...', icon: <FaDumbbell /> },
      { id: 'kb', name: 'Tạ chuông', description: '4.0, 8.0, 12.0...', icon: <FaWeightHanging /> },
    ]
  },
  {
    category: 'Thanh đòn & Đĩa tạ',
    items: [
      { id: 'bb', name: 'Thanh đòn', description: '20.0...', icon: <FaDumbbell /> },
      { id: 'pl', name: 'Đĩa tạ', description: '1.25, 2.5, 5.0...', icon: <FaDotCircle /> },
      { id: 'ez', name: 'Thanh EZ', description: '10.0...', icon: <FaWater /> },
    ]
  },
  {
    category: 'Ghế & Giàn',
    items: [
      { id: 'bench', name: 'Ghế tập', description: 'Phẳng, nghiêng', icon: <FaChair /> },
      { id: 'legpress', name: 'Máy đạp đùi', description: 'Máy cố định', icon: <FaShoePrints /> },
    ]
  }
];

export default function EquipmentOnboardingPage() {
    const navigate = useNavigate();
    const [selected, setSelected] = useState<string[]>([]);
    const [searchTerm, setSearchTerm] = useState('');

    const toggleSelection = (id: string) => {
        setSelected(prev =>
            prev.includes(id) ? prev.filter(item => item !== id) : [...prev, id]
        );
    };

    const filteredEquipment = equipmentData.map(group => ({
        ...group,
        items: group.items.filter(item =>
            item.name.toLowerCase().includes(searchTerm.toLowerCase())
        )
    })).filter(group => group.items.length > 0);

    return (
        <div className="relative min-h-screen">
            <AuthVideoBackground />
            <div className="absolute inset-0 bg-black/70" />
            <div className="relative z-10">
                <AppBar title="Thiết bị của bạn" showActions={false} />
                <main className="container p-4 mx-auto mt-4 pb-32">
                    <p className="text-center text-muted-foreground">Chọn các thiết bị bạn có để chúng tôi cá nhân hóa kế hoạch tập luyện.</p>
                    <div className="relative my-6">
                        <FiSearch className="absolute text-xl left-4 top-1/2 -translate-y-1/2 text-muted-foreground" />
                        <Input
                            placeholder="Tìm kiếm thiết bị..."
                            className="pl-12 h-14 rounded-full bg-secondary/50 border-secondary"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                    <div className="space-y-6">
                        {filteredEquipment.map(group => (
                            <div key={group.category}>
                                <h2 className="text-xl font-bold mb-2 px-2">{group.category}</h2>
                                <div className="space-y-1">
                                    {group.items.map(item => (
                                        <EquipmentListItem
                                            key={item.id}
                                            icon={item.icon}
                                            name={item.name}
                                            description={item.description}
                                            isSelected={selected.includes(item.id)}
                                            onToggle={() => toggleSelection(item.id)}
                                        />
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </main>
                <div className="fixed bottom-0 left-0 right-0 z-20 p-4 bg-background/50 backdrop-blur-sm border-t border-border flex gap-4">
                    <Button onClick={() => navigate('/')} variant="secondary" className="w-full" style={{ height: '56px' }} size="lg">Bỏ qua</Button>
                    <Button onClick={() => navigate('/')} className="w-full" style={{ height: '56px' }} size="lg">Hoàn tất</Button>
                </div>
            </div>
        </div>
    );
}