;; VoteSplit - Quadratic voting with fund allocation
(define-constant ERR-VOTING-ENDED (err u100))

(define-map proposals
    { proposal-id: uint }
    { description: (string-ascii 256), total-funds: uint, voting-deadline: uint, executed: bool }
)

(define-map option-votes { proposal-id: uint, option: uint } { votes: uint })
(define-map user-votes { proposal-id: uint, user: principal, option: uint } { credits: uint })
(define-data-var proposal-counter uint u0)

(define-public (create-proposal (description (string-ascii 256)) (duration uint))
    (let (
        (proposal-id (var-get proposal-counter))
    )
        (map-set proposals { proposal-id: proposal-id } {
            description: description,
            total-funds: u0,
            voting-deadline: (+ block-height duration),
            executed: false
        })
        (var-set proposal-counter (+ proposal-id u1))
        (ok proposal-id)
    )
)

(define-public (vote (proposal-id uint) (option uint) (voice-credits uint))
    (let (
        (proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) ERR-VOTING-ENDED))
        (current-votes (default-to u0 (get votes (map-get? option-votes { proposal-id: proposal-id, option: option }))))
    )
        (asserts! (<= block-height (get voting-deadline proposal)) ERR-VOTING-ENDED)
        (map-set option-votes { proposal-id: proposal-id, option: option } { votes: (+ current-votes voice-credits) })
        (map-set user-votes { proposal-id: proposal-id, user: tx-sender, option: option } { credits: voice-credits })
        (ok true)
    )
)

(define-read-only (get-option-votes (proposal-id uint) (option uint))
    (default-to u0 (get votes (map-get? option-votes { proposal-id: proposal-id, option: option })))
)
