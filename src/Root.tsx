import "./index.css";
import {Composition, Folder} from "remotion";
import {
  LiveTerminal,
  liveDurationFrames,
  liveFps,
  liveHeight,
  liveWidth,
} from "./LiveTerminal";
import {PiExtensionsFilm} from "./PiExtensionsFilm";
import {Close} from "./scenes/Close";
import {Control} from "./scenes/Control";
import {Missions} from "./scenes/Missions";
import {Open} from "./scenes/Open";
import {Orchestrator} from "./scenes/Orchestrator";
import {Stack} from "./scenes/Stack";
import {Tools} from "./scenes/Tools";
import {Wishcraft} from "./scenes/Wishcraft";
import {filmDuration, fps, sceneFrames} from "./timing";
import {layout} from "./theme";

const cards = {
  fps,
  width: layout.width,
  height: layout.height,
};

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="LiveTerminal"
        component={LiveTerminal}
        durationInFrames={liveDurationFrames}
        fps={liveFps}
        width={liveWidth}
        height={liveHeight}
      />
      <Folder name="title-cards">
        <Composition
          id="PiExtensionsFilm"
          component={PiExtensionsFilm}
          durationInFrames={filmDuration}
          {...cards}
        />
        <Composition
          id="Open"
          component={Open}
          durationInFrames={sceneFrames.open}
          {...cards}
        />
        <Composition
          id="Stack"
          component={Stack}
          durationInFrames={sceneFrames.stack}
          {...cards}
        />
        <Composition
          id="Wishcraft"
          component={Wishcraft}
          durationInFrames={sceneFrames.wishcraft}
          {...cards}
        />
        <Composition
          id="Orchestrator"
          component={Orchestrator}
          durationInFrames={sceneFrames.orchestrator}
          {...cards}
        />
        <Composition
          id="Tools"
          component={Tools}
          durationInFrames={sceneFrames.tools}
          {...cards}
        />
        <Composition
          id="Missions"
          component={Missions}
          durationInFrames={sceneFrames.missions}
          {...cards}
        />
        <Composition
          id="Control"
          component={Control}
          durationInFrames={sceneFrames.control}
          {...cards}
        />
        <Composition
          id="Close"
          component={Close}
          durationInFrames={sceneFrames.close}
          {...cards}
        />
      </Folder>
    </>
  );
};
