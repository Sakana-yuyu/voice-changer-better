import React, { useMemo } from "react";
import { useGuiState } from "./001_GuiStateProvider";
import { useAppState } from "../../001_provider/001_AppStateProvider";
import { CrossFadeOverlapSize, Protocol } from "@dannadori/voice-changer-client-js";
import { useMessageBuilder } from "../../hooks/useMessageBuilder";

export const AdvancedSettingDialog = () => {
    const guiState = useGuiState();
    const { setting, serverSetting, setWorkletNodeSetting, setWorkletSetting, setVoiceChangerClientSetting } = useAppState();
    const messageBuilderState = useMessageBuilder();

    useMemo(() => {
        // 国际化消息
    messageBuilderState.setMessage(__filename, "advancedSetting", {
        "ja": "高度な設定",
        "en": "Advanced Setting",
        "ko": "고급 설정",
        "zh": "高级设置"
    });
    messageBuilderState.setMessage(__filename, "close", {
        "ja": "閉じる",
        "en": "close",
        "ko": "닫기",
        "zh": "关闭"
    });
    messageBuilderState.setMessage(__filename, "protocol", {
        "ja": "プロトコル",
        "en": "protocol",
        "ko": "프로토콜",
        "zh": "协议"
    });
    messageBuilderState.setMessage(__filename, "crossfade", {
        "ja": "クロスフェード",
        "en": "Crossfade",
        "ko": "크로스페이드",
        "zh": "交叉淡化"
    });
    messageBuilderState.setMessage(__filename, "overlap", {
        "ja": "重複",
        "en": "overlap",
        "ko": "겹침",
        "zh": "重叠"
    });
    messageBuilderState.setMessage(__filename, "start", {
        "ja": "開始",
        "en": "start",
        "ko": "시작",
        "zh": "开始"
    });
    messageBuilderState.setMessage(__filename, "end", {
        "ja": "終了",
        "en": "end",
        "ko": "끝",
        "zh": "结束"
    });
    messageBuilderState.setMessage(__filename, "trancate", {
        "ja": "切り捨て",
        "en": "Trancate",
        "ko": "자르기",
        "zh": "截断"
    });
    messageBuilderState.setMessage(__filename, "silenceFront", {
        "ja": "無音フロント",
        "en": "SilenceFront",
        "ko": "무음 앞부분",
        "zh": "静音前端"
    });
    messageBuilderState.setMessage(__filename, "off", {
        "ja": "オフ",
        "en": "off",
        "ko": "끄기",
        "zh": "关闭"
    });
    messageBuilderState.setMessage(__filename, "on", {
        "ja": "オン",
        "en": "on",
        "ko": "켜기",
        "zh": "开启"
    });
    messageBuilderState.setMessage(__filename, "protect", {
        "ja": "保護",
        "en": "Protect",
        "ko": "보호",
        "zh": "保护"
    });
    messageBuilderState.setMessage(__filename, "rvcQuality", {
        "ja": "RVC品質",
        "en": "RVC Quality",
        "ko": "RVC 품질",
        "zh": "RVC质量"
    });
    messageBuilderState.setMessage(__filename, "low", {
        "ja": "低",
        "en": "low",
        "ko": "낮음",
        "zh": "低"
    });
    messageBuilderState.setMessage(__filename, "high", {
        "ja": "高",
        "en": "high",
        "ko": "높음",
        "zh": "高"
    });
    messageBuilderState.setMessage(__filename, "skipPassThroughConfirmation", {
        "ja": "パススルー確認をスキップ",
        "en": "Skip Pass through confirmation",
        "ko": "패스스루 확인 건너뛰기",
        "zh": "跳过直通确认"
    });
    messageBuilderState.setMessage(__filename, "no", {
        "ja": "いいえ",
        "en": "No",
        "ko": "아니오",
        "zh": "否"
    });
    messageBuilderState.setMessage(__filename, "yes", {
        "ja": "はい",
        "en": "Yes",
        "ko": "예",
        "zh": "是"
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
                            guiState.stateControls.showAdvancedSettingCheckbox.updateState(false);
                        }}
                    >
                        {messageBuilderState.getMessage(__filename, "close")}
                    </div>
                </div>
                <div className="body-item-text"></div>
            </div>
        );

        const onProtocolChanged = async (val: Protocol) => {
            setWorkletNodeSetting({ ...setting.workletNodeSetting, protocol: val });
        };
        const protocolRow = (
            <div className="advanced-setting-container-row">
                <div className="advanced-setting-container-row-title">{messageBuilderState.getMessage(__filename, "protocol")}</div>
                <div className="advanced-setting-container-row-field">
                    <select
                        value={setting.workletNodeSetting.protocol}
                        onChange={(e) => {
                            onProtocolChanged(e.target.value as Protocol);
                        }}
                    >
                        {Object.values(Protocol).map((x) => {
                            return (
                                <option key={x} value={x}>
                                    {x}
                                </option>
                            );
                        })}
                    </select>
                </div>
            </div>
        );
        const crossfaceRow = (
            <div className="advanced-setting-container-row">
                <div className="advanced-setting-container-row-title">{messageBuilderState.getMessage(__filename, "crossfade")}</div>
                <div className="advanced-setting-container-row-field">
                    <div className="advanced-setting-container-row-field-crossfade-container">
                        <div>
                            <div>{messageBuilderState.getMessage(__filename, "overlap")}:</div>
                            <div>
                                <select
                                    className="body-select"
                                    value={serverSetting.serverSetting.crossFadeOverlapSize}
                                    onChange={(e) => {
                                        serverSetting.updateServerSettings({ ...serverSetting.serverSetting, crossFadeOverlapSize: Number(e.target.value) as CrossFadeOverlapSize });
                                    }}
                                >
                                    {Object.values(CrossFadeOverlapSize).map((x) => {
                                        return (
                                            <option key={x} value={x}>
                                                {x}
                                            </option>
                                        );
                                    })}
                                </select>
                            </div>
                        </div>
                        <div>
                            <div>{messageBuilderState.getMessage(__filename, "start")}:</div>
                            <div>
                                <input
                                    type="number"
                                    min={0}
                                    max={1}
                                    step={0.1}
                                    value={serverSetting.serverSetting.crossFadeOffsetRate}
                                    onChange={(e) => {
                                        serverSetting.updateServerSettings({ ...serverSetting.serverSetting, crossFadeOffsetRate: Number(e.target.value) });
                                    }}
                                />
                            </div>
                        </div>
                        <div>
                            <div>{messageBuilderState.getMessage(__filename, "end")}:</div>
                            <div>
                                <input
                                    type="number"
                                    min={0}
                                    max={1}
                                    step={0.1}
                                    value={serverSetting.serverSetting.crossFadeEndRate}
                                    onChange={(e) => {
                                        serverSetting.updateServerSettings({ ...serverSetting.serverSetting, crossFadeEndRate: Number(e.target.value) });
                                    }}
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );

        const trancateRow = (
            <div className="advanced-setting-container-row">
                <div className="advanced-setting-container-row-title">{messageBuilderState.getMessage(__filename, "trancate")}</div>
                <div className="advanced-setting-container-row-field">
                    <input
                        type="number"
                        min={5}
                        max={300}
                        step={1}
                        value={setting.workletSetting.numTrancateTreshold}
                        onChange={(e) => {
                            setWorkletSetting({
                                ...setting.workletSetting,
                                numTrancateTreshold: Number(e.target.value),
                            });
                        }}
                    />
                </div>
            </div>
        );

        const onSilenceFrontChanged = (val: number) => {
            serverSetting.updateServerSettings({
                ...serverSetting.serverSetting,
                silenceFront: val,
            });
        };
        const silenceFrontRow = (
            <div className="advanced-setting-container-row">
                <div className="advanced-setting-container-row-title">{messageBuilderState.getMessage(__filename, "silenceFront")}</div>
                <div className="advanced-setting-container-row-field">
                    <select
                        value={serverSetting.serverSetting.silenceFront}
                        onChange={(e) => {
                            onSilenceFrontChanged(Number(e.target.value));
                        }}
                    >
                        <option value="0">{messageBuilderState.getMessage(__filename, "off")}</option>
                        <option value="1">{messageBuilderState.getMessage(__filename, "on")}</option>
                    </select>
                </div>
            </div>
        );

        const protectRow = (
            <div className="advanced-setting-container-row">
                <div className="advanced-setting-container-row-title">{messageBuilderState.getMessage(__filename, "protect")}</div>
                <div className="advanced-setting-container-row-field">
                    <div>
                        <input
                            type="range"
                            className="body-item-input-slider"
                            min="0"
                            max="0.5"
                            step="0.1"
                            value={serverSetting.serverSetting.protect || 0}
                            onChange={(e) => {
                                serverSetting.updateServerSettings({ ...serverSetting.serverSetting, protect: Number(e.target.value) });
                            }}
                        ></input>
                        <span className="body-item-input-slider-val">{serverSetting.serverSetting.protect}</span>
                    </div>
                </div>
            </div>
        );

        const onRVCQualityChanged = (val: number) => {
            serverSetting.updateServerSettings({
                ...serverSetting.serverSetting,
                rvcQuality: val,
            });
        };
        const rvcQualityRow = (
            <div className="advanced-setting-container-row">
                <div className="advanced-setting-container-row-title">{messageBuilderState.getMessage(__filename, "rvcQuality")}</div>
                <div className="advanced-setting-container-row-field">
                    <select
                        value={serverSetting.serverSetting.rvcQuality}
                        onChange={(e) => {
                            onRVCQualityChanged(Number(e.target.value));
                        }}
                    >
                        <option value="0">{messageBuilderState.getMessage(__filename, "low")}</option>
                        <option value="1">{messageBuilderState.getMessage(__filename, "high")}</option>
                    </select>
                </div>
            </div>
        );
        const skipPassThroughConfirmationRow = (
            <div className="advanced-setting-container-row">
                <div className="advanced-setting-container-row-title-long">{messageBuilderState.getMessage(__filename, "skipPassThroughConfirmation")}</div>
                <div className="advanced-setting-container-row-field">
                    <select
                        value={setting.voiceChangerClientSetting.passThroughConfirmationSkip ? "1" : "0"}
                        onChange={(e) => {
                            setVoiceChangerClientSetting({ ...setting.voiceChangerClientSetting, passThroughConfirmationSkip: e.target.value == "1" ? true : false });
                        }}
                    >
                        <option value="0">{messageBuilderState.getMessage(__filename, "no")}</option>
                        <option value="1">{messageBuilderState.getMessage(__filename, "yes")}</option>
                    </select>
                </div>
            </div>
        );
        const content = (
            <div className="advanced-setting-container">
                {protocolRow}
                {crossfaceRow}
                {trancateRow}
                {silenceFrontRow}
                {protectRow}
                {rvcQualityRow}
                {skipPassThroughConfirmationRow}
            </div>
        );

        return (
            <div className="dialog-frame">
                <div className="dialog-title">{messageBuilderState.getMessage(__filename, "advancedSetting")}</div>
                <div className="dialog-content">
                    {content}
                    {closeButtonRow}
                </div>
            </div>
        );
    }, [serverSetting.serverSetting, serverSetting.updateServerSettings, setting.workletNodeSetting, setWorkletNodeSetting, setting.workletSetting, setWorkletSetting]);
    return dialog;
};
