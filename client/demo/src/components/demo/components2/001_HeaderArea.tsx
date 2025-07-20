import React, { useMemo } from "react";
import { INDEXEDDB_KEY_AUDIO_OUTPUT, isDesktopApp } from "../../../const";
import { useAppRoot } from "../../../001_provider/001_AppRootProvider";
import { useAppState } from "../../../001_provider/001_AppStateProvider";
import { useIndexedDB } from "@dannadori/voice-changer-client-js";
import { useMessageBuilder } from "../../../hooks/useMessageBuilder";

export type HeaderAreaProps = {
    mainTitle: string;
    subTitle: string;
};

export const HeaderArea = (props: HeaderAreaProps) => {
    const { appGuiSettingState } = useAppRoot();
    const messageBuilderState = useMessageBuilder();
    const { clearSetting, webInfoState } = useAppState();

    const { removeItem, removeDB } = useIndexedDB({ clientType: null });

    useMemo(() => {
        messageBuilderState.setMessage(__filename, "github", { 
            zh: "GitHub", 
            ja: "GitHub", 
            ko: "GitHub", 
            en: "GitHub" 
        });
        messageBuilderState.setMessage(__filename, "manual", { 
            zh: "使用手册", 
            ja: "マニュアル", 
            ko: "매뉴얼", 
            en: "Manual" 
        });
        messageBuilderState.setMessage(__filename, "screenCapture", { 
            zh: "录屏工具", 
            ja: "録画ツール", 
            ko: "화면 녹화", 
            en: "Record Screen" 
        });
        messageBuilderState.setMessage(__filename, "support", { 
            zh: "赞助支持", 
            ja: "支援", 
            ko: "후원", 
            en: "Donation" 
        });
        messageBuilderState.setMessage(__filename, "clearSetting", { 
            zh: "清除设置", 
            ja: "設定をクリア", 
            ko: "설정 지우기", 
            en: "Clear Setting" 
        });
        messageBuilderState.setMessage(__filename, "language", { 
            zh: "语言", 
            ja: "言語", 
            ko: "언어", 
            en: "Language" 
        });
        messageBuilderState.setMessage(__filename, "chinese", { 
            zh: "中文", 
            ja: "中国語", 
            ko: "중국어", 
            en: "Chinese" 
        });
        messageBuilderState.setMessage(__filename, "japanese", { 
            zh: "日语", 
            ja: "日本語", 
            ko: "일본어", 
            en: "Japanese" 
        });
        messageBuilderState.setMessage(__filename, "korean", { 
            zh: "韩语", 
            ja: "韓国語", 
            ko: "한국어", 
            en: "Korean" 
        });
        messageBuilderState.setMessage(__filename, "english", { 
            zh: "英语", 
            ja: "英語", 
            ko: "영어", 
            en: "English" 
        });
    }, []);

    const languageSelector = useMemo(() => {
        const languageOptions = [
            { value: 'zh', label: messageBuilderState.getMessage(__filename, "chinese") },
            { value: 'ja', label: messageBuilderState.getMessage(__filename, "japanese") },
            { value: 'ko', label: messageBuilderState.getMessage(__filename, "korean") },
            { value: 'en', label: messageBuilderState.getMessage(__filename, "english") }
        ];

        return (
            <div className="language-selector tooltip">
                <select 
                    value={messageBuilderState.currentLanguage} 
                    onChange={(e) => messageBuilderState.setLanguage(e.target.value)}
                    className="language-select"
                >
                    {languageOptions.map(option => (
                        <option key={option.value} value={option.value}>
                            {option.label}
                        </option>
                    ))}
                </select>
                <div className="tooltip-text">{messageBuilderState.getMessage(__filename, "language")}</div>
            </div>
        );
    }, [messageBuilderState.currentLanguage]);

    const githubLink = useMemo(() => {
        return isDesktopApp() ? (
            <span
                className="link tooltip"
                onClick={() => {
                    // @ts-ignore
                    window.electronAPI.openBrowser("https://github.com/w-okada/voice-changer");
                }}
            >
                <img src="./assets/icons/github.svg" />
                <div className="tooltip-text">{messageBuilderState.getMessage(__filename, "github")}</div>
            </span>
        ) : (
            <a className="link tooltip" href="https://github.com/w-okada/voice-changer" target="_blank" rel="noopener noreferrer">
                <img src="./assets/icons/github.svg" />
                <div className="tooltip-text">{messageBuilderState.getMessage(__filename, "github")}</div>
            </a>
        );
    }, []);

    const manualLink = useMemo(() => {
        return isDesktopApp() ? (
            <span
                className="link tooltip"
                onClick={() => {
                    // @ts-ignore
                    window.electronAPI.openBrowser("https://github.com/w-okada/voice-changer/blob/master/tutorials/tutorial_rvc_ja_latest.md");
                }}
            >
                <img src="./assets/icons/help-circle.svg" />
                <div className="tooltip-text tooltip-text-100px">{messageBuilderState.getMessage(__filename, "manual")}</div>
            </span>
        ) : (
            <a className="link tooltip" href="https://github.com/w-okada/voice-changer/blob/master/tutorials/tutorial_rvc_ja_latest.md" target="_blank" rel="noopener noreferrer">
                <img src="./assets/icons/help-circle.svg" />
                <div className="tooltip-text tooltip-text-100px">{messageBuilderState.getMessage(__filename, "manual")}</div>
            </a>
        );
    }, []);

    const toolLink = useMemo(() => {
        return isDesktopApp() ? (
            <div className="link tooltip">
                <img src="./assets/icons/tool.svg" />
                <div className="tooltip-text tooltip-text-100px">
                    <p
                        onClick={() => {
                            // @ts-ignore
                            window.electronAPI.openBrowser("https://w-okada.github.io/screen-recorder-ts/");
                        }}
                    >
                        {messageBuilderState.getMessage(__filename, "screenCapture")}
                    </p>
                </div>
            </div>
        ) : (
            <div className="link tooltip">
                <img src="./assets/icons/tool.svg" />
                <div className="tooltip-text tooltip-text-100px">
                    <p
                        onClick={() => {
                            window.open("https://w-okada.github.io/screen-recorder-ts/", "_blank", "noreferrer");
                        }}
                    >
                        {messageBuilderState.getMessage(__filename, "screenCapture")}
                    </p>
                </div>
            </div>
        );
    }, []);

    const coffeeLink = useMemo(() => {
        return isDesktopApp() ? (
            <span
                className="link tooltip"
                onClick={() => {
                    // @ts-ignore
                    window.electronAPI.openBrowser("https://www.buymeacoffee.com/wokad");
                }}
            >
                <img className="donate-img" src="./assets/buymeacoffee.png" />
                <div className="tooltip-text tooltip-text-100px">{messageBuilderState.getMessage(__filename, "support")}</div>
            </span>
        ) : (
            <a className="link tooltip" href="https://www.buymeacoffee.com/wokad" target="_blank" rel="noopener noreferrer">
                <img className="donate-img" src="./assets/buymeacoffee.png" />
                <div className="tooltip-text tooltip-text-100px">{messageBuilderState.getMessage(__filename, "support")}</div>
            </a>
        );
    }, []);

    const headerArea = useMemo(() => {
        const onClearSettingClicked = async () => {
            await clearSetting();
            await removeItem(INDEXEDDB_KEY_AUDIO_OUTPUT);
            await removeDB();
            location.reload();
        };

        return (
            <div className="headerArea">
                <div className="title1">
                    <span className="title">{props.mainTitle}</span>
                    <span className="title-version">{props.subTitle}</span>
                    <span className="title-version-number">{appGuiSettingState.version}</span>
                    <span className="title-version-number">{appGuiSettingState.edition}</span>
                </div>
                <div className="icons">
                    <span className="belongings">
                        {languageSelector}
                        {githubLink}
                        {manualLink}
                        {toolLink}
                        {coffeeLink}
                        {/* {licenseButton} */}
                    </span>
                    <span className="belongings">
                        <div className="belongings-button" onClick={onClearSettingClicked}>
                            {messageBuilderState.getMessage(__filename, "clearSetting")}
                        </div>
                        {/* <div className="belongings-button" onClick={onReloadClicked}>reload</div>
                        <div className="belongings-button" onClick={onReselectVCClicked}>select vc</div> */}
                    </span>
                </div>
            </div>
        );
    }, [props.subTitle, props.mainTitle, appGuiSettingState.version, appGuiSettingState.edition]);

    return headerArea;
};
