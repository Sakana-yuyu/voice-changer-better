import React, { useMemo } from "react";
import { useAppState } from "../../../001_provider/001_AppStateProvider";
import { useMessageBuilder } from "../../../hooks/useMessageBuilder";

export type SpeakerAreaProps = {};

export const SpeakerArea = (_props: SpeakerAreaProps) => {
    const { serverSetting } = useAppState();
    const messageBuilderState = useMessageBuilder();

    useMemo(() => {
        messageBuilderState.setMessage(__filename, "voice", { 
            zh: "声音:", 
            ja: "音声:", 
            ko: "음성:", 
            en: "Voice:" 
        });
        messageBuilderState.setMessage(__filename, "src", { 
            zh: "源", 
            ja: "ソース", 
            ko: "소스", 
            en: "src" 
        });
        messageBuilderState.setMessage(__filename, "dst", { 
            zh: "目标", 
            ja: "ターゲット", 
            ko: "대상", 
            en: "dst" 
        });
    }, []);

    const selected = useMemo(() => {
        if (serverSetting.serverSetting.modelSlotIndex == undefined) {
            return;
        } else if (serverSetting.serverSetting.modelSlotIndex == "Beatrice-JVS") {
            const beatriceJVS = serverSetting.serverSetting.modelSlots.find((v) => v.slotIndex == "Beatrice-JVS");
            return beatriceJVS;
        } else {
            return serverSetting.serverSetting.modelSlots[serverSetting.serverSetting.modelSlotIndex];
        }
    }, [serverSetting.serverSetting.modelSlotIndex, serverSetting.serverSetting.modelSlots]);

    const srcArea = useMemo(() => {
        if (!selected) {
            return <></>;
        }

        if (selected.voiceChangerType != "MMVCv13" && selected.voiceChangerType != "MMVCv15") {
            return <></>;
        }
        const options = Object.keys(selected.speakers).map((key) => {
            const val = selected.speakers[Number(key)];
            return (
                <option key={key} value={key}>
                    {val}[{key}]
                </option>
            );
        });

        const srcSpeakerValueUpdatedAction = async (val: number) => {
            await serverSetting.updateServerSettings({ ...serverSetting.serverSetting, srcId: val });
        };

        return (
            <div className="character-area-control">
                <div className="character-area-control-title">{messageBuilderState.getMessage(__filename, "voice")}</div>
                <div className="character-area-control-field">
                    <div className="character-area-slider-control">
                        <span className="character-area-slider-control-kind">{messageBuilderState.getMessage(__filename, "src")}</span>
                        <span className="character-area-slider-control-slider">
                            <select
                                value={serverSetting.serverSetting.srcId}
                                onChange={(e) => {
                                    srcSpeakerValueUpdatedAction(Number(e.target.value));
                                }}
                            >
                                {options}
                            </select>
                        </span>
                    </div>
                </div>
            </div>
        );
    }, [serverSetting.serverSetting, serverSetting.updateServerSettings, selected]);

    const dstArea = useMemo(() => {
        if (!selected) {
            return <></>;
        }
        if (selected.slotIndex == "Beatrice-JVS") {
            return; // beatrice JVS は変換先話者をグラフから選択するので、ここでは表示しない
        }

        const options = Object.keys(selected.speakers).map((key) => {
            const val = selected.speakers[Number(key)];
            return (
                <option key={key} value={key}>
                    {val}[{key}]
                </option>
            );
        });

        const srcSpeakerValueUpdatedAction = async (val: number) => {
            await serverSetting.updateServerSettings({ ...serverSetting.serverSetting, dstId: val });
        };

        return (
            <div className="character-area-control">
                <div className="character-area-control-title">{selected.voiceChangerType == "DDSP-SVC" || selected.voiceChangerType == "so-vits-svc-40" || selected.voiceChangerType == "RVC" ? messageBuilderState.getMessage(__filename, "voice") : ""}</div>
                <div className="character-area-control-field">
                    <div className="character-area-slider-control">
                        <span className="character-area-slider-control-kind">{selected.voiceChangerType == "MMVCv13" || selected.voiceChangerType == "MMVCv15" ? messageBuilderState.getMessage(__filename, "dst") : ""}</span>
                        <span className="character-area-slider-control-slider">
                            <select
                                value={serverSetting.serverSetting.dstId}
                                onChange={(e) => {
                                    srcSpeakerValueUpdatedAction(Number(e.target.value));
                                }}
                            >
                                {options}
                            </select>
                        </span>
                    </div>
                </div>
            </div>
        );
    }, [serverSetting.serverSetting, serverSetting.updateServerSettings, selected]);

    return (
        <>
            {srcArea}
            {dstArea}
        </>
    );
};
