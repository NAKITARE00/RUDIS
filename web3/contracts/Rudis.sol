// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Rudis {

    struct Researcher{
        string name;
        string email;
        address researcherAddress;
    }
    mapping (address => Researcher) public researchers;

    struct Research{
        string title;
        uint256 id;
        string description;
        address admin;
        uint256 funding;
        string organization;
        string researchURI;
        string profile;
    }  
    mapping (uint256 => Research) public researches;
    uint256 public researchCount;

    struct Collaboration{
        string title;
        uint256 id;
        address[] collaborators;
        string description;
        string uri;
        address admin;
        string profile;
    }
    mapping (uint256 => Collaboration) public collaborations;
    uint256 collaborationCount;

    struct PatentSale{
        uint256 id;
        uint256 patentId;
        string name;
        uint256 amount;
        address owner;
        string profile;
    }
    mapping (uint256 => PatentSale) public patentSales;
    uint256 public patentSaleCount;
    

    function register(string memory _name, string memory _email) public {
        researchers[msg.sender] = Researcher(_name, _email, msg.sender);
    }

    function createPatent
        (
        string memory _title, 
        string memory _description, 
        string memory _organization, 
        string memory _uri,
        address _admin,
        string memory _profile
        ) 
        public
    {
        uint256 id = researchCount + 1;
        Research storage newResearch = researches[id];
        newResearch.title = _title;
        newResearch.id = id;
        newResearch.description = _description;
        newResearch.admin = _admin;
        newResearch.organization = _organization;
        newResearch.researchURI = _uri;
        newResearch.profile = _profile;
        researchCount = id;
    }

    function createCollaboration(string memory _name, string memory _description, string memory _uri, string memory _profile) public{
        uint256 id = collaborationCount + 1;
        Collaboration storage collaboration = collaborations[id];
        collaboration.title = _name;
        collaboration.admin = msg.sender;
        collaboration.id = id;
        collaboration.description = _description;
        collaboration.uri = _uri;
        collaboration.profile = _profile;
        collaborationCount = id;
        collaboration.collaborators.push(msg.sender);
        createPatent(_name, _description, _name, _uri, collaboration.admin, collaboration.profile);
    }

    function joinCollaboration (uint256 _id) public{
        Collaboration storage collaboration = collaborations[_id];
        collaboration.collaborators.push(msg.sender);
    }

    function crowdFund (uint256 _id) public payable {
        require(msg.value > 0, "You must send some ether");
        require(researches[_id].id != 0, "Research does not exist");
        (bool sent, ) = payable(address(this)).call{value: msg.value}("");
        require(sent, "Failed to send ether");
        Research storage research = researches[_id];
        uint256 amount = research.funding + msg.value;
        research.funding = amount;
    }

    function contributeToResearch(uint256 _id, string memory _description) public{
        require(researches[_id].id != 0, "Research does not exist");
        require(researchers[msg.sender].researcherAddress != address(0), "Researcher does not exist");
        Research storage research = researches[_id];
        research.description = _description;
    } 

    function sellPatent(uint256 _id, uint256 _amount) public{
        uint256 id = patentSaleCount + 1;
        Research memory research = researches[_id];
        require(msg.sender == research.admin, "Not Authorized");
        PatentSale storage patentSale = patentSales[id];
        patentSale.id = id;
        patentSale.amount = _amount;
        patentSale.patentId = _id;
        patentSale.name = research.title;
        patentSale.profile = research.profile;
        patentSale.owner = msg.sender;
    }

    function buyPatent (uint256 _id, string memory _organization) public payable {
        PatentSale storage patentSale = patentSales[_id];
        (bool sent, ) = payable(patentSale.owner).call{value: msg.value}("");
        require(sent, "Purchase Failed");
        patentSale.owner = msg.sender;
        Research storage research = researches[patentSale.patentId];
        research.admin = msg.sender;
        research.organization = _organization;
    }

    function getResearch(uint256 _id) public view returns (Research memory){
        return researches[_id];
    }

    function getResearcher(address _address) public view returns (Researcher memory)
    {
        return researchers[_address];
    }

    function getResearch() public view returns (Research[] memory){
        Research[] memory researchList = new Research[](
            researchCount)
            ;
        for (uint i = 1; i <= researchCount; i++){
            Research storage item = researches[i];
            researchList[i-1] = item;
        }
        return researchList;
    }
    
    function getPatentsOnsale() public view returns (PatentSale[] memory){
        PatentSale[] memory patentSaleList = new PatentSale[](patentSaleCount);
        for (uint i = 1; i <= patentSaleCount; i++){
            PatentSale storage item = patentSales[i];
            patentSaleList[i-1] = item;
        }
        return patentSaleList;
    }

    function getCollaborations() public view returns(Collaboration[] memory) {
        Collaboration[] memory collaboration =  new Collaboration[](collaborationCount);
        for (uint i = 1; i <= collaborationCount; i++){
            Collaboration storage item = collaborations[i];
            collaboration[i-1] = item;
        }
        return collaboration;
    }
}