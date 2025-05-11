# PDP-Payments (FWS) System Diagrams

This page contains various diagrams that illustrate the architecture and workflows of the PDP-Payments (FWS) system.

## System Architecture

```mermaid
graph TD
    subgraph "PDP System"
        PV[PDPVerifier Contract]
        PS[SimplePDPService Contract]
        PL[PDPListener Interface]
    end
    
    subgraph "Payments System"
        PC[Payments Contract]
        AI[Arbiter Interface]
        AM[Account Management]
    end
    
    subgraph "Integration Layer"
        IL[Integration Components]
    end
    
    subgraph "Clients"
        C[Client Applications]
    end
    
    subgraph "Storage Providers"
        SP[Storage Provider Systems]
    end
    
    PV <--> PS
    PS <--> PL
    PC <--> AI
    PC <--> AM
    
    PV <--> IL
    PC <--> IL
    
    IL <--> C
    IL <--> SP
    
    C <--> SP
```

The diagram above shows the overall architecture of the PDP-Payments (FWS) system, including the relationships between the PDP components, Payment components, and their integration.

## PDP Workflow

```mermaid
sequenceDiagram
    participant C as Client
    participant PV as PDPVerifier
    participant PS as PDPService
    participant SP as Storage Provider
    
    C->>PV: Create Proof Set
    PV->>PS: Register with Service
    PS->>PV: Set SLA Parameters
    
    SP->>PV: Add Data Roots
    
    loop For each proving period
        PS->>PV: Generate Challenges
        PV->>SP: Request Proofs
        SP->>PV: Submit Proofs
        PV->>PS: Verify Proofs
        
        alt Proofs Valid
            PS->>SP: Record Compliance
        else Proofs Invalid/Missing
            PS->>SP: Record Fault
        end
    end
```

This diagram illustrates the workflow of the Provable Data Possession (PDP) system, from proof set creation to verification.

## Payment Rails

```mermaid
graph LR
    subgraph "Payment Rail"
        P[Payer/Client] -->|Deposits Funds| PC[Payments Contract]
        PC -->|Continuous Payments| PY[Payee/Provider]
        
        A[Arbiter] -->|Adjusts Payments| PC
        O[Operator] -->|Manages Rail| PC
        
        PC -->|Lockup Period| L[Lockup]
        PC -->|Payment Rate| PR[Rate]
    end
    
    subgraph "Settlement"
        PC -->|Settle| S[Settlement Process]
        S -->|Adjusted Amount| PY
    end
```

This diagram shows how payment rails connect payers and payees, with arbitration for SLA enforcement.

## Integration Workflow

```mermaid
sequenceDiagram
    participant C as Client
    participant PV as PDPVerifier
    participant PS as PDPService
    participant PC as Payments Contract
    participant A as Arbiter
    participant SP as Storage Provider
    
    C->>PC: Create Payment Rail
    C->>PC: Deposit Funds
    C->>PV: Create Proof Set
    C->>PV: Link to Payment Rail
    
    SP->>PV: Add Data Roots
    
    loop For each settlement period
        PS->>PV: Generate Challenges
        SP->>PV: Submit Proofs
        PV->>PS: Verify Proofs
        PS->>A: Report Compliance/Faults
        
        PC->>A: Request Arbitration
        A->>PC: Adjust Payment Amount
        
        PC->>SP: Settle Payments
    end
```

This diagram demonstrates how the PDP and Payments systems integrate to provide verifiable storage with automatic payment adjustments.

## Hot Vault Example

```mermaid
graph TD
    subgraph "Client"
        C[Client Application]
        D[Data]
    end
    
    subgraph "Hot Vault"
        HV[Hot Vault Service]
        S[Storage]
    end
    
    subgraph "PDP-Payments"
        PV[PDPVerifier]
        PS[PDPService]
        PC[Payments Contract]
        A[Arbiter]
    end
    
    C -->|Store Data| HV
    D -->|Data Roots| PV
    
    HV -->|Store| S
    HV -->|Submit Proofs| PV
    
    C -->|Create Rail| PC
    C -->|Create Proof Set| PV
    
    PV -->|Verify Proofs| PS
    PS -->|Report Compliance| A
    A -->|Adjust Payments| PC
    PC -->|Continuous Payments| HV
```

This diagram shows the Hot Vault example implementation, which demonstrates how PDP-Payments (FWS) can be used for hot storage with continuous payments.

## Component Relationships

```mermaid
classDiagram
    class PDPVerifier {
        +createProofSet()
        +addDataRoot()
        +submitProof()
        +verifyProof()
    }
    
    class SimplePDPService {
        +setParameters()
        +recordFault()
        +getFaultCount()
    }
    
    class PDPListener {
        <<interface>>
        +onProofSubmitted()
        +onFaultRecorded()
    }
    
    class PaymentsContract {
        +createRail()
        +depositFunds()
        +modifyRail()
        +settlePayments()
    }
    
    class Arbiter {
        <<interface>>
        +arbitratePayment()
    }
    
    class PDPArbiter {
        +arbitratePayment()
    }
    
    PDPVerifier --> SimplePDPService
    SimplePDPService --> PDPListener
    
    PaymentsContract --> Arbiter
    PDPArbiter --|> Arbiter
    PDPArbiter --> SimplePDPService
```

This diagram shows the relationships between the various components of the PDP-Payments (FWS) system, including contracts, interfaces, and services.

## Note on Diagrams

These diagrams are provided for illustrative purposes. The actual implementation may vary slightly. For the most accurate and up-to-date information, please refer to the corresponding documentation pages and the source code.

The diagrams are created using [Mermaid](https://mermaid-js.github.io/mermaid/), a JavaScript-based diagramming and charting tool that renders Markdown-inspired text definitions to create diagrams dynamically.
