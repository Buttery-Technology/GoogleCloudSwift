// GoogleCloudSpeechToText.swift
// Cloud Speech-to-Text for audio transcription

import Foundation

// MARK: - Recognition Config

/// Configuration for speech recognition
public struct GoogleCloudSpeechRecognitionConfig: Codable, Sendable, Equatable {
    /// Encoding of the audio data
    public let encoding: AudioEncoding

    /// Sample rate in Hertz
    public let sampleRateHertz: Int

    /// Language code (e.g., "en-US")
    public let languageCode: String

    /// Additional language codes for multi-language recognition
    public let alternativeLanguageCodes: [String]?

    /// Maximum alternatives to return
    public let maxAlternatives: Int?

    /// Enable profanity filter
    public let profanityFilter: Bool?

    /// Speech adaptation/phrases
    public let speechContexts: [SpeechContext]?

    /// Enable automatic punctuation
    public let enableAutomaticPunctuation: Bool?

    /// Enable spoken punctuation
    public let enableSpokenPunctuation: Bool?

    /// Enable spoken emojis
    public let enableSpokenEmojis: Bool?

    /// Model to use
    public let model: RecognitionModel?

    /// Use enhanced model
    public let useEnhanced: Bool?

    /// Number of audio channels
    public let audioChannelCount: Int?

    /// Enable separate recognition per channel
    public let enableSeparateRecognitionPerChannel: Bool?

    /// Enable word time offsets
    public let enableWordTimeOffsets: Bool?

    /// Enable word confidence
    public let enableWordConfidence: Bool?

    /// Audio encoding
    public enum AudioEncoding: String, Codable, Sendable {
        case unspecified = "ENCODING_UNSPECIFIED"
        case linear16 = "LINEAR16"
        case flac = "FLAC"
        case mulaw = "MULAW"
        case amr = "AMR"
        case amrWb = "AMR_WB"
        case oggOpus = "OGG_OPUS"
        case speexWithHeaderByte = "SPEEX_WITH_HEADER_BYTE"
        case mp3 = "MP3"
        case webmOpus = "WEBM_OPUS"
    }

    /// Recognition model
    public enum RecognitionModel: String, Codable, Sendable {
        case `default` = "default"
        case command_and_search = "command_and_search"
        case phone_call = "phone_call"
        case video = "video"
        case latest_long = "latest_long"
        case latest_short = "latest_short"
        case medical_dictation = "medical_dictation"
        case medical_conversation = "medical_conversation"
        case telephony = "telephony"
        case telephony_short = "telephony_short"
    }

    /// Speech context for adaptation
    public struct SpeechContext: Codable, Sendable, Equatable {
        /// Phrases to boost recognition
        public let phrases: [String]

        /// Boost value (0.0 to 20.0)
        public let boost: Double?

        public init(phrases: [String], boost: Double? = nil) {
            self.phrases = phrases
            self.boost = boost
        }
    }

    public init(
        encoding: AudioEncoding,
        sampleRateHertz: Int,
        languageCode: String,
        alternativeLanguageCodes: [String]? = nil,
        maxAlternatives: Int? = nil,
        profanityFilter: Bool? = nil,
        speechContexts: [SpeechContext]? = nil,
        enableAutomaticPunctuation: Bool? = nil,
        enableSpokenPunctuation: Bool? = nil,
        enableSpokenEmojis: Bool? = nil,
        model: RecognitionModel? = nil,
        useEnhanced: Bool? = nil,
        audioChannelCount: Int? = nil,
        enableSeparateRecognitionPerChannel: Bool? = nil,
        enableWordTimeOffsets: Bool? = nil,
        enableWordConfidence: Bool? = nil
    ) {
        self.encoding = encoding
        self.sampleRateHertz = sampleRateHertz
        self.languageCode = languageCode
        self.alternativeLanguageCodes = alternativeLanguageCodes
        self.maxAlternatives = maxAlternatives
        self.profanityFilter = profanityFilter
        self.speechContexts = speechContexts
        self.enableAutomaticPunctuation = enableAutomaticPunctuation
        self.enableSpokenPunctuation = enableSpokenPunctuation
        self.enableSpokenEmojis = enableSpokenEmojis
        self.model = model
        self.useEnhanced = useEnhanced
        self.audioChannelCount = audioChannelCount
        self.enableSeparateRecognitionPerChannel = enableSeparateRecognitionPerChannel
        self.enableWordTimeOffsets = enableWordTimeOffsets
        self.enableWordConfidence = enableWordConfidence
    }
}

