// GoogleCloudTextToSpeech.swift
// Cloud Text-to-Speech for audio synthesis

import Foundation

// MARK: - Voice Selection

/// Voice selection parameters
public struct GoogleCloudTextToSpeechVoice: Codable, Sendable, Equatable {
    /// Language code (e.g., "en-US")
    public let languageCode: String

    /// Voice name (e.g., "en-US-Wavenet-D")
    public let name: String?

    /// SSML voice gender
    public let ssmlGender: SSMLGender?

    /// Custom voice name for custom voice
    public let customVoice: CustomVoice?

    /// SSML voice gender options
    public enum SSMLGender: String, Codable, Sendable {
        case unspecified = "SSML_VOICE_GENDER_UNSPECIFIED"
        case male = "MALE"
        case female = "FEMALE"
        case neutral = "NEUTRAL"
    }

    /// Custom voice configuration
    public struct CustomVoice: Codable, Sendable, Equatable {
        /// Model resource name
        public let model: String

        /// Reported usage
        public let reportedUsage: ReportedUsage?

        /// Reported usage options
        public enum ReportedUsage: String, Codable, Sendable {
            case unspecified = "REPORTED_USAGE_UNSPECIFIED"
            case realtime = "REALTIME"
            case offline = "OFFLINE"
        }

        public init(model: String, reportedUsage: ReportedUsage? = nil) {
            self.model = model
            self.reportedUsage = reportedUsage
        }
    }

    public init(
        languageCode: String,
        name: String? = nil,
        ssmlGender: SSMLGender? = nil,
        customVoice: CustomVoice? = nil
    ) {
        self.languageCode = languageCode
        self.name = name
        self.ssmlGender = ssmlGender
        self.customVoice = customVoice
    }

    /// Create a standard voice
    public static func standard(_ name: String, languageCode: String = "en-US") -> GoogleCloudTextToSpeechVoice {
        GoogleCloudTextToSpeechVoice(languageCode: languageCode, name: name)
    }

    /// Create a Wavenet voice
    public static func wavenet(_ variant: String, languageCode: String = "en-US") -> GoogleCloudTextToSpeechVoice {
        GoogleCloudTextToSpeechVoice(languageCode: languageCode, name: "\(languageCode)-Wavenet-\(variant)")
    }

    /// Create a Neural2 voice
    public static func neural2(_ variant: String, languageCode: String = "en-US") -> GoogleCloudTextToSpeechVoice {
        GoogleCloudTextToSpeechVoice(languageCode: languageCode, name: "\(languageCode)-Neural2-\(variant)")
    }

    /// Create a Studio voice
    public static func studio(_ variant: String, languageCode: String = "en-US") -> GoogleCloudTextToSpeechVoice {
        GoogleCloudTextToSpeechVoice(languageCode: languageCode, name: "\(languageCode)-Studio-\(variant)")
    }

    /// Create a Polyglot voice
    public static func polyglot(_ variant: String, languageCode: String = "en-US") -> GoogleCloudTextToSpeechVoice {
        GoogleCloudTextToSpeechVoice(languageCode: languageCode, name: "\(languageCode)-Polyglot-\(variant)")
    }

    /// Create a News voice
    public static func news(_ variant: String, languageCode: String = "en-US") -> GoogleCloudTextToSpeechVoice {
        GoogleCloudTextToSpeechVoice(languageCode: languageCode, name: "\(languageCode)-News-\(variant)")
    }

    /// Create by gender
    public static func byGender(_ gender: SSMLGender, languageCode: String = "en-US") -> GoogleCloudTextToSpeechVoice {
        GoogleCloudTextToSpeechVoice(languageCode: languageCode, ssmlGender: gender)
    }
}

// MARK: - Audio Config

/// Audio configuration for synthesis
public struct GoogleCloudTextToSpeechAudioConfig: Codable, Sendable, Equatable {
    /// Audio encoding
    public let audioEncoding: AudioEncoding

    /// Speaking rate (0.25 to 4.0, default 1.0)
    public let speakingRate: Double?

    /// Speaking pitch (-20.0 to 20.0 semitones, default 0.0)
    public let pitch: Double?

    /// Volume gain in dB (-96.0 to 16.0, default 0.0)
    public let volumeGainDb: Double?

    /// Sample rate in Hertz
    public let sampleRateHertz: Int?

