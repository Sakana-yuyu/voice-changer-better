import React, { useMemo } from "react";
import { useGuiState } from "./001_GuiStateProvider";
import { useMessageBuilder } from "../../hooks/useMessageBuilder";


export const TextInputDialog = () => {
    const guiState = useGuiState();
    const messageBuilderState = useMessageBuilder();

    useMemo(() => {
        messageBuilderState.setMessage(__filename, "ok", {
            zh: "确定",
            ja: "OK",
            ko: "확인",
            en: "OK"
        });
        messageBuilderState.setMessage(__filename, "cancel", {
            zh: "取消",
            ja: "キャンセル",
            ko: "취소",
            en: "Cancel"
        });
        messageBuilderState.setMessage(__filename, "inputText", {
            zh: "输入文本:",
            ja: "テキスト入力:",
            ko: "텍스트 입력:",
            en: "Input Text:"
        });
        messageBuilderState.setMessage(__filename, "inputDialog", {
            zh: "输入对话框",
            ja: "入力ダイアログ",
            ko: "입력 대화상자",
            en: "Input Dialog"
        });
    }, []);

    const dialog = useMemo(() => {
        const buttonsRow = (
            <div className="body-row split-3-4-3 left-padding-1">
                <div className="body-item-text">
                </div>
                <div className="body-button-container body-button-container-space-around">
                    <div className="body-button" onClick={() => {
                        const inputText = document.getElementById("input-text") as HTMLInputElement
                        const text = inputText.value
                        inputText.value = ""
                        if (guiState.textInputResolve) {
                            guiState.textInputResolve.resolve!(text)
                            guiState.setTextInputResolve(null)
                        }
                        guiState.stateControls.showTextInputCheckbox.updateState(false)
                    }} >{messageBuilderState.getMessage(__filename, "ok")}</div>
                    <div className="body-button" onClick={() => {
                        const inputText = document.getElementById("input-text") as HTMLInputElement
                        inputText.value = ""
                        if (guiState.textInputResolve) {
                            guiState.textInputResolve.resolve!("")
                            guiState.setTextInputResolve(null)
                        }
                        guiState.stateControls.showTextInputCheckbox.updateState(false)
                    }} >{messageBuilderState.getMessage(__filename, "cancel")}</div>
                </div>
                <div className="body-item-text"></div>
            </div>
        )
        const textInput = (
            <div className="input-text-container">
                <div>{messageBuilderState.getMessage(__filename, "inputText")} </div>
                <input id="input-text" type="text" />
            </div>
        )
        return (
            <div className="dialog-frame">
                <div className="dialog-title">{messageBuilderState.getMessage(__filename, "inputDialog")}</div>
                <div className="dialog-content">
                    {textInput}
                    {buttonsRow}
                </div>
            </div>
        );
    }, [guiState.textInputResolve]);
    return dialog;

};
