import { useRef, useState } from "react"

export type Message = {
    file: string,
    id: string,
    message: { [lang: string]: string }
}

export type MessageBuilderStateAndMethod = {
    setMessage: (file: string, id: string, message: { [lang: string]: string }) => void
    getMessage: (file: string, id: string) => string
    currentLanguage: string
    setLanguage: (lang: string) => void
}

export const useMessageBuilder = (): MessageBuilderStateAndMethod => {
    const messagesRef = useRef<Message[]>([])
    
    // Initialize language from localStorage or browser language
    const getInitialLanguage = () => {
        const savedLang = localStorage.getItem('voice-changer-language')
        if (savedLang && ['zh', 'ja', 'ko', 'en'].includes(savedLang)) {
            return savedLang
        }
        
        let lang = window.navigator.language
        if (lang.startsWith("zh")) {
            return "zh"
        } else if (lang.startsWith("ja")) {
            return "ja"
        } else if (lang.startsWith("ko")) {
            return "ko"
        } else {
            return "en"
        }
    }
    
    const [currentLanguage, setCurrentLanguage] = useState<string>(getInitialLanguage())

    const setMessage = (file: string, id: string, message: { [lang: string]: string }) => {
        if (messagesRef.current.find(x => { return x.file == file && x.id == id })) {
            console.warn("duplicate message is registerd", file, id, message)
        } else {
            messagesRef.current.push({ file, id, message })
        }
    }
    
    const getMessage = (file: string, id: string) => {
        return messagesRef.current.find(x => { return x.file == file && x.id == id })?.message[currentLanguage] || "unknown message"
    }
    
    const setLanguage = (lang: string) => {
        if (['zh', 'ja', 'ko', 'en'].includes(lang)) {
            setCurrentLanguage(lang)
            localStorage.setItem('voice-changer-language', lang)
            // Auto refresh page after language change
            setTimeout(() => {
                window.location.reload()
            }, 100)
        }
    }
    
    return {
        setMessage,
        getMessage,
        currentLanguage,
        setLanguage
    }
}