    /// Effects profile IDs
    public let effectsProfileId: [String]?

    /// Audio encoding options
    public enum AudioEncoding: String, Codable, Sendable {
        case unspecified = "AUDIO_ENCODING_UNSPECIFIED"
        case linear16 = "LINEAR16"
        case mp3 = "MP3"
        case oggOpus = "OGG_OPUS"
        case mulaw = "MULAW"
        case alaw = "ALAW"
    }

    public init(
        audioEncoding: AudioEncoding,
        speakingRate: Double? = nil,
        pitch: Double? = nil,
        volumeGainDb: Double? = nil,
        sampleRateHertz: Int? = nil,
        effectsProfileId: [String]? = nil
    ) {
        self.audioEncoding = audioEncoding
        self.speakingRate = speakingRate
        self.pitch = pitch
        self.volumeGainDb = volumeGainDb
        self.sampleRateHertz = sampleRateHertz
        self.effectsProfileId = effectsProfileId
    }

    /// Default MP3 config
    public static let mp3 = GoogleCloudTextToSpeechAudioConfig(audioEncoding: .mp3)

    /// Default LINEAR16 (WAV) config
    public static let wav = GoogleCloudTextToSpeechAudioConfig(audioEncoding: .linear16)

    /// Default OGG Opus config
    public static let ogg = GoogleCloudTextToSpeechAudioConfig(audioEncoding: .oggOpus)

    /// Telephony optimized (8kHz mulaw)
    public static let telephony = GoogleCloudTextToSpeechAudioConfig(
        audioEncoding: .mulaw,
        sampleRateHertz: 8000
    )

    /// High quality MP3
    public static func highQualityMP3(sampleRate: Int = 24000) -> GoogleCloudTextToSpeechAudioConfig {
        GoogleCloudTextToSpeechAudioConfig(
            audioEncoding: .mp3,
            sampleRateHertz: sampleRate
        )
    }

    /// With effects profile
    public func withEffects(_ effects: [EffectsProfile]) -> GoogleCloudTextToSpeechAudioConfig {
        GoogleCloudTextToSpeechAudioConfig(
            audioEncoding: audioEncoding,
            speakingRate: speakingRate,
            pitch: pitch,
            volumeGainDb: volumeGainDb,
            sampleRateHertz: sampleRateHertz,
            effectsProfileId: effects.map { $0.rawValue }
        )
    }

    /// Pre-defined effects profiles
    public enum EffectsProfile: String, Codable, Sendable {
        case wearableClassDevice = "wearable-class-device"
        case handsetClassDevice = "handset-class-device"
        case headphoneClassDevice = "headphone-class-device"
        case smallBluetoothSpeakerClassDevice = "small-bluetooth-speaker-class-device"
        case mediumBluetoothSpeakerClassDevice = "medium-bluetooth-speaker-class-device"
        case largeHomeEntertainmentClassDevice = "large-home-entertainment-class-device"
        case largeAutomotiveClassDevice = "large-automotive-class-device"
        case telephonyClassApplication = "telephony-class-application"
    }
}

// MARK: - Synthesis Input

/// Input for text synthesis
public struct GoogleCloudTextToSpeechInput: Codable, Sendable, Equatable {
    /// Plain text input
    public let text: String?

    /// SSML input
    public let ssml: String?

    public init(text: String? = nil, ssml: String? = nil) {
        self.text = text
        self.ssml = ssml
    }

    /// Create from plain text
    public static func plainText(_ text: String) -> GoogleCloudTextToSpeechInput {
        GoogleCloudTextToSpeechInput(text: text)
    }

    /// Create from SSML
    public static func ssml(_ ssml: String) -> GoogleCloudTextToSpeechInput {
        GoogleCloudTextToSpeechInput(ssml: ssml)
    }

    /// Build SSML with speech marks
    public static func ssmlBuilder(_ builder: SSMLBuilder) -> GoogleCloudTextToSpeechInput {
        GoogleCloudTextToSpeechInput(ssml: builder.build())
    }
}

// MARK: - SSML Builder

/// Builder for SSML markup
public struct SSMLBuilder: Sendable {
    private var content: String = ""

    public init() {}

    /// Add plain text
    public mutating func text(_ text: String) {
        content += text
    }

    /// Add break/pause
    public mutating func pause(time: String) {
        content += "<break time=\"\(time)\"/>"
    }

