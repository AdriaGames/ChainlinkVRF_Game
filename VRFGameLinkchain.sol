// SPDX-License-Identifier: MIT
// Author: Crypto Mayhem Team
pragma solidity ^0.8.19;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/VRFCoordinatorV2_5.sol";

contract RandomNFT is ERC721Enumerable, VRFConsumerBaseV2Plus {
    event RequestSent(uint256 requestId, uint32 numWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    bytes32 internal keyHash;
    uint256 public subscriptionId;
    uint32 callbackGasLimit;
    uint16 requestConfirmations;
    uint32 numWords;

    uint256 public randomResult;
    LinkTokenInterface LINKTOKEN;

    mapping(uint256 => address) public requestIdToSender;
    mapping(uint256 => uint256) public requestIdToTokenId;

    uint256 public tokenCounter;

    uint256[] public requestIds;
    uint256 public lastRequestId;

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _keyHash,
        uint256 _subscriptionId,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords
    )
        VRFConsumerBaseV2Plus(_linkToken)
        ERC721("RandomNFT", "RNFT")
    {
        LINKTOKEN = LinkTokenInterface(_linkToken);
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
        numWords = _numWords;
        tokenCounter = 0;
    }

    function createRandomNFT() public returns (uint256) {
        console.log("createRandomNFT Start");
        uint256 requestId = requestRandomWords(false);
        console.log("createRandomNFT middle");
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenId[requestId] = tokenCounter;
        tokenCounter++;
        console.log("createRandomNFT end");
        return requestId;
    }

        function requestRandomWords(
        bool enableNativePayment
    ) public onlyOwner returns (uint256 requestId) {
        console.log("requestRandomWords Start");
        // Will revert if subscription is not set and funded.
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: enableNativePayment
                    })
                )
            })
        );
        console.log("requestRandomWords middle");
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        console.log("requestRandomWords requestIds");
        requestIds.push(requestId);
        console.log("requestRandomWords lastRequestId");
        lastRequestId = requestId;
        console.log("requestRandomWords RequestSent");
        emit RequestSent(requestId, numWords);
        console.log("requestRandomWords requestId");
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        address nftOwner = requestIdToSender[requestId];
        uint256 newTokenId = requestIdToTokenId[requestId];
        _safeMint(nftOwner, newTokenId);
        randomResult = randomWords[0];
    }

    function withdrawLink() external onlyOwner {
        uint256 balance = LINKTOKEN.balanceOf(address(this));
        require(balance > 0, "No LINK to withdraw");
        LINKTOKEN.transfer(owner(), balance);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}