// MARK: - Recognition Audio

/// Audio data for recognition
public struct GoogleCloudSpeechRecognitionAudio: Codable, Sendable, Equatable {
    /// Base64-encoded audio content
    public let content: String?

    /// GCS URI of the audio file
    public let uri: String?

    public init(content: String? = nil, uri: String? = nil) {
        self.content = content
        self.uri = uri
    }

    /// Create from GCS URI
    public static func fromGCS(_ uri: String) -> GoogleCloudSpeechRecognitionAudio {
        GoogleCloudSpeechRecognitionAudio(uri: uri)
    }
}

// MARK: - Recognition Request

/// A request to recognize speech
public struct GoogleCloudSpeechRecognitionRequest: Codable, Sendable, Equatable {
    /// Project ID
    public let projectID: String

    /// Recognition configuration
    public let config: GoogleCloudSpeechRecognitionConfig

    /// Audio data
    public let audio: GoogleCloudSpeechRecognitionAudio

    public init(
        projectID: String,
        config: GoogleCloudSpeechRecognitionConfig,
        audio: GoogleCloudSpeechRecognitionAudio
    ) {
        self.projectID = projectID
        self.config = config
        self.audio = audio
    }

    /// Command to recognize speech from a file
    public func recognizeCommand(audioFile: String) -> String {
        var cmd = "gcloud ml speech recognize \(audioFile)"
        cmd += " --language-code=\(config.languageCode)"

        if let model = config.model {
            cmd += " --model=\(model.rawValue)"
        }

        if config.enableAutomaticPunctuation == true {
            cmd += " --include-word-time-offsets"
        }

        cmd += " --project=\(projectID)"

        return cmd
    }

    /// Command for long running recognition
    public func longRunningRecognizeCommand(gcsUri: String) -> String {
        var cmd = "gcloud ml speech recognize-long-running \(gcsUri)"
        cmd += " --language-code=\(config.languageCode)"
        cmd += " --async"

        if let model = config.model {
            cmd += " --model=\(model.rawValue)"
        }

        if config.enableAutomaticPunctuation == true {
            cmd += " --include-word-time-offsets"
        }

        cmd += " --project=\(projectID)"

        return cmd
    }

    /// cURL command for synchronous recognition
    public func curlCommand(audioFile: String) -> String {
        """
        curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" \\
          -H "Content-Type: application/json" \\
          "https://speech.googleapis.com/v1/speech:recognize" \\
          -d '{
            "config": {
              "encoding": "\(config.encoding.rawValue)",
              "sampleRateHertz": \(config.sampleRateHertz),
              "languageCode": "\(config.languageCode)"
            },
            "audio": {
              "content": "'$(base64 -i \(audioFile))'"
            }
          }'
        """
    }
}

// MARK: - Recognition Response

/// Response from speech recognition
public struct GoogleCloudSpeechRecognitionResponse: Codable, Sendable, Equatable {
    /// Recognition results
    public let results: [SpeechRecognitionResult]?

    /// Total billed time
    public let totalBilledTime: String?

    /// Speech adaptation info
    public let speechAdaptationInfo: SpeechAdaptationInfo?

    /// Request ID
    public let requestId: String?

    public init(
        results: [SpeechRecognitionResult]? = nil,
        totalBilledTime: String? = nil,
        speechAdaptationInfo: SpeechAdaptationInfo? = nil,
        requestId: String? = nil
    ) {
        self.results = results
        self.totalBilledTime = totalBilledTime
        self.speechAdaptationInfo = speechAdaptationInfo
        self.requestId = requestId
    }
}

