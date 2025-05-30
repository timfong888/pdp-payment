## Doc Reviews
### What is this document?
This document consists of comments I have had regarding the documentation site.
### How should the AI Agent treat this?
You are an experienced developer and technical writer.  After reading each comment, think.  Then update this `doc_reviews.md` document with
checklist directly beneath each question using markdown `[ ]` with a specific task you will take to address the commment.

If there are aspects of the comment I have provided that are unclear to you and that need to be answered, put them in a `questions.md` document.

Each question have a `[ ]` so that you can show it is considered answered by you after you read my response directly beneath each question.

### May 30, 2025 7:30 AM

1. The README Table of Contents should start with `Getting Started` ahead of the Key Components section.
2. The README should have a section describing the `Synapse SDK` with a link to a dedicated section.  The section should also include a link to the SDK repo.
3. Under the Documentation header, the order listed should move Quick Start above the PDP Overview
4. Under the Documentation header, there should be a link to the SDK-specific documentation. This comes *after* the PDP Overview link.
5. In the `pdp-overview.md` document, include a Sequence Diagram so we understand the Client, the Storage Provider, and the different contracts and data/payment flows through settlement.
6. In the `payments-overview.md` document, under example, write a clear, human readable description of the rail being created.  This includes the cost in USD and real clock time (e.g. cost per month), and how to translate this concept into the attributes.
7. In the `payments-overview.md` document, explain what is settlement and how it occurs.
8. In the `payments/concepts/overview.md` document, I am overall confused as to whether it is duplicate of `payments-overview`.  I would prefer to remove it but make sure relevant content is moved from this page to the `payments-overview`.  Also, this document contains alot of `<<<<<HEAD` that should be removed.

9. 
