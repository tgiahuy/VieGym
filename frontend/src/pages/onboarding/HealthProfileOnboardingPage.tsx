import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { OnboardingLayout } from '@/components/onboarding/OnboardingLayout';
import { SelectableCard } from '@/components/onboarding/SelectableCard';
import { Button } from '@/components/ui/button';
import { AuthVideoBackground } from '@/components/auth/AuthVideoBackground';
import RulerPicker from '@/components/onboarding/RulerPicker';
import { FaVenus, FaMars } from 'react-icons/fa';

const TOTAL_STEPS = 5;

export default function HealthProfileOnboardingPage() {
    const navigate = useNavigate();
    const [step, setStep] = useState(1);
    const [formData, setFormData] = useState({
        gender: '',
        height: 170,
        weight: 65,
        goal: '',
        activityLevel: '',
        experience: '',
    });

    const handleNext = () => {
        if (step < TOTAL_STEPS) {
            setStep(step + 1);
        } else {
            navigate('/onboarding/equipment');
        }
    };

    const handleBack = () => {
        if (step > 1) {
            setStep(step - 1);
        }
    };

    const handleSelection = (field: keyof typeof formData, value: string) => {
        setFormData(prev => ({ ...prev, [field]: value }));
        setTimeout(() => handleNext(), 300);
    };

    const renderStepContent = () => {
        switch (step) {
            case 1:
                return (
                    <OnboardingLayout step={1} totalSteps={TOTAL_STEPS} title="Giới tính của bạn?" onBack={handleBack}>
                        <div className="grid grid-cols-2 gap-4">
                            <SelectableCard icon={<FaMars />} title="Nam" isSelected={formData.gender === 'male'} onClick={() => handleSelection('gender', 'male')} />
                            <SelectableCard icon={<FaVenus />} title="Nữ" isSelected={formData.gender === 'female'} onClick={() => handleSelection('gender', 'female')} />
                        </div>
                    </OnboardingLayout>
                );
            case 2:
                return (
                    <OnboardingLayout step={2} totalSteps={TOTAL_STEPS} title="Chiều cao & Cân nặng" onBack={handleBack}>
                        <div className="space-y-12">
                            <RulerPicker min={120} max={220} unit="cm" value={formData.height} onChange={(val) => setFormData(prev => ({ ...prev, height: val }))} />
                            <RulerPicker min={40} max={150} unit="kg" value={formData.weight} onChange={(val) => setFormData(prev => ({ ...prev, weight: val }))} />
                        </div>
                    </OnboardingLayout>
                );
            case 3:
                return (
                    <OnboardingLayout step={3} totalSteps={TOTAL_STEPS} title="Mục tiêu chính?" onBack={handleBack}>
                        <div className="space-y-4">
                            <SelectableCard title="Tăng cơ" isSelected={formData.goal === 'gain'} onClick={() => handleSelection('goal', 'gain')} />
                            <SelectableCard title="Giảm mỡ" isSelected={formData.goal === 'lose'} onClick={() => handleSelection('goal', 'lose')} />
                            <SelectableCard title="Tăng sức mạnh" isSelected={formData.goal === 'strength'} onClick={() => handleSelection('goal', 'strength')} />
                        </div>
                    </OnboardingLayout>
                );
            case 4:
                 return (
                    <OnboardingLayout step={4} totalSteps={TOTAL_STEPS} title="Mức độ vận động?" onBack={handleBack}>
                        <div className="space-y-4">
                            <SelectableCard title="Ít vận động" description="Ngồi nhiều, làm việc văn phòng" isSelected={formData.activityLevel === 'sedentary'} onClick={() => handleSelection('activityLevel', 'sedentary')} />
                            <SelectableCard title="Vận động nhẹ" description="Đi bộ, công việc nhẹ nhàng" isSelected={formData.activityLevel === 'light'} onClick={() => handleSelection('activityLevel', 'light')} />
                            <SelectableCard title="Năng động" description="Tập thể dục thường xuyên" isSelected={formData.activityLevel === 'active'} onClick={() => handleSelection('activityLevel', 'active')} />
                        </div>
                    </OnboardingLayout>
                );
            case 5:
                return (
                    <OnboardingLayout step={5} totalSteps={TOTAL_STEPS} title="Kinh nghiệm tập luyện?" onBack={handleBack}>
                        <div className="space-y-4">
                            <SelectableCard title="Mới bắt đầu" description="Dưới 6 tháng" isSelected={formData.experience === 'beginner'} onClick={() => handleSelection('experience', 'beginner')} />
                            <SelectableCard title="Trung bình" description="6 tháng - 2 năm" isSelected={formData.experience === 'intermediate'} onClick={() => handleSelection('experience', 'intermediate')} />
                            <SelectableCard title="Nâng cao" description="Trên 2 năm" isSelected={formData.experience === 'advanced'} onClick={() => handleSelection('experience', 'advanced')} />
                        </div>
                    </OnboardingLayout>
                );
            default:
                return null;
        }
    };

    return (
        <div className="relative min-h-screen">
            <AuthVideoBackground />
            <div className="absolute inset-0 bg-black/70" />
            <div className="relative z-10 min-h-screen px-6 pt-8 pb-32">
                {renderStepContent()}
            </div>
            {step === 2 && (
                <div className="fixed bottom-0 left-0 right-0 z-20 p-4 bg-transparent">
                    <Button onClick={handleNext} className="w-full" style={{ height: '56px' }} size="lg">
                        Tiếp tục
                    </Button>
                </div>
            )}
        </div>
    );
}