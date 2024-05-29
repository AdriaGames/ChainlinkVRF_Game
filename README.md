# RandomNFT Game Smart Contract

## Introduction

The `RandomNFT` smart contract enables users to create and mint Non-Fungible Tokens (NFTs) with attributes that are determined through Chainlink VRF V2+ (Verifiable Random Function). This method ensures that the attributes assigned to these NFTs are genuinely random and cannot be manipulated.

## Features

- **Random NFT Creation:** Users can generate NFTs with random attributes by interacting with the smart contract.
- **Chainlink VRF Integration:** Utilizes Chainlink VRF to produce verifiable random numbers, providing true randomness for NFT attributes.
- **ERC721 Standard Compliance:** The contract adheres to the ERC721 standard for NFTs and includes the Enumerable extension to track NFTs effectively.

## Dependencies

This contract relies on several dependencies:
- [OpenZeppelin ERC721Enumerable](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721Enumerable)
- [Chainlink VRF (V2+)](https://docs.chain.link/vrf/v2/introduction)

## Prerequisites

Before deploying the contract, ensure you have the following:
- [Hardhat](https://hardhat.org/getting-started/)
- [Node.js](https://nodejs.org/en/)
- [npm](https://www.npmjs.com)

## Installation

1. **Clone the repository:**
   ```sh
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Install dependencies:**
   ```sh
   npm install
   ```

3. **Configure Hardhat:**
   Ensure your `hardhat.config.js` is set up with the necessary configurations for your network and environment.

## Deployment

1. **Set up environment variables:**
   Create a `.env` file in the root directory with the following variables:
   ```sh
   NETWORK_URL=<your-network-url>
   PRIVATE_KEY=<your-private-key>
   CHAINLINK_VRF_COORDINATOR=<vrf-coordinator-address>
   LINK_TOKEN_ADDRESS=<link-token-address>
   KEY_HASH=<key-hash>
   SUBSCRIPTION_ID=<subscription-id>
   ```

2. **Deploy the contract:**
   ```sh
   npx hardhat run scripts/deploy.js --network <network>
   ```

## Contract Structure

### State Variables

- `keyHash`: Chainlink VRF key hash for randomness.
- `subscriptionId`: Chainlink subscription ID for funding requests.
- `callbackGasLimit`: Gas limit for the callback.
- `requestConfirmations`: Confirmations required for the request.
- `numWords`: Number of random words required.
- `randomResult`: Stores the latest random result.
- `LINKTOKEN`: Interface for the LINK token.
- `requestIdToSender`: Mapping from request ID to sender address.
- `requestIdToTokenId`: Mapping from request ID to token ID.
- `tokenCounter`: Counter to keep track of minted tokens.
- `requestIds`: Array to store request IDs.
- `lastRequestId`: Stores the last request ID.

### Functions

- **Constructor:**
  Initializes the contract with the required parameters including VRF Coordinator, LINK token address, key hash, subscription ID, callback gas limit, request confirmations, and number of words.

- **createRandomNFT():**
  Initiates the process of creating a random NFT, generating a request for random words, and mapping the request to the sender and token ID.

- **requestRandomWords(bool enableNativePayment):**
  Requests random words from Chainlink VRF. Only callable by the contract owner and can utilize native payment if enabled.

- **fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords):**
  Callback function that mints a new NFT once the random words are fulfilled. Overrides Chainlink's `fulfillRandomWords`.

- **withdrawLink():**
  Allows the contract owner to withdraw LINK tokens from the contract.

- **tokenURI(uint256 tokenId):**
  Provides the URI of the given token. Overrides the `ERC721` function.

- **getRequestStatus(uint256 _requestId):**
  Returns the status of a given request including whether it has been fulfilled and the random words associated with it.

## Example Usage

1. **Creating a Random NFT:**
   ```sh
   await randomNFT.createRandomNFT({ from: userAddress });
   ```

2. **Withdrawing LINK:**
   ```sh
   await randomNFT.withdrawLink({ from: ownerAddress });
   ```

3. **Getting Request Status:**
   ```sh
   const status = await randomNFT.getRequestStatus(requestId);
   ```

## License

This project is licensed under the MIT License.

## Acknowledgments

- **Crypto Mayhem Team:** Authors of the smart contract.
- **Chainlink:** Provider of the VRF service enabling verifiable randomness.
- **OpenZeppelin:** Framework for secure smart contract development.
