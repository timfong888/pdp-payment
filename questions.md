# Questions for Clarification

## Questions regarding Doc Review items from May 30, 2025, 10:00 AM PDT

### Question 1: PDPTool Repository Location
- [ ] **Question**: You mentioned PDPTool is in the "curio organization" but I don't see a curio organization listed in the repo_list.md. Could you provide the exact GitHub URL for the PDPTool repository?
- [ ] **Context**: Item #10 references PDPTool but I need the specific repository link to create proper documentation and links.

- [ ] **Answer**: This is the documentation site referencing setting up PDPTool: https://docs.curiostorage.org/experimental-features/enable-pdp#pdp-client
- [ ] **Answer**: This is the repo for Curio: git clone https://github.com/filecoin-project/curio.git


### Question 2: SDK Files Location Clarification  
- [ ] **Question**: You mentioned "In the `pdp` folder, there are a bunch of files labelled `sdk-*`" but I found the sdk-* files are actually in the root `docs/` folder, not in `docs/pdp/`. Should I move the files from `docs/` to `docs/sdk/` or did you mean something else?
- [ ] **Context**: Item #4 - I found these sdk files in docs/: sdk-monitoring.md, sdk-production.md, sdk-quickstart.md, sdk-workflow.md
- [ ] **Answer**: you are correct, they are in `docs/` and do need to be moved to `docs/sdk`.


### Question 3: Payment Rails Consolidation Strategy
- [ ] **Question**: For the three payment-rails files in `payments/concepts/`, should I prioritize the content from one specific file (like payment-rails-updated.md) or merge all unique content from all three files?
- [ ] **Context**: Item #6 - I need to understand your preference for handling potentially conflicting information between the files.
- [ ] **Answer**: It seems like `payment-rails` both in `payments/concepts` and `payments` seem identical.  If not, pretty close, so they should be merged into a single document and put into `payments` folder.
- [ ] **Answer**: `payment-rails-new` is a subset of `payment-rails-update`, and I think `payment-rails-update` contains details not found in `payment-rails` which is details on definitions.  I would merge this new content into the single `payment-rails` document. BUT have a clean table of contents to skip to the appropriate headers

### Question 4: API vs Contracts Folder Naming
- [ ] **Question**: Should I examine the content of `payments-contract.md` first to determine if it's truly about contracts vs API endpoints, or do you already know it should be renamed to `contracts`?
- [ ] **Context**: Item #7 - Want to confirm the approach before making the folder structure change.
- [ ] **Answer:** Sure, examine and see if it is contracts va API endpoints.

### Question 5: Contract Address Definitions Source
- [ ] **Question**: For creating the contracts-details.md document (item #8), should I research the contract addresses by examining the source code repositories listed in repo_list.md, or do you have specific definitions you'd like me to use?
- [ ] **Context**: Need to ensure accuracy when defining Payment proxy address and PDP Service address.
- [ ] **Answer:** Yes, go through all the relevant repositories with contract addresses and give a summary of the contract address, functions and an overall role in the flow (perhaps a sequence diagram if possible).


