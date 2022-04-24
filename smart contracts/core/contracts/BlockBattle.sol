// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract BlockBattle is ERC721, Pausable, Ownable {

    uint256 public maxRow;
    uint256 public maxCol;
    uint256 mintFee;
    mapping(uint256 =>uint256[]) tokens;
    mapping(uint256=>bool) mintedTokens;
    uint8 managerFee100 ;
    uint8 upTimes;
    bool noNomalTransfar;
    constructor() ERC721("BlockBattleToken", "BBT") {
        maxRow=100;
        maxCol=100;
        mintFee=1e16;
        managerFee100=20;
        upTimes=2;//>1
        noNomalTransfar=true ;//only true
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    function checkColor(uint256 color) pure private returns(bool){
        return color<=16777215;
    }
    function mint( uint256 tokenId,uint256 color) public  whenNotPaused payable{
        require((tokenId<=maxRow*maxCol-1)&&!mintedTokens[tokenId],'the Token can not  mint');
        require(checkColor(color),'the color can not use');
        require(msg.value==mintFee,'mintFee error');
        _safeMint(msg.sender, tokenId);

        tokens[tokenId]=[uint(tokenId/maxCol),tokenId%maxCol,color,mintFee];
        mintedTokens[tokenId]=true;
        payable(owner()).transfer(mintFee);

    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override
    {

        super._beforeTokenTransfer(from, to, tokenId);
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public  override {
        require(!noNomalTransfar,'no nomal trans');
        super.safeTransferFrom(from, to, tokenId);

    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public  override {
        require(!noNomalTransfar,'no nomal trans');
        super.safeTransferFrom(from, to, tokenId, _data);
    }
    function loot(uint256 tokenId) public  payable {
        require(mintedTokens[tokenId],'the nft have not be minted');
        require(msg.value==tokens[tokenId][3]*upTimes,' need enough of fee');
        payable(ownerOf(tokenId)).transfer(tokens[tokenId][3]*(upTimes-1)*(1-managerFee100/100)+tokens[tokenId][3]);
        payable(owner()).transfer(tokens[tokenId][3]*(upTimes-1)*(managerFee100/100));
        _approve(msg.sender, tokenId);
        _transfer(ownerOf(tokenId),msg.sender,tokenId);
    }
    function tokenInfo(uint256 tokenId)
    public
    view
    returns (uint256[] memory)
    {
        require(mintedTokens[tokenId],'the nft have not be minted');
        return tokens[tokenId];
    }
}