/// A single recognition result
public struct SpeechRecognitionResult: Codable, Sendable, Equatable {
    /// Alternative transcriptions
    public let alternatives: [SpeechRecognitionAlternative]?

    /// Channel tag
    public let channelTag: Int?

    /// Result end time
    public let resultEndTime: String?

    /// Language code
    public let languageCode: String?

    public init(
        alternatives: [SpeechRecognitionAlternative]? = nil,
        channelTag: Int? = nil,
        resultEndTime: String? = nil,
        languageCode: String? = nil
    ) {
        self.alternatives = alternatives
        self.channelTag = channelTag
        self.resultEndTime = resultEndTime
        self.languageCode = languageCode
    }
}

/// An alternative transcription
public struct SpeechRecognitionAlternative: Codable, Sendable, Equatable {
    /// Transcript text
    public let transcript: String

    /// Confidence score
    public let confidence: Double?

    /// Word-level information
    public let words: [WordInfo]?

    public init(
        transcript: String,
        confidence: Double? = nil,
        words: [WordInfo]? = nil
    ) {
        self.transcript = transcript
        self.confidence = confidence
        self.words = words
    }
}

/// Word-level information
public struct WordInfo: Codable, Sendable, Equatable {
    /// Start time of the word
    public let startTime: String?

    /// End time of the word
    public let endTime: String?

    /// The word itself
    public let word: String

    /// Confidence for this word
    public let confidence: Double?

    /// Speaker tag
    public let speakerTag: Int?

    public init(
        startTime: String? = nil,
        endTime: String? = nil,
        word: String,
        confidence: Double? = nil,
        speakerTag: Int? = nil
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.word = word
        self.confidence = confidence
        self.speakerTag = speakerTag
    }
}

/// Speech adaptation info
public struct SpeechAdaptationInfo: Codable, Sendable, Equatable {
    /// Whether adaptation was applied
    public let adaptationTimeout: Bool?

    /// Timeout message
    public let timeoutMessage: String?

    public init(adaptationTimeout: Bool? = nil, timeoutMessage: String? = nil) {
        self.adaptationTimeout = adaptationTimeout
        self.timeoutMessage = timeoutMessage
    }
}

// MARK: - Streaming Recognition

/// Configuration for streaming recognition
public struct GoogleCloudSpeechStreamingConfig: Codable, Sendable, Equatable {
    /// Recognition config
    public let config: GoogleCloudSpeechRecognitionConfig

    /// Single utterance mode
    public let singleUtterance: Bool?

    /// Interim results
    public let interimResults: Bool?

    public init(
        config: GoogleCloudSpeechRecognitionConfig,
        singleUtterance: Bool? = nil,
        interimResults: Bool? = nil
    ) {
        self.config = config
        self.singleUtterance = singleUtterance
        self.interimResults = interimResults
    }
}

// MARK: - Custom Class

/// A custom class for speech adaptation
public struct GoogleCloudSpeechCustomClass: Codable, Sendable, Equatable {
    /// Custom class name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Display name
    public let displayName: String?

    /// Custom class items
    public let items: [ClassItem]?

    /// A custom class item
    public struct ClassItem: Codable, Sendable, Equatable {
        /// Value of the item
        public let value: String

        public init(value: String) {
            self.value = value
        }
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        displayName: String? = nil,
        items: [ClassItem]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.items = items
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/customClasses/\(name)"
    }

    /// Command to create custom class
    public var createCommand: String {
        var cmd = "gcloud ml speech custom-classes create \(name) --location=\(location) --project=\(projectID)"
        if let displayName = displayName {
            cmd += " --display-name=\"\(displayName)\""
        }
        return cmd
    }

    /// Command to list custom classes
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud ml speech custom-classes list --location=\(location) --project=\(projectID)"
    }
}

// MARK: - Phrase Set

