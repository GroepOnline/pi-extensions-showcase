import "./index.css";
import {Composition, Folder} from "remotion";
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

const size = {
  fps,
  width: layout.width,
  height: layout.height,
};

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="PiExtensionsFilm"
        component={PiExtensionsFilm}
        durationInFrames={filmDuration}
        {...size}
      />
      <Folder name="Scenes">
        <Composition
          id="Open"
          component={Open}
          durationInFrames={sceneFrames.open}
          {...size}
        />
        <Composition
          id="Stack"
          component={Stack}
          durationInFrames={sceneFrames.stack}
          {...size}
        />
        <Composition
          id="Wishcraft"
          component={Wishcraft}
          durationInFrames={sceneFrames.wishcraft}
          {...size}
        />
        <Composition
          id="Orchestrator"
          component={Orchestrator}
          durationInFrames={sceneFrames.orchestrator}
          {...size}
        />
        <Composition
          id="Tools"
          component={Tools}
          durationInFrames={sceneFrames.tools}
          {...size}
        />
        <Composition
          id="Missions"
          component={Missions}
          durationInFrames={sceneFrames.missions}
          {...size}
        />
        <Composition
          id="Control"
          component={Control}
          durationInFrames={sceneFrames.control}
          {...size}
        />
        <Composition
          id="Close"
          component={Close}
          durationInFrames={sceneFrames.close}
          {...size}
        />
      </Folder>
    </>
  );
};
