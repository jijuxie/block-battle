// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract BlockBattle is ERC721, Pausable, Ownable {

    uint256 public maxRow;
    uint256 public maxCol;
    uint256 public mintFee;
    mapping(uint256=>uint256) public tokensColor;
    mapping(uint256=>uint256) public tokensFee;
    mapping(uint256=>address) public tokensOwner;
    uint256[] public tokenIds;
    uint8 public managerFee100 ;
    uint8  public upTimes;
    bool noNomalTransfar;
    address manager;
    constructor() ERC721("BlockBattleToken", "BBT") {
        maxRow=10;
        maxCol=10;
        mintFee=1e16;
        managerFee100=20;
        upTimes=2;//>1
        noNomalTransfar=true ;//only true
        manager=msg.sender;
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
        bool  inTokenIds=false;
        for( uint256 i=0;i<tokenIds.length;i++){
            if(tokenIds[i]==tokenId){
                inTokenIds=true;
            }
        }
        require((tokenId<=maxRow*maxCol-1)&&inTokenIds==false,'the Token can not  mint');
        require(checkColor(color),'the color can not use');
        require(msg.value==mintFee,'mintFee error');
        _safeMint(msg.sender, tokenId);
        tokensColor[tokenId]=color;
        tokensFee[tokenId]=mintFee;
        tokensOwner[tokenId]=msg.sender;
        tokenIds.push(tokenId);
        payable(manager).transfer(mintFee);

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
        bool  inTokenIds=false;
        for( uint256 i=0;i<tokenIds.length;i++){
            if(tokenIds[i]==tokenId){
                inTokenIds=true;
            }
        }
        require(inTokenIds,'the nft have not be minted');
        require(msg.value==tokensFee[tokenId]*upTimes,' need enough of fee');
        require(checkColor(color),'the color can not use');
        payable(ownerOf(tokenId)).transfer(tokensFee[tokenId]*(upTimes-1)*(1-managerFee100/100)+tokensFee[tokenId]);
        payable(manager).transfer(tokensFee[tokenId]*(upTimes-1)*(managerFee100/100));
        tokensFee[tokenId]=tokensFee[tokenId]*upTimes;
        tokensColor[tokenId]=color;
        tokensOwner[tokenId]=msg.sender;
        _approve(msg.sender, tokenId);
        _transfer(ownerOf(tokenId),msg.sender,tokenId);
    }
    function tokenInfo(uint256 tokenId)
    public
    view
    returns (uint256[] memory)
    {
        bool  inTokenIds=false;
        for( uint256 i=0;i<tokenIds.length;i++){
            if(tokenIds[i]==tokenId){
                inTokenIds=true;
            }
        }
        uint256[] memory res;
        if(inTokenIds){
            res[0]=tokenId;
            res[1]=tokensColor[tokenId];
            res[2]=tokensFee[tokenId];
            res[3]=1;
        }else{
            res[0]=tokenId;
            res[1]=tokensColor[tokenId];
            res[2]=tokensFee[tokenId];
            res[3]=0;
        }

        return res;
    }
    function getTokensFee() public view returns(uint256[] memory){
        //溢出风险但是不大
        uint256[]  memory  reTokenFee=new uint256[](tokenIds.length*2);
        for( uint256 i=0;i<tokenIds.length;i++){
            reTokenFee[2*i]=tokenIds[i];
            reTokenFee[2*i+1]=tokensFee[tokenIds[i]];

        }
        return reTokenFee;
    }
    function getTokensColor() public view returns(uint256[] memory){
        //溢出风险但是不大

        uint256[]  memory  reTokensColor=new uint256[](tokenIds.length*2);
        for( uint256 i=0;i<tokenIds.length;i++){
            reTokensColor[2*i]=tokenIds[i];
            reTokensColor[2*i+1]=tokensColor[tokenIds[i]];
        }
        return reTokensColor;
    }
    function mintedTokenIds() public view returns (uint256[] memory){
        return tokenIds;
    }
    function getMyTokens(address myAddress) public view returns(uint256[] memory){
        uint256  countMyTokens;
        for( uint256 i=0;i<tokenIds.length;i++){
            if(tokensOwner[tokenIds[i]]==myAddress){
                countMyTokens++;
            }

        }

        uint256[]  memory  _tokenIds=new uint256[](countMyTokens);
        uint256 index=0;
        for( uint256 i=0;i<tokenIds.length;i++){
            if(tokensOwner[tokenIds[i]]==myAddress){
                //+1好计算
                _tokenIds[index]=tokenIds[i]+1;
                index++;
            }

        }
        return _tokenIds;
    }
}