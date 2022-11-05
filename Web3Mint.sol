//Web3Mint.sol
//SPDX-License-Identifier: UNLICENSED
//soldiityのversion設定
pragma solidity ^0.8.9;
//OpenZeppelinが提供するヘルパー機能をインポート
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./libraries/Base64.sol";//librariesのBase64.solをインポート
import "hardhat/console.sol";//hardhatのconsole.solをインポート

//Web3Mintのcontract(ERC721を継承)
contract Web3Mint is ERC721{

  //NftAttributesの構造体を用意
  struct NftAttributes{
    string name;//名前
    string imageURL;//画像URL
    string menuDescription;//料理の説明
  }
  //NftAttributesの構造体が入る配列を用意
  NftAttributes[] Web3Nfts;

  //NFTに付属するレシピの材料及び工程を格納する変数
  string menuJson;
  string menuOutput;

  //openzeppelinの数を数える規格をインポート
  using Counters for Counters.Counter;
  //tokenId：NFTの一意な識別子(0, 1, 2, .. )
  Counters.Counter private _tokenIds;

  //①
  //constructor()関数(デプロイ時に一度だけ呼ばれる)
  constructor() ERC721("recipeNFT","rNFT"){
    console.log("Recipe NFT contract.");
  }

  //②
  //NFTをmintする関数(引数(名前、imageURI、メニューの説明)→フロント側から渡される。)
  function mintIpfsNFT(string memory name,string memory imageURI, string memory menuIngredient,string memory recipeProcess) public{
    //現在のtokenIdを変数に格納
    uint256 newItemId = _tokenIds.current();

    //NFTに付属するレシピの材料及び工程をJSON形式で1つのURLにする
    //jsonにNFTの情報を格納
    menuJson = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                  //
                  '{"Ingredient": "',menuIngredient,'","recipeProcess": "',recipeProcess,'"}'
                )
            )
        )
    );
    //URLとして出力できる形でoutputに格納
    menuOutput = string(
        abi.encodePacked("data:application/json;base64,", menuJson)
    );

    //NFTをmintする("関数呼び出し者-現在のtokenId"の紐付け)
    _safeMint(msg.sender,newItemId);
    //Web3Nfts配列にNftAttributes構造体を入れる
    Web3Nfts.push(NftAttributes({
      name: name,//NFTの名前
      imageURL: imageURI,//NFTの画像
      menuDescription: menuOutput//レシピの材料及び工程
    }));

    //ログ表示
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    //tokenIdをインクリメント
    _tokenIds.increment();
  }
  
  //③
  //NFTのデータを管理する関数(引数(tokenId=NFTの識別子))
  //tokenURI関数の引数にNFTの識別子を渡すとNFTのメタデータをjson形式返す
  function tokenURI(uint256 _tokenId) public override view returns(string memory){

    //jsonにNFTの情報を格納
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                  //NFTの名前、NFTの説明、NFTの画像URL
                  '{"name": "',Web3Nfts[_tokenId].name,' #: ', Strings.toString(_tokenId),
                  '", "description": "',Web3Nfts[_tokenId].menuDescription,'", "image": "ipfs://',
                  Web3Nfts[_tokenId].imageURL,'"}'
                )
            )
        )
    );
    //URLとして出力できる形でoutputに格納
    string memory output = string(
        abi.encodePacked("data:application/json;base64,", json)
    );
    //outputを返す
    return output;
  }
}
