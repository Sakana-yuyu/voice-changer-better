import React, { useMemo } from "react";
import { useGuiState } from "./001_GuiStateProvider";
import { useAppState } from "../../001_provider/001_AppStateProvider";
import { useMessageBuilder } from "../../hooks/useMessageBuilder";


export const GetServerInfomationDialog = () => {
    const guiState = useGuiState()
    const { serverSetting } = useAppState()
    const messageBuilderState = useMessageBuilder();

    useMemo(() => {
        // 国际化消息
        messageBuilderState.setMessage(__filename, "serverInformation", {
            "ja": "サーバー情報",
            "en": "Server Information",
            "ko": "서버 정보",
            "zh": "服务器信息"
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
                <div className="body-item-text">
                </div>
                <div className="body-button-container body-button-container-space-around">
                    <div className="body-button" onClick={() => { guiState.stateControls.showGetServerInformationCheckbox.updateState(false) }} >{messageBuilderState.getMessage(__filename, "close")}</div>
                </div>
                <div className="body-item-text"></div>
            </div>
        )
        const content = (
            <div className="get-server-information-container">
                <textarea className="get-server-information-text-area" id="get-server-information-text-area" value={JSON.stringify(serverSetting.serverSetting, null, 4)} onChange={() => { }} />
            </div>
        )
        return (
            <div className="dialog-frame">
                <div className="dialog-title">{messageBuilderState.getMessage(__filename, "serverInformation")}</div>
                <div className="dialog-content">
                    {content}
                    {closeButtonRow}
                </div>
            </div>
        );
    }, [serverSetting.serverSetting]);
    return dialog;

};
