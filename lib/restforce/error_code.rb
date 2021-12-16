# frozen_string_literal: true

module Restforce
  module ErrorCode
    GITHUB_ISSUE_URL = "https://github.com/restforce/restforce/issues/new?template=" \
                       "unhandled-salesforce-error.md&title=Unhandled+Salesforce+error" \
                       "%3A+%3Cinsert+error+code+here%3E"

    # We define all of the known errors returned by Salesforce based on the
    # documentation at
    # https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_calls_concepts_core_data_objects.htm#statuscode
    # Previously, these were defined dynamically at runtime using `Module.const_set`. Now
    # we define them up-front.
    # It is possible that we will be missing some errors, so we will handle this in
    # at least a semi-graceful manner.
    class AllOrNoneOperationRolledBack < ResponseError; end

    class AlreadyInProcess < ResponseError; end

    class ApexError < ResponseError; end

    class ApiCurrentlyDisabled < ResponseError; end

    class ApiDisabledForOrg < ResponseError; end

    class AssigneeTypeRequired < ResponseError; end

    class BadCustomEntityParentDomain < ResponseError; end

    class BccNotAllowedIfBccComplianceEnabled < ResponseError; end

    class BccSelfNotAllowedIfBccComplianceEnabled < ResponseError; end

    class BigObjectUnsupportedOperation < ResponseError; end

    class CannotCascadeProductActive < ResponseError; end

    class CannotChangeFieldTypeOfApexReferencedField < ResponseError; end

    class CannotCreateAnotherManagedPackage < ResponseError; end

    class CannotDeactivateDivision < ResponseError; end

    class CannotDeleteLastDatedConversionRate < ResponseError; end

    class CannotDeleteManagedObject < ResponseError; end

    class CannotDisableLastAdmin < ResponseError; end

    class CannotEnableIpRestrictRequests < ResponseError; end

    class CannotExecuteFlowTrigger < ResponseError; end

    class CannotInsertUpdateActivateEntity < ResponseError; end

    class CannotModifyManagedObject < ResponseError; end

    class CannotRenameApexReferencedField < ResponseError; end

    class CannotRenameApexReferencedObject < ResponseError; end

    class CannotReparentRecord < ResponseError; end

    class CannotResolveName < ResponseError; end

    class CannotUpdateConvertedLead < ResponseError; end

    class CantDisableCorpCurrency < ResponseError; end

    class CantUnsetCorpCurrency < ResponseError; end

    class ChildShareFailsParent < ResponseError; end

    class CircularDependency < ResponseError; end

    class CommunityNotAccessible < ResponseError; end

    class CustomClobFieldLimitExceeded < ResponseError; end

    class CustomEntityOrFieldLimit < ResponseError; end

    class CustomFieldIndexLimitExceeded < ResponseError; end

    class CustomIndexExists < ResponseError; end

    class CustomLinkLimitExceeded < ResponseError; end

    class CustomMetadataLimitExceeded < ResponseError; end

    class CustomSettingsLimitExceeded < ResponseError; end

    class CustomTabLimitExceeded < ResponseError; end

    class DeleteFailed < ResponseError; end

    class DependencyExists < ResponseError; end

    class DuplicateCaseSolution < ResponseError; end

    class DuplicateCustomEntityDefinition < ResponseError; end

    class DuplicateCustomTabMotif < ResponseError; end

    class DuplicateDeveloperName < ResponseError; end

    class DuplicatesDetected < ResponseError; end

    class DuplicateExternalId < ResponseError; end

    class DuplicateMasterLabel < ResponseError; end

    class DuplicateSenderDisplayName < ResponseError; end

    class DuplicateUsername < ResponseError; end

    class DuplicateValue < ResponseError; end

    class EmailAddressBounced < ResponseError; end

    class EmailNotProcessedDueToPriorError < ResponseError; end

    class EmailOptedOut < ResponseError; end

    class EmailTemplateFormulaError < ResponseError; end

    class EmailTemplateMergefieldAccessError < ResponseError; end

    class EmailTemplateMergefieldError < ResponseError; end

    class EmailTemplateMergefieldValueError < ResponseError; end

    class EmailTemplateProcessingError < ResponseError; end

    class EmptyScontrolFileName < ResponseError; end

    class EntityFailedIflastmodifiedOnUpdate < ResponseError; end

    class EntityIsArchived < ResponseError; end

    class EntityIsDeleted < ResponseError; end

    class EntityIsLocked < ResponseError; end

    class EnvironmentHubMembershipConflict < ResponseError; end

    class ErrorInMailer < ResponseError; end

    class ExceededMaxSemijoinSubselects < ResponseError; end

    class FailedActivation < ResponseError; end

    class FieldCustomValidationException < ResponseError; end

    class FieldFilterValidationException < ResponseError; end

    class FieldIntegrityException < ResponseError; end

    class FilteredLookupLimitExceeded < ResponseError; end

    class Forbidden < ResponseError; end

    class HtmlFileUploadNotAllowed < ResponseError; end

    class IllegalQueryParameterValue < ResponseError; end

    class ImageTooLarge < ResponseError; end

    class InactiveOwnerOrUser < ResponseError; end

    class InsertUpdateDeleteNotAllowedDuringMaintenance < ResponseError; end

    class InsufficientAccessOnCrossReferenceEntity < ResponseError; end

    class InsufficientAccessOrReadonly < ResponseError; end

    class InvalidAccessLevel < ResponseError; end

    class InvalidArgumentType < ResponseError; end

    class InvalidAssigneeType < ResponseError; end

    class InvalidAssignmentRule < ResponseError; end

    class InvalidBatchOperation < ResponseError; end

    class InvalidContentType < ResponseError; end

    class InvalidCreditCardInfo < ResponseError; end

    class InvalidCrossReferenceKey < ResponseError; end

    class InvalidCrossReferenceTypeForField < ResponseError; end

    class InvalidCurrencyConvRate < ResponseError; end

    class InvalidCurrencyCorpRate < ResponseError; end

    class InvalidCurrencyIso < ResponseError; end

    class InvalidEmailAddress < ResponseError; end

    class InvalidEmptyKeyOwner < ResponseError; end

    class InvalidEventSubscription < ResponseError; end

    class InvalidField < ResponseError; end

    class InvalidFieldForInsertUpdate < ResponseError; end

    class InvalidFieldWhenUsingTemplate < ResponseError; end

    class InvalidFilterAction < ResponseError; end

    class InvalidIdField < ResponseError; end

    class InvalidInetAddress < ResponseError; end

    class InvalidLineitemCloneState < ResponseError; end

    class InvalidMasterOrTranslatedSolution < ResponseError; end

    class InvalidMessageIdReference < ResponseError; end

    class InvalidOperation < ResponseError; end

    class InvalidOperationWithExpiredPassword < ResponseError; end

    class InvalidOperator < ResponseError; end

    class InvalidOrNullForRestrictedPicklist < ResponseError; end

    class InvalidQueryFilterOperator < ResponseError; end

    class InvalidQueryLocator < ResponseError; end

    class InvalidPartnerNetworkStatus < ResponseError; end

    class InvalidPersonAccountOperation < ResponseError; end

    class InvalidReadOnlyUserDml < ResponseError; end

    class InvalidReplicationDate < ResponseError; end

    class InvalidSaveAsActivityFlag < ResponseError; end

    class InvalidSessionId < ResponseError; end

    class InvalidSignupCountry < ResponseError; end

    class InvalidStatus < ResponseError; end

    class InvalidType < ResponseError; end

    class InvalidTypeForOperation < ResponseError; end

    class InvalidTypeOnFieldInRecord < ResponseError; end

    class IpRangeLimitExceeded < ResponseError; end

    class JigsawImportLimitExceeded < ResponseError; end

    class JsonParserError < ResponseError; end

    class LicenseLimitExceeded < ResponseError; end

    class LightPortalUserException < ResponseError; end

    class LimitExceeded < ResponseError; end

    class LoginChallengeIssued < ResponseError; end

    class LoginChallengePending < ResponseError; end

    class LoginMustUseSecurityToken < ResponseError; end

    class MalformedId < ResponseError; end

    class MalformedQuery < ResponseError; end

    class MalformedSearch < ResponseError; end

    class ManagerNotDefined < ResponseError; end

    class MassmailRetryLimitExceeded < ResponseError; end

    class MassMailLimitExceeded < ResponseError; end

    class MaximumCcemailsExceeded < ResponseError; end

    class MaximumDashboardComponentsExceeded < ResponseError; end

    class MaximumHierarchyLevelsReached < ResponseError; end

    class MaximumSizeOfAttachment < ResponseError; end

    class MaximumSizeOfDocument < ResponseError; end

    class MaxActionsPerRuleExceeded < ResponseError; end

    class MaxActiveRulesExceeded < ResponseError; end

    class MaxApprovalStepsExceeded < ResponseError; end

    class MaxFormulasPerRuleExceeded < ResponseError; end

    class MaxRulesExceeded < ResponseError; end

    class MaxRuleEntriesExceeded < ResponseError; end

    class MaxTaskDescriptionExceeded < ResponseError; end

    class MaxTmRulesExceeded < ResponseError; end

    class MaxTmRuleItemsExceeded < ResponseError; end

    class MergeFailed < ResponseError; end

    class MethodNotAllowed < ResponseError; end

    class MissingArgument < ResponseError; end

    class NonuniqueShippingAddress < ResponseError; end

    class NoApplicableProcess < ResponseError; end

    class NoAttachmentPermission < ResponseError; end

    class NoInactiveDivisionMembers < ResponseError; end

    class NoMassMailPermission < ResponseError; end

    class NumberOutsideValidRange < ResponseError; end

    class NumHistoryFieldsBySobjectExceeded < ResponseError; end

    class OpWithInvalidUserTypeException < ResponseError; end

    class OperationTooLarge < ResponseError; end

    class OptedOutOfMassMail < ResponseError; end

    class PackageLicenseRequired < ResponseError; end

    class PlatformEventEncryptionError < ResponseError; end

    class PlatformEventPublishingUnavailable < ResponseError; end

    class PlatformEventPublishFailed < ResponseError; end

    class PortalUserAlreadyExistsForContact < ResponseError; end

    class PrivateContactOnAsset < ResponseError; end

    class QueryTimeout < ResponseError; end

    class RecordInUseByWorkflow < ResponseError; end

    class RequestLimitExceeded < ResponseError; end

    class RequestRunningTooLong < ResponseError; end

    class RequiredFieldMissing < ResponseError; end

    class SelfReferenceFromTrigger < ResponseError; end

    class ServerUnavailable < ResponseError; end

    class ShareNeededForChildOwner < ResponseError; end

    class SingleEmailLimitExceeded < ResponseError; end

    class StandardPriceNotDefined < ResponseError; end

    class StorageLimitExceeded < ResponseError; end

    class StringTooLong < ResponseError; end

    class TabsetLimitExceeded < ResponseError; end

    class TemplateNotActive < ResponseError; end

    class TerritoryRealignInProgress < ResponseError; end

    class TextDataOutsideSupportedCharset < ResponseError; end

    class TooManyApexRequests < ResponseError; end

    class TooManyEnumValue < ResponseError; end

    class TransferRequiresRead < ResponseError; end

    class UnableToLockRow < ResponseError; end

    class UnavailableRecordtypeException < ResponseError; end

    class UndeleteFailed < ResponseError; end

    class UnknownException < ResponseError; end

    class UnspecifiedEmailAddress < ResponseError; end

    class UnsupportedApexTriggerOperation < ResponseError; end

    class UnverifiedSenderAddress < ResponseError; end

    class WeblinkSizeLimitExceeded < ResponseError; end

    class WeblinkUrlInvalid < ResponseError; end

    class WrongControllerType < ResponseError; end

    # Maps `errorCode`s returned from Salesforce to the exception class
    # to be used for these errors
    ERROR_EXCEPTION_CLASSES = {
      "ALL_OR_NONE_OPERATION_ROLLED_BACK" => AllOrNoneOperationRolledBack,
      "ALREADY_IN_PROCESS" => AlreadyInProcess,
      "APEX_ERROR" => ApexError,
      "API_CURRENTLY_DISABLED" => ApiCurrentlyDisabled,
      "API_DISABLED_FOR_ORG" => ApiDisabledForOrg,
      "ASSIGNEE_TYPE_REQUIRED" => AssigneeTypeRequired,
      "BAD_CUSTOM_ENTITY_PARENT_DOMAIN" => BadCustomEntityParentDomain,
      "BCC_NOT_ALLOWED_IF_BCC_COMPLIANCE_ENABLED" =>
   BccNotAllowedIfBccComplianceEnabled,
      "BCC_SELF_NOT_ALLOWED_IF_BCC_COMPLIANCE_ENABLED" =>
   BccSelfNotAllowedIfBccComplianceEnabled,
      "BIG_OBJECT_UNSUPPORTED_OPERATION" => BigObjectUnsupportedOperation,
      "CANNOT_CASCADE_PRODUCT_ACTIVE" => CannotCascadeProductActive,
      "CANNOT_CHANGE_FIELD_TYPE_OF_APEX_REFERENCED_FIELD" =>
   CannotChangeFieldTypeOfApexReferencedField,
      "CANNOT_CREATE_ANOTHER_MANAGED_PACKAGE" => CannotCreateAnotherManagedPackage,
      "CANNOT_DEACTIVATE_DIVISION" => CannotDeactivateDivision,
      "CANNOT_DELETE_LAST_DATED_CONVERSION_RATE" =>
   CannotDeleteLastDatedConversionRate,
      "CANNOT_DELETE_MANAGED_OBJECT" => CannotDeleteManagedObject,
      "CANNOT_DISABLE_LAST_ADMIN" => CannotDisableLastAdmin,
      "CANNOT_ENABLE_IP_RESTRICT_REQUESTS" => CannotEnableIpRestrictRequests,
      "CANNOT_EXECUTE_FLOW_TRIGGER" => CannotExecuteFlowTrigger,
      "CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY" => CannotInsertUpdateActivateEntity,
      "CANNOT_MODIFY_MANAGED_OBJECT" => CannotModifyManagedObject,
      "CANNOT_RENAME_APEX_REFERENCED_FIELD" => CannotRenameApexReferencedField,
      "CANNOT_RENAME_APEX_REFERENCED_OBJECT" => CannotRenameApexReferencedObject,
      "CANNOT_REPARENT_RECORD" => CannotReparentRecord,
      "CANNOT_RESOLVE_NAME" => CannotResolveName,
      "CANNOT_UPDATE_CONVERTED_LEAD" => CannotUpdateConvertedLead,
      "CANT_DISABLE_CORP_CURRENCY" => CantDisableCorpCurrency,
      "CANT_UNSET_CORP_CURRENCY" => CantUnsetCorpCurrency,
      "CHILD_SHARE_FAILS_PARENT" => ChildShareFailsParent,
      "CIRCULAR_DEPENDENCY" => CircularDependency,
      "COMMUNITY_NOT_ACCESSIBLE" => CommunityNotAccessible,
      "CUSTOM_CLOB_FIELD_LIMIT_EXCEEDED" => CustomClobFieldLimitExceeded,
      "CUSTOM_ENTITY_OR_FIELD_LIMIT" => CustomEntityOrFieldLimit,
      "CUSTOM_FIELD_INDEX_LIMIT_EXCEEDED" => CustomFieldIndexLimitExceeded,
      "CUSTOM_INDEX_EXISTS" => CustomIndexExists,
      "CUSTOM_LINK_LIMIT_EXCEEDED" => CustomLinkLimitExceeded,
      "CUSTOM_METADATA_LIMIT_EXCEEDED" => CustomMetadataLimitExceeded,
      "CUSTOM_SETTINGS_LIMIT_EXCEEDED" => CustomSettingsLimitExceeded,
      "CUSTOM_TAB_LIMIT_EXCEEDED" => CustomTabLimitExceeded,
      "DELETE_FAILED" => DeleteFailed,
      "DEPENDENCY_EXISTS" => DependencyExists,
      "DUPLICATE_CASE_SOLUTION" => DuplicateCaseSolution,
      "DUPLICATE_CUSTOM_ENTITY_DEFINITION" => DuplicateCustomEntityDefinition,
      "DUPLICATE_CUSTOM_TAB_MOTIF" => DuplicateCustomTabMotif,
      "DUPLICATE_DEVELOPER_NAME" => DuplicateDeveloperName,
      "DUPLICATES_DETECTED" => DuplicatesDetected,
      "DUPLICATE_EXTERNAL_ID" => DuplicateExternalId,
      "DUPLICATE_MASTER_LABEL" => DuplicateMasterLabel,
      "DUPLICATE_SENDER_DISPLAY_NAME" => DuplicateSenderDisplayName,
      "DUPLICATE_USERNAME" => DuplicateUsername,
      "DUPLICATE_VALUE" => DuplicateValue,
      "EMAIL_ADDRESS_BOUNCED" => EmailAddressBounced,
      "EMAIL_NOT_PROCESSED_DUE_TO_PRIOR_ERROR" => EmailNotProcessedDueToPriorError,
      "EMAIL_OPTED_OUT" => EmailOptedOut,
      "EMAIL_TEMPLATE_FORMULA_ERROR" => EmailTemplateFormulaError,
      "EMAIL_TEMPLATE_MERGEFIELD_ACCESS_ERROR" =>
   EmailTemplateMergefieldAccessError,
      "EMAIL_TEMPLATE_MERGEFIELD_ERROR" => EmailTemplateMergefieldError,
      "EMAIL_TEMPLATE_MERGEFIELD_VALUE_ERROR" => EmailTemplateMergefieldValueError,
      "EMAIL_TEMPLATE_PROCESSING_ERROR" => EmailTemplateProcessingError,
      "EMPTY_SCONTROL_FILE_NAME" => EmptyScontrolFileName,
      "ENTITY_FAILED_IFLASTMODIFIED_ON_UPDATE" =>
   EntityFailedIflastmodifiedOnUpdate,
      "ENTITY_IS_ARCHIVED" => EntityIsArchived,
      "ENTITY_IS_DELETED" => EntityIsDeleted,
      "ENTITY_IS_LOCKED" => EntityIsLocked,
      "ENVIRONMENT_HUB_MEMBERSHIP_CONFLICT" => EnvironmentHubMembershipConflict,
      "ERROR_IN_MAILER" => ErrorInMailer,
      "EXCEEDED_MAX_SEMIJOIN_SUBSELECTS" => ExceededMaxSemijoinSubselects,
      "FAILED_ACTIVATION" => FailedActivation,
      "FIELD_CUSTOM_VALIDATION_EXCEPTION" => FieldCustomValidationException,
      "FIELD_FILTER_VALIDATION_EXCEPTION" => FieldFilterValidationException,
      "FIELD_INTEGRITY_EXCEPTION" => FieldIntegrityException,
      "FILTERED_LOOKUP_LIMIT_EXCEEDED" => FilteredLookupLimitExceeded,
      "FORBIDDEN" => Forbidden,
      "HTML_FILE_UPLOAD_NOT_ALLOWED" => HtmlFileUploadNotAllowed,
      "ILLEGAL_QUERY_PARAMETER_VALUE" => IllegalQueryParameterValue,
      "IMAGE_TOO_LARGE" => ImageTooLarge,
      "INACTIVE_OWNER_OR_USER" => InactiveOwnerOrUser,
      "INSERT_UPDATE_DELETE_NOT_ALLOWED_DURING_MAINTENANCE" =>
   InsertUpdateDeleteNotAllowedDuringMaintenance,
      "INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY" =>
   InsufficientAccessOnCrossReferenceEntity,
      "INSUFFICIENT_ACCESS_OR_READONLY" => InsufficientAccessOrReadonly,
      "INVALID_ACCESS_LEVEL" => InvalidAccessLevel,
      "INVALID_ARGUMENT_TYPE" => InvalidArgumentType,
      "INVALID_ASSIGNEE_TYPE" => InvalidAssigneeType,
      "INVALID_ASSIGNMENT_RULE" => InvalidAssignmentRule,
      "INVALID_BATCH_OPERATION" => InvalidBatchOperation,
      "INVALID_CONTENT_TYPE" => InvalidContentType,
      "INVALID_CREDIT_CARD_INFO" => InvalidCreditCardInfo,
      "INVALID_CROSS_REFERENCE_KEY" => InvalidCrossReferenceKey,
      "INVALID_CROSS_REFERENCE_TYPE_FOR_FIELD" => InvalidCrossReferenceTypeForField,
      "INVALID_CURRENCY_CONV_RATE" => InvalidCurrencyConvRate,
      "INVALID_CURRENCY_CORP_RATE" => InvalidCurrencyCorpRate,
      "INVALID_CURRENCY_ISO" => InvalidCurrencyIso,
      "INVALID_EMAIL_ADDRESS" => InvalidEmailAddress,
      "INVALID_EMPTY_KEY_OWNER" => InvalidEmptyKeyOwner,
      "INVALID_EVENT_SUBSCRIPTION" => InvalidEventSubscription,
      "INVALID_FIELD" => InvalidField,
      "INVALID_FIELD_FOR_INSERT_UPDATE" => InvalidFieldForInsertUpdate,
      "INVALID_FIELD_WHEN_USING_TEMPLATE" => InvalidFieldWhenUsingTemplate,
      "INVALID_FILTER_ACTION" => InvalidFilterAction,
      "INVALID_ID_FIELD" => InvalidIdField,
      "INVALID_INET_ADDRESS" => InvalidInetAddress,
      "INVALID_LINEITEM_CLONE_STATE" => InvalidLineitemCloneState,
      "INVALID_MASTER_OR_TRANSLATED_SOLUTION" => InvalidMasterOrTranslatedSolution,
      "INVALID_MESSAGE_ID_REFERENCE" => InvalidMessageIdReference,
      "INVALID_OPERATION" => InvalidOperation,
      "INVALID_OPERATION_WITH_EXPIRED_PASSWORD" => InvalidOperationWithExpiredPassword,
      "INVALID_OPERATOR" => InvalidOperator,
      "INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST" =>
   InvalidOrNullForRestrictedPicklist,
      "INVALID_QUERY_FILTER_OPERATOR" => InvalidQueryFilterOperator,
      "INVALID_QUERY_LOCATOR" => InvalidQueryLocator,
      "INVALID_PARTNER_NETWORK_STATUS" => InvalidPartnerNetworkStatus,
      "INVALID_PERSON_ACCOUNT_OPERATION" => InvalidPersonAccountOperation,
      "INVALID_READ_ONLY_USER_DML" => InvalidReadOnlyUserDml,
      "INVALID_REPLICATION_DATE" => InvalidReplicationDate,
      "INVALID_SAVE_AS_ACTIVITY_FLAG" => InvalidSaveAsActivityFlag,
      "INVALID_SESSION_ID" => InvalidSessionId,
      "INVALID_SIGNUP_COUNTRY" => InvalidSignupCountry,
      "INVALID_STATUS" => InvalidStatus,
      "INVALID_TYPE" => InvalidType,
      "INVALID_TYPE_FOR_OPERATION" => InvalidTypeForOperation,
      "INVALID_TYPE_ON_FIELD_IN_RECORD" => InvalidTypeOnFieldInRecord,
      "IP_RANGE_LIMIT_EXCEEDED" => IpRangeLimitExceeded,
      "JIGSAW_IMPORT_LIMIT_EXCEEDED" => JigsawImportLimitExceeded,
      "JSON_PARSER_ERROR" => JsonParserError,
      "LICENSE_LIMIT_EXCEEDED" => LicenseLimitExceeded,
      "LIGHT_PORTAL_USER_EXCEPTION" => LightPortalUserException,
      "LIMIT_EXCEEDED" => LimitExceeded,
      "LOGIN_CHALLENGE_ISSUED" => LoginChallengeIssued,
      "LOGIN_CHALLENGE_PENDING" => LoginChallengePending,
      "LOGIN_MUST_USE_SECURITY_TOKEN" => LoginMustUseSecurityToken,
      "MALFORMED_ID" => MalformedId,
      "MALFORMED_QUERY" => MalformedQuery,
      "MALFORMED_SEARCH" => MalformedSearch,
      "MANAGER_NOT_DEFINED" => ManagerNotDefined,
      "MASSMAIL_RETRY_LIMIT_EXCEEDED" => MassmailRetryLimitExceeded,
      "MASS_MAIL_LIMIT_EXCEEDED" => MassMailLimitExceeded,
      "MAXIMUM_CCEMAILS_EXCEEDED" => MaximumCcemailsExceeded,
      "MAXIMUM_DASHBOARD_COMPONENTS_EXCEEDED" => MaximumDashboardComponentsExceeded,
      "MAXIMUM_HIERARCHY_LEVELS_REACHED" => MaximumHierarchyLevelsReached,
      "MAXIMUM_SIZE_OF_ATTACHMENT" => MaximumSizeOfAttachment,
      "MAXIMUM_SIZE_OF_DOCUMENT" => MaximumSizeOfDocument,
      "MAX_ACTIONS_PER_RULE_EXCEEDED" => MaxActionsPerRuleExceeded,
      "MAX_ACTIVE_RULES_EXCEEDED" => MaxActiveRulesExceeded,
      "MAX_APPROVAL_STEPS_EXCEEDED" => MaxApprovalStepsExceeded,
      "MAX_FORMULAS_PER_RULE_EXCEEDED" => MaxFormulasPerRuleExceeded,
      "MAX_RULES_EXCEEDED" => MaxRulesExceeded,
      "MAX_RULE_ENTRIES_EXCEEDED" => MaxRuleEntriesExceeded,
      "MAX_TASK_DESCRIPTION_EXCEEDED" => MaxTaskDescriptionExceeded,
      "MAX_TM_RULES_EXCEEDED" => MaxTmRulesExceeded,
      "MAX_TM_RULE_ITEMS_EXCEEDED" => MaxTmRuleItemsExceeded,
      "MERGE_FAILED" => MergeFailed,
      "METHOD_NOT_ALLOWED" => MethodNotAllowed,
      "MISSING_ARGUMENT" => MissingArgument,
      "NONUNIQUE_SHIPPING_ADDRESS" => NonuniqueShippingAddress,
      "NO_APPLICABLE_PROCESS" => NoApplicableProcess,
      "NO_ATTACHMENT_PERMISSION" => NoAttachmentPermission,
      "NO_INACTIVE_DIVISION_MEMBERS" => NoInactiveDivisionMembers,
      "NO_MASS_MAIL_PERMISSION" => NoMassMailPermission,
      "NUMBER_OUTSIDE_VALID_RANGE" => NumberOutsideValidRange,
      "NUM_HISTORY_FIELDS_BY_SOBJECT_EXCEEDED" => NumHistoryFieldsBySobjectExceeded,
      "OP_WITH_INVALID_USER_TYPE_EXCEPTION" => OpWithInvalidUserTypeException,
      "OPERATION_TOO_LARGE" => OperationTooLarge,
      "OPTED_OUT_OF_MASS_MAIL" => OptedOutOfMassMail,
      "PACKAGE_LICENSE_REQUIRED" => PackageLicenseRequired,
      "PLATFORM_EVENT_ENCRYPTION_ERROR" => PlatformEventEncryptionError,
      "PLATFORM_EVENT_PUBLISHING_UNAVAILABLE" => PlatformEventPublishingUnavailable,
      "PLATFORM_EVENT_PUBLISH_FAILED" => PlatformEventPublishFailed,
      "PORTAL_USER_ALREADY_EXISTS_FOR_CONTACT" => PortalUserAlreadyExistsForContact,
      "PRIVATE_CONTACT_ON_ASSET" => PrivateContactOnAsset,
      "QUERY_TIMEOUT" => QueryTimeout,
      "RECORD_IN_USE_BY_WORKFLOW" => RecordInUseByWorkflow,
      "REQUEST_LIMIT_EXCEEDED" => RequestLimitExceeded,
      "REQUEST_RUNNING_TOO_LONG" => RequestRunningTooLong,
      "REQUIRED_FIELD_MISSING" => RequiredFieldMissing,
      "SELF_REFERENCE_FROM_TRIGGER" => SelfReferenceFromTrigger,
      "SERVER_UNAVAILABLE" => ServerUnavailable,
      "SHARE_NEEDED_FOR_CHILD_OWNER" => ShareNeededForChildOwner,
      "SINGLE_EMAIL_LIMIT_EXCEEDED" => SingleEmailLimitExceeded,
      "STANDARD_PRICE_NOT_DEFINED" => StandardPriceNotDefined,
      "STORAGE_LIMIT_EXCEEDED" => StorageLimitExceeded,
      "STRING_TOO_LONG" => StringTooLong,
      "TABSET_LIMIT_EXCEEDED" => TabsetLimitExceeded,
      "TEMPLATE_NOT_ACTIVE" => TemplateNotActive,
      "TERRITORY_REALIGN_IN_PROGRESS" => TerritoryRealignInProgress,
      "TEXT_DATA_OUTSIDE_SUPPORTED_CHARSET" => TextDataOutsideSupportedCharset,
      "TOO_MANY_APEX_REQUESTS" => TooManyApexRequests,
      "TOO_MANY_ENUM_VALUE" => TooManyEnumValue,
      "TRANSFER_REQUIRES_READ" => TransferRequiresRead,
      "UNABLE_TO_LOCK_ROW" => UnableToLockRow,
      "UNAVAILABLE_RECORDTYPE_EXCEPTION" => UnavailableRecordtypeException,
      "UNDELETE_FAILED" => UndeleteFailed,
      "UNKNOWN_EXCEPTION" => UnknownException,
      "UNSPECIFIED_EMAIL_ADDRESS" => UnspecifiedEmailAddress,
      "UNSUPPORTED_APEX_TRIGGER_OPERATION" => UnsupportedApexTriggerOperation,
      "UNVERIFIED_SENDER_ADDRESS" => UnverifiedSenderAddress,
      "WEBLINK_SIZE_LIMIT_EXCEEDED" => WeblinkSizeLimitExceeded,
      "WEBLINK_URL_INVALID" => WeblinkUrlInvalid,
      "WRONG_CONTROLLER_TYPE" => WrongControllerType
    }.freeze

    def self.get_exception_class(error_code)
      ERROR_EXCEPTION_CLASSES.fetch(error_code) do |_|
        warn "[restforce] An unrecognised error code, `#{error_code}` has been " \
             "received from Salesforce. Instead of raising an error-specific exception" \
             ", we'll raise a generic `ResponseError`. Please report this missing " \
             "error code on GitHub at <#{GITHUB_ISSUE_URL}>."

        # If we've received an unexpected error where we don't have a specific
        # class defined, we can return a generic ResponseError instead
        ResponseError
      end
    end

    def self.const_missing(constant_name)
      warn "[restforce] You're referring to a Restforce error that isn't defined, " \
           "`#{name}::#{constant_name}` (for example by trying to `rescue` it). This " \
           "might be our fault - we've recently made some changes to how errors are " \
           "defined. If you're sure that this is a valid Salesforce error, then " \
           "please create an issue on GitHub at <#{GITHUB_ISSUE_URL}>."

      super(constant_name)
    end
  end
end
