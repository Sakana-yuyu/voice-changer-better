import React, { useMemo } from "react";
import { useGuiState } from "./001_GuiStateProvider";
import { useAppState } from "../../001_provider/001_AppStateProvider";
import { useAppRoot } from "../../001_provider/001_AppRootProvider";
import { useMessageBuilder } from "../../hooks/useMessageBuilder";

export const GetClientInfomationDialog = () => {
    const guiState = useGuiState();
    const { audioContextState } = useAppRoot();
    const { setting } = useAppState();
    const messageBuilderState = useMessageBuilder();

    useMemo(() => {
        // 国际化消息
        messageBuilderState.setMessage(__filename, "clientInformation", {
            "ja": "クライアント情報",
            "en": "Client Information",
            "ko": "클라이언트 정보",
            "zh": "客户端信息"
        });
        messageBuilderState.setMessage(__filename, "close", {
            "ja": "閉じる",
            "en": "close",
            "ko": "닫기",
            "zh": "关闭"
        });
    }, []);
    const dialog = useMemo(() => {
        const closeButtonRow = (
            <div className="body-row split-3-4-3 left-padding-1">
                <div className="body-item-text"></div>
                <div className="body-button-container body-button-container-space-around">
                    <div
                        className="body-button"
                        onClick={() => {
                            guiState.stateControls.showGetClientInformationCheckbox.updateState(false);
                        }}
                    >
                        {messageBuilderState.getMessage(__filename, "close")}
                    </div>
                </div>
                <div className="body-item-text"></div>
            </div>
        );

        const settingJson = JSON.stringify(setting, null, 4);
        const rootAudioContextJson = JSON.stringify(
            {
                sampleRate: audioContextState.audioContext?.sampleRate,
                baseLatency: audioContextState.audioContext?.baseLatency,
                currentTime: audioContextState.audioContext?.currentTime,
                outputLatency: audioContextState.audioContext?.outputLatency,
                // @ts-ignore
                sinkId: audioContextState.audioContext?.sinkId,
                state: audioContextState.audioContext?.state,
            },
            null,
            4
        );

        const concatJson = settingJson + "\n" + rootAudioContextJson;
        console.log("AUDIO_CONTEXT", audioContextState.audioContext);
        const content = (
            <div className="get-server-information-container">
                <textarea className="get-server-information-text-area" id="get-server-information-text-area" value={concatJson} onChange={() => {}} />
            </div>
        );
        return (
            <div className="dialog-frame">
                <div className="dialog-title">{messageBuilderState.getMessage(__filename, "clientInformation")}</div>
                <div className="dialog-content">
                    {content}
                    {closeButtonRow}
                </div>
            </div>
        );
    }, [setting, audioContextState]);
    return dialog;
};
