// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.4.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.4.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.4.2/utils/Counters.sol";

contract DumbPeople is ERC721, ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private supply; // counter

    string public uriPrefix = "";       // } baseUri
    string public uriSuffix = ".json";  // }
    string public hiddenMetadataUri;

    uint256 public cost = 0.01 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmountPerTx = 5;

    bool public paused = true;
    bool public revealed = false;

    constructor() ERC721("DumbPeople", "DPP") {
        setHiddenMetadataUri("ipfs://__CID__/hidden.json"); // not required for now
    }

    modifier mintCompliance(uint256 _mintAmnt){
        require(_mintAmnt > 0 && _mintAmnt <= maxMintAmountPerTx, "Invalid mint amount!");
        require(supply.current() + _mintAmnt <= maxSupply, "Max supply exceeded");
    }
    // NFTs minted
    function totalSupply () public view returns (uint256) {
        return supply.current();
    }

    function mint(uint256 _mintAmnt) public payable mintCompliance(_mintAmount) {
        require(!paused, "The contract is paused!");
        require(msg.value >= cost * _mintAmnt, "Insufficient funds!");
        // unsure what this does
        _mintLoop(msg.sender, _mintAmnt);
    }
    // for owners (giveaways)
    function mintForAddress(uint256 _mintAmnt,address _receiver) public mintCompliance(_mintAmnt) onlyOwner {
        _mintLoop(_receiver, _mintAmnt);
    } 

    function walletOfOwner(address _owner) 
        public 
        view 
        returns (uint256[] memory) {
            uint256 ownerTokenCount = balanceOf(_owner);
            // list of owned tokens ID
            uint256[] memory ownedTokensId = new uint256[](ownerTokenCount);
            uint256 curTokenId = 0; // or 1;
            // index to insert current token ID at
            uint256 ownedTokenIndex = 0;

            while(ownedTokenIndex < ownerTokenCount && curTokenId <= maxSupply) {
                address curTokenOwner = ownerOf(curTokenId);

                if (curTokenOwner == _owner){
                    ownedTokensId[ownedTokenIndex] = curTokenId;
                    ownedTokenIndex++;
                }

                curTokenId++;
            }

            return ownedTokensId;
    }

    function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory) {
        require (
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false){
            return hiddenMetadataUri;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
            : ""; 
    }
    // to hide/unhide the metadata
    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }
    // to update amount in WEI
    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setHiddenMetadataUri(string memory _hiddenMetadataURI) public onlyOwner {
        hiddenMetadataUri = _hiddenMetadataURI;
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
        for (uint256 i=0; i<_mintAmount; i++){
            supply.increment();
            _safeMint(_receiver, supply.current());
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }
}
