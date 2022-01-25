// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DumbGuys is ERC721, ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  mapping(string => uint8) existingURIs;
  mapping(string => address) ownerOf;
  string[] owned;

  constructor() ERC721("DumbGuys", "DMBG") {}

  function _baseURI() internal pure override returns (string memory) {
    return "ipfs://";
  }

  event Transaction(address buyer, uint256 tokenId);

  function safeMint(address to, string memory uri) public onlyOwner {
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, uri);
  }

  // The following functions are overrides required by Solidity.

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
  {
    return super.tokenURI(tokenId);
  }

  modifier notOwned(string memory uri) {
    require(existingURIs[uri] != 1, "NFT already minted");
    _;
  }

  function isContentOwned(string memory uri) public view returns (bool) {
    return existingURIs[uri] == 1;
  }

  function payToMint(address buyer, string memory metadataURI)
    public
    payable
    returns (uint256)
  {
    require(existingURIs[metadataURI] != 1, "NFT already minted!");
    // my nfts are not free for all
    require(msg.value >= 0.05 ether, "Insufficient balance!");

    uint256 newItemId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    existingURIs[metadataURI] = 1;

    _mint(buyer, newItemId);
    _setTokenURI(newItemId, metadataURI);

    emit Transaction(buyer, newItemId);
    ownerOf[metadataURI] = buyer;
    return newItemId;
  }

  // function getOwned(address memory buyer) {

  // }

  function count() public view returns (uint256) {
    return _tokenIdCounter.current();
  }
}
