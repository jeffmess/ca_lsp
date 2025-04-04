# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/language_server-protocol/all/language_server-protocol.rbi
#
# language_server-protocol-3.17.0.4

module LanguageServer
end
module LanguageServer::Protocol
end
module LanguageServer::Protocol::Constant
end
module LanguageServer::Protocol::Constant::CodeActionKind
end
module LanguageServer::Protocol::Constant::CodeActionTriggerKind
end
module LanguageServer::Protocol::Constant::CompletionItemKind
end
module LanguageServer::Protocol::Constant::CompletionItemTag
end
module LanguageServer::Protocol::Constant::CompletionTriggerKind
end
module LanguageServer::Protocol::Constant::DiagnosticSeverity
end
module LanguageServer::Protocol::Constant::DiagnosticTag
end
module LanguageServer::Protocol::Constant::DocumentDiagnosticReportKind
end
module LanguageServer::Protocol::Constant::DocumentHighlightKind
end
module LanguageServer::Protocol::Constant::ErrorCodes
end
module LanguageServer::Protocol::Constant::FailureHandlingKind
end
module LanguageServer::Protocol::Constant::FileChangeType
end
module LanguageServer::Protocol::Constant::FileOperationPatternKind
end
module LanguageServer::Protocol::Constant::FoldingRangeKind
end
module LanguageServer::Protocol::Constant::InitializeErrorCodes
end
module LanguageServer::Protocol::Constant::InlayHintKind
end
module LanguageServer::Protocol::Constant::InsertTextFormat
end
module LanguageServer::Protocol::Constant::InsertTextMode
end
module LanguageServer::Protocol::Constant::MarkupKind
end
module LanguageServer::Protocol::Constant::MessageType
end
module LanguageServer::Protocol::Constant::MonikerKind
end
module LanguageServer::Protocol::Constant::NotebookCellKind
end
module LanguageServer::Protocol::Constant::PositionEncodingKind
end
module LanguageServer::Protocol::Constant::PrepareSupportDefaultBehavior
end
module LanguageServer::Protocol::Constant::ResourceOperationKind
end
module LanguageServer::Protocol::Constant::SemanticTokenModifiers
end
module LanguageServer::Protocol::Constant::SemanticTokenTypes
end
module LanguageServer::Protocol::Constant::SignatureHelpTriggerKind
end
module LanguageServer::Protocol::Constant::SymbolKind
end
module LanguageServer::Protocol::Constant::SymbolTag
end
module LanguageServer::Protocol::Constant::TextDocumentSaveReason
end
module LanguageServer::Protocol::Constant::TextDocumentSyncKind
end
module LanguageServer::Protocol::Constant::TokenFormat
end
module LanguageServer::Protocol::Constant::UniquenessLevel
end
module LanguageServer::Protocol::Constant::WatchKind
end
module LanguageServer::Protocol::Interface
end
class LanguageServer::Protocol::Interface::AnnotatedTextEdit
end
class LanguageServer::Protocol::Interface::ApplyWorkspaceEditParams
end
class LanguageServer::Protocol::Interface::ApplyWorkspaceEditResult
end
class LanguageServer::Protocol::Interface::CallHierarchyClientCapabilities
end
class LanguageServer::Protocol::Interface::CallHierarchyIncomingCall
end
class LanguageServer::Protocol::Interface::CallHierarchyIncomingCallsParams
end
class LanguageServer::Protocol::Interface::CallHierarchyItem
end
class LanguageServer::Protocol::Interface::CallHierarchyOptions
end
class LanguageServer::Protocol::Interface::CallHierarchyOutgoingCall
end
class LanguageServer::Protocol::Interface::CallHierarchyOutgoingCallsParams
end
class LanguageServer::Protocol::Interface::CallHierarchyPrepareParams
end
class LanguageServer::Protocol::Interface::CallHierarchyRegistrationOptions
end
class LanguageServer::Protocol::Interface::CancelParams
end
class LanguageServer::Protocol::Interface::ChangeAnnotation
end
class LanguageServer::Protocol::Interface::ClientCapabilities
end
class LanguageServer::Protocol::Interface::CodeAction
end
class LanguageServer::Protocol::Interface::CodeActionClientCapabilities
end
class LanguageServer::Protocol::Interface::CodeActionContext
end
class LanguageServer::Protocol::Interface::CodeActionOptions
end
class LanguageServer::Protocol::Interface::CodeActionParams
end
class LanguageServer::Protocol::Interface::CodeActionRegistrationOptions
end
class LanguageServer::Protocol::Interface::CodeDescription
end
class LanguageServer::Protocol::Interface::CodeLens
end
class LanguageServer::Protocol::Interface::CodeLensClientCapabilities
end
class LanguageServer::Protocol::Interface::CodeLensOptions
end
class LanguageServer::Protocol::Interface::CodeLensParams
end
class LanguageServer::Protocol::Interface::CodeLensRegistrationOptions
end
class LanguageServer::Protocol::Interface::CodeLensWorkspaceClientCapabilities
end
class LanguageServer::Protocol::Interface::Color
end
class LanguageServer::Protocol::Interface::ColorInformation
end
class LanguageServer::Protocol::Interface::ColorPresentation
end
class LanguageServer::Protocol::Interface::ColorPresentationParams
end
class LanguageServer::Protocol::Interface::Command
end
class LanguageServer::Protocol::Interface::CompletionClientCapabilities
end
class LanguageServer::Protocol::Interface::CompletionContext
end
class LanguageServer::Protocol::Interface::CompletionItem
end
class LanguageServer::Protocol::Interface::CompletionItemLabelDetails
end
class LanguageServer::Protocol::Interface::CompletionList
end
class LanguageServer::Protocol::Interface::CompletionOptions
end
class LanguageServer::Protocol::Interface::CompletionParams
end
class LanguageServer::Protocol::Interface::CompletionRegistrationOptions
end
class LanguageServer::Protocol::Interface::ConfigurationItem
end
class LanguageServer::Protocol::Interface::ConfigurationParams
end
class LanguageServer::Protocol::Interface::CreateFile
end
class LanguageServer::Protocol::Interface::CreateFileOptions
end
class LanguageServer::Protocol::Interface::CreateFilesParams
end
class LanguageServer::Protocol::Interface::DeclarationClientCapabilities
end
class LanguageServer::Protocol::Interface::DeclarationOptions
end
class LanguageServer::Protocol::Interface::DeclarationParams
end
class LanguageServer::Protocol::Interface::DeclarationRegistrationOptions
end
class LanguageServer::Protocol::Interface::DefinitionClientCapabilities
end
class LanguageServer::Protocol::Interface::DefinitionOptions
end
class LanguageServer::Protocol::Interface::DefinitionParams
end
class LanguageServer::Protocol::Interface::DefinitionRegistrationOptions
end
class LanguageServer::Protocol::Interface::DeleteFile
end
class LanguageServer::Protocol::Interface::DeleteFileOptions
end
class LanguageServer::Protocol::Interface::DeleteFilesParams
end
class LanguageServer::Protocol::Interface::Diagnostic
end
class LanguageServer::Protocol::Interface::DiagnosticClientCapabilities
end
class LanguageServer::Protocol::Interface::DiagnosticOptions
end
class LanguageServer::Protocol::Interface::DiagnosticRegistrationOptions
end
class LanguageServer::Protocol::Interface::DiagnosticRelatedInformation
end
class LanguageServer::Protocol::Interface::DiagnosticServerCancellationData
end
class LanguageServer::Protocol::Interface::DiagnosticWorkspaceClientCapabilities
end
class LanguageServer::Protocol::Interface::DidChangeConfigurationClientCapabilities
end
class LanguageServer::Protocol::Interface::DidChangeConfigurationParams
end
class LanguageServer::Protocol::Interface::DidChangeNotebookDocumentParams
end
class LanguageServer::Protocol::Interface::DidChangeTextDocumentParams
end
class LanguageServer::Protocol::Interface::DidChangeWatchedFilesClientCapabilities
end
class LanguageServer::Protocol::Interface::DidChangeWatchedFilesParams
end
class LanguageServer::Protocol::Interface::DidChangeWatchedFilesRegistrationOptions
end
class LanguageServer::Protocol::Interface::DidChangeWorkspaceFoldersParams
end
class LanguageServer::Protocol::Interface::DidCloseNotebookDocumentParams
end
class LanguageServer::Protocol::Interface::DidCloseTextDocumentParams
end
class LanguageServer::Protocol::Interface::DidOpenNotebookDocumentParams
end
class LanguageServer::Protocol::Interface::DidOpenTextDocumentParams
end
class LanguageServer::Protocol::Interface::DidSaveNotebookDocumentParams
end
class LanguageServer::Protocol::Interface::DidSaveTextDocumentParams
end
class LanguageServer::Protocol::Interface::DocumentColorClientCapabilities
end
class LanguageServer::Protocol::Interface::DocumentColorOptions
end
class LanguageServer::Protocol::Interface::DocumentColorParams
end
class LanguageServer::Protocol::Interface::DocumentColorRegistrationOptions
end
class LanguageServer::Protocol::Interface::DocumentDiagnosticParams
end
class LanguageServer::Protocol::Interface::DocumentDiagnosticReportPartialResult
end
class LanguageServer::Protocol::Interface::DocumentFilter
end
class LanguageServer::Protocol::Interface::DocumentFormattingClientCapabilities
end
class LanguageServer::Protocol::Interface::DocumentFormattingOptions
end
class LanguageServer::Protocol::Interface::DocumentFormattingParams
end
class LanguageServer::Protocol::Interface::DocumentFormattingRegistrationOptions
end
class LanguageServer::Protocol::Interface::DocumentHighlight
end
class LanguageServer::Protocol::Interface::DocumentHighlightClientCapabilities
end
class LanguageServer::Protocol::Interface::DocumentHighlightOptions
end
class LanguageServer::Protocol::Interface::DocumentHighlightParams
end
class LanguageServer::Protocol::Interface::DocumentHighlightRegistrationOptions
end
class LanguageServer::Protocol::Interface::DocumentLink
end
class LanguageServer::Protocol::Interface::DocumentLinkClientCapabilities
end
class LanguageServer::Protocol::Interface::DocumentLinkOptions
end
class LanguageServer::Protocol::Interface::DocumentLinkParams
end
class LanguageServer::Protocol::Interface::DocumentLinkRegistrationOptions
end
class LanguageServer::Protocol::Interface::DocumentOnTypeFormattingClientCapabilities
end
class LanguageServer::Protocol::Interface::DocumentOnTypeFormattingOptions
end
class LanguageServer::Protocol::Interface::DocumentOnTypeFormattingParams
end
class LanguageServer::Protocol::Interface::DocumentOnTypeFormattingRegistrationOptions
end
class LanguageServer::Protocol::Interface::DocumentRangeFormattingClientCapabilities
end
class LanguageServer::Protocol::Interface::DocumentRangeFormattingOptions
end
class LanguageServer::Protocol::Interface::DocumentRangeFormattingParams
end
class LanguageServer::Protocol::Interface::DocumentRangeFormattingRegistrationOptions
end
class LanguageServer::Protocol::Interface::DocumentSymbol
end
class LanguageServer::Protocol::Interface::DocumentSymbolClientCapabilities
end
class LanguageServer::Protocol::Interface::DocumentSymbolOptions
end
class LanguageServer::Protocol::Interface::DocumentSymbolParams
end
class LanguageServer::Protocol::Interface::DocumentSymbolRegistrationOptions
end
class LanguageServer::Protocol::Interface::ExecuteCommandClientCapabilities
end
class LanguageServer::Protocol::Interface::ExecuteCommandOptions
end
class LanguageServer::Protocol::Interface::ExecuteCommandParams
end
class LanguageServer::Protocol::Interface::ExecuteCommandRegistrationOptions
end
class LanguageServer::Protocol::Interface::ExecutionSummary
end
class LanguageServer::Protocol::Interface::FileCreate
end
class LanguageServer::Protocol::Interface::FileDelete
end
class LanguageServer::Protocol::Interface::FileEvent
end
class LanguageServer::Protocol::Interface::FileOperationFilter
end
class LanguageServer::Protocol::Interface::FileOperationPattern
end
class LanguageServer::Protocol::Interface::FileOperationPatternOptions
end
class LanguageServer::Protocol::Interface::FileOperationRegistrationOptions
end
class LanguageServer::Protocol::Interface::FileRename
end
class LanguageServer::Protocol::Interface::FileSystemWatcher
end
class LanguageServer::Protocol::Interface::FoldingRange
end
class LanguageServer::Protocol::Interface::FoldingRangeClientCapabilities
end
class LanguageServer::Protocol::Interface::FoldingRangeOptions
end
class LanguageServer::Protocol::Interface::FoldingRangeParams
end
class LanguageServer::Protocol::Interface::FoldingRangeRegistrationOptions
end
class LanguageServer::Protocol::Interface::FormattingOptions
end
class LanguageServer::Protocol::Interface::FullDocumentDiagnosticReport
end
class LanguageServer::Protocol::Interface::Hover
end
class LanguageServer::Protocol::Interface::HoverClientCapabilities
end
class LanguageServer::Protocol::Interface::HoverOptions
end
class LanguageServer::Protocol::Interface::HoverParams
end
class LanguageServer::Protocol::Interface::HoverRegistrationOptions
end
class LanguageServer::Protocol::Interface::HoverResult
end
class LanguageServer::Protocol::Interface::ImplementationClientCapabilities
end
class LanguageServer::Protocol::Interface::ImplementationOptions
end
class LanguageServer::Protocol::Interface::ImplementationParams
end
class LanguageServer::Protocol::Interface::ImplementationRegistrationOptions
end
class LanguageServer::Protocol::Interface::InitializeError
end
class LanguageServer::Protocol::Interface::InitializeParams
end
class LanguageServer::Protocol::Interface::InitializeResult
end
class LanguageServer::Protocol::Interface::InitializedParams
end
class LanguageServer::Protocol::Interface::InlayHint
end
class LanguageServer::Protocol::Interface::InlayHintClientCapabilities
end
class LanguageServer::Protocol::Interface::InlayHintLabelPart
end
class LanguageServer::Protocol::Interface::InlayHintOptions
end
class LanguageServer::Protocol::Interface::InlayHintParams
end
class LanguageServer::Protocol::Interface::InlayHintRegistrationOptions
end
class LanguageServer::Protocol::Interface::InlayHintWorkspaceClientCapabilities
end
class LanguageServer::Protocol::Interface::InlineValueClientCapabilities
end
class LanguageServer::Protocol::Interface::InlineValueContext
end
class LanguageServer::Protocol::Interface::InlineValueEvaluatableExpression
end
class LanguageServer::Protocol::Interface::InlineValueOptions
end
class LanguageServer::Protocol::Interface::InlineValueParams
end
class LanguageServer::Protocol::Interface::InlineValueRegistrationOptions
end
class LanguageServer::Protocol::Interface::InlineValueText
end
class LanguageServer::Protocol::Interface::InlineValueVariableLookup
end
class LanguageServer::Protocol::Interface::InlineValueWorkspaceClientCapabilities
end
class LanguageServer::Protocol::Interface::InsertReplaceEdit
end
class LanguageServer::Protocol::Interface::LinkedEditingRangeClientCapabilities
end
class LanguageServer::Protocol::Interface::LinkedEditingRangeOptions
end
class LanguageServer::Protocol::Interface::LinkedEditingRangeParams
end
class LanguageServer::Protocol::Interface::LinkedEditingRangeRegistrationOptions
end
class LanguageServer::Protocol::Interface::LinkedEditingRanges
end
class LanguageServer::Protocol::Interface::Location
end
class LanguageServer::Protocol::Interface::LocationLink
end
class LanguageServer::Protocol::Interface::LogMessageParams
end
class LanguageServer::Protocol::Interface::LogTraceParams
end
class LanguageServer::Protocol::Interface::MarkupContent
end
class LanguageServer::Protocol::Interface::Message
end
class LanguageServer::Protocol::Interface::MessageActionItem
end
class LanguageServer::Protocol::Interface::Moniker
end
class LanguageServer::Protocol::Interface::MonikerClientCapabilities
end
class LanguageServer::Protocol::Interface::MonikerOptions
end
class LanguageServer::Protocol::Interface::MonikerParams
end
class LanguageServer::Protocol::Interface::MonikerRegistrationOptions
end
class LanguageServer::Protocol::Interface::NotebookCell
end
class LanguageServer::Protocol::Interface::NotebookCellArrayChange
end
class LanguageServer::Protocol::Interface::NotebookCellTextDocumentFilter
end
class LanguageServer::Protocol::Interface::NotebookDocument
end
class LanguageServer::Protocol::Interface::NotebookDocumentChangeEvent
end
class LanguageServer::Protocol::Interface::NotebookDocumentClientCapabilities
end
class LanguageServer::Protocol::Interface::NotebookDocumentFilter
end
class LanguageServer::Protocol::Interface::NotebookDocumentIdentifier
end
class LanguageServer::Protocol::Interface::NotebookDocumentSyncClientCapabilities
end
class LanguageServer::Protocol::Interface::NotebookDocumentSyncOptions
end
class LanguageServer::Protocol::Interface::NotebookDocumentSyncRegistrationOptions
end
class LanguageServer::Protocol::Interface::NotificationMessage
end
class LanguageServer::Protocol::Interface::OptionalVersionedTextDocumentIdentifier
end
class LanguageServer::Protocol::Interface::ParameterInformation
end
class LanguageServer::Protocol::Interface::PartialResultParams
end
class LanguageServer::Protocol::Interface::Position
end
class LanguageServer::Protocol::Interface::PrepareRenameParams
end
class LanguageServer::Protocol::Interface::PreviousResultId
end
class LanguageServer::Protocol::Interface::ProgressParams
end
class LanguageServer::Protocol::Interface::PublishDiagnosticsClientCapabilities
end
class LanguageServer::Protocol::Interface::PublishDiagnosticsParams
end
class LanguageServer::Protocol::Interface::Range
end
class LanguageServer::Protocol::Interface::ReferenceClientCapabilities
end
class LanguageServer::Protocol::Interface::ReferenceContext
end
class LanguageServer::Protocol::Interface::ReferenceOptions
end
class LanguageServer::Protocol::Interface::ReferenceParams
end
class LanguageServer::Protocol::Interface::ReferenceRegistrationOptions
end
class LanguageServer::Protocol::Interface::Registration
end
class LanguageServer::Protocol::Interface::RegistrationParams
end
class LanguageServer::Protocol::Interface::RegularExpressionsClientCapabilities
end
class LanguageServer::Protocol::Interface::RelatedFullDocumentDiagnosticReport
end
class LanguageServer::Protocol::Interface::RelatedUnchangedDocumentDiagnosticReport
end
class LanguageServer::Protocol::Interface::RelativePattern
end
class LanguageServer::Protocol::Interface::RenameClientCapabilities
end
class LanguageServer::Protocol::Interface::RenameFile
end
class LanguageServer::Protocol::Interface::RenameFileOptions
end
class LanguageServer::Protocol::Interface::RenameFilesParams
end
class LanguageServer::Protocol::Interface::RenameOptions
end
class LanguageServer::Protocol::Interface::RenameParams
end
class LanguageServer::Protocol::Interface::RenameRegistrationOptions
end
class LanguageServer::Protocol::Interface::RequestMessage
end
class LanguageServer::Protocol::Interface::ResponseError
end
class LanguageServer::Protocol::Interface::ResponseMessage
end
class LanguageServer::Protocol::Interface::SaveOptions
end
class LanguageServer::Protocol::Interface::SelectionRange
end
class LanguageServer::Protocol::Interface::SelectionRangeClientCapabilities
end
class LanguageServer::Protocol::Interface::SelectionRangeOptions
end
class LanguageServer::Protocol::Interface::SelectionRangeParams
end
class LanguageServer::Protocol::Interface::SelectionRangeRegistrationOptions
end
class LanguageServer::Protocol::Interface::SemanticTokens
end
class LanguageServer::Protocol::Interface::SemanticTokensClientCapabilities
end
class LanguageServer::Protocol::Interface::SemanticTokensDelta
end
class LanguageServer::Protocol::Interface::SemanticTokensDeltaParams
end
class LanguageServer::Protocol::Interface::SemanticTokensDeltaPartialResult
end
class LanguageServer::Protocol::Interface::SemanticTokensEdit
end
class LanguageServer::Protocol::Interface::SemanticTokensLegend
end
class LanguageServer::Protocol::Interface::SemanticTokensOptions
end
class LanguageServer::Protocol::Interface::SemanticTokensParams
end
class LanguageServer::Protocol::Interface::SemanticTokensPartialResult
end
class LanguageServer::Protocol::Interface::SemanticTokensRangeParams
end
class LanguageServer::Protocol::Interface::SemanticTokensRegistrationOptions
end
class LanguageServer::Protocol::Interface::SemanticTokensWorkspaceClientCapabilities
end
class LanguageServer::Protocol::Interface::ServerCapabilities
end
class LanguageServer::Protocol::Interface::SetTraceParams
end
class LanguageServer::Protocol::Interface::ShowDocumentClientCapabilities
end
class LanguageServer::Protocol::Interface::ShowDocumentParams
end
class LanguageServer::Protocol::Interface::ShowDocumentResult
end
class LanguageServer::Protocol::Interface::ShowMessageParams
end
class LanguageServer::Protocol::Interface::ShowMessageRequestClientCapabilities
end
class LanguageServer::Protocol::Interface::ShowMessageRequestParams
end
class LanguageServer::Protocol::Interface::SignatureHelp
end
class LanguageServer::Protocol::Interface::SignatureHelpClientCapabilities
end
class LanguageServer::Protocol::Interface::SignatureHelpContext
end
class LanguageServer::Protocol::Interface::SignatureHelpOptions
end
class LanguageServer::Protocol::Interface::SignatureHelpParams
end
class LanguageServer::Protocol::Interface::SignatureHelpRegistrationOptions
end
class LanguageServer::Protocol::Interface::SignatureInformation
end
class LanguageServer::Protocol::Interface::StaticRegistrationOptions
end
class LanguageServer::Protocol::Interface::SymbolInformation
end
class LanguageServer::Protocol::Interface::TextDocumentChangeRegistrationOptions
end
class LanguageServer::Protocol::Interface::TextDocumentClientCapabilities
end
class LanguageServer::Protocol::Interface::TextDocumentContentChangeEvent
end
class LanguageServer::Protocol::Interface::TextDocumentEdit
end
class LanguageServer::Protocol::Interface::TextDocumentIdentifier
end
class LanguageServer::Protocol::Interface::TextDocumentItem
end
class LanguageServer::Protocol::Interface::TextDocumentPositionParams
end
class LanguageServer::Protocol::Interface::TextDocumentRegistrationOptions
end
class LanguageServer::Protocol::Interface::TextDocumentSaveRegistrationOptions
end
class LanguageServer::Protocol::Interface::TextDocumentSyncClientCapabilities
end
class LanguageServer::Protocol::Interface::TextDocumentSyncOptions
end
class LanguageServer::Protocol::Interface::TextEdit
end
class LanguageServer::Protocol::Interface::TypeDefinitionClientCapabilities
end
class LanguageServer::Protocol::Interface::TypeDefinitionOptions
end
class LanguageServer::Protocol::Interface::TypeDefinitionParams
end
class LanguageServer::Protocol::Interface::TypeDefinitionRegistrationOptions
end
class LanguageServer::Protocol::Interface::TypeHierarchyItem
end
class LanguageServer::Protocol::Interface::TypeHierarchyOptions
end
class LanguageServer::Protocol::Interface::TypeHierarchyPrepareParams
end
class LanguageServer::Protocol::Interface::TypeHierarchyRegistrationOptions
end
class LanguageServer::Protocol::Interface::TypeHierarchySubtypesParams
end
class LanguageServer::Protocol::Interface::TypeHierarchySupertypesParams
end
class LanguageServer::Protocol::Interface::UnchangedDocumentDiagnosticReport
end
class LanguageServer::Protocol::Interface::Unregistration
end
class LanguageServer::Protocol::Interface::UnregistrationParams
end
class LanguageServer::Protocol::Interface::VersionedNotebookDocumentIdentifier
end
class LanguageServer::Protocol::Interface::VersionedTextDocumentIdentifier
end
class LanguageServer::Protocol::Interface::WillSaveTextDocumentParams
end
class LanguageServer::Protocol::Interface::WorkDoneProgressBegin
end
class LanguageServer::Protocol::Interface::WorkDoneProgressCancelParams
end
class LanguageServer::Protocol::Interface::WorkDoneProgressCreateParams
end
class LanguageServer::Protocol::Interface::WorkDoneProgressEnd
end
class LanguageServer::Protocol::Interface::WorkDoneProgressOptions
end
class LanguageServer::Protocol::Interface::WorkDoneProgressParams
end
class LanguageServer::Protocol::Interface::WorkDoneProgressReport
end
class LanguageServer::Protocol::Interface::WorkspaceDiagnosticParams
end
class LanguageServer::Protocol::Interface::WorkspaceDiagnosticReport
end
class LanguageServer::Protocol::Interface::WorkspaceDiagnosticReportPartialResult
end
class LanguageServer::Protocol::Interface::WorkspaceEdit
end
class LanguageServer::Protocol::Interface::WorkspaceEditClientCapabilities
end
class LanguageServer::Protocol::Interface::WorkspaceFolder
end
class LanguageServer::Protocol::Interface::WorkspaceFoldersChangeEvent
end
class LanguageServer::Protocol::Interface::WorkspaceFoldersServerCapabilities
end
class LanguageServer::Protocol::Interface::WorkspaceFullDocumentDiagnosticReport
end
class LanguageServer::Protocol::Interface::WorkspaceSymbol
end
class LanguageServer::Protocol::Interface::WorkspaceSymbolClientCapabilities
end
class LanguageServer::Protocol::Interface::WorkspaceSymbolOptions
end
class LanguageServer::Protocol::Interface::WorkspaceSymbolParams
end
class LanguageServer::Protocol::Interface::WorkspaceSymbolRegistrationOptions
end
class LanguageServer::Protocol::Interface::WorkspaceUnchangedDocumentDiagnosticReport
end
module LanguageServer::Protocol::Transport
end
module LanguageServer::Protocol::Transport::Io
end
class LanguageServer::Protocol::Transport::Io::Reader
end
class LanguageServer::Protocol::Transport::Io::Writer
end
module LanguageServer::Protocol::Transport::Stdio
end
class LanguageServer::Protocol::Transport::Stdio::Reader < LanguageServer::Protocol::Transport::Io::Reader
end
class LanguageServer::Protocol::Transport::Stdio::Writer < LanguageServer::Protocol::Transport::Io::Writer
end