/// A phrase set for speech adaptation
public struct GoogleCloudSpeechPhraseSet: Codable, Sendable, Equatable {
    /// Phrase set name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Display name
    public let displayName: String?

    /// Phrases
    public let phrases: [Phrase]?

    /// Boost value
    public let boost: Double?

    /// A phrase in the phrase set
    public struct Phrase: Codable, Sendable, Equatable {
        /// The phrase value
        public let value: String

        /// Boost for this phrase
        public let boost: Double?

        public init(value: String, boost: Double? = nil) {
            self.value = value
            self.boost = boost
        }
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        displayName: String? = nil,
        phrases: [Phrase]? = nil,
        boost: Double? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.phrases = phrases
        self.boost = boost
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/phraseSets/\(name)"
    }

    /// Command to create phrase set
    public var createCommand: String {
        var cmd = "gcloud ml speech phrase-sets create \(name) --location=\(location) --project=\(projectID)"
        if let displayName = displayName {
            cmd += " --display-name=\"\(displayName)\""
        }
        return cmd
    }

    /// Command to list phrase sets
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud ml speech phrase-sets list --location=\(location) --project=\(projectID)"
    }
}

// MARK: - Recognizer (V2)

/// A Speech-to-Text V2 recognizer
public struct GoogleCloudSpeechRecognizer: Codable, Sendable, Equatable {
    /// Recognizer name
    public let name: String

    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Display name
    public let displayName: String?

    /// Model to use
    public let model: String?

    /// Language codes
    public let languageCodes: [String]

    /// Default recognition config
    public let defaultRecognitionConfig: GoogleCloudSpeechRecognitionConfig?

    /// State
    public let state: RecognizerState?

    /// Recognizer state
    public enum RecognizerState: String, Codable, Sendable {
        case unspecified = "STATE_UNSPECIFIED"
        case active = "ACTIVE"
        case deleted = "DELETED"
    }

    public init(
        name: String,
        projectID: String,
        location: String,
        displayName: String? = nil,
        model: String? = nil,
        languageCodes: [String],
        defaultRecognitionConfig: GoogleCloudSpeechRecognitionConfig? = nil,
        state: RecognizerState? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.displayName = displayName
        self.model = model
        self.languageCodes = languageCodes
        self.defaultRecognitionConfig = defaultRecognitionConfig
        self.state = state
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/recognizers/\(name)"
    }

    /// Command to create recognizer
    public var createCommand: String {
        var cmd = "gcloud ml speech recognizers create \(name) --location=\(location)"
        cmd += " --language-codes=\(languageCodes.joined(separator: ","))"

        if let displayName = displayName {
            cmd += " --display-name=\"\(displayName)\""
        }

        if let model = model {
            cmd += " --model=\(model)"
        }

        cmd += " --project=\(projectID)"
        return cmd
    }

    /// Command to list recognizers
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud ml speech recognizers list --location=\(location) --project=\(projectID)"
    }

    /// Command to describe recognizer
    public var describeCommand: String {
        "gcloud ml speech recognizers describe \(name) --location=\(location) --project=\(projectID)"
    }

    /// Command to delete recognizer
    public var deleteCommand: String {
        "gcloud ml speech recognizers delete \(name) --location=\(location) --project=\(projectID)"
    }
}

// MARK: - Speech Operations

/// Operations for Speech-to-Text
public struct SpeechToTextOperations: Sendable {
    private init() {}

    /// Enable Speech-to-Text API
    public static var enableAPICommand: String {
        "gcloud services enable speech.googleapis.com"
    }

    /// Recognize speech from a local file
    public static func recognizeCommand(audioFile: String, languageCode: String, projectID: String) -> String {
        "gcloud ml speech recognize \(audioFile) --language-code=\(languageCode) --project=\(projectID)"
    }

    /// Recognize speech from GCS (long running)
    public static func recognizeLongRunningCommand(gcsUri: String, languageCode: String, projectID: String) -> String {
        "gcloud ml speech recognize-long-running \(gcsUri) --language-code=\(languageCode) --async --project=\(projectID)"
    }

