// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "./NFT721.sol";


contract ArtGallery is Ownable {

    erc721 public nft721instance; 
    mapping (uint256=>uint256) tokenPrice;
    /*
    1- Crear el contrato del artGalerry que permita crear una instancia de un ERC721
    2- El 721 en su constructor mintea los tokens creados de nuevo al artGallery
    3-Probar la funcionalidad que se deploye el contrato y que los nft vuelvan al artGallery
    4- Crear la metadata
    5- Agregar la metadata a los nft
    */
    constructor ()  {
        //@dev Art gallery creats an ERC721instance to mint NFTS for the gallery
        nft721instance = new erc721("Ewol Art Gallery", "EART");
        
    }
    //@dev publish NFTS for a particular address
	function publishArtwork(string memory _tokenUri, uint256 _tokenPrice, address to, uint96 _royalty) public onlyOwner {
		uint256 _newTokenId = nft721instance.mint(_tokenUri,_royalty, to);
		tokenPrice[_newTokenId] = _tokenPrice;
	}
    //@dev publish NFTS for the gallery
	function publishArtworkForGallery(string memory _tokenUri, uint256 _tokenPrice, uint96 _royalty) public onlyOwner {
		uint256 _newTokenId = nft721instance.mint(_tokenUri,_royalty);
		tokenPrice[_newTokenId] = _tokenPrice;
	}

    //@dev allowance to sell an NFT
	function sellArtwork(uint256 _tokenId, uint256 _tokenPrice) onlyOwner public {
		
        //@dev while price is 0 it's not for sale
		tokenPrice[_tokenId] = _tokenPrice;
	}
	//@dev buy an NFT
	function buyArtwork(uint256 _tokenId) public payable {
		uint256 _tokenPrice = tokenPrice[_tokenId];
		require(_tokenPrice > 0, "Token not for sale");
		require(msg.value == _tokenPrice, "Ether received doesnt match token price");
		address seller = nft721instance.ownerOf(_tokenId);
		nft721instance.safeTransferFrom(seller, msg.sender, _tokenId);
		uint256 amountReceived = msg.value;
		(, uint256 royaltyAmount) = nft721instance.royaltyInfo(_tokenId, _tokenPrice);
		uint256 sellerAmount = amountReceived - royaltyAmount;
		if (seller!=address(this)){
		payable(seller).transfer(sellerAmount);}
		
		tokenPrice[_tokenId] = 0; // Mark token no longer for sale
	}
	
	
	function withdraw(address _to) public onlyOwner {
		uint256 balanceAmount = address(this).balance;
		payable(_to).transfer(balanceAmount);
	}	

    function getTokenPrice(uint _tokenId) public view returns (uint _price) {
        return tokenPrice[_tokenId];
    }
    function getAddressBalance(address _addr) public view returns (uint _balance){
        return _addr.balance;
    }

    // Storage structure for keeping artworks
    

    // Declaration of an event 
    
    // Creation of a random number (required for NFT token properties)
    

    // NFT Token Creation (Artwork)
   

    // NFT Token Price Update 
    
    // Visualize the balance of the Smart Contract (ethers)
   
    // Obtaining all created NFT tokens (artwork)
    
    // Obtaining a user's NFT tokens
    
    // NFT Token Payment
    
    // Extraction of ethers from the Smart Contract to the Owner
    //function withdraw() 
    

}




// contract galleryCollection is ERC721URIStorage, ERC721Royalty, ERC721Enumerable, Ownable {
// 	function mint(string _tokenUri, uint256 _royaltyNumerator, address to) public onlyOwner returns (uint256) {
// 		uint256 _newTokenId = totalSupply();
// 		_safeMint(to, _newTokenId);
// 		_setTokenURI(_newTokenId, _tokenURI);
// 		_setTokenRoyalty(_newTokenId, msg.sender, _royaltyNumerator);
// 		_setApprovalForAll(to, msg.sender, true);
// 		return _newTokenId;	
// 	}
// 	function mint(string _tokenUri, uint256 _royaltyNumerator) public onlyOwner returns (uint256) {
// 		uint256 _newTokenId = totalSupply();
// 		_mint(msg.sender, _newTokenId);
// 		_setTokenURI(_newTokenId, _tokenURI);
// 		_setTokenRoyalty(_newTokenId, msg.sender, _royaltyNumerator);
// 		return _newTokenId;
// 	}
// }


// contract galleryContract is Ownable {

// 	galleryCollection nft721instance;
	
// 	mapping (uint256 => uint256) public tokenPrices;

// 	constructor () {
// 		myCollection = new galleryCollection("Gallery The Rose", "ROSE");
// 	}

// 	function publishArtwork(string _tokenUri, uint256 _tokenPrice, address to) public onlyOwner {
// 		uint256 _newTokenId = myCollection.mint(_tokenUri, to);
// 		tokenPrices[_newTokenId] = _tokenPrice;
// 	}

// 	function publishArtwork(string _tokenUri, uint256 _tokenPrice) public onlyOwner {
// 		uint256 _newTokenId = myCollection.mint(_tokenUri);
// 		tokenPrices[_newTokenId] = _tokenPrice;
// 	}

// 	function sellArtwork(uint256 _tokenId, uint256 _tokenPrice) public {
// 		require(myCollection.ownerOf(_tokenId) == msg.sender, "You are trying to sell art you don't own");
// 		tokenPrices[_tokenId] = _tokenPrice;
// 	}
	
// 	function buyArtwork(uint256 _tokenId) public payable {
// 		uint256 _tokenPrice = tokenPrices[_tokenId];
// 		require(_tokenPrice > 0, "Token not for sale");
// 		require(msg.value == _tokenPrice, "Ether received doesn´t match token price");
// 		address seller = myCollection.ownerOf(_tokenId);
		
// 		# Operacion atomica
// 		#  ETH   buyer/msg.sender   ->   galleryContract  ->  seller
// 		#  NFT   buyer/msg.sender              <-             seller
// 		myCollection.safeTransferFrom(seller, msg.sender, _tokenId);
		
// 		# Royalty goes entirely to the gallery
// 		uint256 amountReceived = msg.value;
// 		(address royaltyReceiver, uint256 royaltyAmount) = myCollection.royaltyInfo(_tokenId, _tokenPrice);
// 		uint256 sellerAmount = amountReceived - royaltyAmount;
		
// 		payable(royaltyReceiver).transfer(royaltyAmount);
// 		payable(seller).transfer(sellerAmount);
		
// 		tokenPrices[_tokenId] = 0; # Mark token no longer for sale
// 	}
	
	
// 	function withdraw(address to) public onlyOwner {
// 		uint256 balanceAmount = address(this).balance;
// 		payable(to).transfer(balanceAmount);
// 	}	

// }