import React, { useEffect, useMemo, useState } from "react";
import { useAppState } from "../../../001_provider/001_AppStateProvider";
import { useGuiState } from "../001_GuiStateProvider";
import { OnnxExporterInfo } from "@dannadori/voice-changer-client-js";
import { useMessageBuilder } from "../../../hooks/useMessageBuilder";
import { TuningArea } from "./101-1_TuningArea";
import { IndexArea } from "./101-2_IndexArea";
import { SpeakerArea } from "./101-3_SpeakerArea";
import { F0FactorArea } from "./101-4_F0FactorArea";
import { SoVitsSVC40SettingArea } from "./101-5_so-vits-svc40SettingArea";
import { DDSPSVC30SettingArea } from "./101-6_ddsp-svc30SettingArea";
import { DiffusionSVCSettingArea } from "./101-7_diffusion-svcSettingArea";
import { Portrait } from "./101-0_Portrait";
import { useAppRoot } from "../../../001_provider/001_AppRootProvider";
import { WebEditionSettingArea } from "./101-8_web-editionSettingArea";

export type CharacterAreaProps = {};

export const CharacterArea = (_props: CharacterAreaProps) => {
    const { appGuiSettingState } = useAppRoot();
    const { serverSetting, initializedRef, setting, setVoiceChangerClientSetting, start, stop, webInfoState } = useAppState();
    const guiState = useGuiState();
    const messageBuilderState = useMessageBuilder();
    const webEdition = appGuiSettingState.edition.indexOf("web") >= 0;
    const { beatriceJVSSpeakerId } = useGuiState();
    useMemo(() => {
        messageBuilderState.setMessage(__filename, "export_to_onnx", { 
            zh: "导出ONNX", 
            ja: "onnx出力", 
            ko: "ONNX 내보내기", 
            en: "export to onnx" 
        });
        messageBuilderState.setMessage(__filename, "save_default", { 
            zh: "保存设置", 
            ja: "設定保存", 
            ko: "설정 저장", 
            en: "save setting" 
        });
        messageBuilderState.setMessage(__filename, "alert_onnx", { 
            zh: "变声启用时无法导出ONNX", 
            ja: "ボイチェン中はonnx出力できません", 
            ko: "음성 변환이 활성화된 상태에서는 ONNX를 내보낼 수 없습니다", 
            en: "cannot export onnx when voice conversion is enabled" 
        });
        messageBuilderState.setMessage(__filename, "name", { 
            zh: "名称", 
            ja: "名前", 
            ko: "이름", 
            en: "Name" 
        });
        messageBuilderState.setMessage(__filename, "gain", { 
            zh: "增益", 
            ja: "ゲイン", 
            ko: "게인", 
            en: "GAIN" 
        });
        messageBuilderState.setMessage(__filename, "input_gain", { 
            zh: "输入", 
            ja: "入力", 
            ko: "입력", 
            en: "in" 
        });
        messageBuilderState.setMessage(__filename, "output_gain", { 
            zh: "输出", 
            ja: "出力", 
            ko: "출력", 
            en: "out" 
        });
        messageBuilderState.setMessage(__filename, "input_gain_tooltip", { 
            zh: "调整输入音频的音量增益，范围0.1-10.0", 
            ja: "入力音声の音量ゲインを調整します（範囲：0.1-10.0）", 
            ko: "입력 오디오의 볼륨 게인을 조정합니다 (범위: 0.1-10.0)", 
            en: "Adjust the volume gain of input audio (range: 0.1-10.0)" 
        });
        messageBuilderState.setMessage(__filename, "output_gain_tooltip", { 
            zh: "调整输出音频的音量增益，范围0.1-10.0", 
            ja: "出力音声の音量ゲインを調整します（範囲：0.1-10.0）", 
            ko: "출력 오디오의 볼륨 게인을 조정합니다 (범위: 0.1-10.0)", 
            en: "Adjust the volume gain of output audio (range: 0.1-10.0)" 
        });
        messageBuilderState.setMessage(__filename, "wait", { 
            zh: "等待中...", 
            ja: "待機中...", 
            ko: "대기 중...", 
            en: "wait..." 
        });
        messageBuilderState.setMessage(__filename, "start", { 
            zh: "开始", 
            ja: "開始", 
            ko: "시작", 
            en: "start" 
        });
        messageBuilderState.setMessage(__filename, "stop", { 
            zh: "停止", 
            ja: "停止", 
            ko: "중지", 
            en: "stop" 
        });
        messageBuilderState.setMessage(__filename, "passthru", { 
            zh: "直通", 
            ja: "パススルー", 
            ko: "패스스루", 
            en: "passthru" 
        });
        messageBuilderState.setMessage(__filename, "speaker", { 
            zh: "说话人", 
            ja: "話者", 
            ko: "화자", 
            en: "speaker" 
        });
        messageBuilderState.setMessage(__filename, "pre", { 
            zh: "预处理", 
            ja: "前処理", 
            ko: "전처리", 
            en: "pre" 
        });
        messageBuilderState.setMessage(__filename, "model", { 
            zh: "模型", 
            ja: "モデル", 
            ko: "모델", 
            en: "model" 
        });
        messageBuilderState.setMessage(__filename, "warmUp", { 
            zh: "预热", 
            ja: "ウォームアップ", 
            ko: "워밍업", 
            en: "warm up" 
        });
    }, []);

    const selected = useMemo(() => {
        if (webEdition) {
            return webInfoState.webModelslot;
        }
        if (serverSetting.serverSetting.modelSlotIndex == undefined) {
            return;
        } else if (serverSetting.serverSetting.modelSlotIndex == "Beatrice-JVS") {
            const beatriceJVS = serverSetting.serverSetting.modelSlots.find((v) => v.slotIndex == "Beatrice-JVS");
            return beatriceJVS;
        } else {
            return serverSetting.serverSetting.modelSlots[serverSetting.serverSetting.modelSlotIndex];
        }
    }, [serverSetting.serverSetting.modelSlotIndex, serverSetting.serverSetting.modelSlots, webEdition]);

    const [startWithAudioContextCreate, setStartWithAudioContextCreate] = useState<boolean>(false);
    useEffect(() => {
        if (!startWithAudioContextCreate) {
            return;
        }
        guiState.setIsConverting(true);
        start();
    }, [startWithAudioContextCreate]);

    const nameArea = useMemo(() => {
        if (!selected) {
            return <></>;
        }
        return (
            <div className="character-area-control">
                <div className="character-area-control-title">{messageBuilderState.getMessage(__filename, "name")}:</div>
                <div className="character-area-control-field">
                    <div className="character-area-text">
                        {selected.name} {selected.slotIndex == "Beatrice-JVS" ? `${messageBuilderState.getMessage(__filename, "speaker")}:${beatriceJVSSpeakerId}` : ""}
                    </div>
                </div>
            </div>
        );
    }, [selected, beatriceJVSSpeakerId]);

    const startAndGainControl = useMemo(() => {
        const onStartClicked = async () => {
            if (serverSetting.serverSetting.enableServerAudio == 0) {
                if (!initializedRef.current) {
                    while (true) {
                        await new Promise<void>((resolve) => {
                            setTimeout(resolve, 500);
                        });
                        if (initializedRef.current) {
                            break;
                        }
                    }
                    setStartWithAudioContextCreate(true);
                } else {
                    guiState.setIsConverting(true);
                    await start();
                }
            } else {
                serverSetting.updateServerSettings({ ...serverSetting.serverSetting, serverAudioStated: 1 });
                guiState.setIsConverting(true);
            }
        };
        const onStopClicked = async () => {
            if (serverSetting.serverSetting.enableServerAudio == 0) {
                guiState.setIsConverting(false);
                await stop();
            } else {
                guiState.setIsConverting(false);
                serverSetting.updateServerSettings({ ...serverSetting.serverSetting, serverAudioStated: 0 });
            }
        };
        const onPassThroughClicked = async () => {
            if (serverSetting.serverSetting.passThrough == false) {
                if (setting.voiceChangerClientSetting.passThroughConfirmationSkip) {
                    serverSetting.updateServerSettings({ ...serverSetting.serverSetting, passThrough: true });
                    guiState.stateControls.showEnablePassThroughDialogCheckbox.updateState(false);
                } else {
                    guiState.stateControls.showEnablePassThroughDialogCheckbox.updateState(true);
                }
            } else {
                serverSetting.updateServerSettings({ ...serverSetting.serverSetting, passThrough: false });
            }
        };
        const startClassName = guiState.isConverting ? "character-area-control-button-active" : "character-area-control-button-stanby";
        const stopClassName = guiState.isConverting ? "character-area-control-button-stanby" : "character-area-control-button-active";
        const passThruClassName = serverSetting.serverSetting.passThrough == false ? "character-area-control-passthru-button-stanby" : "character-area-control-passthru-button-active blinking";

        const currentInputGain = serverSetting.serverSetting.enableServerAudio == 0 ? setting.voiceChangerClientSetting.inputGain : serverSetting.serverSetting.serverInputAudioGain;
        const inputValueUpdatedAction =
            serverSetting.serverSetting.enableServerAudio == 0
                ? async (val: number) => {
                      await setVoiceChangerClientSetting({ ...setting.voiceChangerClientSetting, inputGain: val });
                  }
                : async (val: number) => {
                      await serverSetting.updateServerSettings({ ...serverSetting.serverSetting, serverInputAudioGain: val });
                  };

        const currentOutputGain = serverSetting.serverSetting.enableServerAudio == 0 ? setting.voiceChangerClientSetting.outputGain : serverSetting.serverSetting.serverOutputAudioGain;
        const outputValueUpdatedAction =
            serverSetting.serverSetting.enableServerAudio == 0
                ? async (val: number) => {
                      await setVoiceChangerClientSetting({ ...setting.voiceChangerClientSetting, outputGain: val });
                  }
                : async (val: number) => {
                      await serverSetting.updateServerSettings({ ...serverSetting.serverSetting, serverOutputAudioGain: val });
                  };

        if (webEdition && webInfoState.webModelLoadingState != "ready") {
            if (webInfoState.webModelLoadingState == "none" || webInfoState.webModelLoadingState == "loading") {
                return (
                    <div className="character-area-control">
                        <div className="character-area-control-title">{messageBuilderState.getMessage(__filename, "wait")}</div>
                        <div className="character-area-control-field">
                            <div className="character-area-text blink">{webInfoState.webModelLoadingState}..</div>
                            <div className="character-area-text">
                                {messageBuilderState.getMessage(__filename, "pre")}:{Math.floor(webInfoState.progressLoadPreprocess * 100)}%, {messageBuilderState.getMessage(__filename, "model")}: {Math.floor(webInfoState.progressLoadVCModel * 100)}%
                            </div>
                        </div>
                    </div>
                );
            } else if (webInfoState.webModelLoadingState == "warmup") {
                return (
                    <div className="character-area-control">
                        <div className="character-area-control-title">{messageBuilderState.getMessage(__filename, "wait")}</div>
                        <div className="character-area-control-field">
                            <div className="character-area-text blink">{webInfoState.webModelLoadingState}..</div>
                            <div className="character-area-text">{messageBuilderState.getMessage(__filename, "warmUp")}:{Math.floor(webInfoState.progressWarmup * 100)}%</div>
                        </div>
                    </div>
                );
            } else {
                throw new Error("invalid webModelLoadingState");
            }
        } else {
            return (
                <div className="character-area-control">
                    <div className="character-area-control-field-horizontal">
                        <div className="character-area-control-buttons">
                            <div onClick={onStartClicked} className={startClassName}>
                                {messageBuilderState.getMessage(__filename, "start")}
                            </div>
                            <div onClick={onStopClicked} className={stopClassName}>
                                {messageBuilderState.getMessage(__filename, "stop")}
                            </div>
                            {!webEdition && (
                                <div onClick={onPassThroughClicked} className={passThruClassName}>
                                    {messageBuilderState.getMessage(__filename, "passthru")}
                                </div>
                            )}
                        </div>
                        <div className="character-area-gain-controls" style={{display: 'flex', gap: '8px', alignItems: 'center', flex: 1}}>
                            <span style={{fontSize: '12px', fontWeight: 'bold', minWidth: '30px'}}>{messageBuilderState.getMessage(__filename, "gain")}:</span>
                            <div className="character-area-slider-control" style={{display: 'flex', alignItems: 'center', gap: '4px', flex: 1}}>
                                <span 
                                    className="character-area-slider-control-kind"
                                    title={messageBuilderState.getMessage(__filename, "input_gain_tooltip")}
                                    style={{fontSize: '11px', minWidth: '20px'}}
                                >
                                    {messageBuilderState.getMessage(__filename, "input_gain")}
                                </span>
                                <span className="character-area-slider-control-slider" style={{flex: 1}}>
                                    <input
                                        type="range"
                                        min="0.1"
                                        max="10.0"
                                        step="0.1"
                                        value={currentInputGain}
                                        onChange={(e) => {
                                            inputValueUpdatedAction(Number(e.target.value));
                                        }}
                                    ></input>
                                </span>
                                <span className="character-area-slider-control-val" style={{fontSize: '11px', minWidth: '25px'}}>{currentInputGain}</span>
                            </div>
                            <div className="character-area-slider-control" style={{display: 'flex', alignItems: 'center', gap: '4px', flex: 1}}>
                                <span 
                                    className="character-area-slider-control-kind"
                                    title={messageBuilderState.getMessage(__filename, "output_gain_tooltip")}
                                    style={{fontSize: '11px', minWidth: '20px'}}
                                >
                                    {messageBuilderState.getMessage(__filename, "output_gain")}
                                </span>
                                <span className="character-area-slider-control-slider" style={{flex: 1}}>
                                    <input
                                        type="range"
                                        min="0.1"
                                        max="10.0"
                                        step="0.1"
                                        value={currentOutputGain}
                                        onChange={(e) => {
                                            outputValueUpdatedAction(Number(e.target.value));
                                        }}
                                    ></input>
                                </span>
                                <span className="character-area-slider-control-val" style={{fontSize: '11px', minWidth: '25px'}}>{currentOutputGain}</span>
                            </div>
                        </div>
                    </div>
                </div>
            );
        }
    }, [guiState.isConverting, start, stop, serverSetting.serverSetting, serverSetting.updateServerSettings, webInfoState.progressLoadPreprocess, webInfoState.progressLoadVCModel, webInfoState.progressWarmup, webInfoState.webModelLoadingState, setting, setVoiceChangerClientSetting]);

    const modelSlotControl = useMemo(() => {
        if (!selected) {
            return <></>;
        }
        if (webEdition) {
            return <></>;
        }
        const onUpdateDefaultClicked = async () => {
            await serverSetting.updateModelDefault();
        };

        const onnxExportButtonAction = async () => {
            if (guiState.isConverting) {
                alert(messageBuilderState.getMessage(__filename, "alert_onnx"));
                return;
            }

            document.getElementById("dialog")?.classList.add("dialog-container-show");
            guiState.stateControls.showWaitingCheckbox.updateState(true);
            const res = (await serverSetting.getOnnx()) as OnnxExporterInfo;
            const a = document.createElement("a");
            a.href = res.path;
            a.download = res.filename;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            guiState.stateControls.showWaitingCheckbox.updateState(false);
        };

        const exportOnnx =
            selected.voiceChangerType == "RVC" && selected.modelFile.endsWith("pth") ? (
                <div className="character-area-button" onClick={onnxExportButtonAction}>
                    {messageBuilderState.getMessage(__filename, "export_to_onnx")}
                </div>
            ) : (
                <></>
            );
        return (
            <div className="character-area-control">
                <div className="character-area-control-title"></div>
                <div className="character-area-control-field">
                    <div className="character-area-buttons">
                        <div className="character-area-button" onClick={onUpdateDefaultClicked}>
                            {messageBuilderState.getMessage(__filename, "save_default")}
                        </div>
                        {exportOnnx}
                    </div>
                </div>
            </div>
        );
    }, [selected, serverSetting.getOnnx, serverSetting.updateModelDefault, guiState.isConverting]);

    const characterArea = useMemo(() => {
        return (
            <div className="character-area">
                <Portrait></Portrait>
                <div className="character-area-control-area">
                    {nameArea}
                    {startAndGainControl}
                    <TuningArea />
                    <IndexArea />
                    <SpeakerArea />
                    <F0FactorArea />
                    <SoVitsSVC40SettingArea />
                    <DDSPSVC30SettingArea />
                    <DiffusionSVCSettingArea />
                    <WebEditionSettingArea />
                    {modelSlotControl}
                </div>
            </div>
        );
    }, [startAndGainControl, modelSlotControl]);

    return characterArea;
};
