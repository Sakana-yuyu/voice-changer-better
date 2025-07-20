import React, { useMemo } from "react";
import { useAppState } from "../../../001_provider/001_AppStateProvider";
import { F0Detector } from "@dannadori/voice-changer-client-js";
import { useAppRoot } from "../../../001_provider/001_AppRootProvider";
import { useMessageBuilder } from "../../../hooks/useMessageBuilder";

export type QualityAreaProps = {
    detectors: string[];
};

export const QualityArea = (props: QualityAreaProps) => {
    const { setVoiceChangerClientSetting, serverSetting, setting, webEdition } = useAppState();
    const { appGuiSettingState } = useAppRoot();
    const messageBuilderState = useMessageBuilder();
    const edition = appGuiSettingState.edition;

    useMemo(() => {
        messageBuilderState.setMessage(__filename, "f0Det", { 
            zh: "F0 检测器", 
            ja: "F0 検出器", 
            ko: "F0 감지기", 
            en: "F0 Detector" 
        });
        messageBuilderState.setMessage(__filename, "silentThresh", { 
            zh: "静音阈值", 
            ja: "無音閾値", 
            ko: "무음 임계값", 
            en: "Silent Threshold" 
        });
        messageBuilderState.setMessage(__filename, "noise", { 
            zh: "噪音控制", 
            ja: "ノイズ制御", 
            ko: "노이즈 제어", 
            en: "Noise Control" 
        });
        messageBuilderState.setMessage(__filename, "echo", { 
            zh: "回声消除", 
            ja: "エコーキャンセル", 
            ko: "에코 제거", 
            en: "Echo Cancel" 
        });
        messageBuilderState.setMessage(__filename, "noiseSup1", { 
            zh: "噪音抑制1", 
            ja: "ノイズ抑制1", 
            ko: "노이즈 억제1", 
            en: "Noise Suppression 1" 
        });
        messageBuilderState.setMessage(__filename, "noiseSup2", { 
            zh: "噪音抑制2", 
            ja: "ノイズ抑制2", 
            ko: "노이즈 억제2", 
            en: "Noise Suppression 2" 
        });
    }, []);

    const qualityArea = useMemo(() => {
        if (!serverSetting.updateServerSettings || !setVoiceChangerClientSetting || !serverSetting.serverSetting || !setting) {
            return <></>;
        }

        const generateF0DetOptions = () => {
            if (edition.indexOf("onnxdirectML-cuda") >= 0) {
                const recommended = ["crepe_tiny", "rmvpe_onnx"];
                return Object.values(props.detectors).map((x) => {
                    if (recommended.includes(x)) {
                        return (
                            <option key={x} value={x}>
                                {x}
                            </option>
                        );
                    } else {
                        return (
                            <option key={x} value={x} disabled>
                                {x}(N/A)
                            </option>
                        );
                    }
                });
            } else {
                return Object.values(props.detectors).map((x) => {
                    return (
                        <option key={x} value={x}>
                            {x}
                        </option>
                    );
                });
            }
        };
        const f0DetOptions = generateF0DetOptions();

        const f0Det = webEdition ? (
            <></>
        ) : (
            <div className="config-sub-area-control">
                <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "f0Det")}:</div>
                <div className="config-sub-area-control-field">
                    <select
                        className="body-select"
                        value={serverSetting.serverSetting.f0Detector}
                        onChange={(e) => {
                            serverSetting.updateServerSettings({ ...serverSetting.serverSetting, f0Detector: e.target.value as F0Detector });
                        }}
                    >
                        {f0DetOptions}
                    </select>
                </div>
            </div>
        );

        const threshold = webEdition ? (
            <></>
        ) : (
            <div className="config-sub-area-control">
                <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "silentThresh")}:</div>
                <div className="config-sub-area-control-field">
                    <div className="config-sub-area-slider-control">
                        <span className="config-sub-area-slider-control-kind"></span>
                        <span className="config-sub-area-slider-control-slider">
                            <input
                                type="range"
                                className="config-sub-area-slider-control-slider"
                                min="0.00000"
                                max="0.001"
                                step="0.00001"
                                value={serverSetting.serverSetting.silentThreshold || 0}
                                onChange={(e) => {
                                    serverSetting.updateServerSettings({ ...serverSetting.serverSetting, silentThreshold: Number(e.target.value) });
                                }}
                            ></input>
                        </span>
                        <span className="config-sub-area-slider-control-val">{serverSetting.serverSetting.silentThreshold}</span>
                    </div>
                </div>
            </div>
        );

        return (
            <div className="config-sub-area">
                <div className="config-sub-area-control">
                    <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "noise")}:</div>
                    <div className="config-sub-area-control-field">
                        <div className="config-sub-area-noise-container">
                            <div className="config-sub-area-noise-checkbox-container">
                                <input
                                    type="checkbox"
                                    disabled={serverSetting.serverSetting.enableServerAudio != 0}
                                    checked={setting.voiceChangerClientSetting.echoCancel}
                                    onChange={(e) => {
                                        try {
                                            setVoiceChangerClientSetting({ ...setting.voiceChangerClientSetting, echoCancel: e.target.checked });
                                        } catch (e) {
                                            console.error(e);
                                        }
                                    }}
                                />{" "}
                                <span>{messageBuilderState.getMessage(__filename, "echo")}</span>
                            </div>
                            <div className="config-sub-area-noise-checkbox-container">
                                <input
                                    type="checkbox"
                                    disabled={serverSetting.serverSetting.enableServerAudio != 0}
                                    checked={setting.voiceChangerClientSetting.noiseSuppression}
                                    onChange={(e) => {
                                        try {
                                            setVoiceChangerClientSetting({ ...setting.voiceChangerClientSetting, noiseSuppression: e.target.checked });
                                        } catch (e) {
                                            console.error(e);
                                        }
                                    }}
                                />{" "}
                                <span>{messageBuilderState.getMessage(__filename, "noiseSup1")}</span>
                            </div>
                            <div className="config-sub-area-noise-checkbox-container">
                                <input
                                    type="checkbox"
                                    disabled={serverSetting.serverSetting.enableServerAudio != 0}
                                    checked={setting.voiceChangerClientSetting.noiseSuppression2}
                                    onChange={(e) => {
                                        try {
                                            setVoiceChangerClientSetting({ ...setting.voiceChangerClientSetting, noiseSuppression2: e.target.checked });
                                        } catch (e) {
                                            console.error(e);
                                        }
                                    }}
                                />{" "}
                                <span>{messageBuilderState.getMessage(__filename, "noiseSup2")}</span>
                            </div>
                        </div>
                    </div>
                </div>
                {f0Det}
                {threshold}
            </div>
        );
    }, [serverSetting.serverSetting, setting, serverSetting.updateServerSettings, setVoiceChangerClientSetting]);

    return qualityArea;
};