    /// Add emphasis
    public mutating func emphasis(_ text: String, level: EmphasisLevel = .moderate) {
        content += "<emphasis level=\"\(level.rawValue)\">\(text)</emphasis>"
    }

    /// Add prosody modification
    public mutating func prosody(_ text: String, rate: String? = nil, pitch: String? = nil, volume: String? = nil) {
        var attrs: [String] = []
        if let rate = rate { attrs.append("rate=\"\(rate)\"") }
        if let pitch = pitch { attrs.append("pitch=\"\(pitch)\"") }
        if let volume = volume { attrs.append("volume=\"\(volume)\"") }
        content += "<prosody \(attrs.joined(separator: " "))>\(text)</prosody>"
    }

    /// Add say-as interpretation
    public mutating func sayAs(_ text: String, interpretAs: InterpretAs, format: String? = nil) {
        let formatAttr = format.map { " format=\"\($0)\"" } ?? ""
        content += "<say-as interpret-as=\"\(interpretAs.rawValue)\"\(formatAttr)>\(text)</say-as>"
    }

    /// Add phoneme pronunciation
    public mutating func phoneme(_ text: String, alphabet: String = "ipa", ph: String) {
        content += "<phoneme alphabet=\"\(alphabet)\" ph=\"\(ph)\">\(text)</phoneme>"
    }

    /// Add sub (substitution)
    public mutating func sub(_ text: String, alias: String) {
        content += "<sub alias=\"\(alias)\">\(text)</sub>"
    }

    /// Build the SSML string
    public func build() -> String {
        "<speak>\(content)</speak>"
    }

    /// Emphasis levels
    public enum EmphasisLevel: String, Sendable {
        case strong
        case moderate
        case reduced
        case none
    }

    /// Interpret-as types
    public enum InterpretAs: String, Sendable {
        case cardinal
        case ordinal
        case characters
        case spell_out = "spell-out"
        case fraction
        case expletive
        case unit
        case date
        case time
        case telephone
        case address
    }
}

// MARK: - Synthesis Request

/// Request to synthesize speech
public struct GoogleCloudTextToSpeechRequest: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Input text or SSML
    public let input: GoogleCloudTextToSpeechInput

    /// Voice selection
    public let voice: GoogleCloudTextToSpeechVoice

    /// Audio configuration
    public let audioConfig: GoogleCloudTextToSpeechAudioConfig

    public init(
        projectID: String,
        input: GoogleCloudTextToSpeechInput,
        voice: GoogleCloudTextToSpeechVoice,
        audioConfig: GoogleCloudTextToSpeechAudioConfig
    ) {
        self.projectID = projectID
        self.input = input
        self.voice = voice
        self.audioConfig = audioConfig
    }

    /// gcloud command equivalent
    public var synthesizeCommand: String {
        if let text = input.text {
            return "gcloud ml speech synthesize-text \"\(text)\" --voice-name=\(voice.name ?? "en-US-Wavenet-D") --output-file=output.mp3"
        }
        return "# Use Text-to-Speech API for SSML synthesis"
    }
}

// MARK: - Synthesis Response

/// Response from speech synthesis
public struct GoogleCloudTextToSpeechResponse: Codable, Sendable, Equatable {
    /// Base64-encoded audio content
    public let audioContent: String

    public init(audioContent: String) {
        self.audioContent = audioContent
    }

    /// Decode audio content to Data
    public var audioData: Data? {
        Data(base64Encoded: audioContent)
    }
}

// MARK: - Voice Info

/// Information about an available voice
public struct GoogleCloudTextToSpeechVoiceInfo: Codable, Sendable, Equatable {
    /// Supported language codes
    public let languageCodes: [String]

    /// Voice name
    public let name: String

    /// SSML gender
    public let ssmlGender: GoogleCloudTextToSpeechVoice.SSMLGender

    /// Natural sample rate in Hertz
    public let naturalSampleRateHertz: Int

    public init(
        languageCodes: [String],
        name: String,
        ssmlGender: GoogleCloudTextToSpeechVoice.SSMLGender,
        naturalSampleRateHertz: Int
    ) {
        self.languageCodes = languageCodes
        self.name = name
        self.ssmlGender = ssmlGender
        self.naturalSampleRateHertz = naturalSampleRateHertz
    }

