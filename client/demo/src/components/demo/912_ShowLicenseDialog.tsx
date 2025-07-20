////// Currently not used /////////

import React, { useMemo } from "react";
import { useGuiState } from "./001_GuiStateProvider";
import { isDesktopApp } from "../../const";
import { useMessageBuilder } from "../../hooks/useMessageBuilder";

export const ShowLicenseDialog = () => {
    const guiState = useGuiState();

    const messageBuilderState = useMessageBuilder();
    useMemo(() => {
        messageBuilderState.setMessage(__filename, "nsf_hifigan1", {
            ja: "Diffusion SVC, DDSP SVCはvocodeerはDiffSinger Community Vocodersを使用しています。次のリンクからライセンスをご確認ください。",
            en: "Diffusion SVC and DDSP SVC uses DiffSinger Community Vocoders. Please check the license from the following link.",
            ko: "Diffusion SVC, DDSP SVC는 DiffSinger Community Vocoders를 사용합니다. 다음 링크에서 라이선스를 확인하세요.",
            zh: "Diffusion SVC和DDSP SVC使用DiffSinger Community Vocoders。请从以下链接查看许可证。"
        });
        messageBuilderState.setMessage(__filename, "nsf_hifigan2", { 
            ja: "別のモデルを使用する場合はpretrain\\nsf_hifiganに設置してください。", 
            en: "Please place it on pretrain\\nsf_hifigan if you are using a different model.",
            ko: "다른 모델을 사용하는 경우 pretrain\\nsf_hifigan에 배치하세요.",
            zh: "如果使用其他模型，请放置在pretrain\\nsf_hifigan中。"
        });
        messageBuilderState.setMessage(__filename, "license", {
            ja: "ライセンス",
            en: "license",
            ko: "라이선스",
            zh: "许可证"
        });
        messageBuilderState.setMessage(__filename, "close", {
            ja: "閉じる",
            en: "close",
            ko: "닫기",
            zh: "关闭"
        });
        messageBuilderState.setMessage(__filename, "licenseDialog", {
            ja: "ライセンスダイアログ",
            en: "License Dialog",
            ko: "라이선스 대화상자",
            zh: "许可证对话框"
        });
    }, []);

    const hifiGanLink = useMemo(() => {
        return isDesktopApp() ? (
            // @ts-ignore
            <span
                className="link"
                onClick={() => {
                    // @ts-ignore
                    window.electronAPI.openBrowser("https://openvpi.github.io/vocoders/");
                }}
            >
                {messageBuilderState.getMessage(__filename, "license")}
            </span>
        ) : (
            <a className="link" href="https://openvpi.github.io/vocoders/" target="_blank" rel="noopener noreferrer">
                license
            </a>
        );
    }, []);

    const dialog = useMemo(() => {
        const hifiganMessage = (
            <div className="dialog-content-part">
                <div>{messageBuilderState.getMessage(__filename, "nsf_hifigan1")}</div>
                <div>{messageBuilderState.getMessage(__filename, "nsf_hifigan2")}</div>
                <div>{hifiGanLink}</div>
            </div>
        );

        const buttonsRow = (
            <div className="body-row split-3-4-3 left-padding-1">
                <div className="body-item-text"></div>
                <div className="body-button-container body-button-container-space-around">
                    <div
                        className="body-button"
                        onClick={() => {
                            guiState.stateControls.showLicenseCheckbox.updateState(false);
                        }}
                    >
                        {messageBuilderState.getMessage(__filename, "close")}
                    </div>
                </div>
                <div className="body-item-text"></div>
            </div>
        );

        return (
            <div className="dialog-frame">
                <div className="dialog-title">{messageBuilderState.getMessage(__filename, "licenseDialog")}</div>
                <div className="dialog-content">
                    <div className="body-row">{hifiganMessage}</div>
                    {buttonsRow}
                </div>
            </div>
        );
    }, [guiState.textInputResolve]);
    return dialog;
};
