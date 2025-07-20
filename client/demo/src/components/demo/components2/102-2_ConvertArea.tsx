import React, { useMemo } from "react";
import { useAppState } from "../../../001_provider/001_AppStateProvider";
import { useAppRoot } from "../../../001_provider/001_AppRootProvider";
import { useMessageBuilder } from "../../../hooks/useMessageBuilder";

export type ConvertProps = {
    inputChunkNums: number[];
};

export const ConvertArea = (props: ConvertProps) => {
    const { setting, serverSetting, setWorkletNodeSetting, trancateBuffer, webEdition } = useAppState();
    const { appGuiSettingState } = useAppRoot();
    const messageBuilderState = useMessageBuilder();
    const edition = appGuiSettingState.edition;

    useMemo(() => {
        messageBuilderState.setMessage(__filename, "chunk", { 
            zh: "数据块大小", 
            ja: "チャンクサイズ", 
            ko: "청크 크기", 
            en: "Chunk Size" 
        });
        messageBuilderState.setMessage(__filename, "gpu", { 
            zh: "GPU设备", 
            ja: "GPU", 
            ko: "GPU", 
            en: "GPU" 
        });
        messageBuilderState.setMessage(__filename, "extra", { 
            zh: "额外转换大小", 
            ja: "追加変換サイズ", 
            ko: "추가 변환 크기", 
            en: "Extra Convert Size" 
        });
        messageBuilderState.setMessage(__filename, "moreInfo", { 
            zh: "更多信息", 
            ja: "詳細情報", 
            ko: "자세한 정보", 
            en: "More Info" 
        });
        messageBuilderState.setMessage(__filename, "cpu", { 
            zh: "处理器", 
            ja: "CPU", 
            ko: "CPU", 
            en: "cpu" 
        });
        messageBuilderState.setMessage(__filename, "gpu0", { 
            zh: "显卡0", 
            ja: "GPU0", 
            ko: "GPU0", 
            en: "gpu0" 
        });
        messageBuilderState.setMessage(__filename, "gpu1", { 
            zh: "显卡1", 
            ja: "GPU1", 
            ko: "GPU1", 
            en: "gpu1" 
        });
        messageBuilderState.setMessage(__filename, "gpu2", { 
            zh: "显卡2", 
            ja: "GPU2", 
            ko: "GPU2", 
            en: "gpu2" 
        });
        messageBuilderState.setMessage(__filename, "gpu3", { 
            zh: "显卡3", 
            ja: "GPU3", 
            ko: "GPU3", 
            en: "gpu3" 
        });
    }, []);

    const convertArea = useMemo(() => {
        let nums: number[];
        if (!props.inputChunkNums) {
            nums = [8, 16, 24, 32, 40, 48, 64, 80, 96, 112, 128, 192, 256, 320, 384, 448, 512, 576, 640, 704, 768, 832, 896, 960, 1024, 2048, 4096, 8192, 16384];
        } else {
            nums = props.inputChunkNums;
        }
        if (serverSetting.serverSetting.maxInputLength) {
            nums = nums.filter((x) => {
                return x < serverSetting.serverSetting.maxInputLength / 128;
            });
        }

        const gpusEntry = [...serverSetting.serverSetting.gpus];
        gpusEntry.push({
            id: -1,
            name: "cpu",
            memory: 0,
        });

        // const onClassName = serverSetting.serverSetting.gpu == 0 ? "config-sub-area-button-active" : "config-sub-area-button";
        // const offClassName = serverSetting.serverSetting.gpu == 0 ? "config-sub-area-button" : "config-sub-area-button-active";

        const cpuClassName = serverSetting.serverSetting.gpu == -1 ? "config-sub-area-button-active" : "config-sub-area-button";
        const gpu0ClassName = serverSetting.serverSetting.gpu == 0 ? "config-sub-area-button-active" : "config-sub-area-button";
        const gpu1ClassName = serverSetting.serverSetting.gpu == 1 ? "config-sub-area-button-active" : "config-sub-area-button";
        const gpu2ClassName = serverSetting.serverSetting.gpu == 2 ? "config-sub-area-button-active" : "config-sub-area-button";
        const gpu3ClassName = serverSetting.serverSetting.gpu == 3 ? "config-sub-area-button-active" : "config-sub-area-button";

        const gpuSelect =
            edition.indexOf("onnxdirectML-cuda") >= 0 ? (
                <>
                    <div className="config-sub-area-control">
                        <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "gpu")}(dml):</div>
                        <div className="config-sub-area-control-field">
                            <div className="config-sub-area-buttons">
                                <div
                                    onClick={async () => {
                                        await serverSetting.updateServerSettings({
                                            ...serverSetting.serverSetting,
                                            gpu: -1,
                                        });
                                    }}
                                    className={cpuClassName}
                                >
                                    <span className="config-sub-area-button-text-small">{messageBuilderState.getMessage(__filename, "cpu")}</span>
                                </div>
                                <div
                                    onClick={async () => {
                                        await serverSetting.updateServerSettings({
                                            ...serverSetting.serverSetting,
                                            gpu: 0,
                                        });
                                    }}
                                    className={gpu0ClassName}
                                >
                                    <span className="config-sub-area-button-text-small">{messageBuilderState.getMessage(__filename, "gpu0")}</span>
                                </div>
                                <div
                                    onClick={async () => {
                                        await serverSetting.updateServerSettings({
                                            ...serverSetting.serverSetting,
                                            gpu: 1,
                                        });
                                    }}
                                    className={gpu1ClassName}
                                >
                                    <span className="config-sub-area-button-text-small">{messageBuilderState.getMessage(__filename, "gpu1")}</span>
                                </div>
                                <div
                                    onClick={async () => {
                                        await serverSetting.updateServerSettings({
                                            ...serverSetting.serverSetting,
                                            gpu: 2,
                                        });
                                    }}
                                    className={gpu2ClassName}
                                >
                                    <span className="config-sub-area-button-text-small">{messageBuilderState.getMessage(__filename, "gpu2")}</span>
                                </div>
                                <div
                                    onClick={async () => {
                                        await serverSetting.updateServerSettings({
                                            ...serverSetting.serverSetting,
                                            gpu: 3,
                                        });
                                    }}
                                    className={gpu3ClassName}
                                >
                                    <span className="config-sub-area-button-text-small">{messageBuilderState.getMessage(__filename, "gpu3")}</span>
                                </div>
                                <div className="config-sub-area-control">
                                    <span className="config-sub-area-button-text-small">
                                        <a href="https://github.com/w-okada/voice-changer/issues/410">{messageBuilderState.getMessage(__filename, "moreInfo")}</a>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </>
            ) : webEdition ? (
                <></>
            ) : (
                <div className="config-sub-area-control">
                    <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "gpu")}:</div>
                    <div className="config-sub-area-control-field">
                        <select
                            className="body-select"
                            value={serverSetting.serverSetting.gpu}
                            onChange={(e) => {
                                serverSetting.updateServerSettings({ ...serverSetting.serverSetting, gpu: Number(e.target.value) });
                            }}
                        >
                            {gpusEntry.map((x) => {
                                return (
                                    <option key={x.id} value={x.id}>
                                        {x.name}
                                        {x.name == "cpu" ? "" : `(${(x.memory / 1024 / 1024 / 1024).toFixed(0)}GB)`}{" "}
                                    </option>
                                );
                            })}
                        </select>
                    </div>
                </div>
            );

        const extraArea = webEdition ? (
            <></>
        ) : (
            <div className="config-sub-area-control">
                <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "extra")}:</div>
                <div className="config-sub-area-control-field">
                    <select
                        className="body-select"
                        value={serverSetting.serverSetting.extraConvertSize}
                        onChange={(e) => {
                            serverSetting.updateServerSettings({ ...serverSetting.serverSetting, extraConvertSize: Number(e.target.value) });
                            trancateBuffer();
                        }}
                    >
                        {[1024 * 4, 1024 * 8, 1024 * 16, 1024 * 32, 1024 * 64, 1024 * 128].map((x) => {
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
        return (
            <div className="config-sub-area">
                <div className="config-sub-area-control">
                    <div className="config-sub-area-control-title">{messageBuilderState.getMessage(__filename, "chunk")}:</div>
                    <div className="config-sub-area-control-field">
                        <select
                            className="body-select"
                            value={setting.workletNodeSetting.inputChunkNum}
                            onChange={(e) => {
                                setWorkletNodeSetting({ ...setting.workletNodeSetting, inputChunkNum: Number(e.target.value) });
                                trancateBuffer();
                                serverSetting.updateServerSettings({ ...serverSetting.serverSetting, serverReadChunkSize: Number(e.target.value) });
                            }}
                        >
                            {nums.map((x) => {
                                return (
                                    <option key={x} value={x}>
                                        {x} ({((x * 128 * 1000) / 48000).toFixed(1)} ms, {x * 128})
                                    </option>
                                );
                            })}
                        </select>
                    </div>
                </div>
                {extraArea}
                {gpuSelect}
            </div>
        );
    }, [serverSetting.serverSetting, setting, serverSetting.updateServerSettings, setWorkletNodeSetting, edition]);

    return convertArea;
};
