## Doc Reviews
### What is this document?
This document consists of comments I have had regarding the documentation site.
### How should the AI Agent treat this?
You are an experienced developer and technical writer.  After reading each comment, think.  Then update this `doc_reviews.md` document with
checklist directly beneath each question using markdown `[ ]` with a specific task you will take to address the commment.

If there are aspects of the comment I have provided that are unclear to you and that need to be answered, put them in a `questions.md` document.

Each question have a `[ ]` so that you can show it is considered answered by you after you read my response directly beneath each question.

### Where should the AI Agent go for details on the code?
There is a repo list `repo_list.md` which should list the read-only repos that likely will need to be referenced with a link.  But also the code snippets and human-readable / AI agent parseable concepts should be extracted from those code bases to make it easy to for an AI agent to get accurate context with an efficient use of tokens.  Or to easily prime context.

### What should be done with the changes?
Create a branch and title it `Doc Review [date-time]` using the Date Time used in the header to which the questions were completed.  Create a separate branch for each Date Time header.

Create a pull request that will allow a human User to quickly review and then manually merge (or ask you to merge).

### May 30, 2025 7:30 AM

1. The README Table of Contents should start with `Getting Started` ahead of the Key Components section.
   - [x] Examine current README.md Table of Contents structure
   - [x] Move "Getting Started" section to appear before "Key Components" section
   - [x] Update any internal links if necessary

2. The README should have a section describing the `Synapse SDK` with a link to a dedicated section.  The section should also include a link to the SDK repo.
   - [x] Create a new "Synapse SDK" section in README.md
   - [x] Add description of the Synapse SDK
   - [x] Add link to dedicated SDK documentation section
   - [x] Add link to the SDK repository

3. Under the Documentation header, the order listed should move Quick Start above the PDP Overview
   - [x] Locate Documentation header in README.md
   - [x] Reorder links to put Quick Start before PDP Overview

4. Under the Documentation header, there should be a link to the SDK-specific documentation. This comes *after* the PDP Overview link.
   - [x] Add SDK-specific documentation link after PDP Overview link
   - [x] Ensure proper ordering: Quick Start → PDP Overview → SDK Documentation

5. In the `pdp-overview.md` document, include a Sequence Diagram so we understand the Client, the Storage Provider, and the different contracts and data/payment flows through settlement.
   - [x] Examine current pdp-overview.md content
   - [x] Create a sequence diagram showing Client, Storage Provider, contracts, and data/payment flows
   - [x] Add the sequence diagram to pdp-overview.md with proper explanation

6. In the `payments-overview.md` document, under example, write a clear, human readable description of the rail being created.  This includes the cost in USD and real clock time (e.g. cost per month), and how to translate this concept into the attributes.
   - [x] Locate the example section in payments-overview.md
   - [x] Add clear, human-readable description of the payment rail
   - [x] Include cost in USD and real clock time (monthly cost)
   - [x] Explain how to translate concepts into attributes

7. In the `payments-overview.md` document, explain what is settlement and how it occurs.
   - [x] Add settlement explanation section to payments-overview.md
   - [x] Describe what settlement is
   - [x] Explain how settlement occurs

8. In the `payments/concepts/overview.md` document, I am overall confused as to whether it is duplicate of `payments-overview`.  I would prefer to remove it but make sure relevant content is moved from this page to the `payments-overview`.  Also, this document contains alot of `<<<<<HEAD` that should be removed.
   - [x] Examine payments/concepts/overview.md content
   - [x] Compare with payments-overview.md to identify unique content
   - [x] Move any unique/valuable content from payments/concepts/overview.md to payments-overview.md
   - [x] Remove all `<<<<<HEAD` merge conflict markers
   - [x] Remove payments/concepts/overview.md file after content migration
