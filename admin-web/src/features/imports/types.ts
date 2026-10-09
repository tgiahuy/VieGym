export type ImportStep = 1 | 2 | 3 | 4

export type ImportEntityType = 'EXERCISE' | 'FOOD'

export type ValidationStatus =
  | 'VALID'
  | 'WARNING'
  | 'ERROR_ENUM'
  | 'ERROR_DUPLICATE'
  | 'ERROR_REQUIRED'

export type ConflictStrategy = 'UPSERT' | 'SKIP' | 'ROLLBACK'

export interface ImportRowItem {
  id: string
  rowNumber: number
  status: ValidationStatus
  statusLabel: string
  sku: string
  nameVi: string
  nameEn: string
  primaryCategory: string
  categoryBadgeColor?: string
  secondaryInfo: string
  validationTitle: string
  validationDetail: string
  suggestedFix?: string
  isDuplicate?: boolean
  hasEnumError?: boolean
  hasWarning?: boolean
}

export interface ImportFileMeta {
  fileName: string
  fileSize: string
  totalRows: number
  validRows: number
  warningRows: number
  errorRows: number
  uploadedAt: string
  entityType: ImportEntityType
}

export interface ImportHistoryItem {
  id: string
  batchId: string
  fileName: string
  entityType: ImportEntityType
  totalRows: number
  successCount: number
  skippedCount: number
  errorCount: number
  conflictStrategy: ConflictStrategy
  importedBy: string
  importedAt: string
  status: 'COMPLETED' | 'PARTIAL' | 'FAILED'
  durationMs: number
}

export interface SchemaFieldRule {
  fieldKey: string
  fieldNameVi: string
  dataType: string
  required: boolean
  description: string
  allowedEnums?: string[]
  exampleValue: string
}
