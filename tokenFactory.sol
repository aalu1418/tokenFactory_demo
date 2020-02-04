pragma solidity ^0.5.16;

import "./ERC721.sol";

contract Artist is ERC721Token {
    // Collection of artworks by this Artist
    mapping(uint => ArtWork) artworks;
    address artist;

    constructor() public {
        artist = msg.sender;
        _tokenOwner[0] = artist;
        _tokenCount[artist] += 1;
    }

    modifier onlyArtist {
        require(msg.sender == artist, "only artist");
        _;
    }

    function createArtwork(uint hashIPFS, string memory Name) onlyArtist public returns (ArtWork) {
        ArtWork artContract = new ArtWork(hashIPFS, Name);
        artworks[hashIPFS] = artContract;
        return artContract;
    }

    function checkArtwork(uint hashIPFS) onlyArtist public view returns(bool) {
        if(artworks[hashIPFS] == ArtWork(0x0)) {
            return false;
        }
        return true;
    }

    function sellArtwork(uint hashIPFS, address newOwner) onlyArtist public {
        ArtWork artContract = ArtWork(artworks[hashIPFS]); //get contract instance
        address owner = artContract.ownerOf(hashIPFS); //get owner of art from contract
        require(owner == address(this), "not owner of artwork"); //verify that owner is the artist contract

        artContract.safeTransferFrom(address(this), newOwner, hashIPFS); //transfer art token to new owner
        artContract.setOwner(newOwner); //set new owner
    }
}

contract ArtWork is ERC721Token {
    // Detail of artwork
    address artist;
    string name;
    uint hashIPFS;
    address owner;

    constructor(uint ipfsHash, string memory artName) public {
        artist = msg.sender;
        name = artName;
        hashIPFS = ipfsHash;
        owner = artist;

        _tokenOwner[hashIPFS] = owner;
        _tokenCount[owner] += 1;
    }


    function setOwner(address newOwner) public {
        if(owner == msg.sender) {
            owner = newOwner;
        }
    }

}
