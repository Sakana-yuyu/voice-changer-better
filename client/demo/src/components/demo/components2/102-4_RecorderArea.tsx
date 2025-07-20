import React, { useMemo, useState } from "react";
import { useAppState } from "../../../001_provider/001_AppStateProvider";
import { useGuiState } from "../001_GuiStateProvider";
import { AUDIO_ELEMENT_FOR_SAMPLING_INPUT, AUDIO_ELEMENT_FOR_SAMPLING_OUTPUT } from "../../../const";
import { useMessageBuilder } from "../../../hooks/useMessageBuilder";

export type RecorderAreaProps = {};

export const RecorderArea = (_props: RecorderAreaProps) => {
    const { serverSetting, webEdition } = useAppState();
    const { audioOutputForAnalyzer, setAudioOutputForAnalyzer, outputAudioDeviceInfo } = useGuiState();
    const messageBuilderState = useMessageBuilder();
    const [serverIORecording, setServerIORecording] = useState<boolean>(false);

    useMemo(() => {
        messageBuilderState.setMessage(__filename, "serverIOAnalyzer", { 
            zh: "服务器IO分析器", 
            ja: "サーバーIO分析器", 
            ko: "서버 IO 분석기", 
            en: "ServerIO Analyzer" 
        });
        messageBuilderState.setMessage(__filename, "sioRec", { 
            zh: "SIO录制", 
            ja: "SIO録音", 
            ko: "SIO 녹음", 
            en: "SIO Rec." 
        });
        messageBuilderState.setMessage(__filename, "start", { 
            zh: "开始", 
            ja: "開始", 
            ko: "시작", 
            en: "Start" 
        });
        messageBuilderState.setMessage(__filename, "stop", { 
            zh: "停止", 
            ja: "停止", 
            ko: "정지", 
            en: "Stop" 
        });
        messageBuilderState.setMessage(__filename, "output", { 
            zh: "输出", 
            ja: "出力", 
            ko: "출력", 
            en: "Output" 
        });
        messageBuilderState.setMessage(__filename, "in", { 
            zh: "输入", 
            ja: "入力", 
            ko: "입력", 
            en: "In" 
        });
        messageBuilderState.setMessage(__filename, "out", { 
            zh: "输出", 
            ja: "出力", 
            ko: "출력", 
            en: "Out" 
        });
    }, []);

    const serverIORecorderRow = useMemo(() => {
        if (webEdition) {
            return <> </>;
        }
        const onServerIORecordStartClicked = async () => {
            setServerIORecording(true);
            await serverSetting.updateServerSettings({ ...serverSetting.serverSetting, recordIO: 1 });
        };
        const onServerIORecordStopClicked = async () => {
            setServerIORecording(false);
            await serverSetting.updateServerSettings({ ...serverSetting.serverSetting, recordIO: 0 });

            // set wav (input)
            const wavInput = document.getElementById(AUDIO_ELEMENT_FOR_SAMPLING_INPUT) as HTMLAudioElement;
            wavInput.src = "/tmp/in.wav?" + new Date().getTime();
            wavInput.controls = true;
            try {
                // @ts-ignore
                wavInput.setSinkId(audioOutputForAnalyzer);
            } catch (e) {
                console.log(e);
            }

            // set wav (output)
            const wavOutput = document.getElementById(AUDIO_ELEMENT_FOR_SAMPLING_OUTPUT) as HTMLAudioElement;
            wavOutput.src = "/tmp/out.wav?" + new Date().getTime();
            wavOutput.controls = true;
            try {
                // @ts-ignore
                wavOutput.setSinkId(audioOutputForAnalyzer);
            } catch (e) {
                console.log(e);
            }
        };

        const startClassName = serverIORecording ? "config-sub-area-button-active" : "config-sub-area-button";
        const stopClassName = serverIORecording ? "config-sub-area-button" : "config-sub-area-button-active";
        return (
            <>
                <div className="config-sub-area-control">
                    <div className="config-sub-area-control-title-long">{messageBuilderState.getMessage(__filename, "serverIOAnalyzer")}</div>
                </div>

                <div className="config-sub-area-control left-padding-1">
                    <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "sioRec")}</div>
                    <div className="config-sub-area-control-field">
                        <div className="config-sub-area-buttons">
                            <div onClick={onServerIORecordStartClicked} className={startClassName}>
                                {messageBuilderState.getMessage(__filename, "start")}
                            </div>
                            <div onClick={onServerIORecordStopClicked} className={stopClassName}>
                                {messageBuilderState.getMessage(__filename, "stop")}
                            </div>
                        </div>
                    </div>
                </div>

                <div className="config-sub-area-control left-padding-1">
                    <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "output")}</div>
                    <div className="config-sub-area-control-field">
                        <div className="config-sub-area-control-field-auido-io">
                            <select
                                className="body-select"
                                value={audioOutputForAnalyzer}
                                onChange={(e) => {
                                    setAudioOutputForAnalyzer(e.target.value);
                                    const wavInput = document.getElementById(AUDIO_ELEMENT_FOR_SAMPLING_INPUT) as HTMLAudioElement;
                                    const wavOutput = document.getElementById(AUDIO_ELEMENT_FOR_SAMPLING_OUTPUT) as HTMLAudioElement;
                                    try {
                                        //@ts-ignore
                                        wavInput.setSinkId(e.target.value);
                                        //@ts-ignore
                                        wavOutput.setSinkId(e.target.value);
                                    } catch (e) {
                                        console.log(e);
                                    }
                                }}
                            >
                                {outputAudioDeviceInfo
                                    .map((x) => {
                                        if (x.deviceId == "none") {
                                            return null;
                                        }
                                        return (
                                            <option key={x.deviceId} value={x.deviceId}>
                                                {x.label}
                                            </option>
                                        );
                                    })
                                    .filter((x) => {
                                        return x != null;
                                    })}
                            </select>
                        </div>
                    </div>
                </div>

                <div className="config-sub-area-control left-padding-1">
                    <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "in")}</div>
                    <div className="config-sub-area-control-field">
                        <div className="config-sub-area-control-field-wav-file">
                            <div className="config-sub-area-control-field-wav-file-audio-container">
                                <audio className="config-sub-area-control-field-wav-file-audio" id={AUDIO_ELEMENT_FOR_SAMPLING_INPUT} controls></audio>
                            </div>
                        </div>
                    </div>
                </div>
                <div className="config-sub-area-control left-padding-1">
                    <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "out")}</div>
                    <div className="config-sub-area-control-field">
                        <div className="config-sub-area-control-field-wav-file">
                            <div className="config-sub-area-control-field-wav-file-audio-container">
                                <audio className="config-sub-area-control-field-wav-file-audio" id={AUDIO_ELEMENT_FOR_SAMPLING_OUTPUT} controls></audio>
                            </div>
                        </div>
                    </div>
                </div>
            </>
        );
    }, [serverIORecording, audioOutputForAnalyzer, outputAudioDeviceInfo, serverSetting.updateServerSettings]);

    return <div className="config-sub-area">{serverIORecorderRow}</div>;
};
