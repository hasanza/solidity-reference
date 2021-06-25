// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IERC721.sol';
import './IERC721Receiver.sol';
import './IERC721Metadata.sol';
import './IERC165.sol';
import './Address.sol';
import './Context.sol';
import './Strings.sol';

contract myNFT is Context, IERC721, ERC165, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;
    string private _symbol;

    // NfttokenId to owner address
    mapping(uint256 => address) private _owners;
    // owner address to no. of NFTs owned
    mapping(address => uint256) private _balances;
    // NFTTokenID to approved address
    mapping(uint256 => address) private _tokenApprovals;
    // Owner address to operator address approval status (operator can handle NFTs on behalf of owner)
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    // Assign name and symbol to NFT collection, used for NFT metadata
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // Implementation of the ERC165 supports interface function
    function supportsInterface(bytes4 interfaceId) public view (ERC165, IERC165) returns (bool) {
        return
            // type()returns the type of the interface, interfaceId property returns the intrerface id of the interface by XORing all its func selectors
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            // Calling supportsInterface() of any parent contract
            super.supportsInterface(interfaceId);
    }

    // Returns the no. of NFTs owned by an address
    function balanceOf(address owner) public view  returns (address) {
        require(owner != address(0), "Owner cannot be the zero address");
        return _balances[owner];
    }

    // Returns the owner of a given token ID
    function ownerOf(uint256 tokenId) public view  returns (address) {
        // Returns the addr of the addr owning the tokenId
        address owner = _owners[tokenId];
        require(owner != address(0), "Owner cannot be the zero address");
        return owner;
    }

    /// @notice IERC721Metadata implementation
    // name of NFT collection
    function name() public view  returns (string memory) {
        return _symbol;
    }

    // collection symbol
    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public  view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for non-existent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    // Makes easier to calculate token URI, append tokenId to base URI
    function _baseURI() internal view virtual returns (string memory) {
        // The base URI
        return "";
    }

    // Approve an address to handle a given NFT
    function approve(address to, uint256 tokenId) public {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: Cannot approve owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approver is not owner for approved for all"
        );
        _approve(to, tokenId);
    }

    // Returns the approved address for a given NFT
    function getApprived(uint256 tokenId) public view returns (address) {
        require(_exists(_tokenId), "ERC721: token does not exist");

        return _tokenApprovals[tokenId];
    }

    // Owner calls this to give an operator control of all owned NFTs 
    function setApprovalForAll(address operator, bool approved) public {
        // see that the owner is not approving itself mistakenly
        require(operator != _msg.sender(), "ERC721: Caller cannot approve it self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    // Tells if a given owner has approved a given operator to handle all the funds
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOwner(_msgSender(), tokenId), "ERC721: Caller is not owner nor approved");
        
        _transfer(from, to, tokenId);
    }
    // Transfer only if other address can receive NFTs in case its a contract i.e., it implements the ERCReceiver interface
    // Prevents sending NFTs to incompatible addresses thus locking them up forever
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        _safeTransfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOwner(_msgSender(), tokenId), "ERC721: Caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(fron, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: Transfer to incompatible address");
    }

    // Checks if an NFT exists, NFTs are burned by sending them to address(0)
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners{tokenId} != address(0);
    }{
        try IERC721Receiver(to)._onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            // this func returns its own func selector upon receivng a token
        }
    }
    }

}