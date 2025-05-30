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

Add a link to the branch where you made the changes.

### May 30, 2025, 10:00 AM PDT
1. I do not see a link to the SDK repository and to the dedicated documentation .md files in the `pdp-payment` repository.  Here is text I would expect to see the link on at minimum:   ` Use the Synapse SDK for rapid development with integrated PDP + Payments`:
   - [ ] Examine the current text "Use the Synapse SDK for rapid development with integrated PDP + Payments" in README.md
   - [ ] Add a direct link to the SDK repository (https://github.com/FilOzone/synapse-sdk) in this text
   - [ ] Add links to dedicated SDK documentation files within the pdp-payment repository
   - [ ] Verify all SDK-related links are working and properly formatted

2. Under the Table of Contents Header https://github.com/timfong888/pdp-payment?tab=readme-ov-file#table-of-contents there is no link to the section on the `Synapse SDK` section.
   - [ ] Add "Synapse SDK" entry to the Table of Contents in README.md
   - [ ] Ensure the link points to the correct #synapse-sdk anchor
   - [ ] Verify the Table of Contents ordering is logical and consistent

3. Under the Table of Contents, remove references to Contribution and License across all the pages.
   - [ ] Remove "Contributing" entry from README.md Table of Contents
   - [ ] Remove "License" entry from README.md Table of Contents
   - [ ] Check other documentation pages for similar Table of Contents and remove Contributing/License references
   - [ ] Verify no broken internal links result from these removals

4. In the `pdp` folder, there are a bunch of files labelled `sdk-*`, thee should be moved into their own dedicated folder `sdk`.
   - [ ] Identify all files in docs/ with `sdk-*` naming pattern
   - [ ] Create new `docs/sdk/` folder
   - [ ] Move all sdk-* files to the new sdk folder
   - [ ] Update all internal links that reference the moved files
   - [ ] Update README.md links to point to new sdk folder locations
   - [ ] Verify no broken links remain after the move

5. in the `pdp/concepts` folder, it's confusing to have an `overview.md` file and another in `/docs` called 'pdp-overview'.  Perhaps these can be merged.  If you do so, MAKE SURE there are no orphaned links as a result of this change.
   - [ ] Examine content of `docs/pdp/concepts/overview.md`
   - [ ] Examine content of `docs/pdp-overview.md`
   - [ ] Compare the two files to identify unique content in each
   - [ ] Merge unique content from pdp/concepts/overview.md into pdp-overview.md
   - [ ] Search entire repository for links to `pdp/concepts/overview.md`
   - [ ] Update all found links to point to `pdp-overview.md`
   - [ ] Remove the redundant `docs/pdp/concepts/overview.md` file
   - [ ] Verify all links work correctly after the merge

6. Under `payments/concepts` there are three files with `payment-rails` in the title.  Can you clarify their role and perhaps break it down into a single document that is both comprehensive and concise.  MAKE SURE there are no orphaned links resulting from this refactoring.
   - [ ] Examine content of `docs/payments/concepts/payment-rails.md`
   - [ ] Examine content of `docs/payments/concepts/payment-rails-new.md`
   - [ ] Examine content of `docs/payments/concepts/payment-rails-updated.md`
   - [ ] Analyze the differences and determine the most current/comprehensive version
   - [ ] Create a single consolidated payment-rails.md document with comprehensive content
   - [ ] Search repository for all links to the three separate payment-rails files
   - [ ] Update all links to point to the consolidated document
   - [ ] Remove the redundant payment-rails files
   - [ ] Document the consolidation decision and rationale

7. The folder `payments/api` is confusing a little bit to me when the file name is `payments-contract.md`.  Could we change the name of the folder to `contracts`?  Or is there a reason API is used?
   - [ ] Examine the content of `docs/payments/api/payments-contract.md`
   - [ ] Determine if the content is about contracts or API endpoints
   - [ ] Rename `docs/payments/api/` folder to `docs/payments/contracts/` if content is contract-focused
   - [ ] Update all internal links that reference the old folder path
   - [ ] Update README.md and other documentation references
   - [ ] Verify the new folder name better reflects the content purpose

8. https://github.com/timfong888/pdp-payment/blob/main/docs/MVP.md#client-configuration lists terms which I don't understand.  Are they explained in repositories listed in `repo_list.md`?  Specifically: Payment proxy address (who is the recipient, who sets it up?), PDP Service address (is that the contract address that is listed for the PDP Service Contract?  I am guessing that NONE OF THESE ARE USER DEFINED.  But it would be helpful to a) have a human-readable definition; b) reference links to how these addresses are used (could be in another doc called `contracts details`.
   - [ ] Create a new document `docs/contracts-details.md` with human-readable definitions
   - [ ] Define "Payment proxy address" - explain who the recipient is and who sets it up
   - [ ] Define "PDP Service address" - clarify if this is the contract address for PDP Service Contract
   - [ ] Clarify which addresses are user-defined vs system-defined
   - [ ] Add cross-references to relevant repositories in repo_list.md for deeper technical details
   - [ ] Update MVP.md to link to the new contracts-details.md document
   - [ ] Ensure definitions are accessible to both developers and AI agents

9. You already have good definitions under `Configuration Requirements` which I believe are for the server.
   - [ ] Review the Configuration Requirements section in MVP.md
   - [ ] Clarify that these are server-side configuration requirements
   - [ ] Add a clear distinction between server and client configuration sections
   - [ ] Ensure the section headers clearly indicate server vs client scope

10. https://github.com/timfong888/pdp-payment/blob/main/docs/MVP.md#server-configuration-hot-vault-demo references PDPTool but no link out as to what it is.  I think the docs for PDP Tool should be referenced; or an internal doc explaining what it is, and it's repo (which is in the curio organization).
    - [ ] Research PDPTool in the curio organization repositories
    - [ ] Create internal documentation explaining what PDPTool is and its purpose
    - [ ] Add link to PDPTool repository in the curio organization
    - [ ] Update MVP.md to include proper PDPTool documentation links
    - [ ] Ensure developers understand PDPTool's role in the system


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
