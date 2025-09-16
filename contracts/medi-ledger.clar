;; ------------------------------------------------
;; Contract: medi-ledger
;; Trustless On-Chain Medical Record & Prescription Verification
;; ------------------------------------------------

(define-constant ERR_NOT_ADMIN (err u100))
(define-constant ERR_NOT_APPROVED (err u101))
(define-constant ERR_NOT_FOUND (err u102))
(define-constant ERR_REVOKED (err u103))

;; Contract owner (manages approved healthcare providers)
(define-data-var contract-owner principal tx-sender)

;; Approved healthcare providers (doctors, clinics, hospitals)
(define-map providers
  { provider: principal }
  { approved: bool })

;; Patient records (encrypted or reference strings)
(define-map records
  { id: uint }
  { patient: principal,
    provider: principal,
    data: (string-ascii 200),
    revoked: bool })

(define-data-var record-counter uint u0)

;; ------------------------------
;; Admin Functions
;; ------------------------------

;; Approve healthcare provider
(define-public (approve-provider (provider principal))
  (if (is-eq tx-sender (var-get contract-owner))
    (begin
      (map-set providers { provider: provider } { approved: true })
      (ok true))
    ERR_NOT_ADMIN))

;; Revoke healthcare provider
(define-public (revoke-provider (provider principal))
  (if (is-eq tx-sender (var-get contract-owner))
    (begin
      (map-set providers { provider: provider } { approved: false })
      (ok true))
    ERR_NOT_ADMIN))

;; ------------------------------
;; Record Functions
;; ------------------------------

;; Issue a new medical record/prescription (only approved providers)
(define-public (issue-record (patient principal) (data (string-ascii 200)))
  (let ((prov (map-get? providers { provider: tx-sender })))
    (if (is-some prov)
      (if (get approved (unwrap! prov ERR_NOT_APPROVED))
        (begin
          (var-set record-counter (+ (var-get record-counter) u1))
          (map-set records { id: (var-get record-counter) }
            { patient: patient,
              provider: tx-sender,
              data: data,
              revoked: false })
          (ok (var-get record-counter)))
        ERR_NOT_APPROVED)
      ERR_NOT_APPROVED)))

;; Revoke an existing record/prescription
(define-public (revoke-record (record-id uint))
  (let ((rec (map-get? records { id: record-id })))
    (match rec
      r (if (is-eq tx-sender (get provider r))
          (begin
            (map-set records { id: record-id }
              { patient: (get patient r),
                provider: (get provider r),
                data: (get data r),
                revoked: true })
            (ok true))
          ERR_NOT_APPROVED)
      ERR_NOT_FOUND)))

;; ------------------------------
;; Read-Only Functions
;; ------------------------------

;; Get record details
(define-read-only (get-record (record-id uint))
  (map-get? records { id: record-id }))

;; Verify record authenticity
(define-read-only (verify-record (record-id uint))
  (let ((rec (map-get? records { id: record-id })))
    (match rec
      r (if (not (get revoked r))
          (ok { patient: (get patient r),
                provider: (get provider r),
                data: (get data r) })
          ERR_REVOKED)
      ERR_NOT_FOUND)))

;; Check if provider is approved
(define-read-only (is-approved (provider principal))
  (map-get? providers { provider: provider }))