    /// Voice type (Standard, Wavenet, Neural2, etc.)
    public var voiceType: VoiceType {
        if name.contains("Wavenet") { return .wavenet }
        if name.contains("Neural2") { return .neural2 }
        if name.contains("Studio") { return .studio }
        if name.contains("Polyglot") { return .polyglot }
        if name.contains("News") { return .news }
        if name.contains("Journey") { return .journey }
        return .standard
    }

    /// Voice types
    public enum VoiceType: String, Codable, Sendable {
        case standard = "Standard"
        case wavenet = "Wavenet"
        case neural2 = "Neural2"
        case studio = "Studio"
        case polyglot = "Polyglot"
        case news = "News"
        case journey = "Journey"
    }
}

// MARK: - Long Audio

/// Long audio synthesis request
public struct GoogleCloudTextToSpeechLongAudioRequest: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Input text or SSML
    public let input: GoogleCloudTextToSpeechInput

    /// Voice selection
    public let voice: GoogleCloudTextToSpeechVoice

    /// Audio configuration
    public let audioConfig: GoogleCloudTextToSpeechAudioConfig

    /// Output GCS URI
    public let outputGcsUri: String

    public init(
        projectID: String,
        location: String = "us-central1",
        input: GoogleCloudTextToSpeechInput,
        voice: GoogleCloudTextToSpeechVoice,
        audioConfig: GoogleCloudTextToSpeechAudioConfig,
        outputGcsUri: String
    ) {
        self.projectID = projectID
        self.location = location
        self.input = input
        self.voice = voice
        self.audioConfig = audioConfig
        self.outputGcsUri = outputGcsUri
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)"
    }
}

// MARK: - Custom Voice

/// Custom voice model for cloning
public struct GoogleCloudTextToSpeechCustomVoiceModel: Codable, Sendable, Equatable {
    /// Model resource name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Display name
    public let displayName: String

    /// Training state
    public let state: TrainingState?

    /// Create time
    public let createTime: String?

    /// Training state options
    public enum TrainingState: String, Codable, Sendable {
        case unspecified = "STATE_UNSPECIFIED"
        case training = "TRAINING"
        case complete = "COMPLETE"
        case failed = "FAILED"
    }

    public init(
        name: String,
        projectID: String,
        displayName: String,
        state: TrainingState? = nil,
        createTime: String? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.displayName = displayName
        self.state = state
        self.createTime = createTime
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/customVoices/\(name)"
    }
}

// MARK: - Batch Request

/// Batch synthesis request for multiple inputs
public struct GoogleCloudTextToSpeechBatchRequest: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Voice selection
    public let voice: GoogleCloudTextToSpeechVoice

    /// Audio configuration
    public let audioConfig: GoogleCloudTextToSpeechAudioConfig

    /// Input specifications
    public let inputSpecs: [InputSpec]

    /// Output configuration
    public let outputConfig: OutputConfig

    /// Input specification
    public struct InputSpec: Codable, Sendable, Equatable {
        /// Input text or SSML
        public let input: GoogleCloudTextToSpeechInput

        /// Output key (used in output filename)
        public let outputKey: String?

        public init(input: GoogleCloudTextToSpeechInput, outputKey: String? = nil) {
            self.input = input
            self.outputKey = outputKey
        }
    }

    /// Output configuration
    public struct OutputConfig: Codable, Sendable, Equatable {
        /// GCS bucket URI
        public let gcsUri: String

        public init(gcsUri: String) {
            self.gcsUri = gcsUri
        }
    }

    public init(
        projectID: String,
        voice: GoogleCloudTextToSpeechVoice,
        audioConfig: GoogleCloudTextToSpeechAudioConfig,
        inputSpecs: [InputSpec],
        outputConfig: OutputConfig
    ) {
        self.projectID = projectID
        self.voice = voice
        self.audioConfig = audioConfig
        self.inputSpecs = inputSpecs
        self.outputConfig = outputConfig
    }
}

// MARK: - Operations

/// Text-to-Speech operations helper
public struct GoogleCloudTextToSpeechOperations: Sendable {
    public let projectID: String

    public init(projectID: String) {
        self.projectID = projectID
    }

    /// List available voices
    public var listVoicesCommand: String {
        "gcloud ml speech list-voices --project=\(projectID)"
    }

