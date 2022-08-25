   // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.7 <0.9.0;

    contract Property_Buy_And_Selling{

    address private land_inspector;

    enum Status_buyer { Pending , Approved , Rejected}
    enum Status_land {  Pending, Approved, Rejected }
    enum Status_seller {  Pending, Approved, Rejected }

    //seller Registration
    struct seller_Details{
     string name;
     uint age;
     string city;
     uint cnic;
     string Email;
     Status_seller status_s;
    }

    // land registration
    struct Property_Detail{
     uint landid;
     string area;
     string city;
     string state;
     uint landprice;
     address current_Owner;
     Status_land status_l;
    }

    //LandInspector Details
    struct LandInspector_Details{   
     string name;
     int age;
     string designation;
    }

    // buyer details
    struct Buyer_Details{
     string name;
     int sge;
     string city;
     int cnic;
     string Email;
     Status_buyer status_B;
    }
    
    //MAPPING
    mapping (address => LandInspector_Details) public  landInspector_details;
    mapping (uint => Property_Detail) public Properties; //=>property Details
    mapping (address => seller_Details) public Seller_Details;// =>seller details
    mapping (address => Buyer_Details) public buyer_details;

    //modifier to ensure only land inspector can verify the account
    modifier only_landInspector(){
     require (msg.sender==land_inspector, "you are not the land Inspecotor");
       _;
    }
  
    /// modifier to ALLOW ONLY VERIFIED SELLER TO ACCESS THE FUNCTION
    modifier only_verifiedSeller(){
     require (Seller_Details[msg.sender].status_s==Status_seller.Approved,"you are not approved seller");
       _;
    }
    
    /// modifier to ALLOW ONLY VERIFIED BUYER TO ACCESS THE FUNCTION
    modifier only_verifiedbuyer(){
     require (buyer_details[msg.sender].status_B==Status_buyer.Approved,"you are not approved seller");
       _;
    }

    // seller registration
    function Seller_Details_(  
     string memory _name,
     uint _age,
     string memory _city,
     uint _cnic,
     string memory _Email
    ) 
    public returns(bool)  {
     Seller_Details[msg.sender]=seller_Details(_name,_age, _city,_cnic,_Email,Status_seller.Pending);
     return true;
    }


    //update  seller details
    function Update_Seller_Details_(  
     string memory _name,
     uint _age,
     string memory _city,
     uint _cnic,
     string memory _Email 
    )
    public returns(bool)  {
     Seller_Details[msg.sender]=seller_Details(_name,_age, _city,_cnic,_Email,Status_seller.Pending);
     return true;
    }


    // creating a new property
    function create_Land_Registory( 
     uint _Property_Id,
     uint _landid , 
     string memory _area ,
     string memory _city ,
     string memory _state , 
     uint _landprice  
    )
    public only_verifiedSeller { 
     Properties[_Property_Id]= Property_Detail(_landid, _area, _city,_state, _landprice,msg.sender, Status_land.Pending);
    }

    
    // regitering landInspector
    function Land_Inspector_Details( 
     address _id,
     string memory _name,
     int _age,
     string memory _designation
    )
    public { 
     landInspector_details[_id]=LandInspector_Details(_name,_age,_designation) ;
     land_inspector=_id;
    }


    // Registering Buyyer
    function Buyer_Details_(
     string memory _name,
     int _age,
     string memory _city,
     int _cnic,
     string memory _Email
    )
    public {
     buyer_details[msg.sender]=Buyer_Details(_name,_age ,_city ,_cnic, _Email , Status_buyer.Pending);
    }


    // updating  Buyyer  details
    function Update_Buyer_Details_(
     string memory _name,
     int _age,
     string memory _city,
     int _cnic,
     string memory _Email
    )
    public {
     buyer_details[msg.sender]=Buyer_Details(_name,_age ,_city ,_cnic, _Email , Status_buyer.Pending);
    }


    //approve seller
    function  approve_Seller(address _seller_id) only_landInspector public {
     require (_seller_id != msg.sender, "same id is used for seller and land inspector");
     Seller_Details[_seller_id].status_s=Status_seller.Approved;
    }


    //Approve Property
    function approve_Property(uint _Property_Id) only_landInspector public {
     Properties[_Property_Id].status_l= Status_land.Approved;
    }

    // Reject seller
    function  Reject_Seller(address _seller_id) only_landInspector public {
     require (_seller_id != msg.sender, "same id is used for seller and land inspector");
     Seller_Details[_seller_id].status_s=Status_seller.Rejected;
    }

    //Reject Property
    function Reject_Property(uint _Property_Id) only_landInspector public {
     Properties[_Property_Id].status_l= Status_land.Rejected;
    }

    //Approve buyer
    function  approve_Buyer(address _BuyerId) only_landInspector public {
     require (_BuyerId != msg.sender, "same id is used for buyyer and land inspector");
     buyer_details[_BuyerId].status_B=Status_buyer.Approved;
    }
    

    //Reject buyer
    function  Reject_Buyer(address _BuyerId) only_landInspector public {
     require (_BuyerId != msg.sender, "same id is used for buyyer and land inspector");
     buyer_details[_BuyerId].status_B=Status_buyer.Rejected;
    }

   
    //Payment
    function Payment(
     uint _Propertyid, 
     address payable _Receiver_address
    )
    payable only_verifiedbuyer public returns (string memory ) {  
     require (  Properties[_Propertyid].current_Owner!=msg.sender, "same id is used for buyyer and land inspector");
     require (  Properties[_Propertyid].status_l== Status_land.Approved, "land is not verified");
     require (  Properties[_Propertyid].landprice == msg.value, " your account balance is not equal to land price");
     require (  Properties[_Propertyid].current_Owner== _Receiver_address, "address entered doesnot matches the address to the land owner");
         
     _Receiver_address.transfer(msg.value);
     Properties[_Propertyid].current_Owner=msg.sender;
     return "congradulation land ownership has been tranfered to you";
    }


    //property ownership cheking 
    function Property_Owneship(uint _property_ID )public  view returns( address) {
     return Properties[_property_ID].current_Owner;
    }
    

    //Check verified sellers
    function Check_sellers(address _seller_ID) public view returns (bool){
    if( Seller_Details[_seller_ID].status_s==Status_seller.Approved)
     {
        return true;
     }
    else
     {
        return false;
     }     
    }


    // check verifie buyers
    function check_buyer (address _buyer_ID) public view returns ( bool){
     if(buyer_details[_buyer_ID].status_B==Status_buyer.Approved)
     {
        return true;
     }
    else
     {
        return false;    
     }
    }


    //tranfer of ownership
    function Transfer_of_ownership(address _New_Owner, uint _property_id) public {
     require (  Properties[_property_id].current_Owner==msg.sender, "you are not the property");
     require(Properties[_property_id].status_l== Status_land.Approved,"land is not approved");
     Properties[_property_id].current_Owner=_New_Owner;
    }
}
