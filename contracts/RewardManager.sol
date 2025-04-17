// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interfaces/IShibaGimbabNFT.sol";

contract RewardManager is Initializable, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    address public trustedSigner;
    address public saleToken;
    mapping(uint256 => bool) public claimedTokens;
    uint256 public baseDecimals;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _trustedSigner, address _saleToken) public initializer {
        __Pausable_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        trustedSigner = _trustedSigner;
        saleToken = _saleToken;
        baseDecimals = 1000000000000000000;
    }

    function claimRewards(uint256[] memory tokenIds, uint256[] memory amounts, bytes[] memory signatures) public whenNotPaused nonReentrant {
        require(tokenIds.length == signatures.length, "Mismatched arrays");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 amountRaw = amounts[i];
            bytes memory signature = signatures[i];

            if (claimedTokens[tokenId]) {
                continue;
            }

            // EIP-191 hash
            bytes32 messageHash = keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msg.sender, tokenId, amountRaw)))
            );
            address recoveredSigner = recoverSigner(messageHash, signature);
            require(recoveredSigner == trustedSigner, "Invalid signature");

            claimedTokens[tokenId] = true;
            uint256 amount = amountRaw * baseDecimals; 
            IERC20Upgradeable(saleToken).transfer(msg.sender, amount);
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
    
    function setSaleToken(address _saleToken) external onlyOwner {
        saleToken = _saleToken;
    }
  
    function withdrawRemainingTokens() external onlyOwner {
        uint256 remainingTokens = IERC20Upgradeable(saleToken).balanceOf(address(this));
        require(remainingTokens > 0, "No remaining tokens to withdraw");
        IERC20Upgradeable(saleToken).transfer(owner(), remainingTokens);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