    /// List voices for a language
    public func listVoicesForLanguage(_ languageCode: String) -> String {
        "gcloud ml speech list-voices --filter=\"languageCodes:\(languageCode)\" --project=\(projectID)"
    }

    /// Synthesize text to file
    public func synthesizeToFile(text: String, voice: String, output: String) -> String {
        "gcloud ml speech synthesize-text \"\(text)\" --voice-name=\(voice) --output-file=\(output) --project=\(projectID)"
    }

    /// Synthesize SSML to file
    public func synthesizeSSMLToFile(ssmlFile: String, voice: String, output: String) -> String {
        "gcloud ml speech synthesize-text --ssml-file=\(ssmlFile) --voice-name=\(voice) --output-file=\(output) --project=\(projectID)"
    }

    /// Enable Text-to-Speech API
    public var enableAPICommand: String {
        "gcloud services enable texttospeech.googleapis.com --project=\(projectID)"
    }

    /// IAM roles for Text-to-Speech
    public static let roles: [String: String] = [
        "roles/cloudtts.client": "Text-to-Speech client",
        "roles/cloudtts.admin": "Text-to-Speech admin"
    ]
}

// MARK: - DAIS Template

/// DAIS template for Text-to-Speech
public struct DAISTextToSpeechTemplate: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Default voice
    public let defaultVoice: GoogleCloudTextToSpeechVoice

    /// Default audio config
    public let defaultAudioConfig: GoogleCloudTextToSpeechAudioConfig

    /// Service account for TTS
    public let serviceAccount: String

    /// Output bucket for audio files
    public let outputBucket: String

    public init(
        projectID: String,
        defaultVoice: GoogleCloudTextToSpeechVoice = .wavenet("D"),
        defaultAudioConfig: GoogleCloudTextToSpeechAudioConfig = .mp3,
        serviceAccount: String = "tts-service",
        outputBucket: String = "tts-output"
    ) {
        self.projectID = projectID
        self.defaultVoice = defaultVoice
        self.defaultAudioConfig = defaultAudioConfig
        self.serviceAccount = serviceAccount
        self.outputBucket = outputBucket
    }

    /// Standard American English male voice
    public var americanMaleVoice: GoogleCloudTextToSpeechVoice {
        .wavenet("D", languageCode: "en-US")
    }

    /// Standard American English female voice
    public var americanFemaleVoice: GoogleCloudTextToSpeechVoice {
        .wavenet("F", languageCode: "en-US")
    }

    /// British English male voice
    public var britishMaleVoice: GoogleCloudTextToSpeechVoice {
        .wavenet("B", languageCode: "en-GB")
    }

    /// British English female voice
    public var britishFemaleVoice: GoogleCloudTextToSpeechVoice {
        .wavenet("A", languageCode: "en-GB")
    }

    /// Neural2 high-quality voice
    public var neural2Voice: GoogleCloudTextToSpeechVoice {
        .neural2("A", languageCode: "en-US")
    }

    /// Studio professional voice
    public var studioVoice: GoogleCloudTextToSpeechVoice {
        .studio("O", languageCode: "en-US")
    }

    /// Audio config for podcast
    public var podcastAudioConfig: GoogleCloudTextToSpeechAudioConfig {
        GoogleCloudTextToSpeechAudioConfig(
            audioEncoding: .mp3,
            speakingRate: 1.0,
            sampleRateHertz: 24000
        ).withEffects([.headphoneClassDevice])
    }

    /// Audio config for phone system (IVR)
    public var ivrAudioConfig: GoogleCloudTextToSpeechAudioConfig {
        GoogleCloudTextToSpeechAudioConfig(
            audioEncoding: .mulaw,
            sampleRateHertz: 8000
        ).withEffects([.telephonyClassApplication])
    }

    /// Audio config for smart speaker
    public var smartSpeakerAudioConfig: GoogleCloudTextToSpeechAudioConfig {
        GoogleCloudTextToSpeechAudioConfig(
            audioEncoding: .mp3,
            sampleRateHertz: 24000
        ).withEffects([.mediumBluetoothSpeakerClassDevice])
    }

    /// Simple synthesis request
    public func synthesize(_ text: String) -> GoogleCloudTextToSpeechRequest {
        GoogleCloudTextToSpeechRequest(
            projectID: projectID,
            input: .plainText(text),
            voice: defaultVoice,
            audioConfig: defaultAudioConfig
        )
    }

    /// Synthesis request with custom voice
    public func synthesize(_ text: String, voice: GoogleCloudTextToSpeechVoice) -> GoogleCloudTextToSpeechRequest {
        GoogleCloudTextToSpeechRequest(
            projectID: projectID,
            input: .plainText(text),
            voice: voice,
            audioConfig: defaultAudioConfig
        )
    }

    /// Long audio synthesis
    public func synthesizeLongAudio(_ text: String, outputPath: String) -> GoogleCloudTextToSpeechLongAudioRequest {
        GoogleCloudTextToSpeechLongAudioRequest(
            projectID: projectID,
            input: .plainText(text),
            voice: defaultVoice,
            audioConfig: defaultAudioConfig,
            outputGcsUri: "gs://\(outputBucket)/\(outputPath)"
        )
    }

    /// Setup script
    public var setupScript: String {
        """
        #!/bin/bash
        # DAIS Text-to-Speech Setup

        PROJECT_ID="\(projectID)"

        # Enable Text-to-Speech API
        gcloud services enable texttospeech.googleapis.com --project=$PROJECT_ID

        # Create service account
        gcloud iam service-accounts create \(serviceAccount) \\
            --display-name="Text-to-Speech Service Account" \\
            --project=$PROJECT_ID

        # Grant TTS client role
        gcloud projects add-iam-policy-binding $PROJECT_ID \\
            --member="serviceAccount:\(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com" \\
            --role="roles/cloudtts.client"

        # Create output bucket
        gsutil mb -p $PROJECT_ID gs://\(outputBucket)

        # Grant storage access
        gsutil iam ch serviceAccount:\(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com:objectCreator gs://\(outputBucket)

        echo "Text-to-Speech setup complete!"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        # DAIS Text-to-Speech Teardown

        PROJECT_ID="\(projectID)"

        # Delete output bucket
        gsutil rm -r gs://\(outputBucket) || true

        # Delete service account
        gcloud iam service-accounts delete \(serviceAccount)@$PROJECT_ID.iam.gserviceaccount.com \\
            --quiet --project=$PROJECT_ID || true

        echo "Text-to-Speech resources cleaned up!"
        """
    }

    /// Python synthesis script
    public var pythonScript: String {
        """
        from google.cloud import texttospeech

        def synthesize_text(text, output_file):
            \"\"\"Synthesizes speech from text.\"\"\"
            client = texttospeech.TextToSpeechClient()

            synthesis_input = texttospeech.SynthesisInput(text=text)

            voice = texttospeech.VoiceSelectionParams(
                language_code="en-US",
                name="\(defaultVoice.name ?? "en-US-Wavenet-D")"
            )

            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.MP3,
                speaking_rate=1.0,
                pitch=0.0
            )

            response = client.synthesize_speech(
                input=synthesis_input,
                voice=voice,
                audio_config=audio_config
            )

            with open(output_file, "wb") as out:
                out.write(response.audio_content)
                print(f"Audio content written to {output_file}")

        def synthesize_ssml(ssml, output_file):
            \"\"\"Synthesizes speech from SSML.\"\"\"
            client = texttospeech.TextToSpeechClient()

            synthesis_input = texttospeech.SynthesisInput(ssml=ssml)

            voice = texttospeech.VoiceSelectionParams(
                language_code="en-US",
                name="\(defaultVoice.name ?? "en-US-Wavenet-D")"
            )

            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.MP3
            )

            response = client.synthesize_speech(
                input=synthesis_input,
                voice=voice,
                audio_config=audio_config
            )

            with open(output_file, "wb") as out:
                out.write(response.audio_content)

        def list_voices(language_code=None):
            \"\"\"Lists available voices.\"\"\"
            client = texttospeech.TextToSpeechClient()
            response = client.list_voices(language_code=language_code)

            for voice in response.voices:
                print(f"Name: {voice.name}")
                print(f"  Languages: {', '.join(voice.language_codes)}")
                print(f"  Gender: {texttospeech.SsmlVoiceGender(voice.ssml_gender).name}")
                print(f"  Sample rate: {voice.natural_sample_rate_hertz}Hz")
                print()

        # Example usage
        if __name__ == "__main__":
            synthesize_text("Hello, this is a test of text to speech.", "output.mp3")
        """
    }
}
