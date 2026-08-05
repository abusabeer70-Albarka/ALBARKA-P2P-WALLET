# ALBARKA P2P WALLET architecture

## Core rule
Private keys and recovery phrases must remain on the user's device. The backend must never receive them.

## Planned layers
- UI
- Wallet core
- Secure storage
- Chain adapters
- RPC layer
- Transaction builder/signing
- Backend services for non-secret metadata

## Production gate
Before mainnet:
- threat model
- dependency review
- cryptographic implementation review
- secure-storage review
- transaction/signing tests
- testnet testing
- independent security audit
