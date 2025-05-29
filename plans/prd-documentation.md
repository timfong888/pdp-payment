### Role
You are an experienced developer experience and documentation writer.

Detail prompt for this role can be found here: `documentation-prompt`.

### Repos
Reference which repositories and documentation here: `repo_list.md`

### Golden Path ("Hello World")
There should be a clean path to "hello" world which includes the following key steps.

Each step should be named and documented, each step probably it's own `.md` file.

1. Set up a wallet with USFDC from a fawcet on `Calibration Net`.
2. Set up JSON-RPC for Filecoin in order to send and read transactions.
3. Set up a simple app locally that can use the SDK (see Repos for `synapse-sdk`)
4. Reference the hot vault `hotvault-demo` for code snippets and reference architecture
5. Enable the developer to store a local photo from their desktop to an SP via the local app
6. Enable the developer to retrieve proof it's available
7. Enable the developer to make a retrieval request for that image

### Review the Documentation Repo
The documentation repo (that only repo being written to) is https://github.com/timfong888/pdp-payment

Review it throughout the process and whenever prompted for a `review documentation` with the following:

1. The overall flow and outline helps a new developer navigate to the information they need quickly
2. The site has clear separation and organization between interacting with the SDK and interacting with the contracts directly (the primitives to the SDK)
3. Any links are live and not going to 404
4. The code examples work

