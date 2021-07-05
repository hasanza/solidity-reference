// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IERC721.sol';
import './IERC721Receiver.sol';
import './IERC721Metadata.sol';
import './IERC165.sol';
import './Address.sol';
import './Context.sol';
import './Strings.sol';

/**
 * @notice: override keyword entails that a function can be overridden by the inheriting contract.
 * this means that you can change this function's behaviour when implementing it in the inheriting contract.
 * since we are implementing the functions contained in interfaces like IERC721, we are thus overriding them by
 * defining their behaviour. Any contract which inherits the below contract and wants to change a function's behaviour
 * in the child contract will also use the keyword override in the function signature.
 * if two parent contracts or interfaces have the same function and we are inheriting from them both,
 * we must, in addition to using the override keyword, specify the contracts/ interfaces we are inheriting from
 
 * @notice: virual keyword means that a function can be overriding by an inheriting contract. So, if we want a function
 * to be overridable by a child contract, we must use the keyword virtual. In the ERC721Contract contract, since we are inheriting 
 * several interfaces and giving our own implementations to their functions, we use the word override. In addition, we also want
 * contracts inheriting ERC721Contract to be able to change the bahaviour of our function implementations, and thus have used the keyword
 * virtual as well; this is to signify that this function is virtual and its behaviour can be overriden by the child contract
 */

contract ERC721Contract is Context, IERC721, ERC165, IERC721Metadata {

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
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            // type()returns the type of the interface, interfaceId property returns the intrerface id of the interface by XORing all its func selectors
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            // Calling supportsInterface() of any parent contract
            super.supportsInterface(interfaceId);
    }

    // Returns the no. of NFTs owned by an address
    function balanceOf(address owner) public view virtual override returns (address) {
        require(owner != address(0), "Owner cannot be the zero address");
        return _balances[owner];
    }

    // Returns the owner of a given token ID
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        // Returns the addr of the addr owning the tokenId
        address owner = _owners[tokenId];
        require(owner != address(0), "Owner cannot be the zero address");
        return owner;
    }

    /// @notice IERC721Metadata implementation
    // name of NFT collection
    function name() public view virtual override returns (string memory) {
        return _symbol;
    }

    // collection symbol
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
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
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Contract.ownerOf(tokenId);
        require(to != owner, "ERC721: Cannot approve owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approver is not owner for approved for all"
        );
        _approve(to, tokenId);
    }

    // Returns the approved address for a given NFT
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(_tokenId), "ERC721: token does not exist");

        return _tokenApprovals[tokenId];
    }

    // Owner calls this to give an operator control of all owned NFTs 
    function setApprovalForAll(address operator, bool approved) public virtual override {
        // see that the owner is not approving itself mistakenly
        require(operator != _msg.sender(), "ERC721: Caller cannot approve it self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    // Tells if a given owner has approved a given operator to handle all the funds
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOwner(_msgSender(), tokenId), "ERC721: Caller is not owner nor approved");
        
        _transfer(from, to, tokenId);
    }
    // Transfer only if other address can receive NFTs in case its a contract i.e., it implements the ERCReceiver interface
    // Prevents sending NFTs to incompatible addresses thus locking them up forever
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        _safeTransfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOwner(_msgSender(), tokenId), "ERC721: Caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: Transfer to incompatible address");
    }

    // Checks if an NFT exists, NFTs are burned by sending them to address(0)
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    // Tells if a given address is the owner or approved address of a given NFT
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        // require that the token has not been burned
        require(_exists(tokenId), "ERC721: The token does not exist or has been burned");
        // owner address is the address owning the token with the given Id
        address owner = ERC721Contract.ownerOf(tokenId);
        // return true if the received spender address is the owner, 
        // if the given token has been approved for the spender
        // and if the spender has been approved for all tokens owned by the owner
        // otherwise return false,  
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // calls _safeMint but with empty data parameter
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    // Mints a new NFT with given tokenId, a recipeint address and optional data param which is forwarded to recipients that are contracts
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(
            // If the recipient is a contract, it must implement the IERC721Receiver interface
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to a non ERC721 implementer contract"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        // Make sure we are not sending the newly minted NFT to burn address
        require (to != address(0), "ERC721: the recipient cannot be 0-address");
        // Make sure the tokenId does not exist (we are creating a new token)
        require (!_exists(tokenId), "ERC721: The tokenId exists; token already minted");
        // Calling our hook to implement any additional bahaviour before token transfer
        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    
    // Burns a token by senting it to the 0-address
    function _burn(uint256 tokenId) internal virtual {
        // Retireving the owner of tis token 
        address owner = ERC721Contract.ownerOf(tokenId);
        
        _beforeTokenTransfer(owner, address(0), tokenId);
        // Approving the 0-address for this token
        // This clears existing approvals
        _approve(address(0), tokenId);
        // Reducing the NFT balance of the owner
        _balances[owner] -= 1;
        // Deleting the address as owner for this NFT from the _owners mapping
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        // Require that the froma addr owns this NFT
        require(ERC721Contract.ownerOf(tokenId) == from, "ERC721: trying to transfer token that is not owned");
        // Prevent transfer to the burn address
        require(to != address(0), "ERC721: cannot transfer to the 0-address"); 

        _beforeTokenTransfer(fron, to, tokenId);

        // Clear approvals for this token
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        // Giving a given address control over the NFT
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Contract.ownerOf(tokenId), to, tokenId);
    }

    // Called when the receving address is a contract
    // Invokes onERC721Received function of a contract that implements the ERC721Receiver interface
    // And thus the onERC721Received function, which returns own function slector 
    // Since the ERC721Receiver interface has only 1 func, its func selector is the interfaceId
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        // If the recipient addr is a contract...
        if (to.isContract()) {
            try IERC721Receiver(to).onErc721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ("ERC721: attempted transfer to non-compatible contract");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                } 
            }
        } else {
            return true;
        }
    }

    // This is a hook that is called before every token transfer
    // We implement additional behaviour that we want when token transfers occur
    // E.g., we could restrict transfers to only registered candidates etc.
    // Hooks aand Modifiers both modify the behaviour of a function, but with hooks we implement changes
    // in one place and without overriding.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual{

    }


}