    /// Get operation status
    public static func getOperationCommand(operationName: String) -> String {
        "gcloud ml speech operations describe \(operationName)"
    }

    /// Wait for operation
    public static func waitOperationCommand(operationName: String) -> String {
        "gcloud ml speech operations wait \(operationName)"
    }

    /// List recognizers
    public static func listRecognizersCommand(projectID: String, location: String) -> String {
        "gcloud ml speech recognizers list --location=\(location) --project=\(projectID)"
    }

    /// List phrase sets
    public static func listPhraseSetsCommand(projectID: String, location: String) -> String {
        "gcloud ml speech phrase-sets list --location=\(location) --project=\(projectID)"
    }

    /// List custom classes
    public static func listCustomClassesCommand(projectID: String, location: String) -> String {
        "gcloud ml speech custom-classes list --location=\(location) --project=\(projectID)"
    }
}

// MARK: - DAIS Speech-to-Text Template

/// DAIS template for Speech-to-Text
public struct DAISSpeechToTextTemplate: Sendable {
    /// Project ID
    public let projectID: String

    /// Location
    public let location: String

    /// Service account
    public let serviceAccount: String

    /// GCS bucket for audio files
    public let audioBucket: String

    public init(
        projectID: String,
        location: String = "global",
        serviceAccount: String,
        audioBucket: String
    ) {
        self.projectID = projectID
        self.location = location
        self.serviceAccount = serviceAccount
        self.audioBucket = audioBucket
    }

    /// Standard English recognition config
    public var englishConfig: GoogleCloudSpeechRecognitionConfig {
        GoogleCloudSpeechRecognitionConfig(
            encoding: .linear16,
            sampleRateHertz: 16000,
            languageCode: "en-US",
            enableAutomaticPunctuation: true,
            model: .latest_long,
            useEnhanced: true,
            enableWordTimeOffsets: true
        )
    }

    /// Phone call recognition config
    public var phoneCallConfig: GoogleCloudSpeechRecognitionConfig {
        GoogleCloudSpeechRecognitionConfig(
            encoding: .mulaw,
            sampleRateHertz: 8000,
            languageCode: "en-US",
            enableAutomaticPunctuation: true,
            model: .phone_call,
            useEnhanced: true
        )
    }

    /// Video transcription config
    public var videoConfig: GoogleCloudSpeechRecognitionConfig {
        GoogleCloudSpeechRecognitionConfig(
            encoding: .linear16,
            sampleRateHertz: 16000,
            languageCode: "en-US",
            enableAutomaticPunctuation: true,
            model: .video,
            useEnhanced: true,
            enableWordTimeOffsets: true
        )
    }

    /// Multi-language config
    public var multiLanguageConfig: GoogleCloudSpeechRecognitionConfig {
        GoogleCloudSpeechRecognitionConfig(
            encoding: .linear16,
            sampleRateHertz: 16000,
            languageCode: "en-US",
            alternativeLanguageCodes: ["es-ES", "fr-FR", "de-DE"],
            enableAutomaticPunctuation: true,
            model: .latest_long
        )
    }

    /// Medical transcription config
    public var medicalConfig: GoogleCloudSpeechRecognitionConfig {
        GoogleCloudSpeechRecognitionConfig(
            encoding: .linear16,
            sampleRateHertz: 16000,
            languageCode: "en-US",
            enableAutomaticPunctuation: true,
            model: .medical_dictation,
            useEnhanced: true
        )
    }

    /// Sample speech context for DAIS domain
    public var daisSpeechContext: GoogleCloudSpeechRecognitionConfig.SpeechContext {
        GoogleCloudSpeechRecognitionConfig.SpeechContext(
            phrases: ["DAIS", "distributed AI", "agent", "node", "cluster", "orchestration"],
            boost: 10.0
        )
    }

