pragma solidity  ^0.4.2;

import "./MediaLib.sol";
import "./strings.sol";

contract MediaStore {

    using MediaLib for *;
    using strings for *;
    
    
    ///////////////////// USER ONBOARD MODULE //////////////////////////////////////
    
    MediaLib.User newUser;
    
    mapping (address => MediaLib.User) UserList;
    event userRegisteredEvent(address _userAddr);
    
    //// USER MODIFIERS ////
    
    /// user should exist in the UserList
    modifier ifuserExistsMod(){
        require(UserList[msg.sender].exists);
        _;
    }
    
    
    //// USER EVENTS ////
    
    
    
    //// APIS ////
    
    /// register a new user if he does not exisit
    function registerUser(string _name) public{
        
        // dont register if he is already registered.
        require(!UserList[msg.sender].exists);
        
        // create a user object
        newUser = MediaLib.User({
            exists : true,
            name : _name,
            myUploadedCntLst : new string [](0),
            myBoughtCntLst : new string [](0)
        });
        
        // add the newUser to the list
        UserList[msg.sender] = newUser;
        
        // emit an event that user has successfully registered
        emit userRegisteredEvent(msg.sender);
    }
    
    
    function getUser(address _user) public 
    view 
    returns(bool){
        return UserList[_user].exists;
    }
    
    
    ///////////////////// CONTENT MODULE //////////////////////////////////////
    
    MediaLib.Media mediaObj;
    MediaLib.Buy buyObj;
    
    /// list of media or content
    /// key is contenthash and value is Content struct
    mapping (string => MediaLib.Media) private MediaList;
    
    /// will store array of contentHashes which are available 
    /// key is content type (0,1,2,3) and value is array of contestHash
    mapping (uint8 => string []) private TypeContents;
    
    /// information about buyers , time they bought, price they bought for
    /// key is contenthash and value is Buy struct
    mapping (string => MediaLib.Buy[]) private BuyingList;
    
    
    /// CONTENT MODIFIERS ///
    
    // check if content exists in the mediaList
    modifier ifcontentExistsMod(string contentHash){
        require(MediaList[contentHash].exists);
        _;
    }
    
    modifier ifvalueExistsMod(){
        require(msg.value > 0);
        _;
    }
    
    
    /// CONTENT EVENTS ///
    
    
    /// addContent content 
    /// mediaHash is not the actual hash of media but the excrypted text of ipfs hash
    /// mediaHash is treated as unique id of media
    /// tagString is nothing but the category of media or type of media
    function addContent(string mediaHash,uint8 _contentType, uint256 _price) public 
    ifuserExistsMod{
        
        // media type other than ONFDOC(0), IMAGE(1), MUSIC(2), VID(3) is not allowed
        require(_contentType <= 3);
        
        // media should not be already added
        require(!MediaList[mediaHash].exists);

        // Creating media object
        mediaObj = MediaLib.Media({
            creator : msg.sender,
            claps : 0,
            id: mediaHash,
            cntType : MediaLib.ContentTypes(_contentType),
            exists : true,
            forSale : false,
            isSold : false,
            resaleCnt : 0,
            price : _price,
            currentOwner : msg.sender
        });
        
        // storing new media into mapping
        MediaList[mediaHash] = mediaObj;
        
        
        // updating content according to its type 
        TypeContents[_contentType].push(mediaHash);
        
        // update the user in the userList
        UserList[msg.sender].myUploadedCntLst.push(mediaHash);
        
    }
    
    // Put content for forSale
    function putContentForSale(string _contentHash, uint256 _price) public {
        //content should exist in the list
        require(MediaList[_contentHash].exists);

        // only current owner should be able to put the content on sale
        require(msg.sender == MediaList[_contentHash].currentOwner);

        MediaList[_contentHash].forSale = true;
        MediaList[_contentHash].price = _price;
        MediaList[_contentHash].isSold = false;
    }
    
    
    // fetch all contents which w.r.t type
    function getContentsOnSale(uint8 _contentType) public
    view
    returns(string commaSepContentIds, uint256 count){
        string[] storage contentsOnSale;
        for(uint256 i = 0; i < TypeContents[_contentType].length; i++){
            string memory hash = TypeContents[_contentType][i];
            if(MediaList[hash].exists && MediaList[hash].forSale && !MediaList[hash].isSold){
                contentsOnSale.push(hash);
            }
        }
        if(contentsOnSale.length > 1){
            commaSepContentIds = convertArrayToString(contentsOnSale);    
        }else{
            commaSepContentIds = contentsOnSale[0];
        }
        count = contentsOnSale.length;
    }
    
    
    /// fetch content details
    function getContentDetByHash(string _contentHash) public 
    view
    ifcontentExistsMod(_contentHash)
    returns(address creator, uint8 cntType, bool isSold, uint8 resaleCnt, uint256 price,bool forSale, address currentOwner){
        mediaObj = MediaList[_contentHash];
        creator = mediaObj.creator;
        cntType = uint8(mediaObj.cntType);
        isSold = mediaObj.isSold;
        resaleCnt = mediaObj.resaleCnt;
        price = mediaObj.price;
        forSale = mediaObj.forSale;
        currentOwner = mediaObj.currentOwner;
    }
    
    
    /// buy contentsOnSale
    /// keeping track of all buyers
    function buyContent(string _contentHash) public
    payable
    ifuserExistsMod
    ifvalueExistsMod
    ifcontentExistsMod(_contentHash){
        mediaObj = MediaList[_contentHash];
        
        // content should be forSale  
        require(mediaObj.forSale && !mediaObj.isSold);
        
        // owner can not buy his own content
        require(msg.sender != mediaObj.creator);
        
        buyObj = MediaLib.Buy({
            buyer : msg.sender,
            buyingTime : block.timestamp,
            buyingPrice : msg.value
        });
        BuyingList[_contentHash].push(buyObj);
        
        // update the sold content
        MediaList[_contentHash].isSold = true;
        MediaList[_contentHash].forSale = false;
        MediaList[_contentHash].resaleCnt = MediaList[_contentHash].resaleCnt + 1; 
        MediaList[_contentHash].currentOwner = msg.sender;

        // update user object
        UserList[msg.sender].myBoughtCntLst.push(_contentHash);

        // transfer the cash to the creator
        MediaList[_contentHash].creator.transfer(msg.value);
    }
    
    
    /// fetch user's uploaded-content list 
    /// It will fetch Ids, of all of the content the user have uploaded
    function getUserUploadedContents() public 
    view  
    ifuserExistsMod
    returns(uint256 contentCount,string commaSepContentIds){
        // user should have content in the uplaoded list
        require(UserList[msg.sender].myUploadedCntLst.length > 0);
        contentCount = UserList[msg.sender].myUploadedCntLst.length;
        commaSepContentIds = convertArrayToString(UserList[msg.sender].myUploadedCntLst);
    }
    
    
    /// fetch user's bought-content list 
    /// It will fetch Ids, of all of the content the user have bought
    function getUserBoughtContents() public 
    view  
    ifuserExistsMod
    returns(uint256 contentCount,string commaSepContentIds){
        // user should have content in the uplaoded list
        require(UserList[msg.sender].myBoughtCntLst.length > 0);
        contentCount = UserList[msg.sender].myBoughtCntLst.length;
        commaSepContentIds = convertArrayToString(UserList[msg.sender].myBoughtCntLst);
    }

    function trackOwnerShipsByHash(string _contentHash)public 
    view
    ifcontentExistsMod(_contentHash)
    returns(string commaSepAddress, uint256 addressCnt){
        string[] storage buyerAddressesList;
        // string [] storage buyingTimeList;
        // string [] storage buyingPriceList;

        for (uint256 i = 0; i < BuyingList[_contentHash].length ; i++){
            buyerAddressesList.push(convertAddressToString(BuyingList[_contentHash][i].buyer));
        }
        commaSepAddress = convertArrayToString(buyerAddressesList);
        addressCnt = buyerAddressesList.length;
    }

    
    ///////////////////// COMMON MODULE //////////////////////////////////////

    /// helper method to convert all values of an array in pipe separated
    function convertArrayToString(string [] arr) internal 
    pure 
    returns(string arrConvertedToStr){
        var parts = new strings.slice[](arr.length);
        for (uint32 i = 0; i < arr.length; i++) {
            parts[i] = arr[i].toSlice();
        }
        arrConvertedToStr = "|".toSlice().join(parts);   
    }
    
    
    function convertAddressToString(address x) returns (string) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(byte b) returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
}
