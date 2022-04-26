// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract BlockBattle is ERC721, Pausable, Ownable {

    uint256 public maxRow;
    uint256 public maxCol;
    uint256 public mintFee;
    mapping(uint256 =>uint256[]) tokens;//[row,col,color,fee,minted]
mapping(uint256 =>address)
// uint256[] public tokensRow;
// uint256[] public tokensCol;
// uint256[] public tokensColor;
// uint256[] public tokensFee;
// uint8[] public mintedTokens;//0/1
uint8 public managerFee100 ;
uint8  public upTimes;
bool noNomalTransfar;
constructor() ERC721("BlockBattleToken", "BBT") {
maxRow=10;
maxCol=10;
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
require((tokenId<=maxRow*maxCol-1)&&mintedTokens[tokenId]!=1,'the Token can not  mint');
require(checkColor(color),'the color can not use');
require(msg.value==mintFee,'mintFee error');
_safeMint(msg.sender, tokenId);

tokensRow[tokenId]=uint(tokenId/maxCol);
tokensCol[tokenId]=tokenId%maxCol;
tokensColor[tokenId]=color;
tokensFee[tokenId]=mintFee;
mintedTokens[tokenId]=1;
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
function loot(uint256 tokenId,uint256 color) public whenNotPaused  payable {
require(mintedTokens[tokenId]==1,'the nft have not be minted');
require(msg.value==tokensFee[tokenId]*upTimes,' need enough of fee');
require(checkColor(color),'the color can not use');
payable(ownerOf(tokenId)).transfer(tokensFee[tokenId]*(upTimes-1)*(1-managerFee100/100)+tokensFee[tokenId]);
payable(owner()).transfer(tokensFee[tokenId]*(upTimes-1)*(managerFee100/100));
tokensFee[tokenId]=tokensFee[tokenId]*upTimes;
tokensColor[tokenId]=color;
_approve(msg.sender, tokenId);
_transfer(ownerOf(tokenId),msg.sender,tokenId);
}
function tokenInfo(uint256 tokenId)
public
view
returns (uint256[] memory)
{
require(mintedTokens[tokenId]==1,'the nft have not be minted');
uint256[] memory res;
res[0]=tokenId;
res[1]=tokensRow[tokenId];
res[2]=tokensCol[tokenId];
res[3]=tokensColor[tokenId];
res[4]=tokensFee[tokenId];
res[5]=uint256(mintedTokens[tokenId]);
return res;
}
function getTokensFee() public view returns(uint256[] memory){
return tokensFee;
}
function getTokensColor() public view returns(uint256[] memory){
return tokensColor;
}
}