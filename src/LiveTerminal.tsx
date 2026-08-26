import {Video} from "@remotion/media";
import {AbsoluteFill, staticFile} from "remotion";

export const liveFps = 30;
export const liveWidth = 1920;
export const liveHeight = 1080;

// 62.7s live take at 30 fps (ffprobe).
export const liveDurationFrames = 1881;

export const LiveTerminal: React.FC = () => {
  return (
    <AbsoluteFill style={{backgroundColor: "#111111"}}>
      <Video
        src={staticFile("live-terminal.mp4")}
        muted
        objectFit="contain"
        style={{width: "100%", height: "100%"}}
      />
    </AbsoluteFill>
  );
};
