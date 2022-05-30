// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.7 .0 < 0.9 .0;

/// @title NFT recevier 
/// @author Gustas K (ballisticfreaks@gmail.com)
/// @notice contract receives NFTs, stores them and let's let's users get them back

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/// @notice creates an interface for SafeTransfer function used to transfer NFTs.
interface Interface {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract ERC721Receiver is IERC721Receiver {

    address public parentNFT;

    /// @notice every NFT received will get an owner address attached, so only the owner can withdraw
    mapping(uint => address) OwnerOfID;
    /// @notice checks if the NFT is still in contract. This saves gas on failed withdraw transactions
    mapping(uint => bool) IsInContract;

    /// @notice before launching contract, put parents NFT contract address
    constructor(address _parentNFTAddress) {
        parentNFT = _parentNFTAddress;
    }

    /// @notice transfers token to the address and stores the owners address
    function transferTo(uint _tokenId) public {
        Interface(parentNFT).safeTransferFrom(msg.sender, address(this), _tokenId);
        OwnerOfID[_tokenId] = msg.sender;
        IsInContract[_tokenId] = true;
    }

    /// @notice transfers token to the owner
    /// @dev IsInContract updates after the NFT is sent. You should always update conditions first, but this does not have any inpact on code execution
    function transferBack(uint _tokenId) public {
        require(IsInContract[_tokenId], "NFT is not in the contract");
        require(OwnerOfID[_tokenId] == msg.sender, "You are not the owner of this NFT");
        Interface(parentNFT).safeTransferFrom(address(this), msg.sender, _tokenId);
        IsInContract[_tokenId] = false;
    }

    /// @notice OpenZeppelin requires ERC721Received implementation. It will not let contract receive tokens without this implementation.
    /// @dev this will give warnings on the compiler, because of unused parameters, but ERC721 standards require this function to accept all these parameters. Ignore these warnings.
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public override returns(bytes4) {
        return this.onERC721Received.selector;
    }
}