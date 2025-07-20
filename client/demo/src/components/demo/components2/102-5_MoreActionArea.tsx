import React, { useMemo } from "react";
import { useGuiState } from "../001_GuiStateProvider";
import { useAppState } from "../../../001_provider/001_AppStateProvider";
import { useMessageBuilder } from "../../../hooks/useMessageBuilder";

export type MoreActionAreaProps = {};

export const MoreActionArea = (_props: MoreActionAreaProps) => {
    const { stateControls } = useGuiState();
    const { webEdition } = useAppState();
    const messageBuilderState = useMessageBuilder();

    useMemo(() => {
        messageBuilderState.setMessage(__filename, "more", { 
            zh: "更多", 
            ja: "その他", 
            ko: "더보기", 
            en: "More..." 
        });
        messageBuilderState.setMessage(__filename, "mergeLab", { 
            zh: "合并实验室", 
            ja: "マージラボ", 
            ko: "병합 랩", 
            en: "Merge Lab" 
        });
        messageBuilderState.setMessage(__filename, "advancedSetting", { 
            zh: "高级设置", 
            ja: "詳細設定", 
            ko: "고급 설정", 
            en: "Advanced Setting" 
        });
        messageBuilderState.setMessage(__filename, "serverInfo", { 
            zh: "服务器信息", 
            ja: "サーバー情報", 
            ko: "서버 정보", 
            en: "Server Info" 
        });
        messageBuilderState.setMessage(__filename, "clientInfo", { 
            zh: "客户端信息", 
            ja: "クライアント情報", 
            ko: "클라이언트 정보", 
            en: "Client Info" 
        });
    }, []);

    const serverIORecorderRow = useMemo(() => {
        const onOpenMergeLabClicked = () => {
            stateControls.showMergeLabCheckbox.updateState(true);
        };
        const onOpenAdvancedSettingClicked = () => {
            stateControls.showAdvancedSettingCheckbox.updateState(true);
        };
        const onOpenGetServerInformationClicked = () => {
            stateControls.showGetServerInformationCheckbox.updateState(true);
        };
        const onOpenGetClientInformationClicked = () => {
            stateControls.showGetClientInformationCheckbox.updateState(true);
        };
        return (
            <>
                <div className="config-sub-area-control left-padding-1">
                    <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "more")}</div>
                    <div className="config-sub-area-control-field config-sub-area-control-field-long">
                        <div className="config-sub-area-buttons">
                            <div onClick={onOpenMergeLabClicked} className="config-sub-area-button">
                                {messageBuilderState.getMessage(__filename, "mergeLab")}
                            </div>
                            <div onClick={onOpenAdvancedSettingClicked} className="config-sub-area-button">
                                {messageBuilderState.getMessage(__filename, "advancedSetting")}
                            </div>
                            <div onClick={onOpenGetServerInformationClicked} className="config-sub-area-button">
                                {messageBuilderState.getMessage(__filename, "serverInfo")}
                            </div>
                            <div onClick={onOpenGetClientInformationClicked} className="config-sub-area-button">
                                {messageBuilderState.getMessage(__filename, "clientInfo")}
                            </div>
                        </div>
                    </div>
                </div>
            </>
        );
    }, [stateControls]);

    if (webEdition) {
        return <> </>;
    } else {
        return <div className="config-sub-area">{serverIORecorderRow}</div>;
    }
};
