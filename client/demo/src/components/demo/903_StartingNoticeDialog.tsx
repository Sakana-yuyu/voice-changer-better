import React, { useMemo } from "react";
import { useGuiState } from "./001_GuiStateProvider";
import { isDesktopApp } from "../../const";
import { useAppRoot } from "../../001_provider/001_AppRootProvider";
import { useMessageBuilder } from "../../hooks/useMessageBuilder";

export const StartingNoticeDialog = () => {
    const guiState = useGuiState();
    const { appGuiSettingState } = useAppRoot();

    const messageBuilderState = useMessageBuilder();
    useMemo(() => {
        messageBuilderState.setMessage(__filename, "support", { 
            ja: "支援", 
            en: "Donation", 
            zh: "支持", 
            ko: "지원" 
        });
        messageBuilderState.setMessage(__filename, "support_message_1", { 
            ja: "このソフトウェアを気に入ったら開発者にコーヒーをご馳走してあげよう。黄色いアイコンから。", 
            en: "This software is supported by donations. Thank you for your support!", 
            zh: "如果您喜欢这个软件，请通过黄色图标为开发者买杯咖啡。", 
            ko: "이 소프트웨어가 마음에 드시면 노란색 아이콘을 통해 개발자에게 커피를 사주세요." 
        });
        messageBuilderState.setMessage(__filename, "support_message_2", { 
            ja: "コーヒーをご馳走する。", 
            en: "I will support a developer by buying coffee.", 
            zh: "我要为开发者买咖啡。", 
            ko: "개발자에게 커피를 사겠습니다." 
        });

        messageBuilderState.setMessage(__filename, "directml_1", { 
            ja: "directML版は実験的バージョンです。以下の既知の問題があります。", 
            en: "DirectML version is an experimental version. There are the known issues as follows.", 
            zh: "DirectML版本是实验性版本。存在以下已知问题。", 
            ko: "DirectML 버전은 실험적 버전입니다. 다음과 같은 알려진 문제가 있습니다." 
        });
        messageBuilderState.setMessage(__filename, "directml_2", {
            ja: "(1) 一部の設定変更を行うとgpuを使用していても変換処理が遅くなることが発生します。もしこの現象が発生したらGPUの値を-1にしてから再度0に戻してください。",
            en: "(1) When some settings are changed, conversion process becomes slow even when using GPU. If this occurs, reset the GPU value to -1 and then back to 0.",
            zh: "(1) 更改某些设置时，即使使用GPU，转换处理也可能变慢。如果发生这种情况，请将GPU值设置为-1，然后再设置回0。",
            ko: "(1) 일부 설정을 변경하면 GPU를 사용하더라도 변환 처리가 느려질 수 있습니다. 이런 현상이 발생하면 GPU 값을 -1로 설정한 후 다시 0으로 되돌리세요."
        });
        messageBuilderState.setMessage(__filename, "web_edditon_1", { 
            ja: "このWebエディションは実験的バージョンです。", 
            en: "This edition(web) is an experimental Edition.", 
            zh: "此Web版本是实验性版本。", 
            ko: "이 웹 에디션은 실험적 버전입니다." 
        });
        messageBuilderState.setMessage(__filename, "web_edditon_2", {
            ja: "より高機能・高性能なFullエディションは、",
            en: "The more advanced and high-performance Full Edition can be obtained for free from the following GitHub repository.",
            zh: "功能更强大、性能更高的完整版可以从以下GitHub仓库免费获取。",
            ko: "더 고급 기능과 고성능의 풀 에디션은 다음 GitHub 저장소에서 무료로 얻을 수 있습니다."
        });
        messageBuilderState.setMessage(__filename, "web_edditon_3", {
            ja: "次のgithubリポジトリから無料で取得できます。",
            en: "",
            zh: "",
            ko: ""
        });
        messageBuilderState.setMessage(__filename, "github", { 
            ja: "github", 
            en: "github", 
            zh: "github", 
            ko: "github" 
        });

        messageBuilderState.setMessage(__filename, "click_to_start", { 
            ja: "スタートボタンを押してください。", 
            en: "Click to start", 
            zh: "请点击开始按钮。", 
            ko: "시작 버튼을 클릭하세요." 
        });
        messageBuilderState.setMessage(__filename, "start", { 
            ja: "スタート", 
            en: "start", 
            zh: "开始", 
            ko: "시작" 
        });
    }, []);

    const coffeeLink = useMemo(() => {
        return isDesktopApp() ? (
            // @ts-ignore
            <span
                className="link"
                onClick={() => {
                    // @ts-ignore
                    window.electronAPI.openBrowser("https://www.buymeacoffee.com/wokad");
                }}
            >
                <img className="donate-img" src="./assets/buymeacoffee.png" /> {messageBuilderState.getMessage(__filename, "support_message_2")}
            </span>
        ) : (
            <a className="link" href="https://www.buymeacoffee.com/wokad" target="_blank" rel="noopener noreferrer">
                <img className="donate-img" src="./assets/buymeacoffee.png" /> {messageBuilderState.getMessage(__filename, "support_message_2")}
            </a>
        );
    }, []);

    useMemo(() => {
        messageBuilderState.setMessage(__filename, "license_notice", {
            ja: "ライセンス通知",
            en: "License Notice",
            zh: "许可证通知",
            ko: "라이선스 공지"
        });
    }, []);

    const licenseNoticeLink = useMemo(() => {
        return isDesktopApp() ? (
            <span
                className="link"
                onClick={() => {
                    // @ts-ignore
                    window.electronAPI.openBrowser("https://github.com/w-okada/voice-changer/blob/master/LICENSE-NOTICE");
                }}
            >
                {messageBuilderState.getMessage(__filename, "license_notice")}
            </span>
        ) : (
            <a className="link" href="https://github.com/w-okada/voice-changer/blob/master/LICENSE-NOTICE" target="_blank" rel="noopener noreferrer">
                {messageBuilderState.getMessage(__filename, "license_notice")}
            </a>
        );
    }, []);

    const dialog = useMemo(() => {
        const closeButtonRow = (
            <div className="body-row split-3-4-3 left-padding-1">
                <div className="body-item-text"></div>
                <div className="body-button-container body-button-container-space-around">
                    <div
                        className="body-button"
                        onClick={() => {
                            guiState.stateControls.showStartingNoticeCheckbox.updateState(false);
                        }}
                    >
                        {messageBuilderState.getMessage(__filename, "start")}
                    </div>
                </div>
                <div className="body-item-text"></div>
            </div>
        );

        const donationMessage = (
            <div className="dialog-content-part">
                <div>{messageBuilderState.getMessage(__filename, "support_message_1")}</div>
                <div>{coffeeLink}</div>
            </div>
        );

        const directMLMessage = (
            <div className="dialog-content-part">
                <div>{messageBuilderState.getMessage(__filename, "directml_1")}</div>
                <div className="left-padding-1">{messageBuilderState.getMessage(__filename, "directml_2")}</div>
            </div>
        );

        const licenseInfo = <div className="dialog-content-part">{licenseNoticeLink}</div>;

        const webEdtionMessage = (
            <div className="dialog-content-part">
                <div>{messageBuilderState.getMessage(__filename, "web_edditon_1")}</div>
                <div>{messageBuilderState.getMessage(__filename, "web_edditon_2")}</div>
                <div>{messageBuilderState.getMessage(__filename, "web_edditon_3")}</div>
            </div>
        );

        const githubLink = isDesktopApp() ? (
            <span
                className="link tooltip"
                onClick={() => {
                    // @ts-ignore
                    window.electronAPI.openBrowser("https://github.com/w-okada/voice-changer");
                }}
            >
                <img src="./assets/icons/github.svg" />
                <div className="tooltip-text">{messageBuilderState.getMessage(__filename, "github")}</div>
                <div>github</div>
            </span>
        ) : (
            <a className="link tooltip" href="https://github.com/w-okada/voice-changer" target="_blank" rel="noopener noreferrer">
                <img src="./assets/icons/github.svg" />
                <span>github</span>
                <div className="tooltip-text">{messageBuilderState.getMessage(__filename, "github")}</div>
            </a>
        );

        const clickToStartMessage = (
            <div className="dialog-content-part">
                <div>{messageBuilderState.getMessage(__filename, "click_to_start")}</div>
            </div>
        );

        const edition = appGuiSettingState.edition;
        const content = (
            <div className="body-row">
                {donationMessage}
                {edition.indexOf("onnxdirectML-cuda") >= 0 ? directMLMessage : <></>}
                {licenseInfo}
                {clickToStartMessage}
            </div>
        );
        const contentForWeb = (
            <div className="body-row">
                {webEdtionMessage}
                {githubLink}
                {clickToStartMessage}
            </div>
        );

        return (
            <div className="dialog-frame">
                <div className="dialog-title">Message</div>
                <div className="dialog-content">
                    {edition.indexOf("web") >= 0 ? contentForWeb : content}
                    {closeButtonRow}
                </div>
            </div>
        );
    }, [appGuiSettingState.edition]);
    return dialog;
};