    /// Sample recognizer
    public var recognizer: GoogleCloudSpeechRecognizer {
        GoogleCloudSpeechRecognizer(
            name: "dais-recognizer",
            projectID: projectID,
            location: location,
            displayName: "DAIS Speech Recognizer",
            model: "latest_long",
            languageCodes: ["en-US"]
        )
    }

    /// Sample phrase set
    public var phraseSet: GoogleCloudSpeechPhraseSet {
        GoogleCloudSpeechPhraseSet(
            name: "dais-phrases",
            projectID: projectID,
            location: location,
            displayName: "DAIS Domain Phrases",
            phrases: [
                GoogleCloudSpeechPhraseSet.Phrase(value: "DAIS", boost: 10.0),
                GoogleCloudSpeechPhraseSet.Phrase(value: "distributed AI system", boost: 8.0),
                GoogleCloudSpeechPhraseSet.Phrase(value: "agent cluster", boost: 6.0)
            ],
            boost: 5.0
        )
    }

    /// Setup script
    public var setupScript: String {
        """
        #!/bin/bash
        set -e

        # Enable Speech-to-Text API
        gcloud services enable speech.googleapis.com --project=\(projectID)

        # Create GCS bucket for audio files
        gsutil mb -p \(projectID) gs://\(audioBucket)/ || true

        # Grant service account access
        gsutil iam ch serviceAccount:\(serviceAccount):objectAdmin gs://\(audioBucket)/

        echo "Speech-to-Text infrastructure created successfully"
        """
    }

    /// Teardown script
    public var teardownScript: String {
        """
        #!/bin/bash
        set -e

        # Delete GCS bucket
        gsutil rm -r gs://\(audioBucket)/ || true

        echo "Speech-to-Text teardown complete"
        """
    }

    /// Python processing script
    public var pythonProcessingScript: String {
        """
        from google.cloud import speech_v1 as speech
        import io

        def transcribe_file(audio_file: str, language_code: str = "en-US") -> str:
            \"\"\"Transcribe a local audio file.\"\"\"
            client = speech.SpeechClient()

            with open(audio_file, "rb") as f:
                content = f.read()

            audio = speech.RecognitionAudio(content=content)
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
                sample_rate_hertz=16000,
                language_code=language_code,
                enable_automatic_punctuation=True,
            )

            response = client.recognize(config=config, audio=audio)

            transcript = ""
            for result in response.results:
                transcript += result.alternatives[0].transcript + " "

            return transcript.strip()

        def transcribe_gcs(gcs_uri: str, language_code: str = "en-US") -> str:
            \"\"\"Transcribe audio from GCS (long-running).\"\"\"
            client = speech.SpeechClient()

            audio = speech.RecognitionAudio(uri=gcs_uri)
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
                sample_rate_hertz=16000,
                language_code=language_code,
                enable_automatic_punctuation=True,
                enable_word_time_offsets=True,
            )

            operation = client.long_running_recognize(config=config, audio=audio)
            response = operation.result(timeout=300)

            transcript = ""
            for result in response.results:
                transcript += result.alternatives[0].transcript + " "

            return transcript.strip()

        def transcribe_with_word_timestamps(gcs_uri: str) -> list:
            \"\"\"Transcribe with word-level timestamps.\"\"\"
            client = speech.SpeechClient()

            audio = speech.RecognitionAudio(uri=gcs_uri)
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
                sample_rate_hertz=16000,
                language_code="en-US",
                enable_word_time_offsets=True,
            )

            operation = client.long_running_recognize(config=config, audio=audio)
            response = operation.result(timeout=300)

            words = []
            for result in response.results:
                for word_info in result.alternatives[0].words:
                    words.append({
                        "word": word_info.word,
                        "start_time": word_info.start_time.total_seconds(),
                        "end_time": word_info.end_time.total_seconds(),
                    })

            return words

        if __name__ == "__main__":
            # Example usage
            # transcript = transcribe_file("audio.wav")
            # print(transcript)

            gcs_uri = "gs://\(audioBucket)/sample-audio.flac"
            transcript = transcribe_gcs(gcs_uri)
            print(transcript)
        """
    }
}
