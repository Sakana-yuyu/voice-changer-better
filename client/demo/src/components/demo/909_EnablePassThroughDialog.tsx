import React, { useMemo } from "react";
import { useGuiState } from "./001_GuiStateProvider";
import { useAppState } from "../../001_provider/001_AppStateProvider";
import { useAppRoot } from "../../001_provider/001_AppRootProvider";
import { useMessageBuilder } from "../../hooks/useMessageBuilder";

export const EnablePassThroughDialog = () => {
    const guiState = useGuiState();
    const { audioContextState } = useAppRoot();
    const { serverSetting } = useAppState();
    const { setting } = useAppState();
    const messageBuilderState = useMessageBuilder();

    useMemo(() => {
        // 国际化消息
        messageBuilderState.setMessage(__filename, "enablePassThrough", {
            "ja": "パススルーを有効にする",
            "en": "Enable Pass Through",
            "ko": "패스스루 활성화",
            "zh": "启用直通"
        });
        messageBuilderState.setMessage(__filename, "ok", {
            "ja": "OK",
            "en": "OK",
            "ko": "확인",
            "zh": "确定"
        });
        messageBuilderState.setMessage(__filename, "cancel", {
            "ja": "キャンセル",
            "en": "Cancel",
            "ko": "취소",
            "zh": "取消"
        });
    }, []);
    const dialog = useMemo(() => {
        const buttonRow = (
            <div className="body-row split-3-4-3 left-padding-1">
                <div className="body-item-text"></div>
                <div className="body-button-container body-button-container-space-around">
                    <div
                        className="body-button"
                        onClick={() => {
                            serverSetting.updateServerSettings({ ...serverSetting.serverSetting, passThrough: true });
                            guiState.stateControls.showEnablePassThroughDialogCheckbox.updateState(false);
                        }}
                    >
                        {messageBuilderState.getMessage(__filename, "ok")}
                    </div>
                    <div
                        className="body-button"
                        onClick={() => {
                            guiState.stateControls.showEnablePassThroughDialogCheckbox.updateState(false);
                        }}
                    >
                        {messageBuilderState.getMessage(__filename, "cancel")}
                    </div>
                </div>
                <div className="body-item-text"></div>
            </div>
        );

        console.log("AUDIO_CONTEXT", audioContextState.audioContext);
        return (
            <div className="dialog-frame">
                <div className="dialog-title">{messageBuilderState.getMessage(__filename, "enablePassThrough")}</div>
                <div className="dialog-content">{buttonRow}</div>
            </div>
        );
    }, [setting, audioContextState, serverSetting.serverSetting]);
    return dialog;
};
