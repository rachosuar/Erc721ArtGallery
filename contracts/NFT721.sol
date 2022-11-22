// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract erc721 is ERC721Royalty, ERC721URIStorage,ERC721Enumerable,Ownable {
    constructor(string memory _name, string memory _symbol) ERC721 (_name,_symbol){
        transferOwnership(msg.sender);
    }
 mapping(uint256 => string) private _tokenURIs;
 
 string  _BaseUri;
function setBaseUri(string memory _str) public onlyOwner {
    _BaseUri = _str;
}
    
  function _baseURI() internal view virtual override returns (string memory) {
        return _BaseUri;
    }

 function mint(string memory _tokenUri, uint96 _royaltyNumerator, address to) public returns (uint256) {
		uint256 _newTokenId = totalSupply();
        string memory _stringTokenId=Strings.toString(_newTokenId);
        setBaseUri(_tokenUri);
		_safeMint(to, _newTokenId);
		_setTokenURI(_newTokenId, _stringTokenId);
		_setTokenRoyalty(_newTokenId, msg.sender, _royaltyNumerator);
		_setApprovalForAll(to, msg.sender, true);
		return _newTokenId;	
	}
function mint (string memory _tokenUri, uint96 _royaltyNumerator) public returns (uint256) {
		uint256 _newTokenId = totalSupply();
        string memory _stringTokenId=Strings.toString(_newTokenId);
        setBaseUri(_tokenUri);
		_mint(msg.sender, _newTokenId);
		_setTokenURI(_newTokenId, _stringTokenId);
		_setTokenRoyalty(_newTokenId, msg.sender, _royaltyNumerator);
		return _newTokenId;
}
function _burn(uint256 tokenId) internal virtual override (ERC721Royalty,ERC721URIStorage,ERC721) {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }
     function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Royalty,ERC721Enumerable,ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721Enumerable,ERC721) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);       
    }
    function tokenURI(uint256 tokenId) public view virtual override(ERC721URIStorage,ERC721) returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }
     function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual override (ERC721URIStorage) {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    }
   
    // Counters for the IDs of the NFTs
  
    //  Smart Contract Constructor

    //   NFTs Sending
    // function sendNFT(address _account) public {
    //     _//complete

    // }

//}