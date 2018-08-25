pragma solidity  ^0.4.2;

library MediaLib {
    enum ContentTypes { CONFDOC, IMAGE, MUSIC, VID }
    
    struct Media {
        address creator;
        address currentOwner;
        string id;
        uint32 claps;
        bool exists;
        bool forSale;
        bool isSold;
        uint8 resaleCnt;
        uint256 price;
        ContentTypes cntType;
    }
    
    struct Buy {
        address buyer;
        uint256 buyingTime;
        uint256 buyingPrice;
    }
        
    struct User {
        bool exists;
        string name ;
        string [] myUploadedCntLst;
        string [] myBoughtCntLst;
    }    
}
