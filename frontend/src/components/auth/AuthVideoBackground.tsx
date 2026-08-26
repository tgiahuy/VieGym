import React from 'react';

const videoUrl = "https://videos.pexels.com/video-files/3838708/3838708-hd.mp4";

export const AuthVideoBackground: React.FC = () => {
  return (
    <video
      className="absolute top-0 left-0 w-full h-full object-cover -z-10"
      src={videoUrl}
      autoPlay
      loop
      muted
      playsInline
    />
  );
};