// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Advantages of a statically types language : they'll show where the error is occuring 
// ( Reason why TypeScipt became so popular)


contract   NeoFundr{
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image; // for url of images
        address[] donators;
        uint256[] donations;
    }

    // so now campaigns[0] sould represent a struct Campaign
    mapping(uint256 => Campaign) public campaigns;

    // number ofcampaigns
    uint256 public numberOfCampaigns = 0;


    // IMPLEMENTING ALL THE FUNCTIONALITY OF THE PROGRAM 
    /*
    there are four functions that contains the entire logic of the smarat contracts
    1)function createCampaign(){}
    2)fucntion donateToCampaign(){}
    3)fucntion getDonators() {}
    4)fucntion getCampaigns() {}

    */

    // public means this function can be called from the front end also
    // the underscore in front of the name is to indicate that, that paramter is for that function ONLY
    // returns the ID OF THAT SPECIFIC compaign
    // notice we needed memory keyword with all the string
    function createCampaign(address _owner, string memory _title, string memory _description, uint256 _target,
    uint256 _deadline, string memory _image) public returns (uint256) {
        // creating a new campaign 
        Campaign storage campaign = campaigns[numberOfCampaigns];

        // checking to see if the deadline provided is some date in the past ( if they type 2022 instead of 2023 )
        // NOTICE THE BLOCK KEYWORD
        require(campaign.deadline < block.timestamp, "The deadline should be a date in the future.");

        // populating the campaign with data
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        // Index of the MOST NEWLY created campaign
        return numberOfCampaigns - 1;
    }

    // _id of the campaign that  we want to donate the money to
    // payable is a keyword denoting that throughout the function we are trying to send cryptocurrencies
    // doesn't need return anything
    function donateToCampaign(uint256 _id) public payable {

        // msg.value represents the value we get FROM THE FRONT END
        uint256 amount = msg.value;

        //  campigns is the list of campaign and we are trying to get the campign that the user is trying to get
        Campaign storage campaign = campaigns[_id];

        // pushing the donator and amount to the FIELD OF THAT struct
        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        // making the TRANSACTION
        // payable might return MORE THAN ONE things so you need to have the (type obj1 , type obj2 ,) 
        // the comma at the end is for indicating that THERE COULD BE MORE OBJECTS but we need only first
        // if the payment happens it returns true 
        (bool sent,) = payable(campaign.owner).call{value: amount}("");

        if(sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }


    // again just like above function, we only need the id of tha campaign for viewing their donators
    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    // we need to return ALL THE COMPAIGNS
    function getCampaigns() public view returns (Campaign[] memory) {   
        // a new array of empty campaign structs ( var name is allCampaigns) 
        // is created as many numberOfCampaigns there are

        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint i = 0; i < numberOfCampaigns; i++) {
            // we are fetching that campaign from the storage and popualting it to our campaign
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}