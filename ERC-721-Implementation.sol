pragma solidity ^0.8.0;

contract myNFT {
    // ------------ Ownership
    // An array of unique IDs or hashes of all tokens in existence
    uint256[] internal circulatingTokens;
    // All NFTs owned by an address; addr => array of all NFTs owned
    mapping(address => uint256[]) internal ownedTokens;
    // Who owns a given NFT; tokenID => addr
    // Need this inspite of ownedTokens because array length doesn't change upon deletion of elemment.
    // Upon deletion, an element is just replaced with 0
    // so, upon deletion, we need to rearrange ownedTokens array.
    mapping(uint256 => address) internal tokenOwner;
    // Index of an NFT in ownedTokens array; needed when creating new ownedTokens array after deletion of one
    // tokenID => place/ index in ownedTokens array
    mapping(uint256 => uint256) internal ownedTokensIndex;
    // tokenID => place/ index in circulatingTokens array
    mapping(uint256 => uint256) internal allTokensIndex;
    // Count of NFTs owned by an address; address => count of NFTs owned
    mapping (address => uint256) internal ownedTokensCount;

    // ------------ Creation
}