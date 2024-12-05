// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interfaces/IShibaGimbabNFT.sol";

contract ClaimManager is Initializable, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    address public trustedSigner;
    IShibaGimbabNFT public nftContract;

    mapping(uint256 => bool) public claimedTokens;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _trustedSigner, address _nftContract) public initializer {
        __Pausable_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        trustedSigner = _trustedSigner;
        nftContract = IShibaGimbabNFT(_nftContract);
    }

    function claimNFTs(uint256[] memory tokenIds, bytes[] memory signatures) public whenNotPaused nonReentrant {
        require(tokenIds.length == signatures.length, "Mismatched arrays");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            bytes memory signature = signatures[i];

            require(!claimedTokens[tokenId], "Token already claimed");

            // EIP-191 hash
            bytes32 messageHash = keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msg.sender, tokenId)))
            );
            address recoveredSigner = recoverSigner(messageHash, signature);

            require(recoveredSigner == trustedSigner, "Invalid signature");

            claimedTokens[tokenId] = true;
            nftContract.mint(msg.sender, tokenId);
        }
    }

    function recoverSigner(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        (v, r, s) = splitSignature(signature);

        return ecrecover(hash, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function setTrustedSigner(address _trustedSigner) external onlyOwner {
        trustedSigner = _trustedSigner;
    }

    function setNFTContract(address _nftContract) external onlyOwner {
        nftContract = IShibaGimbabNFT(_nftContract);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
